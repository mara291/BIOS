## Minimalistic BIOS Menu
This project is a minimalistic design of a
BIOS menu that runs in 16 bit real mode. It prints a small menu with 7 options, which are read from the second sector of the disk. <br>
You can navigate through the menu using keys from 1 to 7 and then press Enter.

## Options
On the **Exit** option the program will end with a black screen. <br>
On the **Exit and boot** option the program will enter 32 bit protected mode and will jump to the kernel, which will display a message on the screen.

## Cross Compiler
I used the cross compiler from here: 
https://github.com/mell-o-tron/MellOs/blob/main/A_Setup/setup-gcc-debian.sh

Make sure to add the i386elfgcc binary to your $PATH in the current terminal session:<br>
export PATH=$PATH:/usr/local/i386elfgcc/bin

## OR...
Only use qemu with the compiled binary which you can find in: obj/kernel.bin <br>
command: make qemu
