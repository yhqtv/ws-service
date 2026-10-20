#!/bin/sh
# Railway 容器启动入口：用环境变量渲染 xray 配置后启动
set -e

: "${UUID:?缺少环境变量 UUID}"
: "${WS_PATH:?缺少环境变量 WS_PATH}"
PORT="${PORT:-8080}"

mkdir -p /etc/xray
cat > /etc/xray/config.json <<EOF
{
  "log": { "loglevel": "warning", "access": "none" },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": ${PORT},
      "protocol": "vless",
      "settings": {
        "clients": [ { "id": "${UUID}" } ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": { "path": "${WS_PATH}" }
      },
      "sniffing": { "enabled": true, "destOverride": ["http", "tls", "quic"] }
    }
  ],
  "outbounds": [ { "protocol": "freedom", "tag": "direct" } ]
}
EOF

exec /usr/local/bin/xray run -config /etc/xray/config.json
