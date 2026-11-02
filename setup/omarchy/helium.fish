if not command -q helium-browser
    omarchy pkg aur add helium-browser-bin
    omarchy pkg drop chromium
end

if not grep -Fxq helium /etc/1password/custom_allowed_browsers 2>/dev/null
    sudo mkdir -p /etc/1password; or return
    printf '%s\n' helium | sudo tee --append /etc/1password/custom_allowed_browsers >/dev/null; or return
end

if test -e /etc/chromium/policies/managed/color.json
    sudo rm -f /etc/chromium/policies/managed/color.json; or return
    sudo rmdir --ignore-fail-on-non-empty /etc/chromium/policies/managed; or return
end

if not test -d /usr/share/chromium/extensions
    sudo mkdir -p /usr/share/chromium/extensions; or return
end

set extension_config '{ "external_update_url": "https://services.helium.imput.net/ext" }'
set onepassword aeblfdkhhhdcdjpifhhbdiojplfjncoa
set darkreader eimadpbcbfnmbkopoojfekhnkhdbieeh
set sponsorblock mnjggcdmjocbbbhaepdhchncahnbgone

for id in $onepassword $darkreader $sponsorblock
    set extension_file /usr/share/chromium/extensions/$id.json

    if not test -r $extension_file; or test "$(cat $extension_file)" != "$extension_config"
        printf '%s\n' $extension_config | sudo tee $extension_file >/dev/null; or return
    end

    if test (stat -c %a $extension_file) != 644
        sudo chmod 644 $extension_file; or return
    end
end
