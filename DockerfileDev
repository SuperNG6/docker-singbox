FROM --platform=$BUILDPLATFORM golang:1.21.1-alpine3.18 as builder

WORKDIR /go/src

RUN apk add --no-cache git wget

ARG VERSION=""

RUN CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH \
    go install -v -tags with_wireguard,with_quic,with_ech,with_reality_server \
    -trimpath -ldflags "-s -w -buildid=" \ 
    github.com/sagernet/sing-box/cmd/sing-box@$VERSION

RUN wget "https://github.com/soffchen/sing-geoip/releases/latest/download/geoip.db"
RUN wget "https://github.com/soffchen/sing-geosite/releases/latest/download/geosite.db"

# install static sing-box
FROM scratch

# copy local files && sing-box
COPY --from=builder /go/src/geoip.db /etc/sing-box/geoip/geoip.db
COPY --from=builder /go/src/geosite.db /etc/sing-box/geoip/geosite.db

CMD [ "/usr/bin/sing-box", "-c", "/etc/sing-box/config.json" ]