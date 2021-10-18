#!/bin/sh

#
# Adapted from https://github.com/ponderosa-io/tf-digital-ocean-cluster/blob/master/digital-ocean-cluster.tf
#

RUN_DIR=`dirname $0`
if test -z "$RUN_DIR" \
        -o "$RUN_DIR" = "."
then
    RUN_DIR=`pwd`
fi

ORIGINAL_DIR=`pwd`

uname -a
apk add curl \
    || exit 1

cd "$RUN_DIR" \
    || exit 1

if test -z "$TF_VAR_do_personal_access_token"
then
    echo "ERROR No Digital Ocean personal access token (TF_VAR_do_personal_access_token) environment variable set"
    exit 2
fi

CLUSTER_ID=`terraform output cluster-id \
                | sed 's|^"||' \
                | sed 's|"$||'`
echo "    Cluster ID:"
echo "        $CLUSTER_ID"
if test -z "$CLUSTER_ID"
then
    echo "ERROR Could not determine cluster-id from terraform output cluster-id" >&2
    exit 3
fi

KUBECONFIG="$RUN_DIR/kubeconfig.json"

echo "    Getting kubeconfig for $CLUSTER_ID to $KUBECONFIG..."
curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer ${TF_VAR_do_personal_access_token}" "https://api.digitalocean.com/v2/kubernetes/clusters/$CLUSTER_ID/kubeconfig" \
     > $KUBECONFIG \
    || exit 4

cd "$ORIGINAL_DIR" \
    || exit 5

echo ""
echo "SUCCESS Getting kubeconfig for $CLUSTER_ID to $KUBECONFIG"

exit 0
