function aws_profile_prompt
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


