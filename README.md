# kernel-notify
A program to fetch the latest kernel version on login and notify users if their kernel is no longer the latest
If the program is brogen, please file a bug report under [Issues](https://github.com/Dragon8oy/kernel-notify/issues "Issues")

## Installation:
 * Run `install.sh` to make the program start on login and use an icon
 - ### OR:
 * `dpkg --build debian`
 * `sudo dpkg -i debian.deb`

## Packaging:
 * `dpkg --build debian`

## Updating:
 * `kernel-notify -u`
 - WARNING: Config will be reset after an update, it is recommended to note down current settings first

## Help:
 * -h  | --help      : Display this page and exit
 * -u  | --update    : Update the program and exit - Please install the program before running this
 * -v  | --version   : Display program version and exit
 * -i  | --uninstall : Uninstall the program
 * -s  | --silent    : Run the program without console output
 * -um | --un-mute   : Unmute the program on login
 * -m  | --mute      : Mute the program on login
 * -c  | --config    : Change / read a config value

## Dependencies:
 * wget
 * git
 * notify-send / libnotify4 / libnotify-bin (Not critical, highly recommended)

## Config:
 * Read a value:   `kernel-notify -c CFGVALUE`
 * Change a value: `kernel-notify -c CFGVALUE NEWCFGVALUE`

 - Example:
 * Change the value of 'example' to 'example-complete': `kernel-notify -c example example-complete`
