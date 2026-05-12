#!/usr/bin/env bash
# init-firewall.sh — lock down outbound traffic for the agent container.
#
# Runs as root at container start (dev.sh wires this up). Default-deny egress,
# then allowlist: DNS, localhost, the container's own subnet, GitHub, npm,
# Anthropic, plus anything in $FIREWALL_EXTRA_DOMAINS (space-separated, passed
# in by dev.sh from agent-workflow.config.sh).
#
# Add hosts your build needs to FIREWALL_EXTRA_DOMAINS — e.g. for Firebase:
#   FIREWALL_EXTRA_DOMAINS="firebase.googleapis.com firestore.googleapis.com \
#     identitytoolkit.googleapis.com www.gstatic.com storage.googleapis.com"
# for a Gradle/Maven project:
#   FIREWALL_EXTRA_DOMAINS="repo.maven.apache.org plugins.gradle.org services.gradle.org"
set -euo pipefail

ALLOWED_DOMAINS=(
  github.com api.github.com codeload.github.com
  objects.githubusercontent.com raw.githubusercontent.com uploads.github.com
  registry.npmjs.org
  api.anthropic.com statsig.anthropic.com sentry.io
)
# Append project extras
if [ -n "${FIREWALL_EXTRA_DOMAINS:-}" ]; then
  # shellcheck disable=SC2206
  ALLOWED_DOMAINS+=( ${FIREWALL_EXTRA_DOMAINS} )
fi

echo "init-firewall: allowlisting ${#ALLOWED_DOMAINS[@]} domains"

# Reset
iptables -F; iptables -X; iptables -t nat -F; iptables -t nat -X 2>/dev/null || true
ipset destroy allowed-cidrs 2>/dev/null || true
ipset create allowed-cidrs hash:net

# Always allow GitHub's published IP ranges (covers the dynamic *.github.com set)
if gh_meta=$(curl -fsS --max-time 10 https://api.github.com/meta 2>/dev/null); then
  echo "$gh_meta" | jq -r '(.git // []) + (.api // []) + (.web // []) + (.packages // [])[]?' 2>/dev/null \
    | while read -r cidr; do [ -n "$cidr" ] && ipset add allowed-cidrs "$cidr" 2>/dev/null || true; done
fi

# Resolve each allowed domain (DNS round-robin returns dups — swallow errors)
for d in "${ALLOWED_DOMAINS[@]}"; do
  for ip in $(dig +short A "$d" 2>/dev/null); do
    [[ "$ip" =~ ^[0-9.]+$ ]] && ipset add allowed-cidrs "$ip" 2>/dev/null || true
  done
done

# Base allowances
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT  -i lo -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT  -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow the container's own /24 (host networking / docker bridge)
host_net=$(ip -o -f inet addr show | awk '/scope global/ {print $4}' | head -n1)
[ -n "$host_net" ] && iptables -A OUTPUT -d "$host_net" -j ACCEPT

# Allow traffic to the allowlisted set
iptables -A OUTPUT -m set --match-set allowed-cidrs dst -j ACCEPT

# Default deny everything else outbound
iptables -A OUTPUT -j REJECT --reject-with icmp-port-unreachable

# Self-check: example.com should be blocked, GitHub API reachable
if curl -fsS --max-time 5 https://example.com >/dev/null 2>&1; then
  echo "init-firewall: WARNING — example.com is reachable, firewall may not be active" >&2
fi
curl -fsS --max-time 10 https://api.github.com/zen >/dev/null 2>&1 \
  && echo "init-firewall: ok (GitHub reachable, example.com blocked)" \
  || echo "init-firewall: WARNING — GitHub API not reachable" >&2
