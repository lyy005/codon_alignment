# Codon-based Alignment (TACO)

**For the lastest version of TACO, please go to:**
https://github.com/lyy005/codon_alignment/releases

## Features:

 - Performing codon alignment for coding sequences (CDS)
 - Unaligned coding sequences are the only input needed (if using default universal codon table or invertebrate codon table)
 - Multiple alignment with MAFFT (executable mafft-linsi file needs to be added to current directory)
 - Customized the threshold for the percentage of non-gap basepairs in a multiple sequence alignment
 - Two codon tables are supported:
        1 - for The Standard Genetic Code;
        5 - for The Invertebrate Mitochondrial Genetic Code
 - Details about codon tables please refer to http://www.ncbi.nlm.nih.gov/Taxonomy/taxonomyhome.html/index.cgi?chapter=tgencodes#SG2

## Citation

Li Y, Zhang R, Liu S, Donath A, Peters RS, Ware J, Misof B, Niehuis O, Pfrender ME, Zhou X. The molecular evolutionary dynamics of oxidative phosphorylation (OXPHOS) genes in Hymenoptera. BMC evolutionary biology. 2017 Dec 1;17(1):269.

## Prerequisites:
 - Download MAFFT (https://mafft.cbrc.jp/alignment/software/) and added the executable file mafft-linsi to current directory (i.e. codon_alignment directory).

## Quick start: 
perl codon_alignment.pl [cds fas] [codon table id] [minimum coverage]

 - [cds fas] 	    CDS sequences in fasta file
 - [codon table id]    1 for Standard Code, 5 for Invertebrate Mitochondrial Code
 - [minimum coverage]  Minimum coverage of non-gap basepairs in the multiple alignment (range from 0 to 1). 
		    For example: 0.7 means sequences after the first round of multiple sequence alignment should have >= 70% of non-gap basepairs

## Example:
 - Go to the example file directory 
 - cd ./examples
 - Make multiple sequence alignments based on COX1 gene (mitochondrial codon table) and remove the sequences with < 70% non-gap basepairs
 - ../codon_alignment.pl COX1.fasta 5 0.7
