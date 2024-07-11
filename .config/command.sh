#!/bin/sh

# Initialize skipDev flag
skipDev=false

# Loop through all arguments
for arg in "$@"
do
  if [ "$arg" = "skipDev" ]; then
    skipDev=true
    break
  fi
done

if ! [ -d "/radar/.config/certs" ]; then
    mkdir /radar/.config/certs
    echo "[ req ]\n\
    prompt = no\n\
    distinguished_name = req_distinguished_name\n\n\
    [ req_distinguished_name ]\n\
    C = EN\n\
    ST = City\n\
    L = City\n\
    O = VATSIM Radar\n\
    OU = Radar\n\
    CN = radar\n\
    emailAddress = radar@foo.bar" > /radar/.config/certs/openssl.cnf
    openssl genrsa -out /radar/.config/certs/server.key 4096
    openssl req -config /radar/.config/certs/openssl.cnf -new -key /radar/.config/certs/server.key -out /radar/.config/certs/server.csr
    openssl x509 -req -days 4096 -in /radar/.config/certs/server.csr -signkey /radar/.config/certs/server.key -out /radar/.config/certs/server.crt
fi

cd /radar
yarn
npx prisma generate
npx prisma migrate deployI de
rm -rf /tmp/nitro/worker-*

# Conditionally execute based on skipDev flag
if [ "$skipDev" = true ]; then
  echo "Parameter skipDev provided, skipping yarn dev"
else
  echo "No skipDev parameter provided, running yarn dev"
  exec yarn dev --qr=false
fi