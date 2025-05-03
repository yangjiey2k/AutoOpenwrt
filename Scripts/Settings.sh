#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#添加编译日期标识
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_MARK-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")

WIFI_SH=$(find ./target/linux/{mediatek/filogic,qualcommax}/base-files/etc/uci-defaults/ -type f -name "*set-wireless.sh" 2>/dev/null)
WIFI_UC="./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"
if [ -f "$WIFI_SH" ]; then
	#修改WIFI名称
	sed -i "s/BASE_SSID='.*'/BASE_SSID='$WRT_SSID'/g" $WIFI_SH
	#修改WIFI密码
	sed -i "s/BASE_WORD='.*'/BASE_WORD='$WRT_WORD'/g" $WIFI_SH
elif [ -f "$WIFI_UC" ]; then
	#修改WIFI名称
	sed -i "s/ssid='.*'/ssid='$WRT_SSID'/g" $WIFI_UC
	#修改WIFI密码
	sed -i "s/key='.*'/key='$WRT_WORD'/g" $WIFI_UC
	#修改WIFI地区
	sed -i "s/country='.*'/country='CN'/g" $WIFI_UC
	#修改WIFI加密
	sed -i "s/encryption='.*'/encryption='psk2+ccmp'/g" $WIFI_UC
fi

# Network Configuration
SET_NETWROK="./package/base-files/files/etc/rc.local"

if echo "$WRT_TARGET" | grep -Eiq "64|86"; then
	sed -i "/exit 0/iuci set network.lan.proto=\'static\'\nuci set network.lan.ipaddr=\'$WRT_IP\'\nuci set network.lan.netmask=\'255.255.255.0\'\nuci set network.lan.gateway=\'192.168.1.201\'\nuci set network.lan.dns=\'192.168.1.207\'\nuci commit network\n\/etc\/init.d\/network restart\n" $SET_NETWROK
  	echo "$WRT_TARGET - $WRT_IP SET"
fi
if [[ $WRT_TARGET == "R68S" ]]; then
	# sed -i "/exit 0/iuci set network.wan.device=\'eth3\'\nuci set network.wan.proto=\'pppoe\'\nuci set network.wan.username=\'990001257663\'\nuci set network.wan.password=\'u6s3x4r8\'\nuci set network.@device[0].ports=\'eth0 eth1 eth2\'\nuci set network.wan6.device=\'@wan\'\nuci commit network\n\/etc\/init.d\/network restart\n" $SET_NETWROK
	# sed -i "/exit 0/iuci set dhcp.lan.start=\'150\'\nuci set dhcp.lan.limit=\'100\'\nuci commit dhcp\n" $SET_NETWROK
 	# MyOwn
	sed -i "/exit 0/iuci set ddns.aliyun=\'service\'\nuci set ddns.aliyun.service_name=\'aliyun.com\'\nuci set ddns.aliyun.enabled=\'1\'\nuci set ddns.aliyun.lookup_host=\'fhome.bmwlive.club\'\nuci set ddns.aliyun.domain=\'fhome.bmwlive.club\'\nuci set ddns.aliyun.username=\'LTAIHiwKt52WZmKg\'\nuci set ddns.aliyun.password=\'Wlxr4IEL1IQKPtXaBlhVlGWqefF8BK\'\nuci set uci set ddns.aliyun.ip_source=\'web\'\nuci set ddns.aliyun.ip_url=\'http://ip.3322.net\'\nuci set ddns.aliyun.bind_network=\'wan\'\nuci commit ddns\n" $SET_NETWROK
	# Firewall4 PortForward Configuration
	# sed -i "/exit 0/iuci add firewall redirect\nuci set firewall.@redirect[0].target=\'DNAT\'\nuci set firewall.@redirect[0].src=\'wan\'\nuci set firewall.@redirect[0].dest=\'lan\'\nuci set firewall.@redirect[0].proto=\'tcp udp\'\nuci set firewall.@redirect[0].src_dport=\'8098\'\nuci set firewall.@redirect[0].dest_ip=\'$WRT_IP\'\nuci set firewall.@redirect[0].dest_port=\'80\'\nuci set firewall.@redirect[0].name=\'Router\'\nuci add firewall redirect\nuci set firewall.@redirect[1].target=\'DNAT\'\nuci set firewall.@redirect[1].src=\'wan\'\nuci set firewall.@redirect[1].dest=\'lan\'\nuci set firewall.@redirect[1].proto=\'tcp udp\'\nuci set firewall.@redirect[1].src_dport=\'8043\'\nuci set firewall.@redirect[1].dest_ip=\'$WRT_IP\'\nuci set firewall.@redirect[1].dest_port=\'443\'\nuci set firewall.@redirect[1].name=\'Router\'\nuci commit firewall\n" $SET_NETWROK
 	echo "$WRT_TARGET - $WRT_IP SET"
