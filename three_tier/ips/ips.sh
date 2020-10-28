#!/bin/bash

echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

sudo touch /usr/lib/networkd-dispatcher/routable.d/10-disable-lrogro
sudo chmod +x /usr/lib/networkd-dispatcher/routable.d/10-disable-lrogro

#systemctl restart networking

#mkdir ~/snort_src

# https://www.snort.org/downloads
# http://sublimerobots.com/2015/12/snort-2-9-8-x-ubuntu/
# http://sublimerobots.com/2016/02/snort-ips-inline-mode-on-ubuntu/

# cd ~/snort_src
# wget https://www.snort.org/downloads/snort/daq-2.0.7.tar.gz
# tar -xvzf daq-2.0.7.tar.gz
# cd daq-2.0.7
# autoreconf -f -i
# ./configure
# make
# sudo make install

# cd ~/snort_src
# wget https://www.snort.org/downloads/snort/snort-2.9.16.1.tar.gz
# tar -xvzf snort-2.9.16.1.tar.gz
# cd snort-2.9.16.1
# autoreconf -f -i
# ./configure --enable-sourcefire
# make
# sudo make install

# sudo ldconfig
# sudo ln -s /usr/local/bin/snort /usr/sbin/snort

# Install NGINX OSS
# sudo apt-get update -y
# sudo apt-get install curl gnupg2 ca-certificates lsb-release sshpass -y
# sudo echo "deb http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
# sudo curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
# sudo apt-key fingerprint ABF5BD827BD9BF62
# sudo apt-get update -y
# sudo apt-get install nginx -y
# sudo systemctl start nginx

# echo "${nginx_config}" | base64 -d >/home/${adminUserName}/nginx.conf
# echo "${adminPassword}" > /home/${adminUserName}/pass

# sudo mv /home/${adminUserName}/nginx.conf /etc/nginx/nginx.conf

# sudo systemctl restart nginx
