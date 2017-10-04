#!/usr/bin/perl
use strict;
use FindBin qw($Bin $Script);
use File::Basename qw(basename dirname);

die "perl $0 [cds fas] [codon table id] [minimum coverage]\n Aligning codon based on protein information (1 for Standard Code, 5 for Invertebrate Mitochondrial Code)\n 

Features:
* Performing codon alignment for input CDS sequences
* Multiple alignment with MUSCLE (binary of MUSCLE should be added to current directory)
* Customized the threshold for the percentage of non-gap basepairs in a multiple sequence alignment (sequence with lower percentage of non-gap basepairs will be removed)
* Two codon tables supported:
        1 - for The Standard Code;
        5 - for The Invertebrate Mitochondrial Code
Details please refer to http://www.ncbi.nlm.nih.gov/Taxonomy/taxonomyhome.html/index.cgi?chapter=tgencodes#SG2

" unless (@ARGV == 3);
my %CODE = (
                "1" => {
                                'GCA' => 'A', 'GCC' => 'A', 'GCG' => 'A', 'GCT' => 'A',                               # Alanine
                                'TGC' => 'C', 'TGT' => 'C',                                                           # Cysteine
                                'GAC' => 'D', 'GAT' => 'D',                                                           # Aspartic Acid
                                'GAA' => 'E', 'GAG' => 'E',                                                           # Glutamic Acid
                                'TTC' => 'F', 'TTT' => 'F',                                                           # Phenylalanine
                                'GGA' => 'G', 'GGC' => 'G', 'GGG' => 'G', 'GGT' => 'G',                               # Glycine
                                'CAC' => 'H', 'CAT' => 'H',                                                           # Histidine
                                'ATC' => 'I', 'ATT' => 'I', 'ATA' => 'I',                                           # Isoleucine
                                'AAA' => 'K', 'AAG' => 'K',                                                           # Lysine
                                'CTA' => 'L', 'CTC' => 'L', 'CTG' => 'L', 'CTT' => 'L', 'TTA' => 'L', 'TTG' => 'L',   # Leucine
                                'ATG' => 'M',                                                                         # Methionine
                                'AAC' => 'N', 'AAT' => 'N',                                                           # Asparagine
                                'CCA' => 'P', 'CCC' => 'P', 'CCG' => 'P', 'CCT' => 'P',                               # Proline
                                'CAA' => 'Q', 'CAG' => 'Q',                                                           # Glutamine
                                'CGA' => 'R', 'CGC' => 'R', 'CGG' => 'R', 'CGT' => 'R', 'AGG' => 'R', 'AGA' => 'R', 'AGG' => 'R',   # Arginine
                                'TCA' => 'S', 'TCC' => 'S', 'TCG' => 'S', 'TCT' => 'S', 'AGC' => 'S', 'AGT' => 'S',   # Serine
                                'ACA' => 'T', 'ACC' => 'T', 'ACG' => 'T', 'ACT' => 'T',                               # Threonine
                                'GTA' => 'V', 'GTC' => 'V', 'GTG' => 'V', 'GTT' => 'V',                               # Valine
                                'TGG' => 'W',                                                                         # Tryptophan
                                'TAC' => 'Y', 'TAT' => 'Y',                                                           # Tyrosine
                                'TAA' => 'X', 'TAG' => 'X', 'TGA' => 'X',                                             # Stop
                },


                "5" => {        'GCA' => 'A', 'GCC' => 'A', 'GCG' => 'A', 'GCT' => 'A',                               # Alanine
                                'TGC' => 'C', 'TGT' => 'C',                                                           # Cysteine
                                'GAC' => 'D', 'GAT' => 'D',                                                           # Aspartic Acid
                                'GAA' => 'E', 'GAG' => 'E',                                                           # Glutamic Acid
                                'TTC' => 'F', 'TTT' => 'F',                                                           # Phenylalanine
                                'GGA' => 'G', 'GGC' => 'G', 'GGG' => 'G', 'GGT' => 'G',                               # Glycine
                                'CAC' => 'H', 'CAT' => 'H',                                                           # Histidine
                                'ATC' => 'I', 'ATT' => 'I',                                             # Isoleucine
                                'AAA' => 'K', 'AAG' => 'K',                                                           # Lysine
                                'CTA' => 'L', 'CTC' => 'L', 'CTG' => 'L', 'CTT' => 'L', 'TTA' => 'L', 'TTG' => 'L',   # Leucine
                                'ATG' => 'M', 'ATA' => 'M',                                                           # Methionine
                                'AAC' => 'N', 'AAT' => 'N',                                                           # Asparagine
                                'CCA' => 'P', 'CCC' => 'P', 'CCG' => 'P', 'CCT' => 'P',                               # Proline
                                'CAA' => 'Q', 'CAG' => 'Q',                                                           # Glutamine
                                'CGA' => 'R', 'CGC' => 'R', 'CGG' => 'R', 'CGT' => 'R', 'AGG' => 'R',   # Arginine
                                'TCA' => 'S', 'TCC' => 'S', 'TCG' => 'S', 'TCT' => 'S', 'AGC' => 'S', 'AGT' => 'S', 'AGA' => 'S', 'AGG' => 'S', # Serine
                                'ACA' => 'T', 'ACC' => 'T', 'ACG' => 'T', 'ACT' => 'T',                               # Threonine
                                'GTA' => 'V', 'GTC' => 'V', 'GTG' => 'V', 'GTT' => 'V',                               # Valine
                                'TGG' => 'W', 'TGA' => 'W',                                                                        # Tryptophan
                                'TAC' => 'Y', 'TAT' => 'Y',                                                           # Tyrosine
                                'TAA' => 'X', 'TAG' => 'X',                                                           # Stop
                }

        );


