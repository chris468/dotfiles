set paths ~/.local/bin ~/.dotnet/tools

for path in $paths
    if test -d $path ;
        set fish_user_paths $path $fish_user_paths
    end
end

