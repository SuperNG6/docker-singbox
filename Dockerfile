FROM lsiobase/alpine:3.17-69ac1933-ls26 as builder


RUN apk add --no-cache curl \
    &&  bash -c "$(curl -L https://sing-box.vercel.app)" @ install --go

# install static sing-box
FROM scratch

# set label
LABEL maintainer="NG6"

# copy local files && sing-box
COPY --from=builder /usr/local/bin/sing-box /usr/local/bin/sing-box
COPY --from=builder /usr/local/share/sing-box/geoip.db /usr/local/share/sing-box/geoip.db
COPY --from=builder /usr/local/share/sing-box/geosite.db /usr/local/share/sing-box/geosite.db

CMD [ "run","-D","/usr/local/bin/sing-box"]
