# Security

Wayfinder is designed for **self-hosted, trusted networks** (home lab, field
kit, Project N.O.M.A.D., etc.). Treat every deployment as operator-controlled
infrastructure, not a multi-tenant SaaS.

## Defaults

- The map UI has **no end-user login screen**. Access control is your
  responsibility (firewall, VPN, reverse proxy, network isolation).
- The REST API is **open** until you generate a key in **Settings → About →
  REST API access** or set `WAYFINDER_REST_API_KEY` on the server.
- Docker images do **not** include map tiles or geocoding database contents.

## Recommendations

1. **Enable REST API key auth** before the server is reachable from other
   devices on your LAN.
2. **Do not expose** ports `18080`, `18082`, `18182`, or the client UI port
   directly to the public internet without TLS, authentication, and rate limiting.
3. Keep **`.env`** and API keys out of git; rotate keys if leaked.
4. Run **all three images from the same release tag** when upgrading
   (`v1.0.1` server + client + geocoding server).

## Reporting vulnerabilities

Please report security issues privately:

- Open a [GitHub Security Advisory](https://github.com/kennethbrewer3/wayfinder/security/advisories/new)
  (preferred), or
- Email the repository owner via the contact on their GitHub profile.

Do not open public issues for undisclosed vulnerabilities.

We aim to acknowledge reports within a few days and will coordinate disclosure
once a fix is available.
