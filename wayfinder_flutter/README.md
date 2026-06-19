# wayfinder_flutter

Flutter client for Wayfinder.

## Local development

Make sure the server is running, then from this directory:

```bash
flutter run
```

For web:

```bash
flutter run -d chrome
```

Server URLs are read from `assets/config.json`.

## Docker web client

The Flutter web app can run in its own container with nginx, separate from the Serverpod backend.

From `wayfinder_server/`:

```bash
docker compose --profile client up -d --build client
```

Open `http://localhost:8080` (or the port set by `WAYFINDER_CLIENT_PORT` in `.env`).

Set `WAYFINDER_API_URL` and `WAYFINDER_WEB_URL` in `wayfinder_server/.env` to the server addresses reachable from the user's browser. The container writes these into `/config.json` at startup.

To run only the client container on another machine, copy the repo (or build and push the image), set the server URLs in `.env`, and start the `client` service.
