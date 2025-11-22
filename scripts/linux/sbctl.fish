sudo sbctl create-keys
sudo sbctl enroll-keys --microsoft || exit 1
sudo sbctl status
sudo sbctl verify 
#| sed 's/✗ /sbctl sign -s /e'
#sbctl status