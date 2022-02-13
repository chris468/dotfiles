function fish_right_prompt
    function prompt-k8s-context
        type -q kubectl ; or return
        set -l context (kubectl config current-context)
        test -n $context ; or return
        echo "[k8s:$context]"
    end

    function prompt-aws-profile
        set -la aws_prompt
        if test -n $AWS_PROFILE
            set -a aws_prompt $AWS_PROFILE
        end
        if test $AWS_ACCESS_KEY_ID
            set -a aws_prompt "Key"
        end

        test "$aws_prompt" ; or return
        printf "[AWS:%s]" (string join ',' $aws_prompt)
    end

    set components (prompt-k8s-context) (prompt-aws-profile)

    string join '/' $components
end
