#!/bin/sh

DATE_TIME=`date '+%Y%m%d%H%M%S'`

USER_NAME=`id --user --name`
GROUP_NAME=`id --user --name`

RUN_DIR=`dirname $0`
if test -z "$RUN_DIR" \
        -o "$RUN_DIR" = "."
then
    RUN_DIR=`pwd`
fi

LOG_FILE="$RUN_DIR/${DATE_TIME}_infrastructure.log"

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
     2>&1 \
    | tee "$LOG_FILE" \
    || exit 4
EXIT_CODE=$?
if test $EXIT_CODE -ne 0
then
    exit 4
fi

#
# Now grab the kubeconfig.json for the cluster.
#
rm -f "$RUN_DIR/kubeconfig.json"
sudo docker run --mount type=bind,readonly=false,source=`pwd`,destination=/vibrant_games/infrastructure --mount type=bind,readonly=true,source=$HOME/.ssh/vibrant_games,destination=/root/.ssh/vibrant_games --env TF_VAR_do_personal_access_token=`cat ../../scrts/do_terraform_key.txt | grep -v '^$'` --env TF_VAR_do_ssh_private_key_file=/root/.ssh/vibrant_games/do_id_ed25519 --entrypoint "" hashicorp/terraform:1.0.8@sha256:c4abe7a8d7b4ae05da852d56093da3704d6684a6d560d31e3a3ab18335cf5dcf /vibrant_games/infrastructure/get_kubeconfig.sh \
    || exit 5


sudo chown -R "$USER_NAME:$GROUP_NAME" . \
    || exit 6

if test ! -f "$RUN_DIR/kubeconfig.json"
then
    echo "ERROR No kubeconfig.json was created by get_kubeconfig.sh: $RUN_DIR/kubeconfig.json"
    exit 7
fi

echo "    The kubconfig.json file can be found in:"
echo "        $RUN_DIR/kubeconfig.json"

echo ""
echo "SUCCESS Deploying production infrastructure."

exit 0
