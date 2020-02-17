#!/bin/bash
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
source functions

buildNotifications() {
  if ! g++ --version > /dev/null 2>&1; then
    echo "g++ not found, required to build notifications"
    exit
  fi
  if ! ls /usr/include/libnotify/notify.h > /dev/null 2>&1; then
    echo "libnotify-dev not found, required to build notifications"
    exit
  fi
  if g++ notifications.cc -o notifications `pkg-config --cflags --libs libnotify`; then
    echo "g++: built notifications"
  else
    echo "  ATTENTION: g++: failed to build notifications"
  fi
}

compressIcons() {
  for filename in ./icons/*.png; do
    optipng -o7 -zm1-9 -strip all "$filename"
  done
  if [ -f "icons/kernel-notify.png" ]; then
    cp icons/kernel-notify.png docs/icon.png
  fi
}

checkDeps() {
  if [[ "$1" == *"p"* ]]; then
    echo "-------------------------------"; echo ""

    deps=("awk curl cmp grep pkexec sed sudo")
    for i in $deps; do
      if which $i > /dev/null 2>&1; then
        echo "${i^} found"
      else
        echo "${i^} not found"
        missingProgDeps="$missingProgDeps \n${i^}"
      fi
    done

    if which fuser > /dev/null 2>&1; then
      echo "Psmisc found"
    else
      echo "Psmisc not found"
      missingProgDeps="$missingProgDeps \nPsmisc"
    fi

    if which w > /dev/null 2>&1; then
      echo "Procps found"
    else
      echo "Procps not found"
      missingProgDeps="$missingProgDeps \nProcps"
    fi

    if which zenity > /dev/null 2>&1; then
      echo "Zenity found"
    else
      echo "Zenity not found, required for graphical menus"
    fi
    echo ""; echo "-------------------------------"; echo ""
  fi

  if [[ "$1" == *"b"* ]]; then
    buildDeps=("g++ sed optipng")
    for i in $buildDeps; do
      if which $i > /dev/null 2>&1; then
        echo "${i^} found"
      else
        echo "${i^} not found"
        missingBuildDeps="$missingBuildDeps \n${i^}"
      fi
    done

    if ls /usr/include/libnotify/notify.h > /dev/null 2>&1; then
      echo "libnotify-dev found"
    else
      echo "libnotify-dev not found"
      missingBuildDeps="$missingBuildDeps \nlibnotify-dev"
    fi

    echo ""; echo "-------------------------------"; echo ""
  fi

    if [[ "$missingProgDeps" != "" ]] || [[ "$missingBuildDeps" != "" ]]; then
      if [[ "$missingBuildDeps" != "" ]]; then
        echo -e "Build dependencies:$missingBuildDeps\n"
        if [[ "$missingProgDeps" == "" ]]; then
          echo -e "Weren't found, exiting"
          echo ""; echo "-------------------------------"; echo ""
        fi
      fi
      if [[ "$missingProgDeps" != "" ]]; then
        echo -e "Program dependencies:$missingProgDeps \n\nWeren't found, exiting"
        echo ""; echo "-------------------------------"; echo ""
      fi
      exit
    fi
}

uninstall() {
  if [[ "$USER" != "root" ]]; then
    echo "  ATTENTION: Insufficient permission, please rerun with root"
  else
    read -r -p "Are you sure you want to uninstall? [y/N] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
      echo "Uninstalling:"
      if dpkg -s kernel-notify | grep Status |grep -q installed; then
        echo "Kernel-notify installed via .deb, removing"
        checkDpkg
        dpkg -r kernel-notify
        exit
      else
        uninstallList=$(cat ./uninstall-list)
        for filename in $uninstallList; do
          if [ -f $filename ]; then
            rm -rfv "$filename"
        fi
        done
        echo "Done"; exit
      fi
    fi
  fi
}

buildPackage() {
  echo "Enter the new version number: (Leave blank to only build package)"
  read newVersion
  compressIcons
  if [[ "$newVersion" == "" ]]; then
    newVersion=$(cat kernel-notify.desktop | sed -n '5p')
    newVersion=${newVersion//Version=}
    echo "Building package:"
  fi
  read -r -p "Update manpage date? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    manDate=$(date "+%B %Y")
    sed "s|Built: .*|Built: \"$manDate\" \"Version: $newVersion\" \"kernel-notify man page\"|" docs/kernel-notify.1 > docs/kernel-notify.1.temp
    mv -v docs/kernel-notify.1.temp docs/kernel-notify.1
  fi
  sed "s|.*version=\".*|version=\"$newVersion\"|" kernel-notify > kernel-notify.temp
  mv -v kernel-notify.temp kernel-notify
  sed "s|.*Version=.*|Version=$newVersion|" kernel-notify.desktop > kernel-notify.desktop.temp
  mv -v kernel-notify.desktop.temp kernel-notify.desktop

  sed "s|.*Version:.*|Version: $newVersion|" package/debian/DEBIAN/control > package/debian/DEBIAN/control.temp
  mv -v package/debian/DEBIAN/control.temp package/debian/DEBIAN/control

  chmod -v +x actions
  chmod -v +x updater
  chmod -v +x kernel-notify

  if which dpkg > /dev/null 2>&1; then
    debianPath="package/debian/usr/share/kernel-notify"
    iconPath="package/debian/usr/share/icons/hicolor"
    mkdir -v package/debian/usr && mkdir -v package/debian/usr/share && mkdir -v package/debian/usr/share/kernel-notify && mkdir -v package/debian/usr/share/applications && mkdir -v package/debian/usr/share/man && mkdir -v package/debian/usr/share/man/man1
    mkdir -v package/debian/usr/bin
    mkdir -v package/debian/etc && mkdir -v package/debian/etc/xdg && mkdir -v package/debian/etc/xdg/autostart
    mkdir -v package/debian/usr/share/icons && mkdir -v package/debian/usr/share/icons/hicolor && mkdir -v package/debian/usr/share/icons/hicolor/scalable && mkdir -v package/debian/usr/share/icons/hicolor/scalable/apps && mkdir -v package/debian/usr/share/icons/hicolor/256x256 && mkdir -v package/debian/usr/share/icons/hicolor/256x256/apps

    buildNotifications
    chmod +x notifications
    gzip -kqv9 docs/kernel-notify.1 docs/kernel-notify.1.gz

    cp -v actions $debianPath/
    cp -v config $debianPath/
    cp -v docs/kernel-notify.1.gz package/debian/usr/share/man/man1/
    cp -v functions $debianPath/
    cp -v kernel-notify.desktop package/debian/etc/xdg/autostart/
    cp -v kernel-notify.desktop package/debian/usr/share/applications/
    cp -v kernel-notify package/debian/usr/bin/
    cp -v notifications $debianPath/
    cp -v notifications.cc $debianPath/
    cp -v updater $debianPath/

    cp -v icons/kernel-notify.svg $iconPath/scalable/apps/
    cp -v icons/kernel-notify-app.svg $iconPath/scalable/apps/
    cp -v icons/kernel-notify.png $iconPath/256x256/apps/
    cp -v icons/kernel-notify-app.png $iconPath/256x256/apps/

    sed "s|.*Exec=.*|Exec=kernel-notify -zw|" package/debian/usr/share/applications/kernel-notify.desktop > package/debian/usr/share/applications/kernel-notify.desktop.temp
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

installPackage() {
  if [[ "$USER" != "root" ]]; then
    echo "  ATTENTION: Insufficient permission, please rerun with root"
  else
    cp kernel-notify /usr/bin/kernel-notify
    if [ -d "/usr/share/kernel-notify" ]; then
      echo "/usr/share/kernel-notify found"
      mv /usr/share/kernel-notify/config /usr/share/kernel-notify/config.old
    else
      echo "/usr/share/kernel-notify not found, creating it"
      mkdir /usr/share/kernel-notify
      echo "Created program directory"
    fi

    buildNotifications

    if [ -d "/etc/xdg/autostart" ]; then
      cp kernel-notify.desktop /etc/xdg/autostart/kernel-notify.desktop
    fi

    chmod +x kernel-notify
    chmod +x notifications
    chmod +x actions
    chmod +x updater

    if [ -d "/usr/share/man/man1/" ]; then
      gzip -kqv9 docs/kernel-notify.1 docs/kernel-notify.1.gz
      cp -v docs/kernel-notify.1.gz /usr/share/man/man1/
      rm -v docs/kernel-notify.1.gz
    fi

    cp -v actions /usr/share/kernel-notify/actions
    cp -v config /usr/share/kernel-notify/config
    cp -v functions /usr/share/kernel-notify/functions
    cp -v updater /usr/share/kernel-notify/updater
    cp -v uninstall-list /usr/share/kernel-notify/uninstall-list
    mv -v notifications /usr/share/kernel-notify/notifications

    if [ -d "/usr/share/icons/hicolor/scalable/apps/" ]; then
      cp -v icons/kernel-notify.png /usr/share/icons/hicolor/scalable/apps/kernel-notify.svg
      cp -v icons/kernel-notify-app.png /usr/share/icons/hicolor/scalable/apps/kernel-notify-app.svg
    fi
    if [ -d "/usr/share/icons/hicolor/256x256/apps/" ]; then
      cp -v icons/kernel-notify.png /usr/share/icons/hicolor/512x512/apps/kernel-notify.png
      cp -v icons/kernel-notify-app.png /usr/share/icons/hicolor/256x256/apps/kernel-notify-app.png
    fi

    sed "s|.*Exec=.*|Exec=kernel-notify -zw|" kernel-notify.desktop > kernel-notify.desktop.temp
    mv -v kernel-notify.desktop.temp /usr/share/applications/kernel-notify.desktop

    echo "Installed program files"

    if [ -f /usr/share/kernel-notify/config.old ] && ! diff /usr/share/kernel-notify/config /usr/share/kernel-notify/config.old > /dev/null; then
      echo "Updating config values..."
      configs=$(cat /usr/share/kernel-notify/config.old |grep -v "#" |sed 's|=.*||')
      for i in $configs; do
        configValue=$(cat /usr/share/kernel-notify/config.old |grep -v "#" |grep "$i" |sed 's|.*=||')
        configValue=${configValue//'"'}
        kernel-notify -c "$i" "$configValue"
      done
      echo "  ATTENTION: Config updated, run 'kernel-notify -o' to view the old config"
    fi

    echo ""; echo "-------------------------------"; echo ""

    if kernel-notify -v; then
      echo ""; echo "Successfully installed / updated kernel-notify"
    else
      echo ""; echo "  ATTENTION: Installing / updating kernel-notify failed"
    fi
  fi
}

while [[ "$#" -gt 0 ]]; do case $1 in
  -h|--help) echo "Kernel-notify Copyright (C) 2020 Stuart Hayhurst"; echo "This program comes with ABSOLUTELY NO WARRANTY."; echo "This is free software; see the source for copying conditions."; echo ""; echo "Usage: ./install.sh [-OPTION]"; echo "Help:"; echo "-h | --help          : Display this page"; echo "-b | --build         : Build and prepare the program for release"; echo "-d | --debian        : Build the .deb and install"; echo "-v | --version       : Display program version"; echo "-u | --uninstall     : Uninstall the program"; echo "-c | --compress      : Compress icons"; echo "-n | --notifications : Build the notifications"; echo "-D | --dependencies  : Check if dependencies are installed"; echo ""; echo "Program written by: Dragon8oy"; exit;;
  -u|--uninstall) uninstall; exit;;
  -n|--notifications) buildNotifications; exit;;
  -D|--dependencies) checkDeps "pb"; exit;;
  -c|--compress) compressIcons; exit;;
  -v|--version) ./kernel-notify -v; exit;;
  -d|--debian) checkDeps "b"; buildPackage; echo "Installing package:"; sudo dpkg -i "kernel-notify-${newVersion}_all.deb"; exit;;
  -b|--build) checkDeps "b"; buildPackage; exit;;
  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

checkDeps "pb"
installPackage
