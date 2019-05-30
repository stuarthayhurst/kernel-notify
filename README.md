# kernel-notify
A program to fetch the latest kernel version on login and notify users if their kernel is no longer the latest
If the program is broken, please file a bug report under [Issues](https://github.com/Dragon8oy/kernel-notify/issues "Issues")

## Installation:
 * Run `./install.sh`
 - ### OR:
 * `dpkg --build debian`
 * `sudo dpkg -i debian.deb`

## Packaging:
 * `dpkg --build debian`

## Updating:
 * `kernel-notify -u`
 - WARNING: Config will be reset after an update, it is recommended to note down current settings first
 - If the config has changed, the old and new configs will be displayed during the update so you can re-apply configs or can be displayed any time with `kernel-notify -l`

## Help:
 * -h  | --help      : Display this page and exit
 * -u  | --update    : Update the installed program and exit
 * -v  | --version   : Display program version and exit
 * -i  | --uninstall : Uninstall the program
 * -l  | --list-config: List old and new config values
 * -c  | --config    : Change / read a config value
 * -r  | --remove    : Remove a specific kernel version from a menu and exit
 * -s  | --silent    : Run the program without console output
 * -um | --unmute    : Unmute the program on login
 * -m  | --mute      : Mute the program on login

## Dependencies:
 * wget
 * git
 * notify-send / libnotify4 / libnotify-bin (Not critical, highly recommended)

## Config:
 * Read a value:   `kernel-notify -c CFGVALUE`
 * Change a value: `kernel-notify -c CFGVALUE NEWCFGVALUE`

 - Example:
 * Change the value of 'example' to 'example-complete': `kernel-notify -c example example-complete`
