# kernel-notify
 - A program to fetch the latest kernel version on login and notify users if their kernel is no longer the latest
 - Updating and removing the kernel is supported on systems with dpkg
 - If you have an issue, please file a bug report under [Issues](https://github.com/Dragon8oy/kernel-notify/issues "Issues")

## Installation:
 * Run `./install.sh`
 - ### OR:
 * Run `./install.sh -b`
 * Run `sudo dpkg -i kernel-notify-x.x_all.deb`
 - ### OR:
 * Download the latest deb from the Releases page
 * Run `sudo dpkg -i kernel-notify-x.x_all.deb`

## Packaging:
 * Run `./install.sh -b`

## Updating:
 * Run `kernel-notify -u`
 - WARNING: Config will be reset after an update
 - If the config has changed, the old and new configs will be displayed during the update so you can re-apply configs or can be displayed any time with `kernel-notify -o`

## Notes:
 * The program starting on login can be toggled with `kernel-notify --mute` and `kernel-notify --unmute`
 * The program and kernel can be automatically updated if the program is unmuted and autoupdate is set to 1 in the config

## Help:
 - ### Program Help:
   * -h  | --help       : Display the help page and exit
   * -u  | --update     : Update the program and exit
   * -v  | --version    : Display program version and exit
   * -i  | --uninstall  : Uninstall the program
   * -o  | --old-config : List old and new config values and exit
   * -c  | --config     : Change / read a config value and exit

 - ### Feature Help:
   * -r  | --remove-kernel : Remove a kernels from a menu and exit
   * -l  | --list-kernels  : List installed kernels and exit
   * -a  | --add-kernel    : Install a new kernel and exit
   * -um | --unmute        : Unmute the program on login and exit
   * -m  | --mute          : Mute the program on login and exit

## Dependencies:
 * curl
 * notify-send / libnotify4 / libnotify-bin (Used for notifications)
 * libnotify-dev (Used in package building (.deb), installing and updating (source))
 * dpkg (Used in program and kernel installation / removal)

## Config:
 * Read a value:   `kernel-notify -c CFGVALUE`
 * Change a value: `kernel-notify -c CFGVALUE NEWCFGVALUE`

 - Example:
 * Change the value of 'example' to 'example-complete': `kernel-notify -c example example-complete`
