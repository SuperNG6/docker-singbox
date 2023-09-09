FROM debian as builder

RUN apt update && apt -y install curl \
    &&  bash -c "$(curl -L https://sing-box.vercel.app)" @ install --go

# install static sing-box
FROM scratch

# copy local files && sing-box
COPY --from=builder /usr/local/bin/sing-box /usr/local/bin/sing-box
COPY --from=builder /usr/local/share/sing-box/geoip.db /usr/local/share/sing-box/geoip.db
COPY --from=builder /usr/local/share/sing-box/geosite.db /usr/local/share/sing-box/geosite.db

CMD [ "run","-D","/usr/local/bin/sing-box"]
