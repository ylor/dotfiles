# clear dock
defaults write "com.apple.dock" "persistent-apps"
defaults write "com.apple.dock" "persistent-others"

# add folders
for folder in "/Applications" "${HOME}/Downloads"; do
	# key:
	## <arrangement>
	###   1 -> Name
	###   3 -> Date Modified
	###   2 -> Date Added
	###   4 -> Date Created
	###   5 -> Kind
	# <displayas>
	###   0 -> Stack
	###   1 -> Folder
	## <showas>
	###   0 -> Automatic
	###   1 -> Fan
	###   2 -> Grid
	###   3 -> List
	defaults write com.apple.dock persistent-others -array-add "<dict>
        <key>tile-data</key>
        <dict>
            <key>arrangement</key>
            <integer>1</integer>
            <key>displayas</key>
            <integer>1</integer>
            <key>file-data</key>
            <dict>
                <key>_CFURLString</key>
                <string>file://${folder}/</string>
                <key>_CFURLStringType</key>
                <integer>15</integer>
            </dict>
            <key>file-type</key>
            <integer>3</integer>
            <key>showas</key>
            <integer>0</integer>
        </dict>
        <key>tile-type</key>
        <string>directory-tile</string>
    </dict>"
done
