FROM alpine:3.21 AS builder
ARG PB_VERSION=0.25.0
RUN apk add --no-cache unzip ca-certificates wget && \
    wget -q "https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip" -O /tmp/pb.zip && \
    unzip /tmp/pb.zip -d /pb && rm /tmp/pb.zip

FROM alpine:3.21
RUN apk add --no-cache ca-certificates wget && \
    addgroup -S pbgroup && adduser -S pbuser -G pbgroup
COPY --from=builder /pb/pocketbase /pb/pocketbase
COPY pb_hooks/ /pb/pb_hooks/
RUN chown -R pbuser:pbgroup /pb
USER pbuser
EXPOSE 8090
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:8090/api/health || exit 1
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8090"]
