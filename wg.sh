#!/bin/bash

rand(){
    min=$1
    max=$(($2-$min+1))
    num=$(cat /dev/urandom | head -n 10 | cksum | awk -F ' ' '{print $1}')
    echo $(($num%$max+$min))  
}

wireguard_install(){
    version=$(cat /etc/os-release | awk -F '[".]' '$1=="VERSION="{print $2}')
    if [ $version == 18 ]
    then
         apt-get update -y
         apt-get install -y software-properties-common
         apt-get install -y openresolv
    else
         apt-get update -y
         apt-get install -y software-properties-common
    fi
     add-apt-repository -y ppa:wireguard/wireguard
     apt-get update -y
     apt-get install -y wireguard curl

     echo net.ipv4.ip_forward = 1 >> /etc/sysctl.conf
    sysctl -p
    echo "1"> /proc/sys/net/ipv4/ip_forward
    
    mkdir /etc/wireguard
    cd /etc/wireguard
    wg genkey | tee sprivatekey | wg pubkey > spublickey
    wg genkey | tee cprivatekey | wg pubkey > cpublickey
    s1=$(cat sprivatekey)
    s2=$(cat spublickey)
    c1=$(cat cprivatekey)
    c2=$(cat cpublickey)
    serverip=$(curl ipv4.icanhazip.com)
    port=$(rand 10000 60000)
    eth=$(ls /sys/class/net | awk '/^e/{print}')

 cat > /etc/wireguard/wg0.conf <<-EOF
[Interface]
PrivateKey = $s1
Address = 10.0.0.1/24 
PostUp   = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -A FORWARD -o wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $eth -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -D FORWARD -o wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $eth -j MASQUERADE
ListenPort = $port
DNS = 8.8.8.8
MTU = 1420

[Peer]
PublicKey = $c2
AllowedIPs = 10.0.0.2/32
EOF


 cat > /etc/wireguard/client.conf <<-EOF
[Interface]
PrivateKey = $c1
Address = 10.0.0.2/24 
DNS = 8.8.8.8
MTU = 1420

[Peer]
PublicKey = $s2
Endpoint = $serverip:$port
AllowedIPs = 0.0.0.0/0, ::0/0
PersistentKeepalive = 25
EOF

     apt-get install -y qrencode

 cat > /etc/init.d/wgstart <<-EOF
#! /bin/bash
### BEGIN INIT INFO
# Provides:		wgstart
# Required-Start:	$remote_fs $syslog
# Required-Stop:    $remote_fs $syslog
# Default-Start:	2 3 4 5
# Default-Stop:		0 1 6
# Short-Description:	wgstart
### END INIT INFO
 wg-quick up wg0
EOF

     chmod +x /etc/init.d/wgstart
    cd /etc/init.d
    if [ $version == 14 ]
    then
        update-rc.d wgstart defaults 90
    else
         update-rc.d wgstart defaults
    fi
    
     wg-quick up wg0
    
    content=$(cat /etc/wireguard/client.conf)
}

wireguard_remove(){

     wg-quick down wg0
     apt-get remove -y wireguard
     rm -rf /etc/wireguard

}

add_user(){
    read -p "Please enter the username: " newname
    cd /etc/wireguard/
    cp client.conf $newname.conf
    wg genkey | tee temprikey | wg pubkey > tempubkey
    ipnum=$(grep Allowed /etc/wireguard/wg0.conf | tail -1 | awk -F '[ ./]' '{print $6}')
    newnum=$((10#${ipnum}+1))
    sed -i 's%^PrivateKey.*$%'"PrivateKey = $(cat temprikey)"'%' $newname.conf
    sed -i 's%^Address.*$%'"Address = 10.0.0.$newnum\/24"'%' $newname.conf

cat >> /etc/wireguard/wg0.conf <<-EOF
[Peer]
PublicKey = $(cat tempubkey)
AllowedIPs = 10.0.0.$newnum/32
EOF
    wg set wg0 peer $(cat tempubkey) allowed-ips 10.0.0.$newnum/32
    echo -e "Add complete, file directory：/etc/wireguard/$newname.conf"
    rm -f temprikey tempubkey
}

#Start Menu
start_menu(){
    echo
    echo -e " 1. Install Wireguard"
    echo -e " 2. Uninstall Wireguard"
    echo -e " 3. Add User"
    echo -e " 0. Exit"
    echo
    read -p "Please enter a number: " num
    case "$num" in
    1)
    wireguard_install
    ;;
    2)
    wireguard_remove
    ;;
    3)
    add_user
    ;;
    0)
    exit 1
    ;;
    *)
    clear
    echo -e "Please enter the correct number."
    sleep 2s
    start_menu
    ;;
    esac
}

start_menu





