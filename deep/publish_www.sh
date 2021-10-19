#!/bin/sh

sudo echo "Testing sudo access..." \
    || exit 1

OLD_DIR=`pwd`

cd ~/development/deep/ \
    || exit 2

sudo doctl auth switch --context vibrantgames \
    || exit 4

sudo doctl registry login \
    || exit 5

configured_infrastructure_compute=kind configured_infrastructure_registry=digitalocean_container_registry configured_config_web_www_content=git@github.com:vibrant-games/docs-index.git ./application/web/www/nginx/install.sh --nowait \
    || exit 3

sudo docker push registry.digitalocean.com/production-registry/www:0.0.1 \
    || exit 6

kubectl rollout restart deployment www-v1 --namespace www --kubeconfig ~/development/vibrant_games/source/infrastructure/kubeconfig.json \
    || exit 7

echo "SUCCESS publishing www."

exit 0