open (FA, $ARGV[0]) or die "$ARGV[0] $!\n";
open (OT1, ">$ARGV[0].pep") or die "$ARGV[0].pep $!\n";

$/=">"; <FA>; $/="\n";
while (<FA>) {					# Read in CDS fasta file
        my $head = $_;
        chomp $head;
        my $key = $1 if($head =~ /^(\S+)/);
        my $phase = ($head =~ /\s+phase[:\s]+([012])\s+/i) ? $1 : 0 ; 	# if any phase info in the header will be used
        $/=">";
        my $seq = <FA>;
        chomp $seq;
        $/="\n";

        my $prot = cds2aa($seq,$phase);		# translate CDS to Amino Acids
        Display_seq(\$prot);
        print OT1 ">$key\n".$prot;		# reform the output format of the Amino Acids

}
close FA;
close OT1;

print "Step 1 of 6: nt to aa translation finished\n";

`$Bin/muscle -in $ARGV[0].pep -out $ARGV[0].pep.aln -quiet`;							# Run MUSCLE alignment
print "Step 2 of 6: aa MUSCLE alignment finished\n";

system("perl $Bin/final_cleanup.pl $ARGV[0].pep.aln $ARGV[2]");							# Calculate the percentage of gaps for each sequence
print "Step 3 of 6: cleanup aa finished $ARGV[0].pep.aln.cleanup. Coverage of all sequences: $ARGV[0].pep.aln.cleanup.log\n";

system("perl $Bin/find_seq_through_namelist.pl $ARGV[0] $ARGV[0].pep.aln.cleanup.list $ARGV[0].cleanup");	# Pick sequences match the criteria
print "Step 4 of 6: cleanup nt finished $ARGV[0].cleanup\n";

`$Bin/muscle -in $ARGV[0].pep.aln.cleanup -out $ARGV[0].pep.aln.cleanup.aln -quiet`;				# After removing sequences don't meet the criteria, sequences are aligned again
print "Step 5 of 6: second-round aa alignment finished $ARGV[0].pep.aln.cleanup\n";

open (AA, "$ARGV[0].pep.aln.cleanup.aln") or die "$ARGV[0].pep.aln.cleanup.aln $!\n";
open (OT2, ">$ARGV[0].nt.cleanup.aln") or die "$ARGV[0].nt.cleanup.aln $!\n";			# FASTA format output of finalized alignment
open (OT3, ">$ARGV[0].nt.cleanup.aln.phylip") or die "$ARGV[0].nt.cleanup.aln.phylip $!\n";	# PHYLIP format output of finalized alignment

