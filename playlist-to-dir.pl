#!/usr/bin/perl -w

use strict;
use File::Basename;
use Getopt::Long;

# Parse command line arguments
my $remote;
my $playlist;
GetOptions (
	"r|remote=s" => \$remote,
	"p|playlist=s" => \$playlist
);

if (!($remote && $playlist)) {
	print "Usage:\n";
	print "  -r --remote      Destination path to copy music to\n";
	print "  -p --playlist    Path to M3U playlist\n";
	exit;
}

die "Could not find playlist $playlist" unless -e $playlist;
if ($playlist !~ /\.m3u$/i) {
	print"Must use m3u format playlist\n";
	exit;
}
my $pldir = dirname($playlist);
 
my @files = ();
open M3U, $playlist or die "Cannnot open $playlist $!";
while(<M3U>) {
	next if /^#/;
	chomp;
	my $file = $_;

	# The M3U playlist may contain absolute or relative paths to the MP3 from its own location
	# So we test and try to prepend the dir of the M3U to get an absolute path to the MP3
	if ( -e "$file" ) {
		push @files, "$file";
	} elsif ( -e "$pldir/$file" ) {
		push @files, "$pldir/$file";
	}
}
close M3U;

if ($#files == 0) {
	print "No files found\n";
	exit;
}

# Assuming the files are laid out
# /arbitrary/path/<artist>/</album>/<title>.mp3
# then we can deduce /arbitrary/path by examining one of the files
my $title = $files[0];
my $album = dirname($title);
my $artist = dirname($album);
my $local = dirname($artist) . '/';

my %dirs;

# Loop round args
foreach my $a(@files) {
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
foreach my $dir (sort keys %dirs) {
	`echo "$dir" >> /tmp/rsyncfilter`;
}

if (!-d $remote) {
	print "Remote dir $remote does not exist\n";
	exit;
}

my @log = `rsync -rauv --delete --delete-excluded  --include='*.mp3' --include='*.jpg' --include-from=/tmp/rsyncfilter --exclude=/** "$local" "$remote"`;
unlink '/tmp/rsyncfilter';
foreach (@log) {
	print;
}
