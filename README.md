# m3usync

This script syncs the contents of an m3u playlist to a target directory.

The intended usage is to use your PC's music library/player to generate a playlist with a subset of that music that you
want to copy to another device, e.g. a USB stick or SD card for use in a car stereo, etc.

## Generate playlist

The way of generating your playlist depends on your music player. As this script probably only works on Linux,
I'll focus on Rhythmbox:

1. Add a playlist - either automatic or regular
1. Add music to the playlist
1. Select the playlist, click `Playlist` and then click `Save to File...`
1. Select `*.m3u` format and save the playlist

N.B. the playlist must contain relative paths to the MP3 files from the location of the playlist file

## Mount your storage

1. Insert your SD card or USB stick
1. Find where it is mounted by looking at the output of `mount`

## Sync the music

Run the script with the following arguments:

```
-r --remote      Destination path to copy music to
-p --playlist    Path to M3U playlist
```

Example:

```
./playlist-to-dir.pl -p /path/to/playlist.m3u -r /path/to/remote
```

Quote or escape the filenames if they have spaces:

```
/playlist-to-dir.pl -r "/run/media/jonathan/USB DISK" -p ~/Auto\ Car\ playlist.m3u
```
