set paths ~/.local/bin ~/.dotnet/tools ~/.linuxbrew/bin

for path in $paths
    if test -d $path ;
        set fish_user_paths $path $fish_user_paths
    end
end

