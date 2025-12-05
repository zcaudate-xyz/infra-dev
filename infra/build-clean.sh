#!/bin/bash
set -e

# Turn infra clean into a build script for jules
# Based on infra/Dockerfile_foundation_clean

echo "Starting build-clean.sh..."

# Ensure the script is run with sudo if not root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo"
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

# Prerequisites
echo "Installing Prerequisites..."
apt-get update
apt-get install -y \
       build-essential software-properties-common apt-transport-https lsb-release ca-certificates net-tools \
       sudo \
       libreadline-dev zlib1g-dev libssl-dev libpcre3 libpcre3-dev \
       libhiredis-dev libsqlite3-dev libjemalloc-dev gettext-base \
       git gpg gnupg2 make cmake wget curl lsof unzip jq gcc tcc bc \
       x11vnc xvfb entr \
       openjdk-21-jdk openjfx default-jdk \
       python3 python3-pip python3-redis r-base

# Node
echo "Installing Node..."
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get update && apt-get install -y nodejs

# Docker
echo "Installing Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update && apt-get install -y docker.io docker-compose docker-buildx-plugin

# CONDA
echo "Installing Conda..."
if [ ! -d "/opt/conda" ]; then
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
            bash /tmp/miniconda.sh -b -p /opt/conda
            ;;
        aarch64)
            wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh -O /tmp/miniconda.sh && \
            bash /tmp/miniconda.sh -b -p /opt/conda
            ;;
        *)
            echo "Unsupported architecture for Conda: $ARCH"
            exit 1
            ;;
    esac
fi
export PATH=/opt/conda/bin:$PATH

# R
echo "Installing R packages..."
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        R -e "install.packages('jsonlite',repos='https://cloud.r-project.org/')"
        if [ ! -f /usr/bin/r ]; then ln -s /usr/bin/R /usr/bin/r; fi
        ;;
    aarch64)
        ;;
    *)
        echo "Unsupported architecture for R: $ARCH"
        exit 1
        ;;
esac

# Leiningen
echo "Installing Leiningen..."
wget https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein -O /usr/bin/lein && chmod +x /usr/bin/lein

# Rust
echo "Installing Rust..."
curl https://sh.rustup.rs -sSf | bash -s -- -y
# Assuming default install location for root is /root/.cargo
if [ -f "$HOME/.cargo/bin/rustc" ]; then
    ln -sf "$HOME/.cargo/bin/rustc" /usr/bin/rustc
elif [ -f "/root/.cargo/bin/rustc" ]; then
    ln -sf "/root/.cargo/bin/rustc" /usr/bin/rustc
fi

# Minio
echo "Installing Minio..."
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        MINIO_URL="https://dl.min.io/server/minio/release/linux-amd64/minio"
        ;;
    aarch64)
        MINIO_URL="https://dl.min.io/server/minio/release/linux-arm64/minio"
        ;;
    *)
        echo "Unsupported architecture for Minio: $ARCH"
        exit 1
        ;;
esac
curl -o /usr/bin/minio $MINIO_URL && chmod +x /usr/bin/minio

# Java
export JAVA_HOME=/usr/lib/jvm/default-java

# Vnc
echo "Configuring VNC..."
mkdir -p /root/.vnc
x11vnc -storepasswd 1234 /root/.vnc/passwd

# Node MODULES
echo "Installing Node Modules..."
export NODE_PATH=/usr/lib/node_modules
npm -g install ganache http-server pnpm yarn
npm -g install \
    @react-native-async-storage/async-storage \
    blessed@0.1.81 \
    blessed-contrib@4.10.1 \
    bresenham@0.0.4 \
    chalk@4.1.2 \
    crypto-js \
    dateformat@5.0.2 \
    drawille \
    eventsource@1.1.0 \
    fastify \
    gl-matrix \
    javascript-time-ago@2.3.10 \
    osc-js \
    node-fetch@2.6.6 \
    node-localstorage@2.2.1 \
    pg \
    react-blessed-contrib \
    react-blessed@0.7.2 \
    react@17.0.2 \
    redis \
    sql.js \
    tiny-worker \
    ua-parser-js \
    valtio \
    uuid@8.3.2 \
    window \
    ws
npm -g install bip32 bip39 bip84 bitcoinjs-lib@5.2.0 bitcoinjs-message@2.2.0 ecpair safe-buffer tiny-secp256k1 wif
npm -g install ethers@5.7.2 solc@0.8.17

