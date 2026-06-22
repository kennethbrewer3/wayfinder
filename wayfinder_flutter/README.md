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

End users can install the web client **without cloning the repo** — see [deploy/client/](../deploy/client/) and [DEPLOY.md](../DEPLOY.md).

Developers with a repo clone can build locally from this directory:

```bash
cp .env.example .env
docker compose up -d --build
```
