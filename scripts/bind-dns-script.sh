#!/usr/bin/env bash
#
# Script de criação de zonas

# Variables
BIND_LOCAL='/etc/bind/named.conf.local'
ZONE_DIR='/etc/bind/zones/'
BIND_USER='bind'
NAME_SERVER_1="ns1.${USER}.com"
NAME_SERVER_2="ns2.${USER}.com"
SERIAL=$(date +"%Y%m%d")01

# Functions
ok() { echo -e '\e[32m'$1'\e[m'; } # Green

error() { echo -e '\e[1;31m'$1'\e[m'; } # Red

usage () {
  ok "[*] Usage: $0 [ -i ip ] [ -d domain ] [ -h ]"
}

# Sanity check
if [[ $EUID -ne 0 ]]
then
    error "[*] Script must be run as root"
fi

# Get arguments
while getopts ":hd:i:" option; do
  case "$option" in
    d)  DOMAIN="$OPTARG" ;;
    i)  IP="$OPTARG" ;;
    h)  usage
        exit 0 
        ;;
    :)  error "[*] Error: -$OPTARG requires an argument" 
        usage
        exit 1
        ;;
    ?)  error "[*] Error: unknown option -$OPTARG" 
        usage
        exit 1
        ;;
  esac
done   

if [[ -z "$DOMAIN" || -z "$IP" ]]; then
  error "[*] Error: you must specify a Domain Name using -d and IP Address using -i"
  usage
  exit 1
fi

# Create zones directory
mkdir -p $ZONE_DIR

# Check if exist
grep "zone \"${DOMAIN}\"" ${BIND_LOCAL} > /dev/null

if [[ 0 -eq $? ]]
then
  error "[*] Error: ${DOMAIN} is already added!" >&2
  exit 1
else

# Create zone file
  cat > ${ZONE_DIR}db.${DOMAIN} << _EOF_
\$ORIGIN ${DOMAIN}.
\$TTL 86400;    expire in 1 day.
@       IN      SOA     ${NAME_SERVER_1}. admin.${DOMAIN}. (
                        ${SERIAL}      ; serial
                        10800           ; Refresh
                        3600            ; Retry
                        604800          ; Expire
                        300             ; Negative Response TTL
                )

; DNS Servers
@               IN      NS      ${NAME_SERVER_1}.
@               IN      NS      ${NAME_SERVER_2}.

; A Records
@               IN      A       ${IP}
localhost       IN      A       127.0.0.1
host            IN      A       ${IP}
mail            IN      A       ${IP}

; MX Records
@               IN      MX 10   ${DOMAIN}.
@               IN      MX 20   mail.${DOMAIN}.

; TXT Records
@               IN      TXT     "v=spf1 a mx -all"

; Aliases
ftp             IN      CNAME   ${DOMAIN}.
_EOF_

# Add record
  cat >> ${BIND_LOCAL} << _EOF_

zone "${DOMAIN}" {
type master;
file "${ZONE_DIR}db.${DOMAIN}";
};
_EOF_

# Add reverse zone
  cat >> /etc/bind/db.10 << _EOF_

\$TTL 86400;
@      IN       SOA    ${NAME_SERVER_1}. admin.${DOMAIN}. (
		       ${SERIAL}       ; serial
                       10800           ; Refresh
                       3600            ; Retry
                       604800          ; Expire
                       300             ; Negative Response TTL
                )
;
@               IN     NS       ${NAME_SERVER_1}.
2               IN     PTR      www.${DOMAIN}.
_EOF_

fi

ok "${DOMAIN} has been successfully added."
