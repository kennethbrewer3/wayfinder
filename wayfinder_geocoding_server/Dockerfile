# Build stage — context is the repo root (see docker-compose.yaml).
FROM dart:3.8.0 AS build
WORKDIR /app

COPY pubspec.docker.geocoding.yaml pubspec.yaml
COPY wayfinder_geocoding_client/pubspec.yaml wayfinder_geocoding_client/pubspec.yaml
COPY wayfinder_geocoding_client/lib wayfinder_geocoding_client/lib
COPY wayfinder_geocoding_server/pubspec.yaml wayfinder_geocoding_server/pubspec.yaml
COPY wayfinder_geocoding_server/bin wayfinder_geocoding_server/bin
COPY wayfinder_geocoding_server/lib wayfinder_geocoding_server/lib
COPY wayfinder_geocoding_server/lib/src/geocoding/data wayfinder_geocoding_server/lib/src/geocoding/data
COPY wayfinder_geocoding_server/config wayfinder_geocoding_server/config
COPY wayfinder_geocoding_server/migrations wayfinder_geocoding_server/migrations
COPY wayfinder_geocoding_server/web wayfinder_geocoding_server/web
COPY wayfinder_geocoding_server/analysis_options.yaml wayfinder_geocoding_server/analysis_options.yaml

WORKDIR /app/wayfinder_geocoding_server
RUN dart pub get
RUN dart compile exe bin/main.dart -o bin/server

FROM alpine:latest

RUN apk add --no-cache ca-certificates

ENV runmode=development
ENV serverid=default
ENV logging=normal
ENV role=monolith
ENV SERVERPOD_APPLY_MIGRATIONS=true
ENV SERVERPOD_DATABASE_HOST=postgres
ENV SERVERPOD_DATABASE_PORT=5432
ENV SERVERPOD_API_SERVER_PORT=18180
ENV SERVERPOD_INSIGHTS_SERVER_PORT=18181
ENV SERVERPOD_WEB_SERVER_PORT=18182
ENV SERVERPOD_API_SERVER_PUBLIC_HOST=localhost
ENV SERVERPOD_API_SERVER_PUBLIC_PORT=18180
ENV SERVERPOD_API_SERVER_PUBLIC_SCHEME=http
ENV SERVERPOD_WEB_SERVER_PUBLIC_HOST=localhost
ENV SERVERPOD_WEB_SERVER_PUBLIC_PORT=18182
ENV SERVERPOD_WEB_SERVER_PUBLIC_SCHEME=http

WORKDIR /app

COPY --from=build /runtime/ /
COPY --from=build /app/wayfinder_geocoding_server/bin/server server
COPY --from=build /app/wayfinder_geocoding_server/config/ config/
COPY --from=build /app/wayfinder_geocoding_server/web/ web/
COPY --from=build /app/wayfinder_geocoding_server/migrations/ migrations/
COPY --from=build /app/wayfinder_geocoding_server/lib/src/geocoding/data/ lib/src/geocoding/data/
COPY --from=build /app/wayfinder_geocoding_server/lib/src/generated/protocol.yaml lib/src/generated/protocol.yaml

EXPOSE 18180
EXPOSE 18181
EXPOSE 18182

ENTRYPOINT ["./server"]
CMD ["--mode=development", "--server-id=default", "--logging=normal", "--role=monolith", "--apply-migrations"]
