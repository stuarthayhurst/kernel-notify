# kernel-notify
 - A program to fetch the latest kernel version on login and notify users if their kernel is no longer the latest
 - Updating and removing the kernel is supported on systems with dpkg installed
 - If you have an issue, please file a bug report under [Issues](https://github.com/Dragon8oy/kernel-notify/issues "Issues")
 - GitHub Link: https://github.com/Dragon8oy/kernel-notify
 - The master branch is usually unstable, refer to the releases page for stable releases

## Code of Conduct and Contributing:
 - Read 'CODE\_OF\_CONDUCT.md' and 'CONTRIBUTING.md' in 'docs/' for information

## Installation:
 * Run `./install.sh`
 - ### OR: (Debian - Source)
   * Run `./install.sh -d`
 - ### OR: (Debian - Release)
   * Download the latest deb from the Releases page
   * Run `sudo dpkg -i kernel-notify-x.x_all.deb`

## Packaging:
 * Run `./install.sh -b`
 * This will prepare the code for release and build a .deb with the version specified, if left blank then the version won't be updated and kernel-notify will be built with the current version

## Updating:
 - ### Automatic:
   * Run `kernel-notify -u`
 - ### Manual:
   * Follow the instructions in the `Installation` section, configs will be saved through updates
 - WARNING: kernel-notify will attempt to update the config after an update
 - If the config breaks, the old config can be viewed with `kernel-notify -o`

## Notes:
 * The program sending update notifications can be toggled with `kernel-notify --mute` and `kernel-notify --unmute`
 * The program and kernel can be automatically updated if autoupdate is set to 1 in the config
 * On .deb installation, the package will attempt to rebuild the notifications program if the architecture is not amd64
 * Man page available with `man kernel-notify`

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
 - ### Required:
   * coreutils (8.25+)
   * curl
   * diffutils / cmp
   * gawk & grep & sed
   * psmisc & procps
   * policykit-1
   * sudo

 - ### Optional:
   * zenity
   * libnotify4 (Notifications)

 - ### Build:
   * dpkg (Used in package building and program + kernel installation / removal)
   * imagemagick (Used to generate .pngs from .svgs)
   * libnotify-dev & g++ (Used in package building (.deb), installing and updating (source) or package install (non-amd46))
   * optipng (Compress icons)
   * sed (Update versions)

## Common Problems:
 - ### Notifications missing / failed to build:
   * If no notifications are sent when they should be, the notifications binary is likely missing or broken
   * If `ATTENTION: g++: failed to build notifications` was seen during install, the binary will be missing
   * Notifications can be rebuilt with `./install.sh -n` and then `sudo mv notifications /usr/share/kernel-notify/`
   * If you no longer have access to kernel-notify's source code or need build the notifications specifiaclly for the installed version, use `g++ /usr/share/kernel-notify/notifications.cpp -o /usr/share/kernel-notify/notifications` \``pkg-config --cflags --libs libnotify`\`
   * In the event both options failed, submit a bug report, following the template and giving all available information

 - ### Updating failed:
   * Download the latest release from the Releases page (.deb or .tar.gz / .zip)
   * Follow the install instructions in the `Installation` section
   * Submit a bug report if installing failed, following the template and giving all available information

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
  * autoupdate="0/1" - Set to 0 to ask before updates, set to 1 to automatically update when the program is run
  * warnautostart="1/0" - Warn users if the program cannot start on login
  * maxkernelcount="1-99" - How many kernels should be saved before notifying users to remove a kernel (e.g. "5" would notify on the 6th kernel installed)
  * priority="critical/normal" - Keep notifications with buttons on the screen until dismissed or not (critical / normal)

## License
 * GNU GENERAL PUBLIC LICENSE (v3)
 * Kernel-notify Copyright (C) 2020 Stuart Hayhurst
