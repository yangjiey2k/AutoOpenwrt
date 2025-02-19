#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#添加编译日期标识
sed -i "s/(\(luciversion || ''\))/(\1) + (' \/ $WRT_CI-$WRT_DATE')/g" $(find ./feeds/luci/modules/luci-mod-status/ -type f -name "10_system.js")

WIFI_SH=$(find ./target/linux/{mediatek/filogic,qualcommax}/base-files/etc/uci-defaults/ -type f -name "*set-wireless.sh")
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
SET_NETWROK="./package/base-files/files/etc/uci-defaults/991_set-network.sh"
# Check if the file exists, if not create it
if [ ! -f "$SET_NETWORK" ]; then
    touch "$SET_NETWROK"
    cat <<EOF >> "$SET_NETWROK"
#!/bin/bash

# Check if network.globals.ula_prefix exists and is not empty
ula_prefix=\$(uci get network.globals.ula_prefix 2>/dev/null)

if [ -n "\$ula_prefix" ]; then
    uci set dhcp.wan6=dhcp
    uci set dhcp.wan6.interface='wan6'
    uci set dhcp.wan6.ignore='1'

    uci set dhcp.lan.force='1'
    uci set dhcp.lan.ra='hybrid'
    uci set dhcp.lan.ra_default='1'
    uci set dhcp.lan.max_preferred_lifetime='1800'
    uci set dhcp.lan.max_valid_lifetime='3600'

    uci del dhcp.lan.dhcpv6
    uci del dhcp.lan.ra_flags
    uci del dhcp.lan.ra_slaac
    uci add_list dhcp.lan.ra_flags='none'

    uci commit dhcp

    uci set network.wan6=interface
    uci set network.wan6.proto='dhcpv6'
    uci set network.wan6.device='@wan'
    uci set network.wan6.reqaddress='try'
    uci set network.wan6.reqprefix='auto'
    uci set network.lan.ip6assign='64'
    uci set network.lan.ip6ifaceid='eui64'
    uci del network.globals.ula_prefix

    uci commit network
fi

exit 0
EOF
fi

