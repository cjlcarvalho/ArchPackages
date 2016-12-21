Arch Linux:

* List the packages: `comm -13 <(pacman -Qmq | sort) < (pacman -Qqe | sort) > arch-files.txt`

* Installing: `sudo pacman -S $(< arch-files.txt)`
