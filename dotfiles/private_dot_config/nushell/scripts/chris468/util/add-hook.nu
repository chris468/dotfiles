export def --env main [ hook: cell-path, callback: any ] {
    $env.config = (
        $env.config | upsert $hook { |config|
            $config
                | get -i $hook
                | default []
                | append $callback
        }
    )
}

