FROM --platform=$BUILDPLATFORM mirror.gcr.io/library/golang:1.25 AS builder

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETARCH
ARG TARGETVARIANT
ARG VERSION

WORKDIR /src

RUN apt update -qq && apt install -y -qq --no-install-recommends git build-essential

RUN git clone --depth 1 --branch ${VERSION} https://github.com/sagernet/sing-box.git .

ENV CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=$TARGETARCH

# 根据 TARGETVARIANT 自动判断并设置 GOAMD64
# 1. 如果是 amd64 且 variant=v3 -> GOAMD64=v3
# 2. 如果是 amd64 且 variant=v2 -> GOAMD64=v2
# 3. 其他情况 (包括 v1 或 arm64) -> 不设置 GOAMD64，使用默认值
RUN if [ "$TARGETARCH" = "amd64" ] && [ "$TARGETVARIANT" = "v3" ]; then \
        export GOAMD64=v3; \
    elif [ "$TARGETARCH" = "amd64" ] && [ "$TARGETVARIANT" = "v2" ]; then \
        export GOAMD64=v2; \
    fi && \
    go build -v -trimpath \
    -tags "with_gvisor,with_quic,with_dhcp,with_wireguard,with_utls,with_acme,with_clash_api,with_tailscale,with_ccm,with_ocm,badlinkname,tfogo_checklinkname0" \
    -ldflags "-X 'github.com/sagernet/sing-box/constant.Version=$VERSION' \
              -X 'internal/godebug.defaultGODEBUG=multipathtcp=0' \
              -s -w -buildid= -checklinkname=0" \
    -o /src/sing-box \
    ./cmd/sing-box

FROM gcr.io/distroless/static-debian12:latest

COPY --from=builder --chown=0:0 --chmod=755 /src/sing-box /usr/bin/sing-box

VOLUME /etc/sing-box
ENV TZ=Asia/Shanghai

ENTRYPOINT ["/usr/bin/sing-box"]
CMD ["run", "-D", "/etc/sing-box"]