#!/bin/bash

# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root::0:0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' package/base-files/files/etc/shadow

# Add branches package
svn co https://github.com/Lienol/openwrt/branches/21.02/package/{lean,default-settings} package
sed -i 's/TARGET_rockchip/TARGET_rockchip\|\|TARGET_armvirt/g' package/lean/autocore/Makefile
svn co https://github.com/xiaorouji/openwrt-passwall/trunk package/openwrt-passwall
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash package/luci-app-openclash
pushd package/luci-app-openclash/tools/po2lmo && make && sudo make install && popd
svn co https://github.com/fw876/helloworld/trunk/luci-app-ssr-plus package/lean/luci-app-ssr-plus
svn co https://github.com/coolsnowwolf/lede/trunk/package/lean/{luci-app-rclone,rclone,rclone-ng,rclone-webui-react} package/lean
svn co https://github.com/lisaac/luci-app-diskman/trunk/applications/luci-app-diskman package/lean/luci-app-diskman
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -q -P package/lean/parted
pushd package/lean/parted && mv -f Parted.Makefile Makefile && popd
