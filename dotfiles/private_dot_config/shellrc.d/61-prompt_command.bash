function _prompt_commands {
    ret=$?
    for c in $(find ~/.config/shellrc.d/prompt_command.d -maxdepth 1 -type f -name '*.bash')
    do
        . $c
    done

    # preserve original return code so that it will display
    # properly in prompt
    return $ret
}

# Note: put at the front of the list so that it will run before
#       oh-my-posh. But note that tnis needs to be added *after*
#       oh-my-posh has already been added, becasue it also adds
#       to the front.
if ! [[ "$PROMPT_COMMAND" =~ "_prompt_commands" ]]
then
    PROMPT_COMMAND="_prompt_commands; $PROMPT_COMMAND"
fi

