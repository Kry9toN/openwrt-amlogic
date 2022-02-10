#!/bin/bash

# System
# Add the default password for the 'root' user（Change the empty password to 'password'）
sed -i 's/root::0:0:99999:7:::/root:$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.:0:0:99999:7:::/g' package/base-files/files/etc/shadow

# Modify default theme（FROM uci-theme-bootstrap CHANGE TO luci-theme-material）
sed -i 's/luci-theme-bootstrap/luci-theme-material/g' feeds/luci/collections/luci/Makefile

# Set etc/openwrt_release
sed -i "s|DISTRIB_REVISION='.*'|DISTRIB_REVISION='R$(date +%Y.%m.%d)'|g" package/base-files/files/etc/openwrt_release
echo "DISTRIB_SOURCECODE='openwrt'" >>package/base-files/files/etc/openwrt_release

# Package
# Add luci-app-amlogic
svn co https://github.com/ophub/luci-app-amlogic/trunk package/luci-app-amlogic

# Openclash
svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash package/luci-app-openclash
pushd package/luci-app-openclash/tools/po2lmo && make && sudo make install && popd

# Diskman
svn co https://github.com/lisaac/luci-app-diskman/trunk/applications/luci-app-diskman package/lean/luci-app-diskman
wget https://raw.githubusercontent.com/lisaac/luci-app-diskman/master/Parted.Makefile -q -P package/lean/parted
pushd package/lean/parted && mv -f Parted.Makefile Makefile && popd
