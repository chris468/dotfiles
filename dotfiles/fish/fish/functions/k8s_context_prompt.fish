function k8s_context_prompt
    type -q kubectl ; or return
    set -l context (kubectl config current-context 2>/dev/null) ; or return
    test -n $context ; or return
    echo "[k8s:$context]"
end
