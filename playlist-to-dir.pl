#!/usr/bin/perl -w

use strict;
use File::Basename;

# Path to local music dir, with trailing slash
my $local = '/home/jonathan/Music/';

# Path to SD card etc
my $remote = '/home/jonathan/Downloads/sdtest/';

# Total args
my $total = $#ARGV + 1;

if ($total == 0) {
	print "Must pass args to this script\n";
	exit;
}

my %dirs;

# Loop round args
foreach my $a(@ARGV) {
	# Find the dir of the file
	my($filename, $dir, $suffix) = fileparse($a);

	# Strip off the local path prefix
	$dir =~ s/$local//;

	# Stash the path so it gets de-duped
	$dirs{$dir} = 1;

	# Also stash the parent to make rsync happy
	my $parent = dirname($dir);
	$dirs{$parent} = 1;
}

# Change to local dir
chdir $local;

unlink '/tmp/rsyncfilter';

# Print all de-duped dirs
foreach my $dir (keys %dirs) {
	`echo "$dir" >> /tmp/rsyncfilter`;
}

`rsync -rauv --delete --delete-excluded  --include='*.mp3' --include='*.jpg' --include-from=/tmp/rsyncfilter --exclude=/** $local $remote > /tmp/rsync.log`;
unlink '/tmp/rsyncfilter';
