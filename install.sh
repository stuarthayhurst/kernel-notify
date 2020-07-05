#!/bin/bash

uninstall() {
  if [[ "$USER" != "root" ]]; then
    echo "  ATTENTION: Insufficient permission, please rerun with root"
  else
    read -r -p "Are you sure you want to uninstall? [y/N] " response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
      echo "Uninstalling:"
      sudo make uninstall
    fi
  fi
}

checkDeps() {
  if [[ "$1" == *"p"* ]]; then
    echo "-------------------------------"; echo ""

    deps=("awk" "curl" "cmp" "file" "git" "grep" "less" "pkexec" "sed" "sudo")
    for i in "${deps[@]}"; do
      if which "$i" > /dev/null 2>&1; then
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

    if ldconfig -p |grep libnotify > /dev/null 2>&1; then
      echo "libnotify found"
    else
      echo "libnotify not found"
      missingProgDeps="$missingProgDeps \nlibnotify"
    fi

    if which zenity > /dev/null 2>&1; then
      echo "Zenity found"
    else
      echo "Zenity not found, required for graphical menus"
    fi
    echo ""; echo "-------------------------------"; echo ""
  fi

  if [[ "$1" == *"b"* ]] || [[ "$1" == *"i"* ]]; then
    if [[ "$1" == *"i"* ]]; then
      buildDeps=("g++" "inkscape" "optipng" "pkg-config" "sed")
    else
      buildDeps=("g++" "pkg-config" "sed")
    fi
    for i in "${buildDeps[@]}"; do
      if which "$i" > /dev/null 2>&1; then
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

updateVersion() {
  if [[ "$1" != "" ]]; then
    newVersion="$1"
    echo "Building package v$buildVersion:"
  else
    echo "Enter the new version number:"
    read -r newVersion
  fi
  if [[ "$newVersion" == "" ]]; then
    echo "No new version entered, exiting"
    exit
  fi

  if [[ "$1" == "" ]]; then
    echo "Building package:"
  fi
  read -r -p "Update manpage date? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    manDate=$(date "+%B %Y")
    sed "s|Built: .*|Built: $manDate\" \"Version: $newVersion\" \"kernel-notify man page\"|" docs/kernel-notify.1 > docs/kernel-notify.1.temp
    mv -v docs/kernel-notify.1.temp docs/kernel-notify.1
  fi
  sed "s|.*version=\".*|version=\"$newVersion\"|" src/kernel-notify > src/kernel-notify.temp
  mv -v src/kernel-notify.temp src/kernel-notify
  chmod +x src/kernel-notify
  sed "s|.*Version=.*|Version=$newVersion|" src/kernel-notify.desktop > src/kernel-notify.desktop.temp
  mv -v src/kernel-notify.desktop.temp src/kernel-notify.desktop
  sed "s|.*Version:.*|Version: $newVersion|" src/debian/DEBIAN/control > src/debian/DEBIAN/control.temp
  mv -v src/debian/DEBIAN/control.temp src/debian/DEBIAN/control
}

installDebian() {
  make dist
  currVersion="$(sed -n '5p' "src/kernel-notify.desktop")"
  currVersion=${currVersion//Version=}
  sudo dpkg -i "./dist/kernel-notify-${currVersion}_all.deb"
  make clean
}

makeAssist() {
  if [[ -f "/usr/share/kernel-notify/kernel-notify.desktop.old" ]]; then
    autostartEnabled="$(grep "X-GNOME-Autostart-enabled=" "/usr/share/kernel-notify/kernel-notify.desktop.old" |grep -v "#")"
    autostartEnabled="${autostartEnabled//X-GNOME-Autostart-enabled=}"
    if [ "$autostartEnabled" == "false" ]; then
      autostartFile="/etc/xdg/autostart/kernel-notify.desktop"
      sed "s|X-GNOME-Autostart-enabled=true|X-GNOME-Autostart-enabled=false|" "$autostartFile" > "/tmp/kernel-notify-autostart-debian.desktop.temp"
      mv "/tmp/kernel-notify-autostart-debian.desktop.temp" "$autostartFile"
    fi
  fi
  if [ -f /usr/share/kernel-notify/config.old ] && ! diff /usr/share/kernel-notify/config /usr/share/kernel-notify/config.old > /dev/null; then
    echo "Updating config values..."
    configs=$(grep -v "#" "/usr/share/kernel-notify/config.old" |sed 's|=.*||')
    for i in $configs; do
      configValue=$(grep -v "#" "/usr/share/kernel-notify/config.old" |grep "$i" |sed 's|.*=||')
      configValue=${configValue//'"'}
      kernel-notify -c "$i" "$configValue" "silent"
    done
    echo "  ATTENTION: Config updated, run 'kernel-notify -o' to view the old config"
  fi
    if which update-desktop-database > /dev/null; then
    echo "Updating desktop-file-utils"; update-desktop-database > /dev/null
  fi
  if which gtk-update-icon-cache > /dev/null; then
    echo "Updating gtk-update-icon-cache"; touch /usr/share/icons/hicolor > /dev/null
    gtk-update-icon-cache -f /usr/share/icons/hicolor/ &> /dev/null
  fi
}

for i in "$@"; do
  if [[ "$i" != *"d"* ]] && [[ "$i" != *"s"* ]] && [[ "$i" != *"-"* ]]; then
    buildVersion="$i"
  fi
done

while [[ "$#" -gt 0 ]]; do case $1 in
  -h|--help) echo "Kernel-notify Copyright (C) 2020 Stuart Hayhurst"; \
  echo "This program comes with ABSOLUTELY NO WARRANTY."; \
  echo "This is free software; see the source for copying conditions."; \
  echo ""; \
  echo "Usage: ./install.sh [-OPTION]"; \
  echo "Help:"; \
  echo "-h | --help             : Display this page"; \
  echo "-b | --build            : Build the Debian package"; \
  echo "-d | --debian           : Build and install the program for Debian"; \
  echo "-i | --install          : Install the program"; \
  echo "-u | --uninstall        : Uninstall the program"; \
  echo "-D | --dependencies     : Check if dependencies are installed"; \
  echo "-x | --update-version   : Update the version of the package"; \
  echo ""; \
  echo "Program written by: Dragon8oy"; exit;;
  -b|--build) checkDeps "b"; make dist; exit;;
  -i|--install) make build; sudo make install; exit;;
  -u|--uninstall) uninstall; exit;;
  -d|--debian) installDebian; exit;;
  -D|--dependencies) checkDeps "pbi"; exit;;
  -x|--update-version) updateVersion "$buildVersion"; exit;;
  --make-assist) makeAssist; exit;;
  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

checkDeps "pb"
exit
make build; sudo make install;
