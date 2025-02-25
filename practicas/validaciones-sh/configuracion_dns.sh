ip_address=$1
domain=$2

IFS='.' read -r o1 o2 o3 o4 <<< "$ip_address"
reverse_ip="${o3}.${o2}.${o1}"
last_octet="$o4"

# Instalación de Bind9
sudo apt-get update && sudo apt-get install -y bind9 bind9utils bind9-doc

# Configuración de named.conf.options
sudo tee /etc/bind/named.conf.options > /dev/null <<EOT
options {
    directory "/var/cache/bind";
    forwarders { 8.8.8.8; };
    dnssec-validation auto;
    listen-on-v6 { any; };
};
EOT

# Configuración de named.conf.local
sudo tee /etc/bind/named.conf.local > /dev/null <<EOT
zone "$domain" {
    type master;
    file "/etc/bind/db.$domain";
};

zone "$reverse_ip.in-addr.arpa" {
    type master;
    file "/etc/bind/db.${reverse_ip}";
};
EOT

# Archivos de zona
cp /etc/bind/db.127 /etc/bind/db.${reverse_ip}
sudo tee /etc/bind/db.${reverse_ip} > /dev/null <<EOT
\$TTL 604800
@   IN  SOA $domain. root.$domain. (1 604800 86400 2419200 604800)
@   IN  NS  $domain.
$last_octet IN PTR $domain.
EOT

cp /etc/bind/db.local /etc/bind/db.$domain
sudo tee /etc/bind/db.$domain > /dev/null <<EOT
\$TTL 604800
@   IN  SOA $domain. root.$domain. (2 604800 86400 2419200 604800)
@   IN  NS  $domain.
@   IN  A   $ip_address
www IN  CNAME $domain.
EOT

# Configuración de resolv.conf
sudo tee /etc/resolv.conf > /dev/null <<EOT
search $domain.
domain $domain.
nameserver $ip_address
options edns0 trust-ad
EOT

# Reinicio de Bind9 y prueba
service bind9 restart
service bind9 status
nslookup $domain
nslookup www.$domain
nslookup $ip_address