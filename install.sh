#!/bin/bash
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )

uninstall() {
  read -r -p "Are you sure you want to uninstall? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    echo "Uninstalling:"
    if dpkg -s kernel-notify | grep Status |grep -q installed; then
      checkDpkg
      sudo dpkg -r kernel-notify
      exit
    else
      if [ -f /etc/xdg/autostart/kernel-notify.desktop ]; then
        sudo rm /etc/xdg/autostart/kernel-notify.desktop
      fi
      if [ -f /usr/share/applications/kernel-notify.desktop ]; then
        sudo rm /usr/share/applications/kernel-notify.desktop
      fi
      if [ -f /usr/share/man/man1/kernel-notify.1.gz ]; then
        sudo rm /usr/share/man/man1/kernel-notify.1.gz
      fi
      if [ -f /usr/share/man/man1/kernel-notify.1 ]; then
        sudo rm /usr/share/man/man1/kernel-notify.1
      fi
      sudo rm /usr/bin/kernel-notify
      sudo rm -rf /usr/share/kernel-notify
      echo "Done"
      exit
    fi
  fi
}

buildPackage() {
  echo "Enter the new version number: (Leave blank to only build package)"
  read newVersion
  checkBuildDeps
  if [[ "$newVersion" == "" ]]; then
    newVersion=$(cat kernel-notify.desktop | sed -n '5p')
    newVersion=${newVersion//Version=}
    echo "Building package:"
  fi
  sed "s|.*version=\".*|version=\"$newVersion\"|" kernel-notify > kernel-notify.temp
  mv -v kernel-notify.temp kernel-notify
  sed "s|.*Version=.*|Version=$newVersion|" kernel-notify.desktop > kernel-notify.desktop.temp
  mv -v kernel-notify.desktop.temp kernel-notify.desktop
  manDate=$(date "+%B %Y")
  sed "s|Built: .*|Built: \"$manDate\" \"Version: $newVersion\" \"kernel-notify man page\"|" docs/kernel-notify.1 > docs/kernel-notify.1.temp
  mv -v docs/kernel-notify.1.temp docs/kernel-notify.1

  sed "s|.*Version:.*|Version: $newVersion|" package/debian/DEBIAN/control > package/debian/DEBIAN/control.temp
  mv -v package/debian/DEBIAN/control.temp package/debian/DEBIAN/control

  chmod -v +x actions
  chmod -v +x updater
  chmod -v +x kernel-notify

  if which dpkg > /dev/null 2>&1; then
    debianPath="package/debian/usr/share/kernel-notify"
    mkdir -v package/debian/usr && mkdir -v package/debian/usr/share && mkdir -v package/debian/usr/share/kernel-notify && mkdir -v package/debian/usr/share/applications && mkdir -v package/debian/usr/share/man && mkdir -v package/debian/usr/share/man/man1
    mkdir -v package/debian/usr/bin
    mkdir -v package/debian/etc && mkdir -v package/debian/etc/xdg && mkdir -v package/debian/etc/xdg/autostart

    buildNotifications
    chmod +x notifications
    gzip -kqv9 docs/kernel-notify.1 docs/kernel-notify.1.gz

    cp -v actions $debianPath/
    cp -v config $debianPath/
    cp -v icon.png $debianPath/
    cp -v notifications $debianPath/
    cp -v notifications.cc $debianPath/
    cp -v docs/kernel-notify.1.gz package/debian/usr/share/man/man1/
    cp -v kernel-notify.desktop package/debian/etc/xdg/autostart/
    cp -v kernel-notify.desktop package/debian/usr/share/applications/
    cp -v kernel-notify package/debian/usr/bin/
    cp -v updater $debianPath/
    sed 's|.*Exec=.*|Exec='"kernel-notify -zw"'|' package/debian/usr/share/applications/kernel-notify.desktop > package/debian/usr/share/applications/kernel-notify.desktop.temp
    mv -v package/debian/usr/share/applications/kernel-notify.desktop.temp package/debian/usr/share/applications/kernel-notify.desktop
    dpkg --build package/debian/ && mv package/debian.deb ./kernel-notify-"$newVersion"_all.deb

    rm -v notifications
    rm -v docs/kernel-notify.1.gz
    rm -rfv package/debian/etc/
    rm -rfv package/debian/usr/
    echo "Done"
  else
    echo "Building Debian packages not supported on this system"
    exit
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
  if which sed > /dev/null 2>&1; then
    echo "Sed found"
  else
    echo "Sed not installed, exiting"
    exit
  fi
  if which awk > /dev/null 2>&1 || which gawk > /dev/null 2>&1; then
    echo "Awk found"
  else
    echo "Awk not installed, exiting"
    exit
  fi
  if which fuser > /dev/null 2>&1; then
    echo "Psmisc found"
  else
    echo "Psmisc not installed, exiting"
    exit
  fi
  if which zenity > /dev/null 2>&1; then
    echo "Zenity found"
  else
    echo "Zenity not installed, it is required for graphical menus"
  fi
  if which w > /dev/null 2>&1; then
    echo "Procps found"
  else
    echo "Procps not installed, exiting"
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
  if which sed > /dev/null 2>&1; then
    echo "Sed found"
  else
    echo "Sed not installed, exiting"
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

  if [ -d "/etc/xdg/autostart" ]; then
    sudo cp kernel-notify.desktop /etc/xdg/autostart/kernel-notify.desktop
  fi

  chmod +x kernel-notify
  chmod +x notifications
  chmod +x actions
  chmod +x updater

  if [ -d "/usr/share/man/man1/" ]; then
    gzip -kqv9 docs/kernel-notify.1 docs/kernel-notify.1.gz
    sudo cp -v docs/kernel-notify.1.gz /usr/share/man/man1/
    rm -v docs/kernel-notify.1.gz
  fi

  sudo cp icon.png /usr/share/kernel-notify/icon.png
  sudo cp config /usr/share/kernel-notify/config
  sudo cp updater /usr/share/kernel-notify/updater
  sudo cp actions /usr/share/kernel-notify/actions
  sudo mv notifications /usr/share/kernel-notify/notifications

  sed 's|.*Exec=.*|Exec='"kernel-notify -zw"'|' kernel-notify.desktop > kernel-notify.desktop.temp
  sudo mv -v kernel-notify.desktop.temp /usr/share/applications/kernel-notify.desktop

  echo "Installed program files"

  kernel-notify -o
  kernel-notify -v

  echo "Successfully installed / updated program"
}

while [[ "$#" -gt 0 ]]; do case $1 in
  -h|--help) echo "Kernel-notify Copyright (C) 2019 Stuart Hayhurst"; echo "This program comes with ABSOLUTELY NO WARRANTY."; echo "This is free software; see the source for copying conditions."; echo ""; echo "Usage: ./install.sh [-OPTION]"; echo "Help:"; echo "-h | --help          : Display this page"; echo "-b | --build         : Build and prepare the program for release"; echo "-d | --debian        : Build the .deb and install"; echo "-v | --version       : Display program version"; echo "-u | --uninstall     : Uninstall the program"; echo "-n | --notifications : Build the notifications"; echo ""; echo "Program written by: Dragon8oy"; exit;;
  -u|--uninstall) echo "Are you sure you want to uninstall?"; echo "Use 'apt-get remove kernel-notify' for .deb installs"; uninstall; exit;;
  -n|--notifications) buildNotifications; exit;;
  -v|--version) ./kernel-notify -v; exit;;
  -d|--debian) buildPackage; echo "Installing package:"; sudo dpkg -i kernel-notify-"$newVersion"_all.deb; exit;;
  -b|--build) buildPackage; exit;;
  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

checkDeps
installPackage
