# sing-box Docker Image

[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/SuperNG6/docker-singbox/Auto%20Build%20Image.yml?branch=main\&logo=github\&label=Auto%20Build)](https://github.com/SuperNG6/docker-singbox/actions/workflows/Auto%20Build%20Image.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/superng6/singbox?logo=docker\&label=Docker%20Hub%20Pulls)](https://hub.docker.com/r/superng6/singbox)
[![GitHub Stars](https://img.shields.io/github/stars/SuperNG6/docker-singbox?logo=github\&label=Stars)](https://github.com/SuperNG6/docker-singbox)

一个基于 [SagerNet/sing-box](https://github.com/SagerNet/sing-box) 官方源码自动构建的多平台 Docker 镜像。

官方文档: [https://sing-box.sagernet.org](https://sing-box.sagernet.org/)

---

## 镜像仓库地址

镜像同时推送到 Docker Hub 和 GitHub Container Registry (GHCR)。

* **Docker Hub:**

  ```console
  docker pull superng6/singbox
  ```
* **GHCR.io:**

  ```console
  docker pull ghcr.io/superng6/singbox
  ```

---

## 标签 (Tags) 与功能

本仓库根据上游官方 Release 自动构建并维护两个主要标签：

* **`latest`** & `version tag` (如 `v1.10.0`)
  稳定版 [SagerNet/sing-box 的最新稳定版 (Stable Release)](https://github.com/SagerNet/sing-box/releases)，推荐生产环境使用。

* **`dev`** & `version tag` (如 `v1.12.0-rc.1`)
  开发版 (Pre-release)，包含最新功能，适合测试和尝鲜。

### 编译时包含的功能 (Build Features):

```
with_gvisor, with_quic, with_dhcp, with_wireguard, with_utls, with_acme, with_clash_api, with_tailscale
```

---

## 支持的架构

通过 GitHub Actions 自动构建，支持以下架构：

* `linux/amd64`
* `linux/arm64` (arm64/v8)
* `linux/arm/v7`
* `linux/ppc64le`
* `linux/s390x`

---

## Dockerfile 设计说明

* 使用多阶段构建，第一阶段基于 `golang:1.24`（Debian12） 进行编译，支持多种cpu架构。
* 运行阶段基于 `gcr.io/distroless/static-debian12:latest`，安全无 Shell。

---

## 配置文件和数据卷

* `/etc/sing-box/config.json` 配置文件位置。
* 你可以将 GeoIP、GeoSite 等数据文件放入 `/etc/sing-box/`，并在配置中引用。
* 挂载覆盖 `/etc/sing-box` 目录，实现灵活配置管理。

---

## 使用示例

以下示例展示如何在支持 TUN 设备的模式下运行 sing-box。

### Docker Compose (推荐)

**Docker Hub 镜像示例：**

```yaml
services:
  sing-box:
    image: superng6/singbox:latest
    container_name: sing-box
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./config.json:/etc/sing-box/config.json
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
```

**GHCR 镜像示例：**

```yaml
services:
  sing-box:
    image: ghcr.io/superng6/singbox:latest
    container_name: sing-box
    restart: unless-stopped
    network_mode: host
    volumes:
      - ./config.json:/etc/sing-box/config.json
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
```

### Docker CLI

**Docker Hub：**

```bash
docker run -d \
  --name sing-box \
  --network host \
  --restart unless-stopped \
  -v ./config.json:/etc/sing-box/config.json \
  --cap-add NET_ADMIN \
  --device /dev/net/tun \
  superng6/singbox:latest
```

**GHCR：**

```bash
docker run -d \
  --name sing-box \
  --network host \
  --restart unless-stopped \
  -v ./config.json:/etc/sing-box/config.json \
  --cap-add NET_ADMIN \
  --device /dev/net/tun \
  ghcr.io/superng6/singbox:latest
```


---

## 自动化构建

所有镜像通过 GitHub Actions 自动构建，保证镜像纯净且及时更新。
构建状态查看：[GitHub Actions](https://github.com/SuperNG6/docker-singbox/actions)

---

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

---

