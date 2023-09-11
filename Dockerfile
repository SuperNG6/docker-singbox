FROM --platform=$BUILDPLATFORM golang:1.21.1-alpine3.18 as builder

WORKDIR /go/src

COPY ReleaseTag /go/src

RUN apk add --no-cache git

RUN export VERSION=$(cat ReleaseTag | grep -oP '(?<=release=)[^,]+')

RUN CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH \
    go install -v -tags with_wireguard,with_quic,with_ech,with_reality_server \
    -trimpath -ldflags "-s -w -buildid=" \ 
    github.com/sagernet/sing-box/cmd/sing-box@$VERSION

# install static sing-box
FROM scratch

# copy local files && sing-box
COPY --from=builder /go/bin/sing-box /usr/local/bin/sing-box

CMD [ "run", "-D", "/usr/local/bin/sing-box" ]