if echo "$WRT_TARGET" | grep -Eiq "64|86"; then
	sed -i "/uci commit network/i\    uci set network.wan.device=\'eth1\'\n    uci set network.wan.proto=\'pppoe\'\n    uci set network.wan.username=\'990003835168\'\n    uci set network.wan.password=\'k5k4t5b6\'\n    uci set network.@device[0].ports=\'eth0 eth2 eth3 eth4\'\n    uci set network.lan.delegate=\'0\'\n" $SET_NETWROK
	sed -i "/uci commit dhcp/i\    uci set dhcp.lan.start=\'150\'\n    uci set dhcp.lan.limit=\'100\'\n    uci set dhcp.lan.ra=\'server\'\n    uci set dhcp.lan.ndp=\'relay\'\n    uci set dhcp.lan.ra_flags=\'none\'\n    uci set dhcp.lan.dns_service=\'0\'\n    uci add dhcp host\n    uci set dhcp.@host[0].name=\'HOME-SRV\'\n    uci set dhcp.@host[0].mac=\'90:2e:16:bd:0b:cc\'\n    uci set dhcp.@host[0].ip=\'192.168.50.8\'\n    uci set dhcp.@host[0].leasetime=\'infinite\'\n    uci add dhcp host\n    uci set dhcp.@host[1].name=\'AP\'\n    uci set dhcp.@host[1].mac=\'60:cf:84:28:8f:80\'\n    uci set dhcp.@host[1].ip=\'192.168.50.6\'\n    uci set dhcp.@host[1].leasetime=\'infinite\'\n" $SET_NETWROK
	# MyOwn
	sed -i "/exit 0/iuci set ddns.AliDDNS=\'service\'\nuci set ddns.AliDDNS.service_name=\'aliyun.com\'\nuci set ddns.AliDDNS.enabled=\'1\'\nuci set ddns.AliDDNS.lookup_host=\'homev6.bmwlive.club\'\nuci set ddns.AliDDNS.domain=\'homev6.bmwlive.club\'\nuci set ddns.AliDDNS.username=\'LTAIHiwKt52WZmKg\'\nuci set ddns.AliDDNS.password=\'Wlxr4IEL1IQKPtXaBlhVlGWqefF8BK\'\nuci set ddns.AliDDNS.use_ipv6=\'1\'\nuci set ddns.AliDDNS.ip_source=\'interface\'\nuci set ddns.AliDDNS.interface=\'pppoe-wan\'\nuci set ddns.AliDDNS.ip_interface=\'pppoe-wan\'\nuci set ddns.aliyun=\'service\'\nuci set ddns.aliyun.service_name=\'aliyun.com\'\nuci set ddns.aliyun.enabled=\'1\'\nuci set ddns.aliyun.lookup_host=\'home.bmwlive.club\'\nuci set ddns.aliyun.domain=\'home.bmwlive.club\'\nuci set ddns.aliyun.username=\'LTAIHiwKt52WZmKg\'\nuci set ddns.aliyun.password=\'Wlxr4IEL1IQKPtXaBlhVlGWqefF8BK\'\nuci set uci set ddns.aliyun.ip_source=\'web\'\nuci set ddns.aliyun.ip_url=\'http://ip.3322.net\'\nuci set ddns.aliyun.bind_network=\'wan\'\nuci commit ddns\n" $SET_NETWROK
	# Firewall4 PortForward Configuration
	sed -i "/exit 0/iuci add firewall redirect\nuci set firewall.@redirect[0].target=\'DNAT\'\nuci set firewall.@redirect[0].src=\'wan\'\nuci set firewall.@redirect[0].dest=\'lan\'\nuci set firewall.@redirect[0].src_dport=\'1688\'\nuci set firewall.@redirect[0].dest_ip=\'$WRT_IP\'\nuci set firewall.@redirect[0].dest_port=\'1688\'\nuci set firewall.@redirect[0].name=\'KMS\'\nuci add firewall redirect\nuci set firewall.@redirect[1].target=\'DNAT\'\nuci set firewall.@redirect[1].src=\'wan\'\nuci set firewall.@redirect[1].proto=\'tcp\'\nuci set firewall.@redirect[1].src_dport=\'3389\'\nuci set firewall.@redirect[1].dest_ip=\'192.168.50.8\'\nuci set firewall.@redirect[1].dest_port=\'3389\'\nuci set firewall.@redirect[1].name=\'RDP\'\nuci set firewall.@redirect[1].dest=\'lan\'\nuci add firewall redirect\nuci set firewall.@redirect[2].target=\'DNAT\'\nuci set firewall.@redirect[2].src=\'wan\'\nuci set firewall.@redirect[2].proto=\'tcp udp\'\nuci set firewall.@redirect[2].src_dport=\'2302\'\nuci set firewall.@redirect[2].dest_ip=\'192.168.50.8\'\nuci set firewall.@redirect[2].dest_port=\'2302\'\nuci set firewall.@redirect[2].name=\'DayZ\'\nuci set firewall.@redirect[2].dest=\'lan\'\nuci add firewall redirect\nuci set firewall.@redirect[3].target=\'DNAT\'\nuci set firewall.@redirect[3].src=\'wan\'\nuci set firewall.@redirect[3].dest=\'lan\'\nuci set firewall.@redirect[3].proto=\'udp\'\nuci set firewall.@redirect[3].src_dport=\'27016\'\nuci set firewall.@redirect[3].dest_ip=\'192.168.50.8\'\nuci set firewall.@redirect[3].dest_port=\'27016\'\nuci set firewall.@redirect[3].name=\'DayZ\'\nuci add firewall redirect\nuci set firewall.@redirect[4].target=\'DNAT\'\nuci set firewall.@redirect[4].src=\'wan\'\nuci set firewall.@redirect[4].dest=\'lan\'\nuci set firewall.@redirect[4].proto=\'tcp udp\'\nuci set firewall.@redirect[4].src_dport=\'2308\'\nuci set firewall.@redirect[4].dest_ip=\'192.168.50.8\'\nuci set firewall.@redirect[4].dest_port=\'2308\'\nuci set firewall.@redirect[4].name=\'DayZ\'\nuci add firewall redirect\nuci set firewall.@redirect[5].target=\'DNAT\'\nuci set firewall.@redirect[5].src=\'wan\'\nuci set firewall.@redirect[5].dest=\'lan\'\nuci set firewall.@redirect[5].proto=\'tcp udp\'\nuci set firewall.@redirect[5].src_dport=\'8098\'\nuci set firewall.@redirect[5].dest_ip=\'$WRT_IP\'\nuci set firewall.@redirect[5].dest_port=\'80\'\nuci set firewall.@redirect[5].name=\'Router\'\nuci add firewall redirect\nuci set firewall.@redirect[6].target=\'DNAT\'\nuci set firewall.@redirect[6].src=\'wan\'\nuci set firewall.@redirect[6].dest=\'lan\'\nuci set firewall.@redirect[6].proto=\'tcp udp\'\nuci set firewall.@redirect[6].src_dport=\'8043\'\nuci set firewall.@redirect[6].dest_ip=\'$WRT_IP\'\nuci set firewall.@redirect[6].dest_port=\'443\'\nuci set firewall.@redirect[6].name=\'Router\'\nuci add firewall redirect\nuci set firewall.@redirect[7].target=\'DNAT\'\nuci set firewall.@redirect[7].src=\'wan\'\nuci set firewall.@redirect[7].dest=\'lan\'\nuci set firewall.@redirect[7].proto=\'tcp udp\'\nuci set firewall.@redirect[7].src_dport=\'8099\'\nuci set firewall.@redirect[7].dest_ip=\'192.168.50.9\'\nuci set firewall.@redirect[7].dest_port=\'19999\'\nuci set firewall.@redirect[7].name=\'Netdata\'\nuci add firewall redirect\nuci set firewall.@redirect[8].target=\'DNAT\'\nuci set firewall.@redirect[8].src=\'wan\'\nuci set firewall.@redirect[8].dest=\'lan\'\nuci set firewall.@redirect[8].proto=\'tcp udp\'\nuci set firewall.@redirect[8].src_dport=\'9090\'\nuci set firewall.@redirect[8].dest_ip=\'$WRT_IP\'\nuci set firewall.@redirect[8].dest_port=\'9090\'\nuci set firewall.@redirect[8].name=\'OpenClash\'\nuci add firewall redirect\nuci set firewall.@redirect[9].target=\'DNAT\'\nuci set firewall.@redirect[9].src=\'wan\'\nuci set firewall.@redirect[9].dest=\'lan\'\nuci set firewall.@redirect[9].proto=\'tcp udp\'\nuci set firewall.@redirect[9].src_dport=\'19999\'\nuci set firewall.@redirect[9].dest_ip=\'$WRT_IP\'\nuci set firewall.@redirect[9].dest_port=\'19999\'\nuci set firewall.@redirect[9].name=\'LedeNetdata\'\nuci add firewall redirect\nuci set firewall.@redirect[10].target=\'DNAT\'\nuci set firewall.@redirect[10].src=\'wan\'\nuci set firewall.@redirect[10].dest=\'lan\'\nuci set firewall.@redirect[10].proto=\'tcp udp\'\nuci set firewall.@redirect[10].src_dport=\'7681\'\nuci set firewall.@redirect[10].dest_ip=\'$WRT_IP\'\nuci set firewall.@redirect[10].dest_port=\'7681\'\nuci set firewall.@redirect[10].name=\'TTYD\'\nuci add firewall redirect\nuci set firewall.@redirect[11].target=\'DNAT\'\nuci set firewall.@redirect[11].src=\'wan\'\nuci set firewall.@redirect[11].dest=\'lan\'\nuci set firewall.@redirect[11].proto=\'tcp\'\nuci set firewall.@redirect[11].src_dport=\'8096\'\nuci set firewall.@redirect[11].dest_ip=\'192.168.50.10\'\nuci set firewall.@redirect[11].dest_port=\'80\'\nuci set firewall.@redirect[11].name=\'ESXi\'\nuci commit firewall\n" $SET_NETWROK
 	# set default language to english
  	sed -i "/exit 0/iuci set luci.main.lang=\'en\'\nuci commit luci\n" $SET_NETWROK
  	echo "$WRT_TARGET - $WRT_IP SET"
