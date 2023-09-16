# sing-box

The universal proxy platform.

## Documentation

[https://sing-box.sagernet.org](https://sing-box.sagernet.org/)



## Tags & Feature

- **`latest`** *([main branch/stable release](https://github.com/SagerNet/sing-box/tree/main))*

  - Enabled feature:

  > `with_gvisor,with_quic,with_wireguard,with_utls,with_reality_server,with_ech`

- **`dev`** *([dev branch/beta release](https://github.com/SagerNet/sing-box/tree/dev))*

  - Enabled feature:

  > `with_gvisor,with_quic,with_wireguard,with_utls,with_reality_server,with_ech`

- **`git`** *([dev-next branch/latest commit](https://github.com/SagerNet/sing-box/tree/dev-next))*

  - Enabled feature:

  > `with_gvisor,with_quic,with_wireguard,with_utls,with_reality_server,with_ech`



## Supported architectures

- `i386`, `amd64`, `arm32v7`, `arm64v8`, `s390x`



## Volumes

| Variable                      | Description       |
| ----------------------------- | ----------------- |
| **/etc/sing-box/config.json** | Config file       |
| **/etc/sing-box/**            | Working directory |
| **/etc/sing-box/geoip/**       | geoip    |


## Examples of usage

### Docker Compose *(Recommended, [More details](https://docs.docker.com/compose/features-uses/))*

```yaml
version: '3'

services:
  sing-box:
    image: superng6/singbox
    restart: unless-stopped
    network_mode: "host"
    volumes:
      - $PWD/:/etc/sing-box/
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
```

### Docker CLI *([More details](https://docs.docker.com/engine/reference/commandline/cli/))*

```console
docker run -d \
  --network host \
  --restart unless-stopped \
  --volume $PWD/:/etc/sing-box/ \
  --cap-add NET_ADMIN \
  --device /dev/net/tun
  superng6/singbox
```



## License

```
Copyright (C) 2023 by nekohasekai <contact-sagernet@sekai.icu>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
```
