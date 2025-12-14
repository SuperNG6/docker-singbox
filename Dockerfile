FROM --platform=$BUILDPLATFORM golang:1.25 AS builder
ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /src

RUN apt update -qq && apt install -y -qq --no-install-recommends git build-essential

ARG VERSION=""
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=$TARGETARCH

RUN git clone --depth 1 --branch ${VERSION} https://github.com/sagernet/sing-box.git .

RUN LD_FLAGS="-s -w -buildid= -X 'github.com/sagernet/sing-box/constant.Version=${VERSION}'" && \
    cd cmd/sing-box && \
    go build -trimpath -tags "with_gvisor,with_quic,with_dhcp,with_wireguard,with_utls,with_acme,with_clash_api,with_tailscale" \
    -gcflags="all=-l=4" \
    -ldflags="$LD_FLAGS" \
    -o /src/sing-box


FROM gcr.io/distroless/static-debian12:latest

COPY --from=builder --chown=0:0 --chmod=755 /src/sing-box /usr/bin/sing-box

VOLUME /etc/sing-box

ENV TZ=Asia/Shanghai

ENTRYPOINT ["/usr/bin/sing-box"]
CMD ["run", "-D", "/etc/sing-box"]
