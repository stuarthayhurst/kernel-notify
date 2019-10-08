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
 - ### Debian:
   * curl
   * gawk & sed
   * psmisc & policykit-1

 - ### Optional:
   * zenity
   * libnotify4 (Notifications)

 - ### Build:
   * dpkg (Used in package building and program + kernel installation / removal)
   * libnotify-dev & libgtk-3-dev & g++ (Used in package building (.deb), installing and updating (source) or package install (non-amd46))

## Config:
 * Read a value:   `kernel-notify -c CFGOPTION`
 * Change a value: `kernel-notify -c CFGOPTION NEWCFGVALUE`
 * The config can also be changed by editing `/usr/share/kernel-notify/config`

 - Example:
  * Show all configs and their values: `kernel-notify -c`
  * Change the value of 'example' to 'example-complete': `kernel-notify -c example example-complete`
 
 - Configs:
   * '/' shows multiple options
   * '-' shows a range of values
  * muted="0/1" - This value shouldn't be editied, use -m to mute and -um to unmute
  * detail="1/2" - Set to 1 for minor and 2 for patch kernel version checking
  * autoupdate="0/1" - Set to 0 to ask before updates, set to 1 to automatically update when the program is run
  * maxkernelcount="1-99" - How many kernels should be saved before notifying users to remove a kernel (e.g. "5" would notify on the 6th kernel installed)
