# Build stage — context is the repo root (see docker-compose.yaml).
FROM dart:3.8.0 AS build
WORKDIR /app

COPY pubspec.docker.yaml pubspec.yaml
COPY wayfinder_client/pubspec.yaml wayfinder_client/pubspec.yaml
COPY wayfinder_client/lib wayfinder_client/lib
COPY wayfinder_client/dartdoc_options.yaml wayfinder_client/dartdoc_options.yaml
COPY wayfinder_server/pubspec.yaml wayfinder_server/pubspec.yaml
COPY wayfinder_server/bin wayfinder_server/bin
COPY wayfinder_server/lib wayfinder_server/lib
COPY wayfinder_server/config wayfinder_server/config
COPY wayfinder_server/migrations wayfinder_server/migrations
COPY wayfinder_server/web wayfinder_server/web
COPY wayfinder_server/analysis_options.yaml wayfinder_server/analysis_options.yaml

WORKDIR /app/wayfinder_server
RUN dart pub get
RUN dart compile exe bin/main.dart -o bin/server

# Final stage
FROM alpine:latest

ENV runmode=development
ENV serverid=default
ENV logging=normal
ENV role=monolith
ENV WAYFINDER_PMTILES_STORAGE=/data/pmtiles
ENV SERVERPOD_APPLY_MIGRATIONS=true
ENV SERVERPOD_DATABASE_HOST=postgres
ENV SERVERPOD_DATABASE_PORT=5432
ENV SERVERPOD_API_SERVER_PORT=18080
ENV SERVERPOD_INSIGHTS_SERVER_PORT=18081
ENV SERVERPOD_WEB_SERVER_PORT=18082
ENV SERVERPOD_API_SERVER_PUBLIC_HOST=localhost
ENV SERVERPOD_API_SERVER_PUBLIC_PORT=18080
ENV SERVERPOD_API_SERVER_PUBLIC_SCHEME=http
ENV SERVERPOD_WEB_SERVER_PUBLIC_HOST=localhost
ENV SERVERPOD_WEB_SERVER_PUBLIC_PORT=18082
ENV SERVERPOD_WEB_SERVER_PUBLIC_SCHEME=http

WORKDIR /app

COPY --from=build /runtime/ /
COPY --from=build /app/wayfinder_server/bin/server server
COPY --from=build /app/wayfinder_server/config/ config/
COPY --from=build /app/wayfinder_server/web/ web/
COPY --from=build /app/wayfinder_server/migrations/ migrations/
COPY --from=build /app/wayfinder_server/lib/src/generated/protocol.yaml lib/src/generated/protocol.yaml

EXPOSE 18080
EXPOSE 18081
EXPOSE 18082

VOLUME ["/data/pmtiles"]

ENTRYPOINT ["./server"]
CMD ["--mode=development", "--server-id=default", "--logging=normal", "--role=monolith", "--apply-migrations"]
