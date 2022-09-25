function decode-k8s-secret {
    local secret=$1
    local key=$2

    if [ -n "$key" ]
    then
        kubectl get secret $secret -o json | jq -r '.data."'$key'" | @base64d'
    else
        kubectl get secret $secret -o json | jq -r '.data | map_values(@base64d)'
    fi
}
