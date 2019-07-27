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

buildPackage() {
  echo "Enter the new version number: (Leave blank to only build package)"
  read newVersion
  if [[ "$newVersion" == "" ]]; then
    newVersion=$(cat kernel-notify.desktop | sed -n '3p')
    newVersion=${newVersion//Version=}
    echo "Building package:"
  fi
  sed 's|.*version=".*|version="'$newVersion'"|' kernel-notify > kernel-notify.temp
  mv -v kernel-notify.temp kernel-notify
  sed 's|.*Version=.*|Version='$newVersion'|' kernel-notify.desktop > kernel-notify.desktop.temp
  mv -v kernel-notify.desktop.temp kernel-notify.desktop
  sed 's|.*version=".*|version="'$newVersion'"|' updater > updater.temp
  mv -v updater.temp updater

  debianPath="package/debian/usr/share/kernel-notify"
  sed 's|.*version=".*|version="'$newVersion'"|' $debianPath/updater > $debianPath/updater.temp
  mv -v $debianPath/updater.temp $debianPath/updater
  sed 's|.*Version:.*|Version: '$newVersion'|' package/debian/DEBIAN/control > package/debian/DEBIAN/control.temp
  mv -v package/debian/DEBIAN/control.temp package/debian/DEBIAN/control

  chmod -v +x actions
  chmod -v +x updater
  chmod -v +x kernel-notify
  chmod -v +x package/debian/usr/share/kernel-notify/updater

  if which dpkg > /dev/null 2>&1; then
    mkdir -v package/debian/usr/bin/
    mkdir -v package/debian/etc && mkdir package/debian/etc/xdg && mkdir package/debian/etc/xdg/autostart
    cp -v actions $debianPath/
    cp -v config $debianPath/
    cp -v icon.png $debianPath/
    cp -v kernel-notify.desktop $debianPath/
    cp -v kernel-notify.desktop package/debian/etc/xdg/autostart/
    cp -v kernel-notify package/debian/usr/bin/
    dpkg --build package/debian/ && mv package/debian.deb ./kernel-notify-"$newVersion"_all.deb

    rm -rfv package/debian/usr/bin/
    rm -v $debianPath/actions
    rm -v $debianPath/config
    rm -v $debianPath/icon.png
    rm -v $debianPath/kernel-notify.desktop
    rm -rfv package/debian/etc/
    echo "Done"
  else
    echo "Building Debian packages not supported on this system"
  fi
}

while [[ "$#" -gt 0 ]]; do case $1 in
  -h|--help) echo "Help:"; echo "-h  | --help      : Display this page and exit"; echo "-b  | --build     : Build and prepare the program for release"; echo "-v  | --version   : Display program version and exit"; echo "-ui | --uninstall : Uninstall the program"; echo ""; echo "Program written by: Dragon8oy"; exit;;
  -ui|--uninstall) echo "Are you sure you want to uninstall?"; echo "Use 'apt-get remove kernel-notify' for .deb installs"; uninstall; exit;;
  -v|--version) ./kernel-notify -v; exit;;
  -b|--build) buildPackage; exit;;
  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

if which curl > /dev/null 2>&1; then
  echo "Curl found"
else
  echo "Curl not installed, exiting"
  exit
fi
if which notify-send > /dev/null 2>&1; then
  echo "Notify-send found"
else
  echo "Notify-send not installed"
  exit
fi

sudo cp kernel-notify /usr/bin/kernel-notify
if [ -d "/usr/share/kernel-notify" ]; then
  echo "/usr/share/kernel-notify was found, not creating it"
  sudo mv /usr/share/kernel-notify/config /usr/share/kernel-notify/config.old
else
  echo "/usr/share/kernel-notify not found, creating it"
  sudo mkdir /usr/share/kernel-notify
  echo "Created directory"
fi

sudo cp icon.png /usr/share/kernel-notify/icon.png
sudo cp config /usr/share/kernel-notify/config
sudo cp kernel-notify.desktop /usr/share/kernel-notify/kernel-notify.desktop
sudo cp updater /usr/share/kernel-notify/updater
sudo cp actions /usr/share/kernel-notify/actions
echo "Installed app files"

kernel-notify -o
kernel-notify -v

echo "Successfully installed / updated program"
