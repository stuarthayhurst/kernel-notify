# Contributing to kernel-notify
## Overview:
  - Your contributions and pull requests are welcome, this project can always use extra help! Contributing to this project consists of making whatever you're working on known, working on it, testing and finally submitting a pull request to merge your changes back to the master branch.
 
## Suggestions for contributing:
  - Work on bug reports under 'Issues'
  - Work on feature requests under 'Issues'
  - Improve the clarity and coverage of any documents in the 'docs/' folder
  - Improving efficieny and clarity of the code
  - Reducing the size of the code

## Working with Issues:
  - If someone else is already working on a reported issue you wanted, help them out. Don't try beat them to the pull request or take over the issue and drown them out.
  - If the issue or feature you are working on has not been reported, do so before attempting to work on it.
  - If you are working on your own issue, use that report as a ground to write down any information you know about the issue as it may help others down the line, people helping you and keep track of what's going on.
  - If any help is required, please make it known.

## Building and testing the project:
  > Building / Installing: 
  - To build the .deb, run `./install.sh -b` and press enter instead of making a new version.
  - Install the .deb you built with `sudo dpkg -i kernel-notify-x.x_all.deb`.
  - Alternatively, `./install.sh -d` can be run and will build and install the package.
  - Installing the program on a non-debian system can be done by running `./install.sh`.
  > Testing:
  - Test EVERY part of the program that may be affected by the changes you made, by comparing outputs between your modified version and the master branch.
  - The notifications can be built separately with `./install.sh -n` and tested with `./notifications "[Title Text]" "[Body Text]" "[Icon Path]" "[kernel/program/""]" #Button "[mute/""]" #Button "[true/""]" #Critical priority or not`.

## Submitting a pull request:
  - When you believe your contribution to be complete, submit a pull request and use the template provided.
  - Your code will be reviewed and approved, or told what needs to change, to be repeated until approved. 
  - Make sure to outline any note-worthy changes you make, as this will make creating a release easier further down the line.
 
 ## Other informaton:
   - ALL changes must be allowed under the license (See LICENSE.md).
   - ALL changes and discussions must abide by the Code of Conduct (docs/CODE_OF_CONDUCT.md).
  
