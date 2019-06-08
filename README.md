# kernel-notify
A program to fetch the latest kernel version on login and notify users if their kernel is no longer the latest
Updating and removing the kernel is supported on Debian based systems
If the program is broken, please file a bug report under [Issues](https://github.com/Dragon8oy/kernel-notify/issues "Issues")

## Installation:
 * Run `./install.sh`
 - ### OR:
 * Run `dpkg --build debian`
 * Run `sudo dpkg -i debian.deb`
 - ### OR:
 * Download the latest .deb from the Releases page
 * Run `sudo dpkg -i kernel-notify-x.x_all.deb`

## Packaging:
 * `dpkg --build debian`

## Updating:
 * `kernel-notify -u`
 - WARNING: Config will be reset after an update
 - If the config has changed, the old and new configs will be displayed during the update so you can re-apply configs or can be displayed any time with `kernel-notify -l`

## Help:
 * -h  | --help       : Display this page and exit
 * -u  | --update     : Update the installed program and exit
 * -v  | --version    : Display program version and exit
 * -i  | --uninstall  : Uninstall the program
 * -l  | --list-config: List old and new config values
 * -a  | --add-kernel : Install a new kernel and exit
 * -c  | --config     : Change / read a config value
 * -r  | --remove     : Remove a specific kernel version from a menu and exit
 * -s  | --silent     : Run the program without console output
 * -um | --unmute     : Unmute the program on login
 * -m  | --mute       : Mute the program on login

## Dependencies:
 * wget
 * curl
 * git (Only required for source code)
 * notify-send / libnotify4 / libnotify-bin (Not critical, highly recommended - if not used, bsdutils must be installed for wall)
 * dpkg (Used for kernel install / removal on Debian systems and program installation)

## Config:
 * Read a value:   `kernel-notify -c CFGVALUE`
 * Change a value: `kernel-notify -c CFGVALUE NEWCFGVALUE`

 - Example:
 * Change the value of 'example' to 'example-complete': `kernel-notify -c example example-complete`