# Quickjs
echo "Installing QuickJS..."
QUICKJS_VERSION=2024-01-13
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        wget https://bellard.org/quickjs/binary_releases/quickjs-linux-x86_64-${QUICKJS_VERSION}.zip -O /tmp/quickjs.zip
        unzip -o /tmp/quickjs.zip -d /tmp
        mv /tmp/qjs /usr/local/bin
        ;;
    aarch64)
        wget https://bellard.org/quickjs/binary_releases/quickjs-cosmo-${QUICKJS_VERSION}.zip -O /tmp/quickjs.zip
        unzip -o /tmp/quickjs.zip -d /tmp
        mv /tmp/qjs /usr/local/bin
        ;;
    *)
        echo "QuickJS not installed: $ARCH"
        ;;
esac

# Python
echo "Installing Python packages..."
export PIP_BREAK_SYSTEM_PACKAGES=1
ln -sf /usr/bin/python3 /usr/bin/python
pip3 install websocket redis

# Openresty/Nginx
echo "Installing OpenResty/Nginx..."
OPENRESTY_VERSION=1.27.1.1
LUAROCKS_VERSION=3.12.2
NCHAN_VERSION=1.3.7

BUILD_DIR=$(mktemp -d)
pushd $BUILD_DIR

wget https://openresty.org/download/openresty-${OPENRESTY_VERSION}.tar.gz && tar -xf openresty-${OPENRESTY_VERSION}.tar.gz
wget https://github.com/slact/nchan/archive/refs/tags/v${NCHAN_VERSION}.tar.gz && tar -xf v${NCHAN_VERSION}.tar.gz
wget https://luarocks.github.io/luarocks/releases/luarocks-${LUAROCKS_VERSION}.tar.gz && tar -xf luarocks-${LUAROCKS_VERSION}.tar.gz

cd openresty-${OPENRESTY_VERSION} && ./configure --add-module=../nchan-${NCHAN_VERSION} --with-pcre-jit \
        --with-ipv6 --prefix=/opt/openresty \
        && make && make install

cd ../luarocks-${LUAROCKS_VERSION} && ./configure --prefix=/opt/openresty/luajit --with-lua=/opt/openresty/luajit \
        --lua-suffix=jit --with-lua-include=/opt/openresty/luajit/include/luajit-2.1 \
        && make && make install

popd
export PATH=/opt/openresty/bin:/opt/openresty/luajit/bin:/opt/openresty/nginx/sbin:$PATH

# Luarocks
echo "Installing LuaRocks packages..."
/opt/openresty/luajit/bin/luarocks install luasocket
/opt/openresty/luajit/bin/luarocks install lustache
/opt/openresty/luajit/bin/luarocks install lua-cjson
/opt/openresty/luajit/bin/luarocks install lua-crypt
/opt/openresty/luajit/bin/luarocks install lua-resty-openssl
/opt/openresty/luajit/bin/luarocks install lua-resty-http
/opt/openresty/luajit/bin/luarocks install lua-resty-uuid
/opt/openresty/luajit/bin/luarocks install lua-resty-mail

pushd /tmp
curl -O https://luarocks.org/manifests/dougcurrie/lsqlite3-0.9.6-1.rockspec && /opt/openresty/luajit/bin/luarocks install lsqlite3-0.9.6-1.rockspec
popd

/opt/openresty/luajit/bin/luarocks install multipart
/opt/openresty/luajit/bin/luarocks install pgmoon
/opt/openresty/luajit/bin/luarocks install luaposix

# Redis
echo "Installing Redis..."
REDIS_VERSION=6.2.1
LUAJIT_VERSION=2.1.2

BUILD_DIR=$(mktemp -d)
pushd $BUILD_DIR

wget https://github.com/zcaudate/redis-luajit/archive/refs/tags/v${REDIS_VERSION}-luajit.tar.gz && tar -xf v${REDIS_VERSION}-luajit.tar.gz
wget https://github.com/zcaudate/LuaJIT/archive/refs/tags/${LUAJIT_VERSION}-redis.tar.gz && tar -xf ${LUAJIT_VERSION}-redis.tar.gz
rm -R redis-luajit-${REDIS_VERSION}-luajit/deps/LuaJIT
mv LuaJIT-${LUAJIT_VERSION}-redis redis-luajit-${REDIS_VERSION}-luajit/deps/LuaJIT

