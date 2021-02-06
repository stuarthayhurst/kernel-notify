# kernel-notify
 - A program to fetch the latest kernel version on login and notify users if their kernel is no longer the latest
 - Updating and removing the kernel is supported on Debian-based systems
 - If you have an issue, please file a bug report under [Issues](https://github.com/Dragon8oy/kernel-notify/issues "Issues")
 - GitHub Link: https://github.com/Dragon8oy/kernel-notify

## Code of Conduct and Contributing:
 - Read 'CODE\_OF\_CONDUCT.md' and 'CONTRIBUTING.md' in 'docs/' for information

## Installation:
 * Run `./install.sh`
 - ### OR: (Debian - Source)
   * Run `./install.sh -d`
 - ### OR: (Debian - Release)
   * Download the latest deb from the Releases page
   * Run `sudo dpkg -i kernel-notify-x.x_all.deb`

## Uninstallation:
 * Run `sudo make uninstall`

## Packaging:
 * Run `make dist`
 * This will prepare the code for release and build a .deb

## Updating:
 * Install the program, using the instructions in the `Installation` section

## Notes:
 * Kernel-notify starting on login can be toggled with `kernel-notify --enable-autostart` and `kernel-notify --disable-autostart`
 * Kernel-notify sending notifications can be toggled in the config, with the `muted=0/1` option
 * The program and kernel can be automatically updated if autoupdate is set to 1 in the config
 * On .deb installation, the package will attempt to rebuild the notifications program if the architecture is not amd64
 * Man page available with `man kernel-notify`

## Help:
 - ### Program Help:
   * -g  | --gui         : Launch the program with a gui, if available
   * -h  | --help        : Display the help page
   * -v  | --version     : Display program version
   * -o  | --old-config  : List old and new config values
   * -c  | --config      : Change / read a config value
   * --enable-autostart  : Enable kernel-notify starting on login
   * --disable-autostart : Disable kernel-notify starting on login

 - ### Feature Help:
   * -L  | --list-available : List all kernels available to install
   * -r  | --remove-kernel  : Remove a kernels from a menu
   * -l  | --list-kernels   : List installed kernels
   * -a  | --add-kernel     : Install a new kernel
   * -p  | --precision      : Check either major or minor kernel updates

## Dependencies:
 - ### Required:
   * grep & sed
   * coreutils (8.25+)
   * curl
   * diffutils
   * file
   * git
   * less
   * psmisc
   * policykit-1

 - ### Optional:
   * libnotify4 (Notifications)
   * zenity
   * sudo

 - ### Build:
   * dpkg (Used in package building and program + kernel installation / removal)
   * gzip (Used to compress manpage)
   * libnotify-dev & g++ && pkg-config (Used in package building (.deb), installing and updating (source))
   * make
   * sed (Update versions and modify files at build / install time)
   * Optional: inkscape (Used to generate .pngs from .svgs)
   * Optional: optipng (Compress icons)

## Common Problems:
 - ### Updating failed:
   * Download the latest release from the Releases page (.deb or .tar.gz / .zip)
   * Follow the install instructions in the `Installation` section
   * Submit a bug report if installing failed, following the template and giving all available information

 - ### Permission error:
   * The issue is likely caused by the current user not having access to a file in /tmp/ if kernel-notify was previously run as root
   * To solve the issue, reboot the machine and try again. If the issue persists, file a bug report

## Config:
 * Read a value:   `kernel-notify -c configName`
 * Change a value: `kernel-notify -c configName configValue` OR `kernel-notify -c configName="configValue"`
 * The config can also be changed by editing `/usr/share/kernel-notify/config`

 - Example:
  * Show all configs and their values: `kernel-notify -c`
  * Change the value of 'maxkernelcount' to '3': `kernel-notify -c maxkernelcount 3`
  * Or you can use: `kernel-notify -c maxkernelcount="3"`

 - Configs:
   * '/' shows multiple options
   * '-' shows a range of values
  * muted="true/false" - Whether or not to send notifications for kernel and program updates
  * autoupdate="true/false" - Set to false to ask before updates, set to true to automatically update the kernel when the program is run
  * kernelcountwarning="true/false" - Show a warning if the number of kernels installed exceeds maxkernelcount
  * maxkernelcount="1-99" - Number of kernels installed before warning users (e.g. "5" would notify on the 6th kernel installed)
  * kernelcleanup="true/false" - Whether or not to clean up kernel module directory after dpkg exits
  * priority="critical/normal/low" - Keep notifications with buttons on-screen until dismissed or not
  * checkingprecision="minor/major" - Whether to check for major and minor updates or only major version updates
  * primarycheckingmethod="web/git" - Which method to use to check latest kernel version
  * kernelrepourl="git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git" - Git repository for checking major and minor versions

## License
 * GNU GENERAL PUBLIC LICENSE (v3)
 * Kernel-notify Copyright (C) 2021 Stuart Hayhurst
