# Blinko HA Add-on (local)

This Home Assistant Supervisor add-on runs Blinko (blinkospace/blinko) and exposes its web UI via Home Assistant Ingress.

## Required
- A PostgreSQL database reachable from Home Assistant (Blinko requires Postgres).
- A strong `NEXTAUTH_SECRET` (set in the add-on options).
- Configure `DATABASE_URL` in the add-on options.

## Install
1. Place this folder under your Home Assistant add-ons directory (e.g. `/addons/blinko`).
2. Install the local add-on from Supervisor → Add-on Store → Repositories / Local.
3. Set options (`NEXTAUTH_SECRET`, `DATABASE_URL`, `TZ`, etc).
4. Start the add-on and open via the Add-on UI or the sidebar (Ingress).

## Notes
- This add-on uses Ingress. The add-on does **not** expose a host port; access is only via Home Assistant.
- If you want the add-on to host Postgres as well, you can use the community postgresql add-on and set `DATABASE_URL` accordingly.
