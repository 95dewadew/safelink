
    cd /etc/wireguard/
    cp client-wg0.conf $username.conf
    wg genkey | tee temprikey | wg pubkey > tempubkey
    ipnum=$(grep Allowed /etc/wireguard/wg0.conf | tail -1 | awk -F '[ ./]' '{print $6}')
    newnum=$((10#${ipnum}+1))
    sed -i 's%^PrivateKey.*$%'"PrivateKey = $(cat temprikey)"'%' $username.conf
    sed -i 's%^Address.*$%'"Address = 10.9.0.$newnum\/24"'%' $username.conf

cat >> /etc/wireguard/wg0.conf <<-EOF
[Peer]
PublicKey = $(cat tempubkey)
AllowedIPs = 10.9.0.$newnum/32
EOF
    wg set wg0 peer $(cat tempubkey) allowed-ips 10.9.0.$newnum/32
    cp $username.conf /home/vps/public_html/
    qrencode -t ansiutf8  < /etc/wireguard/$username.conf

    echo -e "Add complete, file directory：/$username.conf"
    rm -f temprikey tempubkey
