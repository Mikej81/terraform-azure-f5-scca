#!/bin/bash
#!/bin/bash
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install NGINX OSS
sudo apt-get update -y
sudo apt-get install curl gnupg2 ca-certificates lsb-release sshpass -y
sudo echo "deb http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list
sudo curl -fsSL https://nginx.org/keys/nginx_signing.key | sudo apt-key add -
sudo apt-key fingerprint ABF5BD827BD9BF62
sudo apt-get update -y
sudo apt-get install nginx -y
sudo systemctl start nginx

echo "${nginx_config}" | base64 -d >/home/${adminUserName}/nginx.conf
echo "${proxy_config}" | base64 -d >/home/${adminUserName}/proxy.conf
echo "${adminPassword}" > /home/${adminUserName}/pass

sudo mv /home/${adminUserName}/nginx.conf /etc/nginx/nginx.conf
sudo mv /home/${adminUserName}/proxy.conf /etc/nginx/conf.d/default.conf

sudo systemctl restart nginx
