#!/bin/sh

USER_NAME=`id --user --name`
GROUP_NAME=`id --user --name`

sudo docker run --mount type=bind,readonly=false,source=`pwd`,destination=/vibrant_games/terraform hashicorp/terraform:1.0.8@sha256:c4abe7a8d7b4ae05da852d56093da3704d6684a6d560d31e3a3ab18335cf5dcf -chdir=/vibrant_games/terraform init \
    || exit 1

sudo docker run --mount type=bind,readonly=false,source=`pwd`,destination=/vibrant_games/infrastructure --mount type=bind,readonly=true,source=$HOME/.ssh/vibrant_games,destination=/root/.ssh/vibrant_games --env TF_VAR_do_personal_access_token=`cat ../../scrts/do_terraform_key.txt | grep -v '^$'` --env TF_VAR_do_ssh_private_key_file=/root/.ssh/vibrant_games/do_id_ed25519 hashicorp/terraform:1.0.8@sha256:c4abe7a8d7b4ae05da852d56093da3704d6684a6d560d31e3a3ab18335cf5dcf -chdir=/vibrant_games/infrastructure plan --out /vibrant_games/infrastructure/tfplan \
    || exit 2

sudo chown -R "$USER_NAME:$GROUP_NAME" . \
    || exit 3

#
# Add --env TF_LOG=DEBUG to turn debug logging on:
#
sudo docker run --mount type=bind,readonly=false,source=`pwd`,destination=/vibrant_games/infrastructure --mount type=bind,readonly=true,source=$HOME/.ssh/vibrant_games,destination=/root/.ssh/vibrant_games --env TF_VAR_do_personal_access_token=`cat ../../scrts/do_terraform_key.txt | grep -v '^$'` --env TF_VAR_do_ssh_private_key_file=/root/.ssh/vibrant_games/do_id_ed25519 hashicorp/terraform:1.0.8@sha256:c4abe7a8d7b4ae05da852d56093da3704d6684a6d560d31e3a3ab18335cf5dcf -chdir=/vibrant_games/infrastructure apply /vibrant_games/infrastructure/tfplan \
    || exit 4

sudo chown -R "$USER_NAME:$GROUP_NAME" . \
    || exit 5

exit 0
