function decode-k8s-secret --argument-names secret key
    kubectl get secret $secret -o json | jq -r '.data."'$key'" | @base64d'
end
