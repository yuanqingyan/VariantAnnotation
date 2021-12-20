#!/bin/bash

annovar="/mnt/g/NGS/reference/ExomRef/annovar/"
bcftools="/mnt/c/NGS/tools/bcftools-1.7/software/bin"


###For bcftools norm to work properly, the header of vcf file generated from freeBayes should be modified accordingly
sed -i 's/DPR,Number=A/DPR,Number=R/g' ./DownloadData/UnAnno.vcf
${bcftools}/bcftools norm -Ov -m-any ./DownloadData/UnAnno.vcf > ./tmp/De_UnAnno.vcf

###Anotate by annovar program####
${annovar}/convert2annovar.pl -format vcf4 \
	./tmp/De_UnAnno.vcf  \
	-outfile ./tmp/UnAnno.avinput \
	-allsample -withfreq  -includeinfo

${annovar}/table_annovar.pl ./tmp/UnAnno.avinput \
	${annovar}/humandb/ -buildver hg19\
	-out ./tmp/UnAnno.anno -remove \
	-protocol refGene,exac03,gnomad211_genome,cosmic70,clinvar_20170905,mcap,mcap13,revel,dbscsnv11,dbnsfp33a\
	-operation g,f,f,f,f,f,f,f,f,f\
	-nastring . -polish	
	
###extract variant type#######
awk '{print $16}' ./tmp/UnAnno.avinput |  awk -F';' '{print $41}' | awk -F '=' '{print $2}' > ./tmp/UnAnno.VariantType
sed -i '1 i\VariantType' ./tmp/UnAnno.VariantType

###extract sample information#####
grep -v '##' DownloadData/UnAnno.vcf | head -1 | cut -f6- > ./tmp/vcf_sample.txt
cut -f14- tmp/UnAnno.avinput >> ./tmp/vcf_sample.txt


###extract DP and calcualte VAF#####
grep -v '##' DownloadData/UnAnno.vcf | head -1 | cut -f10- > ./tmp/SampleName
sed 's/\</DP_locus./g' ./tmp/SampleName > ./tmp/DP_locus.txt
sed 's/\</DP_alt./g' ./tmp/SampleName > ./tmp/DP_alt.txt
sed 's/\</VAF./g' ./tmp/SampleName > ./tmp/VAF.txt
sed 's/\</GT./g' ./tmp/SampleName > ./tmp/GT.txt

python ExtractCoverage.py -inputData ./tmp/UnAnno.avinput
cat ./tmp/temp_DP_locus.txt >> ./tmp/DP_locus.txt
cat ./tmp/temp_DP_alt.txt >> ./tmp/DP_alt.txt
cat ./tmp/temp_VAF.txt >> ./tmp/VAF.txt
cat ./tmp/temp_GT.txt >> ./tmp/GT.txt

###combine all files together###
paste -d '\t' ./tmp/UnAnno.anno.hg19_multianno.txt ./tmp/UnAnno.VariantType ./tmp/vcf_sample.txt ./tmp/GT.txt ./tmp/DP_locus.txt ./tmp/DP_alt.txt ./tmp/VAF.txt> ./finalResult/Annotated.txt








