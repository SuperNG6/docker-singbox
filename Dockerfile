FROM --platform=$BUILDPLATFORM golang:1.24 AS builder
ARG TARGETARCH

# 设置工作目录
WORKDIR /app

RUN apt update && apt install -y --no-install-recommends git build-essential

ARG VERSION=""
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=$TARGETARCH

RUN git clone --depth 1 --branch ${VERSION} https://github.com/sagernet/sing-box.git .

RUN LD_FLAGS="-s -w -buildid= -X 'github.com/sagernet/sing-box/constant.Version=${VERSION}'" && \
    cd cmd/sing-box && \
    go build -v -trimpath -tags "with_gvisor,with_quic,with_dhcp,with_wireguard,with_utls,with_acme,with_clash_api,with_tailscale" \
    -ldflags="$LD_FLAGS" \
    -o /app/sing-box


FROM gcr.io/distroless/static-debian12:latest

COPY --from=builder /app/sing-box /usr/bin/sing-box

ENV TZ=Etc/UTC

ENTRYPOINT ["/usr/bin/sing-box"]
CMD ["run", "-D", "/etc/sing-box"]