fi
if [[ $WRT_TARGET == "R68S" ]]; then
	sed -i "/uci commit network/i\    uci set network.wan.device=\'eth3\'\n    uci set network.wan.proto=\'pppoe\'\n    uci set network.wan.username=\'990001257663\'\n    uci set network.wan.password=\'u6s3x4r8\'\n    uci set network.@device[0].ports=\'eth0 eth1 eth2\'\n    uci set network.lan.delegate=\'0\'\n" $SET_NETWROK
	sed -i "/uci commit dhcp/i\    uci set dhcp.lan.start=\'150\'\n    uci set dhcp.lan.limit=\'100\'\n    uci set dhcp.lan.ra=\'server\'\n    uci set dhcp.lan.ndp=\'relay\'\n    uci set dhcp.lan.ra_flags=\'none\'\n    uci set dhcp.lan.dns_service=\'0\'\n" $SET_NETWROK
 	# MyOwn
	sed -i "/exit 0/iuci set ddns.aliyun=\'service\'\nuci set ddns.aliyun.service_name=\'aliyun.com\'\nuci set ddns.aliyun.enabled=\'1\'\nuci set ddns.aliyun.lookup_host=\'fhome.bmwlive.club\'\nuci set ddns.aliyun.domain=\'fhome.bmwlive.club\'\nuci set ddns.aliyun.username=\'LTAIHiwKt52WZmKg\'\nuci set ddns.aliyun.password=\'Wlxr4IEL1IQKPtXaBlhVlGWqefF8BK\'\nuci set uci set ddns.aliyun.ip_source=\'web\'\nuci set ddns.aliyun.ip_url=\'http://ip.3322.net\'\nuci set ddns.aliyun.bind_network=\'wan\'\nuci commit ddns\n" $SET_NETWROK
	# Firewall4 PortForward Configuration
	sed -i "/exit 0/iuci add firewall redirect\nuci set firewall.@redirect[0].target=\'DNAT\'\nuci set firewall.@redirect[0].src=\'wan\'\nuci set firewall.@redirect[0].dest=\'lan\'\nuci set firewall.@redirect[0].proto=\'tcp udp\'\nuci set firewall.@redirect[0].src_dport=\'8098\'\nuci set firewall.@redirect[0].dest_ip=\'$WRT_IP\'\nuci set firewall.@redirect[0].dest_port=\'80\'\nuci set firewall.@redirect[0].name=\'Router\'\nuci add firewall redirect\nuci set firewall.@redirect[1].target=\'DNAT\'\nuci set firewall.@redirect[1].src=\'wan\'\nuci set firewall.@redirect[1].dest=\'lan\'\nuci set firewall.@redirect[1].proto=\'tcp udp\'\nuci set firewall.@redirect[1].src_dport=\'8043\'\nuci set firewall.@redirect[1].dest_ip=\'$WRT_IP\'\nuci set firewall.@redirect[1].dest_port=\'443\'\nuci set firewall.@redirect[1].name=\'Router\'\nuci commit firewall\n" $SET_NETWROK
 	echo "$WRT_TARGET - $WRT_IP SET"
