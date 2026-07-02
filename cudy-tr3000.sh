#!/bin/bash

# git clone -b openwrt-24.10-6.6 --single-branch --filter=blob:none https://github.com/padavanonly/immortalwrt-mt798x-24.10 immortalwrt-mt798x-24.10
# cd immortalwrt-mt798x-24.10

# git config --local https.proxy socks5://host.docker.internal:1080

# ./scripts/feeds update -a
# ./scripts/feeds install -a

# theme
rm -rf feeds/luci/themes/luci-theme-argon
git clone https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# passwall

rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages

rm -rf feeds/luci/applications/luci-app-passwall
# git clone https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall-luci
git clone https://github.com/Openwrt-Passwall/openwrt-passwall2 package/passwall2-luci

# tailscale
# sed -i '/\/etc\/init\.d\/tailscale/d;/\/etc\/config\/tailscale/d;' feeds/packages/net/tailscale/Makefile
# git clone https://github.com/asvow/luci-app-tailscale package/luci-app-tailscale

# Modify default IP
sed -i 's/192.168.6.1/192.168.10.1/g' package/base-files/files/bin/config_generate

# Force daed to v1.27.0 (latest official release from daeuniverse/daed)
# The feed Makefile uses daed-web-1.27.0.zip naming but the actual GitHub release
# only ships web.zip (no version suffix). Also need correct hash.
if [ -f feeds/packages/net/daed/Makefile ]; then
    sed -i 's|PKG_VERSION:=1\.[0-9]*\.[0-9]*|PKG_VERSION:=1.27.0|' feeds/packages/net/daed/Makefile
    sed -i 's|PKG_RELEASE:=.*|PKG_RELEASE:=1|' feeds/packages/net/daed/Makefile
    # Fix the WEB_FILE name (daeuniverse/daed uses web.zip, not daed-web-X.Y.Z.zip)
    sed -i 's|WEB_FILE:=$(PKG_NAME)-web-$(PKG_VERSION).zip|WEB_FILE:=web.zip|' feeds/packages/net/daed/Makefile
    # Update HASH to actual v1.27.0 web.zip sha256
    sed -i 's|HASH:=.*|HASH:=da8755fb2cabfab392854e807e385b12d9e9842d6c8b5e347284d1ae0e582bfc|' feeds/packages/net/daed/Makefile
    echo "daed Makefile bumped to 1.27.0 with corrected web filename and hash"
fi

# defconfig
# cp -f ../.config .config
# cp -f defconfig/mt7981-ax3000.config .config
sed -i 's|IMG_PREFIX:=|IMG_PREFIX:=$(shell TZ="Asia/Shanghai" date +"%Y%m%d")-24.10-6.6-|' include/image.mk
# make menuconfig

# compile and build
# make download -j8
# make -j$(nproc)
