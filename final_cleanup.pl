#!usr/bin/perl -w
use strict;

die "Usage: perl $0 [.aln] [minimum coverage]\n" unless (@ARGV == 2);
open (FA, $ARGV[0]) or die "$ARGV[0] $!\n";
open OUT, ">$ARGV[0].cleanup" or die "$ARGV[0].cleanup $!\n";
open LST, ">$ARGV[0].cleanup.list" or die "$ARGV[0].cleanup.list $!\n";
open LOG, ">$ARGV[0].cleanup.log" or die "$ARGV[0].cleanup.log $!\n";

$/=">";
my $null = <FA>;

my $read = <FA>;
my @read = split /\n/, $read;
shift @read;
$read = join "", @read;
my $ref_len = length $read;				# Calculate the total length of the alignment
close FA;

open (FA, $ARGV[0]) or die "$ARGV[0] $!\n";
$null = <FA>;
while(<FA>){
        chomp;
        my @raw = split /\n/;
        my $name = shift @raw;
        my $seq = join "", @raw;
        my $base = $seq;
        $base =~ s/\-//g;
        my $len = length $base;
        my $rate = $len/$ref_len;			# Calculate the percentage of non-gap basepairs

        if($rate >= $ARGV[1]){				# Keep the sequence if the percentage is higher than the threshold
                print OUT ">$name\n$seq\n";
                print LST "$name\n";
                print LOG "$name\t$rate\n";
        }else{
                print LOG "$name\t$rate\t*\n";
                print "\t$ARGV[0]\t$name\t$rate\t*\n";
        }
}

close FA;
close OUT;
close LST;
