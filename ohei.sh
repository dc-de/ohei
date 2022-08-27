#!/bin/bash
# OHEI by dc
if [[ $EUID -ne 0 ]]; then
   echo 'This script must be run as root!'
   exit 1
fi
apt-get update &>/dev/null && apt-get -y upgrade &>/dev/null && apt-get install -y git dialog &>/dev/null & PID=$!
i=1
sp="/-\|"
while [ -d /proc/$PID ]
do
  printf "\b${sp:i++%${#sp}:1}"
  echo ' Loading OHEI...'
  clear
done
while true ; do
	lo=0
	HEIGHT=12
	WIDTH=70
	CHOICE_HEIGHT=5
	TITLE="OHEI - openHABian EASY installer"
	MENU="Choose one of the following options:"
	OPTIONS=(1 "install openHABian"
	2 "openHABian config"
	3 "openHABian status"
	4 "openHABian security patch"
	5 "change web UI username/password")
	CHOICE=$(dialog --clear \
	--backtitle "$BACKTITLE" \
	--title "$TITLE" \
	--menu "$MENU" \
	$HEIGHT $WIDTH $CHOICE_HEIGHT \
	"${OPTIONS[@]}" \
	2>&1 >/dev/tty)
	clear
	case $CHOICE in
        1)
		dialog --title "install openHABian" --msgbox "openHABian is an openHAB package for Debian. Press ENTER to install." 5 100
		useradd -p $(echo openhabian | openssl passwd -1 -stdin) openhabian &> /dev/null
		apt-get update &>/dev/null
counter=0
(
while :
do
cat <<EOF
XXX
$counter
check and install updates...
XXX
EOF
(( counter+=10 ))
[ $counter -eq 100 ] && break
sleep 1
done
) |
		dialog --title "install openHABian" --gauge "Please wait" 7 70 0
		git clone -b stable https://github.com/openhab/openhabian.git /opt/openhabian &>/dev/null
        ln -s /opt/openhabian/openhabian-setup.sh /usr/local/bin/openhabian-config &>/dev/null
counter=0
(
while :
do
cat <<EOF
XXX
$counter
download openHABian...
XXX
EOF
(( counter+=10 ))
[ $counter -eq 100 ] && break
sleep 1
done
) |
		dialog --title "install openHABian" --gauge "Please wait" 7 70 0
		cp /opt/openhabian/openhabian.conf.dist /etc/openhabian.conf &>/dev/null
counter=0
(
while :
do
cat <<EOF
XXX
$counter
install openHABian...
XXX
EOF
(( counter+=10 ))
[ $counter -eq 100 ] && break
sleep 1
done
) |
		dialog --title "install openHABian" --gauge "Please wait" 7 70 0
		openhabian-config unattended &>/dev/null
		dialog --backtitle "$BACKTITLE" --title "install done!" --msgbox "openHABian is now ready to use! The default openhabian user password is openhabian." 6 100
		lo=1
		;;
		2)
		openhabian-config
		lo=1
		;;
		3)
		if systemctl status openhab2.service | grep -q "running"
		then stat="running"
		else stat="NOT running"
		fi
		dialog --title "openHABian status" --msgbox "openHABian service is "$stat"." 5 100
		lo=1
        ;;
		4)
		dialog --title "openHABian security patch" --msgbox "openHABian had no web UI authentication, this patch fix that. Press ENTER to patch." 5 100
counter=0
(
while :
do
cat <<EOF
XXX
$counter
check and install updates...
XXX
EOF
(( counter+=10 ))
[ $counter -eq 100 ] && break
sleep 1
done
) |
		dialog --title "openHABian security patch" --gauge "Please wait" 7 70 0
		apt-get update &>/dev/null && apt-get -y upgrade &>/dev/null && apt-get install -y apache2 apache2-utils openssl ssl-cert &>/dev/null
