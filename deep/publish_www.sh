#!/bin/sh

sudo echo "Testing sudo access..." \
    || exit 1

OLD_DIR=`pwd`

cd ~/development/deep/ \
    || exit 2

sudo doctl auth switch --context vibrantgames \
    || exit 3

sudo doctl registry login \
    || exit 4

configured_infrastructure_compute=kind configured_infrastructure_registry=digitalocean_container_registry configured_config_web_www_content=git@github.com:vibrant-games/docs-index.git ./application/web/www/nginx/install.sh --nowait \
    || exit 5

sudo docker tag localhost/www:0.0.1 registry.digitalocean.com/production-registry/www:0.0.1 \
    || exit 6

sudo docker push registry.digitalocean.com/production-registry/www:0.0.1 \
    || exit 7

kubectl rollout restart deployment www-v1 --namespace www --kubeconfig ~/development/vibrant_games/source/infrastructure/kubeconfig.json \
    || exit 8

cd ~/development/vibrant_games/source/infrastructure \
    || exit 9

kubectl apply --filename quick_hacks_www.yaml --kubeconfig kubeconfig.json \
    || exit 10

cd $OLD_DIR

echo "SUCCESS publishing www."

exit 0
