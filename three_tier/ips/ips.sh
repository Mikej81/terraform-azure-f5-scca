# Install IPS https://docs.microsoft.com/en-us/azure/network-watcher/network-watcher-intrusion-detection-open-source-tools
# https://suricata.readthedocs.io/en/suricata-5.0.2/setting-up-ipsinline-for-linux.html
sudo apt-get update -y
# Install Suricata
sudo add-apt-repository ppa:oisf/suricata-stable -y
sudo apt update -y
#sudo apt install libjansson4 libjansson-dev python-simplejson -y
sudo apt install suricata jq -y
sudo suricata-update
sudo sed -i 's/#  mode: accept/mode: route/g' /etc/suricata/suricata.yaml
#sudo sed -i 's/  enabled: auto/  enabled: yes/g' /etc/suricata/suricata.yaml
sudo iptables -I FORWARD -i eth0 -o eth1 -j NFQUEUE
sudo iptables -I FORWARD -i eth1 -o eth0 -j NFQUEUE
sudo systemctl restart suricata
# Install ElasticSearch
#curl -L -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.2.0.deb
#sudo dpkg -i elasticsearch-5.2.0.deb
#sudo /etc/init.d/elasticsearch start
# Install Logstash
# sudo apt install default-jre -y
# curl -L -O https://artifacts.elastic.co/downloads/logstash/logstash-5.2.0.deb
# sudo dpkg -i logstash-5.2.0.deb
# sudo touch /etc/logstash/conf.d/logstash.conf
# sudo echo -e 'aW5wdXQgewpmaWxlIHsKICAgIHBhdGggPT4gWyIvdmFyL2xvZy9zdXJpY2F0YS9ldmUuanNvbiJdCiAgICBjb2RlYyA9PiAgImpzb24iCiAgICB0eXBlID0+ICJTdXJpY2F0YUlEUFMiCn0KCn0KCmZpbHRlciB7CmlmIFt0eXBlXSA9PSAiU3VyaWNhdGFJRFBTIiB7CiAgICBkYXRlIHsKICAgIG1hdGNoID0+IFsgInRpbWVzdGFtcCIsICJJU084NjAxIiBdCiAgICB9CiAgICBydWJ5IHsKICAgIGNvZGUgPT4gIgogICAgICAgIGlmIGV2ZW50LmdldCgnW2V2ZW50X3R5cGVdJykgPT0gJ2ZpbGVpbmZvJwogICAgICAgIGV2ZW50LnNldCgnW2ZpbGVpbmZvXVt0eXBlXScsIGV2ZW50LmdldCgnW2ZpbGVpbmZvXVttYWdpY10nKS50b19zLnNwbGl0KCcsJylbMF0pCiAgICAgICAgZW5kCiAgICAiCiAgICB9CgogICAgcnVieXsKICAgIGNvZGUgPT4gIgogICAgICAgIGlmIGV2ZW50LmdldCgnW2V2ZW50X3R5cGVdJykgPT0gJ2FsZXJ0JwogICAgICAgIHNwID0gZXZlbnQuZ2V0KCdbYWxlcnRdW3NpZ25hdHVyZV0nKS50b19zLnNwbGl0KCcgZ3JvdXAgJykKICAgICAgICBpZiAoc3AubGVuZ3RoID09IDIpIGFuZCAvXEFcZCtcei8ubWF0Y2goc3BbMV0pCiAgICAgICAgICAgIGV2ZW50LnNldCgnW2FsZXJ0XVtzaWduYXR1cmVdJywgc3BbMF0pCiAgICAgICAgZW5kCiAgICAgICAgZW5kCiAgICAgICAgIgogICAgfQp9CgppZiBbc3JjX2lwXSAgewogICAgZ2VvaXAgewogICAgc291cmNlID0+ICJzcmNfaXAiCiAgICB0YXJnZXQgPT4gImdlb2lwIgogICAgI2RhdGFiYXNlID0+ICIvb3B0L2xvZ3N0YXNoL3ZlbmRvci9nZW9pcC9HZW9MaXRlQ2l0eS5kYXQiCiAgICBhZGRfZmllbGQgPT4gWyAiW2dlb2lwXVtjb29yZGluYXRlc10iLCAiJXtbZ2VvaXBdW2xvbmdpdHVkZV19IiBdCiAgICBhZGRfZmllbGQgPT4gWyAiW2dlb2lwXVtjb29yZGluYXRlc10iLCAiJXtbZ2VvaXBdW2xhdGl0dWRlXX0iICBdCiAgICB9CiAgICBtdXRhdGUgewogICAgY29udmVydCA9PiBbICJbZ2VvaXBdW2Nvb3JkaW5hdGVzXSIsICJmbG9hdCIgXQogICAgfQogICAgaWYgIVtnZW9pcC5pcF0gewogICAgaWYgW2Rlc3RfaXBdICB7CiAgICAgICAgZ2VvaXAgewogICAgICAgIHNvdXJjZSA9PiAiZGVzdF9pcCIKICAgICAgICB0YXJnZXQgPT4gImdlb2lwIgogICAgICAgICNkYXRhYmFzZSA9PiAiL29wdC9sb2dzdGFzaC92ZW5kb3IvZ2VvaXAvR2VvTGl0ZUNpdHkuZGF0IgogICAgICAgIGFkZF9maWVsZCA9PiBbICJbZ2VvaXBdW2Nvb3JkaW5hdGVzXSIsICIle1tnZW9pcF1bbG9uZ2l0dWRlXX0iIF0KICAgICAgICBhZGRfZmllbGQgPT4gWyAiW2dlb2lwXVtjb29yZGluYXRlc10iLCAiJXtbZ2VvaXBdW2xhdGl0dWRlXX0iICBdCiAgICAgICAgfQogICAgICAgIG11dGF0ZSB7CiAgICAgICAgY29udmVydCA9PiBbICJbZ2VvaXBdW2Nvb3JkaW5hdGVzXSIsICJmbG9hdCIgXQogICAgICAgIH0KICAgIH0KICAgIH0KfQp9CgpvdXRwdXQgewplbGFzdGljc2VhcmNoIHsKICAgIGhvc3RzID0+ICJsb2NhbGhvc3QiCn0KfQ==' | sudo base64 -d > logstash.conf
# sudo cp ./logstash.conf /etc/logstash/conf.d/
# sudo chmod 775 /var/log/suricata/eve.json
# sudo systemctl start logstash.service
# Install Kibana
#curl -L -O https://artifacts.elastic.co/downloads/kibana/kibana-5.2.0-linux-x86_64.tar.gz
#tar xzvf kibana-5.2.0-linux-x86_64.tar.gz
#kibana-5.2.0-linux-x86_64/bin/kibana &
