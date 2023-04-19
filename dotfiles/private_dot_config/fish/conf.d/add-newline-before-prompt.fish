if not status is-interactive
    exit
end

function _add_newline_before_prompt --on-event fish_prompt
    echo
end