counter=0
(
while :
do
cat <<EOF
XXX
$counter
patching...
XXX
EOF
(( counter+=10 ))
[ $counter -eq 100 ] && break
sleep 1
done
) |
		dialog --title "openHABian security patch" --gauge "Please wait" 7 70 0
		htpasswd -cmb /etc/apache2/.htpasswd openhabian openhabian &>/dev/null
		echo '<VirtualHost *:80>' > /etc/apache2/sites-enabled/000-default.conf
		echo 'ProxyPass / http://127.0.0.1:8080/' >> /etc/apache2/sites-enabled/000-default.conf
		echo 'ProxyPassReverse / http://127.0.0.1:8080/' >> /etc/apache2/sites-enabled/000-default.conf
		echo '<Location />' >> /etc/apache2/sites-enabled/000-default.conf
		echo '	AuthType Basic' >> /etc/apache2/sites-enabled/000-default.conf
		echo '	AuthName "openHAB2 restricted"' >> /etc/apache2/sites-enabled/000-default.conf
		echo '	AuthUserFile /etc/apache2/.htpasswd' >> /etc/apache2/sites-enabled/000-default.conf
		echo '	Require valid-user' >> /etc/apache2/sites-enabled/000-default.conf
		echo '</Location>' >> /etc/apache2/sites-enabled/000-default.conf
		echo '</VirtualHost>' >> /etc/apache2/sites-enabled/000-default.conf
		echo '<VirtualHost *:443>' >> /etc/apache2/sites-enabled/000-default.conf
		echo '        SSLEngine on' >> /etc/apache2/sites-enabled/000-default.conf
		echo '        SSLCertificateFile      /etc/ssl/certs/ssl-cert-snakeoil.pem' >> /etc/apache2/sites-enabled/000-default.conf
		echo '        SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key' >> /etc/apache2/sites-enabled/000-default.conf
		echo '        ProxyPass / http://127.0.0.1:8080/' >> /etc/apache2/sites-enabled/000-default.conf
		echo '        ProxyPassReverse / http://127.0.0.1:8080/' >> /etc/apache2/sites-enabled/000-default.conf
		echo '        RequestHeader set X-Forwarded-Proto "http" env=HTTP' >> /etc/apache2/sites-enabled/000-default.conf
		echo '        <Location />' >> /etc/apache2/sites-enabled/000-default.conf
		echo '                AuthType Basic' >> /etc/apache2/sites-enabled/000-default.conf
		echo '                AuthName "openHAB2 restricted"' >> /etc/apache2/sites-enabled/000-default.conf
		echo '                AuthUserFile /etc/apache2/.htpasswd' >> /etc/apache2/sites-enabled/000-default.conf
		echo '                Require valid-user' >> /etc/apache2/sites-enabled/000-default.conf
		echo '        </Location>' >> /etc/apache2/sites-enabled/000-default.conf
		echo '</VirtualHost>' >> /etc/apache2/sites-enabled/000-default.conf
		echo 'OPENHAB_HTTP_ADDRESS=127.0.0.1' >> /etc/default/openhab2
		a2enmod proxy proxy_http proxy_ajp rewrite deflate headers proxy_balancer proxy_connect proxy_html xml2enc &>/dev/null
		systemctl restart apache2.service &>/dev/null
		a2enmod ssl &>/dev/null
counter=0
(
while :
do
cat <<EOF
XXX
$counter
restart services...
XXX
EOF
(( counter+=10 ))
[ $counter -eq 100 ] && break
sleep 1
done
) |
		dialog --title "openHABian security patch" --gauge "Please wait" 7 70 0
		systemctl restart apache2.service &>/dev/null
		systemctl restart openhab2.service &>/dev/null
		dialog --backtitle "$BACKTITLE" --title "install done!" --msgbox "openHABian is now patched. The default web UI user and password is openhabian openhabian." 5 100
		lo=1
        ;;
		5)
		user=$(dialog --inputbox "username:" 8 50 --output-fd 1)
		pass=$(dialog --inputbox "password:" 8 50 --output-fd 1)
		htpasswd -cmb /etc/apache2/.htpasswd $user $pass &>/dev/null
		dialog --title "changing web UI username/password done!" --msgbox "The openHABian web UI username/password is now changed!" 5 100
		lo=1
        ;;
	esac
if [[ "$lo" = 1 ]] ; then
	continue
else
	break
fi
done
clear
if openhab-cli info &>/dev/null ; then
    echo 'openHABian info'
    openhab-cli info | grep Version
	openhab-cli info | grep Directories
	openhab-cli info | grep OPENHAB
else
    clear
fi
exit
