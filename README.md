# kernel-notify
A program to fetch the latest kernel version on login and notify users if their kernel is no longer the latest
The program will work until kernel 99.99.99 is released, when it will need a minor patch

## Installation:
 * Run `install.sh` to make the program start on login and use an icon
 - ### OR:
 * `dpkg --build debian`
 * `sudo dpkg -i debian.deb`

## Packaging
 * `dpkg --build debian`

## Help:
 * -h  | --help      : Display this page and exit
 * -u  | --update    : Update the program and exit - Please install the program before attempting to run this
 * -v  | --version   : Display program version and exit
 * -i  | --uninstall : Uninstall the program
 * -um | --un-mute   : Unmute the program on boot
 * -m  | --mute      : Mute the program on boot

## Dependencies:
 * wget
 * git
 * notify-send / libnotify4 / libnotify-bin (Not critical, highly recommended)
