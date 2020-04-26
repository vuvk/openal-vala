# Audio bindings for Vala
alure1.2 (OpenAL) with file system based on PhysFS. It can play audio files from buffers or stream, both from a folder and from archives directly.

### alure1.2 
Alure is a C++ 3D audio API. It uses OpenAL for audio rendering, and provides common higher-level features such as file loading and decoding, buffer caching, background streaming, and source management for virtually unlimited sound source handles.

Link : <https://repo.or.cz/alure.git/shortlog/refs/heads/alure-1.x>

### libPhysFS 
PhysicsFS is a library to provide abstract access to various archives. The programmer does not know and does not care where each of these files came from, and what sort of archive (if any) is storing them.

Link : <https://icculus.org/physfs/>

### Examples
For build examples you can use meson or script 'build_without_meson.sh'
```
$ meson build && ninja -C build
$ ./build/alurestream samples/evenstar_x.it
```
or
```
$ ./build_without_meson.sh
$ ./build/alurestream samples/evenstar_x.it
```

### Extras
copy physfs.pc from folder `extras` to `/usr/lib/pkgconfig` if it doesn't exist

### Errors
If you see this: "Error loading libfluidsynth.so.1: libfluidsynth.so.1: cannot open shared object file: No such file or directory", you can make link:
```
$ find /usr/lib -name "libfluidsynth.so"
$ sudo ln -s /usr/lib/libfluidsynth.so /usr/lib/libfluidsynth.so.1
```

### Small info
Supported formats|
------------- |
WAV |
OGG |
FLAC|
MP3 |
XM, MPTM, IT, S3M |
MIDI |

dependencies  |
------------- |
libalure |
libphysfs |
libopenal |
libfluidsynth |
libFLAC |
libsndfile |
libmodplug |
libmpg123 |
libogg |
libvorbis |
libvorbisfile |
libvorbisenc |

I used MSYS2 with mingw-w64 and cmake for create libraries in Windows.

For Ubuntu/Debian Linux:

```sh
$ sudo apt install libalure1 libalure-dev libphysfs1 libphysfs-dev libopenal1 libopenal-dev libfluidsynth1 libsndfile1 libmodplug1 libmpg123-0 libogg0 libvorbis0a libvorbisfile3 libvorbisenc2 libflac8
```