fi
if [[ $WRT_TARGET == "ROCKCHIP" ]]; then
	sed -i "/exit 0/iuci set network.lan.delegate=\'0\'\nuci commit network\n" $SET_NETWROK
	# sed -i "/exit 0/iuci set dhcp.lan.start=\'150\'\nuci set dhcp.lan.limit=\'100\'\nuci set dhcp.lan.ra=\'server\'\nuci set dhcp.lan.ndp=\'relay\'\nuci set dhcp.lan.ra_flags=\'none\'\nuci set dhcp.lan.dns_service=\'0\'\nuci commit dhcp\n" $SET_NETWROK
	# Firewall4 PortForward Configuration
 	sed -i "/exit 0/iuci add firewall redirect\nuci set firewall.@redirect[0].target=\'DNAT\'\nuci set firewall.@redirect[0].src=\'wan\'\nuci set firewall.@redirect[0].dest=\'lan\'\nuci set firewall.@redirect[0].proto=\'tcp udp\'\nuci set firewall.@redirect[0].src_dport=\'8098\'\nuci set firewall.@redirect[0].dest_ip=\'$WRT_IP\'\nuci set firewall.@redirect[0].dest_port=\'80\'\nuci set firewall.@redirect[0].name=\'Router\'\nuci commit firewall\n" $SET_NETWROK
  	echo "$WRT_TARGET - $WRT_IP SET"
fi
# cat "$SET_NETWROK"
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE

#配置文件修改
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config

#手动调整的插件
if [ -n "$WRT_PACKAGE" ]; then
	echo -e "$WRT_PACKAGE" >> ./.config
fi

#高通平台调整
DTS_PATH="./target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/"
if [[ $WRT_TARGET == *"QUALCOMMAX"* ]]; then
	#取消nss相关feed
	echo "CONFIG_FEED_nss_packages=n" >> ./.config
	echo "CONFIG_FEED_sqm_scripts_nss=n" >> ./.config
	#设置NSS版本
	echo "CONFIG_NSS_FIRMWARE_VERSION_11_4=n" >> ./.config
	echo "CONFIG_NSS_FIRMWARE_VERSION_12_2=y" >> ./.config
 	#无WIFI配置调整Q6大小
	if [[ "${WRT_TARGET,,}" == *"wifi"* && "${WRT_TARGET,,}" == *"no"* ]]; then
		find $DTS_PATH -type f ! -iname '*nowifi*' -exec sed -i 's/ipq\(6018\|8074\).dtsi/ipq\1-nowifi.dtsi/g' {} +
 		echo "qualcommax set up nowifi successfully!"
	fi
fi

#编译器优化
if [[ $WRT_TARGET != *"X86"* ]]; then
	echo "CONFIG_TARGET_OPTIONS=y" >> ./.config
	echo "CONFIG_TARGET_OPTIMIZATION=\"-O2 -pipe -march=armv8-a+crypto+crc -mcpu=cortex-a53+crypto+crc -mtune=cortex-a53\"" >> ./.config
fi
