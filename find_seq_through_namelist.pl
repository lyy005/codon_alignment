#! /usr/bin/perl -w                                                                                                                                         
use strict;

die "usage: perl $0 [fa] [list] [new.fa]\n" unless (@ARGV == 3);

open LST, $ARGV[1] or die "$ARGV[1] $!\n";
open FA, $ARGV[0] or die "$ARGV[0] $!\n";
open OUT, ">$ARGV[2]" or die "$ARGV[2] $!\n";

my (@temp, %list, $flag);
while (<LST>) {
	chomp;
	@temp = split;
	$temp[0] =~ s/\>//;
	$list{$temp[0]} = 1;
}
close LST;

$flag = 0;
while (<FA>) {
	if (/^>(\S+)/) {
		if (exists $list{$1}) {
			$flag = 1;
		}else{
			$flag = 0;
		}
	}
	print OUT "$_"  if ($flag == 1);
}
close FA;
close OUT;
