read -p "Please enter the username: " newname
    cp client-wg0.conf $newname.conf
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
    qrencode -t ansiutf8  < /etc/wireguard/$newname.conf
    qrencode -o $userdir/$user.png  < /etc/wireguard/$newname.conf
    echo -e "Add complete, file directory：/etc/wireguard/$newname.conf"
    rm -f temprikey tempubkey
