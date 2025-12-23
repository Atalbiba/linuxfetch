This is my first project of this kind. I'll start with the differences from other similar fetch utilities.

Screenfetch is the first such project, which also displays information about installed packages, laptop and computer hardware, and much more. (It's a bit larger and older in functionality than my linuxfetch...) 

neofetch: The successor to the first fetch, it has about 150 Linux distribution logos and extensive customization (something my fetch, which I developed in about a week or two, doesn't have, I didn't time it exactly). It's definitely top-notch. Fastfetch: It's written in C and is a direct competitor to neofetch, which has a modular structure and a similar configuration. It's often recommended as a modern replacement for neofetch. It has slightly more (much more) hardware information compared to the first version of linuxfetch. Not to mention that neofetch is marked as a legacy project on GitHub.


How do I download and use this utility? There are several options.
1) Click the "code" button and click "download zip" in the list. Then, navigate to the directory where you downloaded the file, unzip it, and then select the versions. There are two directories.
1) The single .sh file, which runs without compilation, is located in the "linuxfetch1file" directory. This is convenient and quick.
2) The files for compilation are located in the "linuxfetch" directory (version for compilation).
Here's how to compile:

mkdir build && cd build && cmake .. && make && make install

This was tested on the Gentoo distribution; it is not guaranteed to work on other distributions.

2) Select the utility versions.
3) Compile the utility or run a single .sh file.

That's it.
