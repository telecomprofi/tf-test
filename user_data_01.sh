#!/bin/bash
yum -y update
yum -y install httpd curl
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
myip=`curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/public-ipv4`
echo "<html><body bgcolor=grey><center><h1><p><font color=yellow>Web Server-1</h1></center><br><p>
<font color="green">ServerPublicIP: <font color="aqua">$myip<br><br></body></html>" > /var/www/html/index.html
sudo service httpd start
sudo chkconfig httpd on