fi
if [[ $WRT_TARGET == "ROCKCHIP" ]]; then
	sed -i "/uci commit network/i\    uci set network.lan.delegate=\'0\'\n" $SET_NETWROK
	sed -i "/uci commit dhcp/i\    uci set dhcp.lan.start=\'150\'\n    uci set dhcp.lan.limit=\'100\'\n    uci set dhcp.lan.ra=\'server\'\n    uci set dhcp.lan.ndp=\'relay\'\n    uci set dhcp.lan.ra_flags=\'none\'\n    uci set dhcp.lan.dns_service=\'0\'\n" $SET_NETWROK
	# Firewall4 PortForward Configuration
 	sed -i "/exit 0/iuci add firewall redirect\nuci set firewall.@redirect[0].target=\'DNAT\'\nuci set firewall.@redirect[0].src=\'wan\'\nuci set firewall.@redirect[0].dest=\'lan\'\nuci set firewall.@redirect[0].proto=\'tcp udp\'\nuci set firewall.@redirect[0].src_dport=\'8098\'\nuci set firewall.@redirect[0].dest_ip=\'$WRT_IP\'\nuci set firewall.@redirect[0].dest_port=\'80\'\nuci set firewall.@redirect[0].name=\'Router\'\nuci commit firewall\n" $SET_NETWROK
  	echo "$WRT_TARGET - $WRT_IP SET"
fi
#cat "$SET_NETWROK"
#修改immortalwrt.lan关联IP
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $(find ./feeds/luci/modules/luci-mod-system/ -type f -name "flash.js")
# Add restart dropbear firewall and DDNS
SET_RESTART="./package/base-files/files/etc/uci-defaults/999_auto-restart.sh"
sed -i "/exit/i/etc/init.d/firewall restart\n/etc/init.d/ddns restart\n" $SET_RESTART

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
if [[ $WRT_TARGET == *"QUALCOMMAX"* ]]; then
	#取消nss相关feed
	echo "CONFIG_FEED_nss_packages=n" >> ./.config
	echo "CONFIG_FEED_sqm_scripts_nss=n" >> ./.config
	#设置NSS版本
	echo "CONFIG_NSS_FIRMWARE_VERSION_11_4=n" >> ./.config
	echo "CONFIG_NSS_FIRMWARE_VERSION_12_2=y" >> ./.config
fi

#编译器优化
if [[ $WRT_TARGET != *"X86"* ]]; then
	echo "CONFIG_TARGET_OPTIONS=y" >> ./.config
	echo "CONFIG_TARGET_OPTIMIZATION=\"-O2 -pipe -march=armv8-a+crypto+crc -mcpu=cortex-a53+crypto+crc -mtune=cortex-a53\"" >> ./.config
fi
