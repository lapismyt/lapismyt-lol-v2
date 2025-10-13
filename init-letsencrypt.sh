#!/bin/bash

# Initial SSL certificate setup script for Let's Encrypt
# This script should be run once before starting docker-compose

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

domains=(lapis.uno www.lapis.uno)
rsa_key_size=4096
data_path="./certbot"
email="" # Adding a valid email is strongly recommended
staging=0 # Set to 1 if you're testing your setup to avoid hitting request limits

if [ -d "$data_path" ]; then
  read -p "Existing data found for $domains. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi

if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

echo "### Stopping any running containers ..."
docker-compose down
echo

echo "### Starting nginx with temporary config for certificate acquisition ..."
docker-compose run -d --name temp-nginx --service-ports \
  -v $(pwd)/nginx/nginx-certbot.conf:/etc/nginx/nginx.conf:ro \
  nginx nginx -g "daemon off;"
echo

echo "### Waiting for nginx to start ..."
sleep 5
echo

echo "### Requesting Let's Encrypt certificate for $domains ..."
# Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

# Select appropriate email arg
case "$email" in
  "") email_arg="--register-unsafely-without-email" ;;
  *) email_arg="--email $email" ;;
esac

# Enable staging mode if needed
if [ $staging != "0" ]; then staging_arg="--staging"; fi

docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot

if [ $? -ne 0 ]; then
  echo "### Certificate acquisition failed!"
  echo "### Stopping temporary nginx ..."
  docker stop temp-nginx
  docker rm temp-nginx
  exit 1
fi

echo

echo "### Stopping temporary nginx ..."
docker stop temp-nginx
docker rm temp-nginx
echo

echo "### Starting all services with full HTTPS configuration ..."
docker-compose up -d
echo

echo "### Certificate acquisition complete!"
echo "### Your site should now be available at https://lapis.uno"
