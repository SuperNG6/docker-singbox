FROM --platform=$BUILDPLATFORM golang:1.24-alpine as builder

WORKDIR /go/src

RUN apk add --no-cache git wget ca-certificates

ARG VERSION=""

RUN CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH \
    go install -v -tags with_utls,with_wireguard,with_quic,with_ech,with_reality_server,with_gvisor,with_clash_api \
    -trimpath -ldflags "-s -w -buildid=" \ 
    github.com/sagernet/sing-box/cmd/sing-box@$VERSION

# install static sing-box
FROM scratch

# copy local files && sing-box
COPY --from=builder /go/bin/sing-box /usr/bin/sing-box
COPY --from=builder /etc/ssl /etc/ssl

CMD ["/usr/bin/sing-box", "run", "-D", "/etc/sing-box"]
