#!/bin/bash

REPO_URL=https://github.com/openwrt/openwrt
REPO_BRANCH=openwrt-21.02
ROOT_DIR=$(pwd)

function setup {
    export DEBIAN_FRONTEND=noninteractive
    rm -rf /etc/apt/sources.list.d/* /usr/share/dotnet /usr/local/lib/android /opt/ghc
    apt-get update
    apt-get upgrade -y
    apt-get install curl wget -y
    apt-get install $(curl -fsSL git.io/depends-ubuntu-1804) -y
    apt-get autoremove --purge
    apt-get clean
    timedatectl set-timezone "Asia/Jakarta"
}

function clone {
    git clone --depth 1 $REPO_URL -b $REPO_BRANCH openwrt
}

function update_install {
    cd openwrt && ./scripts/feeds update -a
    cd openwrt && ./scripts/feeds install -a
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
    export FILE_DATE=$(date +"%Y.%m.%d.%H%M")
    if [! -f "../openwrt/bin/targets/*/*/*.tar.gz"]
    then
        echo "Build error"
        exit 1
    fi
}

function armvirt {
    cd openwrt/bin/targets/*/*
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
    chmod +x make.sh
    $ROOT_DIR/make.sh -d -b s905x -k 5.9.16
    cd out/ && gzip *.img
    cp -f ../openwrt-armvirt/*.tar.gz . && sync
    export FILEPATH=$(pwd)
}

setup
clone
update_install
download
compile
armvirt
build