# Calculate the number of basepairs in the alignment for the header of PHYLIP output
$/=">"; <AA>;
my $len;
my $count = 0;
while(<AA>){
        chomp;
        my @seq = split /\n+/;
        shift @seq;
        my $seq = join "",@seq;
        $len = length($seq);
        $count ++;
}
my $L = $len*3;
print OT3 "$count\t$L\n";
close AA;
close FA;

# Align the CDS sequences based on the corresponding amino acid alignments
open (NT, "$ARGV[0].cleanup") or die "$ARGV[0].cleanup $!\n";
open (AA, "$ARGV[0].pep.aln.cleanup.aln") or die "$ARGV[0].pep.aln.cleanup.aln $!\n";
my %aa;
$/=">"; <AA>;
while(<AA>){
        my $aa = $_;
        chomp $aa;
        my @aa = split/\s+/, $aa;
        my $aa_name = shift @aa;
        my $aa_seq = join "", @aa;
        $aa{$aa_name} = $aa_seq;
}


<NT>;
while (<NT>) {
        my $nt = $_;
        chomp $nt;

        my @nt = split/\n+/, $nt;
        my $name = shift @nt;
	print "Mapping $name\n";
	my @nt_name = split/\s+/, $name;
	my $nt_name = $nt_name[0];

        my $nt_seq = join "", @nt;


        if($aa{$nt_name}){
                my $prot = compare_cds_aa($nt_seq,$aa{$nt_name});
                print OT2 ">$nt_name\n$prot\n";
                print OT3 "$nt_name\n$prot\n";
        }else{
                print "Warning: $nt_name. No corresponding amino acid\n";
        }

}

print "Step 6 of 6: nt alignment finished\n\tProtein alignment: $ARGV[0].pep.aln.cleanup.aln\n\tNucleotide alignment: $ARGV[0].nt.cleanup.aln\n\tPhylip format: $ARGV[0].nt.cleanup.aln.phylip\n";

close NT;
close AA;
close OT2;
close OT3;





####################################################
################### Sub Routines ###################
####################################################


#display a sequence in specified number on each line
#############################################
sub Display_seq{
        my $seq_p=shift;
        my $num_line=(@_) ? shift : 50; ##set the number of charcters in each line
        my $disp;

        $$seq_p =~ s/\s//g;
        for (my $i=0; $i<length($$seq_p); $i+=$num_line) {
                $disp .= substr($$seq_p,$i,$num_line)."\n";
        }
        $$seq_p = ($disp) ?  $disp : "\n";
}
#############################################


## translate CDS to pep
####################################################
sub cds2aa {
        my $seq = shift;
        my $phase = shift || 0;

        $seq =~ s/\s//g;
        $seq = uc($seq);

        my $len = length($seq);

        my $prot;
        for (my $i=$phase; $i<$len; $i+=3) {
                my $codon = substr($seq,$i,3);
                last if(length($codon) < 3);
                $prot .= (exists $CODE{$ARGV[1]}{$codon}) ? $CODE{$ARGV[1]}{$codon} : 'X';
        }
        $prot =~ s/U$//;
        return $prot;

}

## compair CDS and pep
####################################################
sub compare_cds_aa {
        my $nt = shift;
        my $aa = shift;

        $nt =~ s/\s+//g;
        $aa =~ s/\s+//g;

        $nt = uc($nt);
        $aa = uc($aa);

        my $len = length($aa);
        my $prot;
        my $j = 0;
        for (my $i=0; $i<$len; $i+=1) {
        my $base = substr($aa,$i,1);
                if($base eq "-"){
                        $prot .= "---";
                        next;
                }else{
                        my $codon = substr($nt,$j,3);
                        $j += 3;

                        if($CODE{$ARGV[1]}{$codon} eq $base){
#                               print "###$codon\t$base\n";
                                $prot .= $codon;
                        }else{
                                $prot .= $codon;
                                print "Warning: the codon does not match the amino acid\t$base\t$codon\n";
                        }
print "Stop codon found: (location: $j) $base\t$codon\n" if $CODE{$ARGV[1]}{$codon} eq "X";

                }
        }
        return $prot;
}
