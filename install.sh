#!/bin/bash
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )

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
  checkBuildDeps
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

  sed 's|.*Version:.*|Version: '$newVersion'|' package/debian/DEBIAN/control > package/debian/DEBIAN/control.temp
  mv -v package/debian/DEBIAN/control.temp package/debian/DEBIAN/control

  chmod -v +x actions
  chmod -v +x updater
  chmod -v +x kernel-notify
  chmod -v +x updater

  if which dpkg > /dev/null 2>&1; then
    debianPath="package/debian/usr/share/kernel-notify"
    mkdir -v package/debian/usr && mkdir -v package/debian/usr/share && mkdir -v package/debian/usr/share/kernel-notify
    mkdir -v package/debian/usr/bin
    mkdir -v package/debian/etc && mkdir -v package/debian/etc/xdg && mkdir -v package/debian/etc/xdg/autostart

    buildNotifications

    cp -v actions $debianPath/
    cp -v config $debianPath/
    cp -v icon.png $debianPath/
    cp -v notifications $debianPath/
    cp -v notifications.cc $debianPath/
    cp -v kernel-notify.desktop $debianPath/
    cp -v kernel-notify.desktop package/debian/etc/xdg/autostart/
    cp -v kernel-notify package/debian/usr/bin/
    cp -v updater $debianPath/
    dpkg --build package/debian/ && mv package/debian.deb ./kernel-notify-"$newVersion"_all.deb

    rm -rfv package/debian/usr/bin/
    rm -v $debianPath/actions
    rm -v $debianPath/config
    rm -v $debianPath/icon.png
    rm -v notifications
    rm -v $debianPath/notifications
    rm -v $debianPath/notifications.cc
    rm -v $debianPath/kernel-notify.desktop
    rm -rfv package/debian/etc/
    rm -rfv package/debian/usr/
    echo "Done"
  else
    echo "Building Debian packages not supported on this system"
  fi
}

buildNotifications() {
  if g++ notifications.cc -o notifications `pkg-config --cflags --libs libnotify`; then
    echo "g++: built notifications"
  else
    echo "g++: failed to build notifications"
  fi
}

checkDeps() {
  if which curl > /dev/null 2>&1; then
    echo "Curl found"
  else
    echo "Curl not installed, exiting"
    exit
  fi
  if which pkexec > /dev/null 2>&1; then
    echo "Policykit-1 found"
  else
    echo "Policykit-1 not installed, exiting"
    exit
  fi
  if which awk > /dev/null 2>&1 || which gawk > /dev/null 2>&1; then
    echo "Gawk found"
  else
    echo "Gawk not installed, exiting"
    exit
  fi
  if which fuser > /dev/null 2>&1; then
    echo "Psmisc found"
  else
    echo "Psmisc not installed, exiting"
    exit
  fi
}

checkBuildDeps() {
  if which g++ > /dev/null 2>&1; then
    echo "G++ found"
  else
    echo "G++ not installed, exiting"
    exit
  fi
  if ls /usr/include/libnotify/notify.h > /dev/null 2>&1; then
    echo "libnotify-dev found"
  else
    echo "libnotify-dev not installed, exiting"
    exit
  fi
}

installPackage() {
  checkBuildDeps
  sudo cp kernel-notify /usr/bin/kernel-notify
  if [ -d "/usr/share/kernel-notify" ]; then
    echo "/usr/share/kernel-notify was found, not creating it"
    sudo mv /usr/share/kernel-notify/config /usr/share/kernel-notify/config.old
  else
    echo "/usr/share/kernel-notify not found, creating it"
    sudo mkdir /usr/share/kernel-notify
    echo "Created directory"
  fi

  buildNotifications

  sudo cp icon.png /usr/share/kernel-notify/icon.png
  sudo cp config /usr/share/kernel-notify/config
  sudo cp kernel-notify.desktop /usr/share/kernel-notify/kernel-notify.desktop
  sudo cp updater /usr/share/kernel-notify/updater
  sudo cp actions /usr/share/kernel-notify/actions
  sudo mv notifications /usr/share/kernel-notify/notifications
  echo "Installed app files"

  kernel-notify -o
  kernel-notify -v

  echo "Successfully installed / updated program"
}

while [[ "$#" -gt 0 ]]; do case $1 in
  -h|--help) echo "Help:"; echo "-h  | --help          : Display this page"; echo "-b  | --build         : Build and prepare the program for release"; echo "-v  | --version       : Display program version"; echo "-ui | --uninstall     : Uninstall the program"; echo "-n  | --notifications : Build the notifications"; echo ""; echo "Program written by: Dragon8oy"; exit;;
  -ui|--uninstall) echo "Are you sure you want to uninstall?"; echo "Use 'apt-get remove kernel-notify' for .deb installs"; uninstall; exit;;
  -n|--notifications) buildNotifications; exit;;
  -v|--version) ./kernel-notify -v; exit;;
  -b|--build) buildPackage; exit;;
  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

checkDeps
installPackage
