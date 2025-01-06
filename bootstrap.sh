# Installs haosu/.files configuration on what is assumed to be a brand-new machine.
#
# Execute by running:
#
#   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/haosu/.files/HEAD/bootstrap.sh)"

# Halt on first failed command
set -e

# Map Caps Lock to Left-Ctrl
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0}]}' >/dev/null

# Persist mapping across reboots
# See https://hidutil-generator.netlify.app/
mkdir -p ~/Library/LaunchAgents
cat - <<EOF > ~/Library/LaunchAgents/com.local.CapsLockLeftControlRemapping.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.local.KeyRemapping</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/hidutil</string>
        <string>property</string>
        <string>--set</string>
        <string>{"UserKeyMapping":[
            {
              "HIDKeyboardModifierMappingSrc": 0x700000039,
              "HIDKeyboardModifierMappingDst": 0x7000000E0
            },
            {
              "HIDKeyboardModifierMappingSrc": 0x7000000E0,
              "HIDKeyboardModifierMappingDst": 0x700000029
            }
        ]}</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
EOF

# Install Homebrew (which takes care of Xcode CLI tools, including git)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to the path temporarily (install script will make it permanent)
export PATH="/opt/homebrew/bin:$PATH"

# Clone repo. Use HTTPS since we don't have SSH set up yet
git clone https://github.com/haosu/.files.git ~/.files

cd ~/.files

# Switch repo to use SSH going forward (we'll have SSH set up soon)
git remote remove origin >/dev/null 2>&1
git remote add origin git@github.com:haosu/.files

# Replace this script with the install script and execute it
exec ./install
