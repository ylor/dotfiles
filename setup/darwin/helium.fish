set extension_dir "$HOME/Library/Application Support/net.imput.helium/External Extensions"
set extension_config '{ "external_update_url": "https://services.helium.imput.net/ext" }'
set onepassword aeblfdkhhhdcdjpifhhbdiojplfjncoa
set darkreader eimadpbcbfnmbkopoojfekhnkhdbieeh
set sponsorblock mnjggcdmjocbbbhaepdhchncahnbgone

mkdir -p $extension_dir

for id in $onepassword $darkreader $sponsorblock
    set extension_file $extension_dir/$id.json

    if not test -r $extension_file; or test "$(cat $extension_file)" != "$extension_config"
        printf '%s\n' $extension_config >$extension_file
    end
end
