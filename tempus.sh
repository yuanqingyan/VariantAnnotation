#!/bin/bash

annovar="/mnt/g/NGS/reference/ExomRef/annovar/"
bcftools="/mnt/c/NGS/tools/bcftools-1.7/software/bin"


##copy the data###
cp ./DownloadData/Challenge_data.vcf  ./DownloadData/tempus.vcf

###For bcftools norm to work properly, the header of vcf file generated from freeBayes should be modified accordingly
sed -i 's/DPR,Number=A/DPR,Number=R/g' ./DownloadData/tempus.vcf
${bcftools}/bcftools norm -Ov -m-any ./DownloadData/tempus.vcf > ./tmp/De_tempus.vcf

###Anotate by annovar program####
${annovar}/convert2annovar.pl -format vcf4 \
	./tmp/De_tempus.vcf  \
	-outfile ./tmp/tempus.avinput \
	-allsample -withfreq  -includeinfo

${annovar}/table_annovar.pl ./tmp/tempus.avinput \
	${annovar}/humandb/ -buildver hg19\
	-out ./tmp/tempus.anno -remove \
	-protocol refGene,exac03,gnomad211_genome,cosmic70,clinvar_20170905,mcap,mcap13,revel,dbscsnv11,dbnsfp33a\
	-operation g,f,f,f,f,f,f,f,f,f\
	-nastring . -polish	
	
###extract variant type#######
awk '{print $16}' ./tmp/tempus.avinput |  awk -F';' '{print $41}' | awk -F '=' '{print $2}' > ./tmp/tempus.VariantType
sed -i '1 i\VariantType' ./tmp/tempus.VariantType

###extract sample information#####
grep -v '##' DownloadData/tempus.vcf | head -1 | cut -f6- > ./tmp/vcf_sample.txt
cut -f14- tmp/tempus.avinput >> ./tmp/vcf_sample.txt


###extract DP and calcualte VAF#####
grep -v '##' DownloadData/tempus.vcf | head -1 | cut -f10- > ./tmp/SampleName
sed 's/\</DP_locus./g' ./tmp/SampleName > ./tmp/DP_locus.txt
sed 's/\</DP_alt./g' ./tmp/SampleName > ./tmp/DP_alt.txt
sed 's/\</VAF./g' ./tmp/SampleName > ./tmp/VAF.txt
sed 's/\</GT./g' ./tmp/SampleName > ./tmp/GT.txt

python tempus_ExtractCoverage.py -inputData ./tmp/tempus.avinput
cat ./tmp/temp_DP_locus.txt >> ./tmp/DP_locus.txt
cat ./tmp/temp_DP_alt.txt >> ./tmp/DP_alt.txt
cat ./tmp/temp_VAF.txt >> ./tmp/VAF.txt
cat ./tmp/temp_GT.txt >> ./tmp/GT.txt

###combine all files together###
paste -d '\t' ./tmp/tempus.anno.hg19_multianno.txt ./tmp/tempus.VariantType ./tmp/vcf_sample.txt ./tmp/GT.txt ./tmp/DP_locus.txt ./tmp/DP_alt.txt ./tmp/VAF.txt> ./finalResult/TempusAnnotated.txt








