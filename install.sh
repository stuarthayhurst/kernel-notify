#!/bin/bash

uninstall() {
  read -r -p "Are you sure you want to uninstall? [y/N] " response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
    echo "Uninstalling:"
    sudo make uninstall
  fi
}

checkDeps() {
  echo "-------------------------------"
  for depSet in "$@"; do
    echo "${depSet^} dependencies:"; echo ""
    while read -r line; do
      if [[ "$line" == *"$depSet"* ]]; then
        depName="${line%%,*}" #Get first value
        depCommand="${line/$depName,}" #Remove depName
        depCommand="${depCommand%%,*}" #Remove everything after depCommand
        depAuthority="${line/$depName,}" #Remove depName
        depAuthority="${depAuthority//$depCommand,}" #Remove depCommand
        depAuthority="${depAuthority%%,*}" #Remove everything after depAuthority
        if bash -c "$depCommand" > /dev/null 2>&1; then #Check if the dependency is present
          echo "$depName found"
        else
          if [[ "$depAuthority" == "mandatory" ]]; then
            echo "$depName not found"
            missingDeps+=", $depName"
          else
            echo "$depName not found, dependency optional so not fatal"
            missingDepsOptional+=", $depName"
          fi
        fi
      fi
    done < src/lists/dependencies.list
    if [[ "$missingDeps" != "" ]]; then
      missingDeps=${missingDeps/,}
      echo -e "\nMissing $depSet dependencies:$missingDeps"
      cancelInstall="true"
      unset missingDeps
    elif [[ "$missingDepsOptional" != "" ]]; then
      echo ""
    fi
    if [[ "$missingDepsOptional" != "" ]]; then
      missingDepsOptional=${missingDepsOptional/,}
      echo -e "Missing optional $depSet dependencies:$missingDepsOptional"
      unset missingDepsOptional
    fi
    echo ""; echo "-------------------------------"
  done
  if [[ "$cancelInstall" == "true" ]]; then
    echo "Some dependencies are missing"
    exit 1
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
  if ! make test; then
    exit 1
  fi
  sudo dpkg -i "./dist/kernel-notify-${currVersion}_all.deb"
  make clean
}

makeAssist() {
  if [[ -f "/tmp/remove-kernel-notify-autostart" ]]; then
    rm "/tmp/remove-kernel-notify-autostart"
    if [[ -f "/etc/xdg/autostart/kernel-notify.desktop" ]]; then
      rm "/etc/xdg/autostart/kernel-notify.desktop"
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
    if command -v update-desktop-database > /dev/null; then
    echo "Updating desktop-file-utils"; update-desktop-database > /dev/null
  fi
  if command -v gtk-update-icon-cache > /dev/null; then
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
  -b|--build) checkDeps "build"; make dist; exit;;
  -i|--install) make build; sudo make install; exit;;
  -u|--uninstall) uninstall; exit;;
  -d|--debian) installDebian; exit;;
  -D|--dependencies) checkDeps "runtime" "build" "icon"; exit;;
  -x|--update-version) updateVersion "$buildVersion"; exit;;
  --make-assist) makeAssist; exit;;
  *) echo "Unknown parameter passed: $1"; exit 1;;
esac; shift; done

checkDeps "runtime" "build"
make build; sudo make install;
