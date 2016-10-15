# Config MSB address
MSB_IP=`echo $MSB_ADDR | cut -d: -f 1`
sed -i "s|127\.0\.0\.1|${MSB_IP}|" etc/conf/restclient.json
cat etc/conf/restclient.json

# Set self IP
sed -i "s|127\.0\.0\.1|`hostname -i`|" etc/adapterInfo/resmgradapterinfo.json
cat etc/adapterInfo/resmgradapterinfo.json
