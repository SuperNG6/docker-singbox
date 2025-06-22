# sing-box Docker Image

[![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/SuperNG6/docker-singbox/Auto%20Build%20Image.yml?branch=main&logo=github&label=Auto%20Build)](https://github.com/SuperNG6/docker-singbox/actions/workflows/Auto%20Build%20Image.yml)
[![Docker Pulls](https://img.shields.io/docker/pulls/superng6/singbox?logo=docker&label=Docker%20Hub%20Pulls)](https://hub.docker.com/r/superng6/singbox)
[![GitHub Stars](https://img.shields.io/github/stars/SuperNG6/docker-singbox?logo=github&label=Stars)](https://github.com/SuperNG6/docker-singbox)

这是一个基于 [SagerNet/sing-box](https://github.com/SagerNet/sing-box) 官方 Release 自动构建的多平台 Docker 镜像。

官方文档: [https://sing-box.sagernet.org](https://sing-box.sagernet.org/)

---

## 镜像仓库地址

镜像同时推送到 Docker Hub 和 GitHub Container Registry (GHCR)。

- **Docker Hub:**
  ```console
  docker pull superng6/singbox
  ```
- **GHCR.io:**
  ```console
  docker pull ghcr.io/superng6/singbox
  ```

---

## 标签 (Tags) 与功能

本仓库根据上游的官方 Release 自动构建并维护两个主要标签：

-   **`latest`** & `version tag` (e.g., `v1.10.0`)
    -   追踪 [SagerNet/sing-box 的最新稳定版 (Stable Release)](https://github.com/SagerNet/sing-box/releases)。
    -   这是推荐在生产环境中使用的版本。

-   **`dev`** & `version tag` (e.g., `v1.12.0-rc.1`)
    -   追踪 [SagerNet/sing-box 的最新预发布版 (Pre-release)](https://github.com/SagerNet/sing-box/releases)。
    -   包含最新功能，但可能不稳定，适合尝鲜和测试。

#### ✅ 编译时包含的功能 (Build Features):

```
with_gvisor, with_quic, with_dhcp, with_wireguard, with_utls, with_acme, with_clash_api, with_tailscale
```

---

## 支持的架构

通过 GitHub Actions 自动构建，支持以下所有架构：

- `linux/amd64`
- `linux/arm64` (or `linux/arm64/v8`)
- `linux/arm/v7`
- `linux/ppc64le`
- `linux/s390x`

---

## 配置文件和数据卷

-   **`/etc/sing-box/config.json `**: 核心配置文件路径。
-   **`/etc/sing-box/`**: 工作目录。你可以将 GeoIP/GeoSite 等数据文件放在此处，并在 `config.json` 中引用。

---

## 使用示例

以下示例展示了如何在 `TUN` 模式下运行 sing-box

### Docker Compose (推荐)

**使用 Docker Hub 镜像:**
```yaml
# docker-compose.yml
services:
  sing-box:
    image: superng6/singbox:latest
    container_name: sing-box
    restart: unless-stopped
    network_mode: "host"
    volumes:
      # 将当前目录下的 config.json 挂载到容器中
      - ./config.json:/etc/sing-box/config.json 
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
```

**使用 GHCR.io 镜像:**
```yaml
# docker-compose.yml
services:
  sing-box:
    image: ghcr.io/superng6/singbox:latest
    container_name: sing-box
    restart: unless-stopped
    network_mode: "host"
    volumes:
      - ./config.json:/etc/sing-box/config.json 
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun
```

### Docker CLI

**使用 Docker Hub 镜像:**
```console
docker run -d \
  --name sing-box \
  --network host \
  --restart unless-stopped \
  -v $PWD/config.json:/etc/sing-box/config.json \
  --cap-add NET_ADMIN \
  --device /dev/net/tun \
  superng6/singbox:latest
```

**使用 GHCR.io 镜像:**
```console
docker run -d \
  --name sing-box \
  --network host \
  --restart unless-stopped \
  -v $PWD/config.json:/etc/sing-box/config.json \
  --cap-add NET_ADMIN \
  --device /dev/net/tun \
  ghcr.io/superng6/singbox:latest
```

---

## 自动化构建

本项目的所有镜像均通过 [GitHub Actions](https://github.com/SuperNG6/docker-singbox/actions) 自动构建，确保镜像的纯净与及时更新。

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
