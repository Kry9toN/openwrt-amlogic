#!/bin/bash

REPO_URL=https://github.com/openwrt/openwrt
REPO_BRANCH=openwrt-21.02
ROOT_DIR=$(pwd)
export FORCE_UNSAFE_CONFIGURE=1
TZ=Asia/Jakarta
function setup {
    export DEBIAN_FRONTEND=noninteractive
    rm -rf /etc/apt/sources.list.d/* /usr/share/dotnet /usr/local/lib/android /opt/ghc
    apt-get update
    apt-get upgrade -y
    apt-get -qq install curl wget -y
    apt-get -qq install $(curl -fsSL git.io/depends-ubuntu-1804) -y
    apt-get autoremove --purge
    apt-get clean
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
}

function clone {
    git clone --depth 1 $REPO_URL -b $REPO_BRANCH openwrt
}

function update_install {
    cd openwrt
    ./scripts/feeds update -a && ./scripts/feeds install -a
    cd $ROOT_DIR
    cp -f config/.config openwrt/.config
}

function download {
    cd openwrt
    make defconfig
    make download -j8
}

function compile {
    echo -e "$(nproc) thread compile"
    make -j$(nproc) || make -j1 || make -j1 V=s
    ls $ROOT_DIR/openwrt/bin/targets/*/*/
    if [ ! -f "$ROOT_DIR/openwrt/bin/targets/*/*/*.tar.gz" ]
    then
        echo "Build error"
        exit 1
    fi
}

function armvirt {
    cd $ROOT_DIR/openwrt/bin/targets/*/*
    rm -rf packages
    export TMPFILEPATH=$(pwd)
    cd $ROOT_DIR
}

function build {
    git clone --depth 1 https://github.com/ophub/amlogic-s9xxx-openwrt.git
    cd amlogic-s9xxx-openwrt/
    [ -d openwrt-armvirt ] || mkdir -p openwrt-armvirt
    cp -f ../openwrt/bin/targets/*/*/*.tar.gz openwrt-armvirt/ && sync
    rm -rf ../openwrt && sync
    chmod +x $ROOT_DIR/make.sh
    $ROOT_DIR/make.sh -d -b s905x -k 5.9.16
    cd out/ && gzip *.img
    cp -f ../openwrt-armvirt/*.tar.gz . && sync
    export FILEPATH=$(pwd)
}

function upload {
   chmod +x $ROOT_DIR/upload.sh
   $ROOR_DIR/upload.sh github_api_token=$token owner=kry9ton repo=openwrt-amlogic filename=$FILEPATH/*.img.gz
}
setup
clone
update_install
download
compile
armvirt
build
upload