cd redis-luajit-${REDIS_VERSION}-luajit && make && make PREFIX=/opt/redis install
cd deps/LuaJIT && make install
mv /usr/local/bin/luajit-2.1.0-beta3 /usr/local/bin/luajit

popd
export PATH=/opt/redis/bin:$PATH

# Postgres
echo "Installing Postgres and Wrapper..."
REDIS_WRAPPER_VERSION=0.1.0
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/postgresql.gpg
apt-get update && apt-get install -y postgresql-plpython3-15 postgresql-server-dev-15 libhiredis-dev

BUILD_DIR=$(mktemp -d)
pushd $BUILD_DIR
wget https://github.com/zcaudate-xyz/redis_wrapper/archive/refs/tags/${REDIS_WRAPPER_VERSION}.tar.gz && tar -xf ${REDIS_WRAPPER_VERSION}.tar.gz
cd redis_wrapper-${REDIS_WRAPPER_VERSION} && make && make install
popd

# Postgres Password
PG_HBA_FILE="/etc/postgresql/15/main/pg_hba.conf"
if [ -f "$PG_HBA_FILE" ]; then
    sed -i 's/local\s\+all\s\+postgres\s\+peer/local   all             postgres                                trust/' "$PG_HBA_FILE"
else
    echo "Warning: $PG_HBA_FILE not found. Skipping Postgres auth configuration."
fi

# Torch
echo "Installing Torch..."
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        if [ ! -d "/opt/torch" ]; then
            git clone https://github.com/torch/distro.git /opt/torch --recursive
            cd /opt/torch
            ./install.sh

            /opt/torch/install/bin/luarocks install luasocket
            /opt/torch/install/bin/luarocks install lustache
            /opt/torch/install/bin/luarocks install lua-crypt
            /opt/torch/install/bin/luarocks install lua-cjson
            /opt/torch/install/bin/luarocks install lua-resty-openssl
            /opt/torch/install/bin/luarocks install lua-resty-http
            /opt/torch/install/bin/luarocks install lua-resty-uuid
            /opt/torch/install/bin/luarocks install lua-resty-mail

            pushd /tmp
            curl -O https://luarocks.org/manifests/dougcurrie/lsqlite3-0.9.6-1.rockspec && /opt/torch/install/bin/luarocks install lsqlite3-0.9.6-1.rockspec
            popd

            /opt/torch/install/bin/luarocks install multipart
            /opt/torch/install/bin/luarocks install pgmoon
            /opt/torch/install/bin/luarocks install luaposix
        else
             echo "Torch already installed at /opt/torch"
        fi
        ;;
    *)
        echo "Torch not installed: $ARCH"
        ;;
esac
export PATH=$PATH:/opt/torch/install/bin/

# Mesa
echo "Installing Mesa..."
add-apt-repository -y ppa:kisak/kisak-mesa && apt-get update && apt-get -y upgrade

# Chromium
echo "Installing Chromium Driver..."
add-apt-repository -y ppa:xtradeb/apps && apt-get update && apt-get install -y chromium-driver

# Clojure
echo "Installing Clojure deps..."
pushd /tmp
wget https://raw.githubusercontent.com/zcaudate-xyz/foundation-base/master/project.clj && lein deps && rm project.clj
popd

# Persist environment variables
echo "Persisting environment variables..."
cat <<EOF > /etc/profile.d/z_jules_infra.sh
export CONDA_DIR=/opt/conda
export PATH=/opt/conda/bin:\$PATH
export JAVA_HOME=/usr/lib/jvm/default-java
export NODE_PATH=/usr/lib/node_modules
export QUICKJS_VERSION=2024-01-13
export PIP_BREAK_SYSTEM_PACKAGES=1
export OPENRESTY_VERSION=1.27.1.1
export LUAROCKS_VERSION=3.12.2
export NCHAN_VERSION=1.3.7
export PATH=/opt/openresty/bin:/opt/openresty/luajit/bin:/opt/openresty/nginx/sbin:\$PATH
export REDIS_VERSION=6.2.1
export LUAJIT_VERSION=2.1.2
export PATH=/opt/redis/bin:\$PATH
export REDIS_WRAPPER_VERSION=0.1.0
export PG_HBA_FILE="/etc/postgresql/15/main/pg_hba.conf"
export PATH=\$PATH:/opt/torch/install/bin/
EOF

echo "Build complete. Environment variables saved to /etc/profile.d/z_jules_infra.sh"
