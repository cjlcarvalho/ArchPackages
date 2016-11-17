Arch Linux:

* List the packages: `comm -13 <(pacman -Qmq | sort) < (pacman -Qqe | sort) > files.txt`

* Installing: `sudo pacman -S $(< files.txt)`
