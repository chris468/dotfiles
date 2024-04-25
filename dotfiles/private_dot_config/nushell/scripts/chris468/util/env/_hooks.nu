export def --env "hook add" [ hook: cell-path, callback: any ] {
    $env.config = (
        $env.config | upsert $hook { |config|
            $config
                | get -i $hook
                | default []
                | append $callback
        }
    )
}

