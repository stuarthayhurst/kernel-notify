#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $DIR

uninstall() {
PS3='Make your choice: '
options=("Yes" "No")
  select opt in "${options[@]}"
  do
      case $opt in
          "Yes")
              echo "Uninstalling:"
              if [ -f /etc/xdg/autostart/kernel-notify.desktop ]; then
                sudo rm /etc/xdg/autostart/kernel-notify.desktop
              fi
              sudo rm /usr/bin/kernel-notify
              sudo rm -rf /usr/share/kernel-notify
              echo "Done"
              break
              ;;
          "No")
              exit
              ;;
          *) echo "invalid option $REPLY";;
      esac
  done
}

prepareRelease() {
  debianPath="debian/usr/share/kernel-notify"
  echo "Enter the new version number: (Leave blank to only build packages)"
  read newVersion
  sed 's|.*version=".*|version="'$newVersion'"|' kernel-notify > kernel-notify.temp
  mv kernel-notify.temp kernel-notify
  sed 's|.*Version=.*|Version='$newVersion'|' kernel-notify.desktop > kernel-notify.desktop.temp
  mv kernel-notify.desktop.temp kernel-notify.desktop
  sed 's|.*version=".*|version="'$newVersion'"|' updater > updater.temp
  mv updater.temp updater
  sed 's|.*version=".*|version="'$newVersion'"|' $debianPath/updater > $debianPath/updater.temp
  mv $debianPath/updater.temp $debianPath/updater
  sed 's|.*Version:.*|Version: '$newVersion'|' debian/DEBIAN/control > debian/DEBIAN/control.temp
  mv debian/DEBIAN/control.temp debian/DEBIAN/control

  chmod +x actions
  chmod +x updater
  chmod +x kernel-notify
  chmod +x debian/usr/share/kernel-notify/updater
  chmod +x debian/usr/bin/kernel-notify

  cp config $debianPath/
  cp icon.jpg $debianPath/
  cp actions $debianPath/
  cp kernel-notify.desktop $debianPath/
  cp kernel-notify debian/usr/bin/
  dpkg --build debian/ && mv debian.deb kernel-notify-"$newVersion"_all.deb
}

while [[ "$#" -gt 0 ]]; do case $1 in
  -h|--help) echo "Help:"; echo "-h  | --help      : Display this page and exit"; echo "-b  | --build     : Build and prepare the program for release"; echo "-v  | --version   : Display program version and exit"; echo "-ui | --uninstall : Uninstall the program"; echo ""; echo "Program written by: Dragon8oy"; exit;;
  -ui|--uninstall) echo "Are you sure you want to uninstall?"; echo "Use 'apt-get remove kernel-notify' for .deb installs"; uninstall; exit;;
  -v|--version) ./kernel-notify -v; exit;;
  -b|--build) prepareRelease; exit;;
  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if which curl; then
  echo "Curl found"
else
  echo "Curl not installed, exiting"
  exit
fi
if which notify-send; then
  echo "Notify-send found"
else
  echo "Notify-send not installed"
  exit
fi

#Move kernel-notify to /usr/bin/kernel-notify
sudo cp kernel-notify /usr/bin/kernel-notify

#Make /usr/share/kernel-notify
if [ -d "/usr/share/kernel-notify" ]; then
  echo "/usr/share/kernel-notify was found, not creating it"
  sudo mv /usr/share/kernel-notify/config /usr/share/kernel-notify/config.old
else
  echo "/usr/share/kernel-notify not found, creating it"
  sudo mkdir /usr/share/kernel-notify
  echo "Created directory"
fi

kernel-notify -o

sudo cp icon.jpg /usr/share/kernel-notify/icon.jpg
sudo cp config /usr/share/kernel-notify/config
sudo cp kernel-notify.desktop /usr/share/kernel-notify/kernel-notify.desktop
sudo cp updater /usr/share/kernel-notify/updater
sudo cp actions /usr/share/kernel-notify/actions
echo "Installed app files"

kernel-notify -v

echo "Successfully installed / updated program"
