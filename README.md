# kernel-notify
 - A program to fetch the latest kernel version on login and notify users if their kernel is no longer the latest
 - Updating and removing the kernel is supported on systems with dpkg installed
 - If you have an issue, please file a bug report under [Issues](https://github.com/Dragon8oy/kernel-notify/issues "Issues")
 - GitHub Link: https://github.com/Dragon8oy/kernel-notify
 - The master branch is usually unstable, refer to the releases page for stable releases
 - 'kernel-notify -l' is know to fail on a Raspberry Pi / Raspbian

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
 - If the config has changed, the old and new configs will be displayed during the update so you can re-apply configs, or can be displayed any time with `kernel-notify -o`

## Notes:
 * The program sending update notifications can be toggled with `kernel-notify --mute` and `kernel-notify --unmute`
 * The program and kernel can be automatically updated if autoupdate is set to 1 in the config
 * On .deb installation, the package will attempt to rebuild the notifications program if the architecture is not amd64

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
 * gawk & sed
 * psmisc & policykit-1
 * libnotify4
 * zenity
 * libnotify-dev & libgtk-3-dev & g++ (Used in package building (.deb), installing and updating (source) or package install (Non-amd46))
 * dpkg (Used in package building and program + kernel installation / removal)

## Config:
 * Read a value:   `kernel-notify -c CFGOPTION`
 * Change a value: `kernel-notify -c CFGOPTION NEWCFGVALUE`
 * The config can also be changed by editing `/usr/share/kernel-notify/config`

 - Example:
 * Change the value of 'example' to 'example-complete': `kernel-notify -c example example-complete`
