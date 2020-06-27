# install webserver
cd
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/95dewadew/ooo/master/conf/nginx.conf"
sed -i 's/www-data/nginx/g' /etc/nginx/nginx.conf
mkdir -p /root/users/
echo "<pre><center><img src="http:///favicon.png" data-original-height="120" data-original-width="120" height="320" width="320" /></a></center><br><center><font color="red" size="50"> SETUP BY: JUCKY VENGEANCE</b></font></center><center><br><font color="blue" size="50"> WA: 083898587500</b></font></center></pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /root/users/info.php
rm /etc/nginx/conf.d/*
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/95dewadew/ooo/master/conf/vps.conf"
sed -i 's/apache/nginx/g' /etc/php-fpm.d/www.conf
chmod -R +rx /root/users/
service php-fpm restart
service nginx restart
