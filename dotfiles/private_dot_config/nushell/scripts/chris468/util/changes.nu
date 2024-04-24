export def main [
    original, 
    updated
] {
    {
        updates: ($updated
            | reject ...($updated
                | columns 
                | where { |it| ($updated | get $it) == ($original | get -i $it) }
            )
        )

        deletes: ($original
            | columns
            | where { $in not-in ($updated | columns) }
        )
    }
}
