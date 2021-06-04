# Variant Annotation

## Description
This is to annotate the variants in the file of "Challenge_data_(1).vcf". Based on the header information provided, the variant was called by freeBays. Two samples (or probably one sample) were provided. The names of the samples are "normal" and "vaf5". The variants were annoated by ANNOVAR program. Shell command, Python as well as R were used to extract/analyze the data. To obtain the same results as provided, copy the vcf file to "DownloadData" folder and rename it as "tempus.vcf". Make the folders of "tmp" and "finalResult". The final result is stored in "finalResult" folder. To run this program, you should have "ANNOVAR" as well as "samtools/bcftools" installed. Use command "sh tempus.sh" in linux to complete the analysis.  
 
## Details of the command in tempus.sh
###Copy the vcf data 
```
cp ./DownloadData/Challenge_data.vcf  ./DownloadData/tempus.vcf
```

###bcftools to normalize the vcf file
The vcf was generated by freeBayes. Use bcftools to normalize the file resulting in error with the message of "Error: wrong number of fields in FMT/DPR at 1:10292359, expected 4, found 6". To make it work properly, the header of vcf file should be modified accordingly
```
sed -i 's/DPR,Number=A/DPR,Number=R/g' ./DownloadData/tempus.vcf
/mnt/c/NGS/tools/bcftools-1.7/software/bin/bcftools norm -Ov -m-any ./DownloadData/tempus.vcf > ./tmp/De_tempus.vcf
```

###The variant is annoatated by annovar program
```
/mnt/g/NGS/reference/ExomRef/annovar/convert2annovar.pl -format vcf4 \
	./tmp/De_tempus.vcf  \
	-outfile ./tmp/tempus.avinput \
	-allsample -withfreq  -includeinfo

/mnt/g/NGS/reference/ExomRef/annovar//table_annovar.pl ./tmp/tempus.avinput \
	/mnt/g/NGS/reference/ExomRef/annovar//humandb/ -buildver hg19\
	-out ./tmp/tempus.anno -remove \
	-protocol refGene,exac03,gnomad211_genome,cosmic70,clinvar_20170905,mcap,mcap13,revel,dbscsnv11,dbnsfp33a\
	-operation g,f,f,f,f,f,f,f,f,f\
	-nastring . -polish	
```


###Extract the variant type and save in the file of tempus.VariantType
```
awk '{print $16}' ./tmp/tempus.avinput |  awk -F';' '{print $41}' | awk -F '=' '{print $2}' > ./tmp/tempus.VariantType
sed -i '1 i\VariantType' ./tmp/tempus.VariantType
```

###Extract the genotype as well as other information for all the samples in vcf file. Save this to the file of vcf_sample.txt
```
grep -v '##' DownloadData/tempus.vcf | head -1 | cut -f6- > ./tmp/vcf_sample.txt
cut -f14- tmp/tempus.avinput >> ./tmp/vcf_sample.txt
```

###extract DP(depth of coverage) of the locus, alternative allele and calcualte the variant allele fraction
```
grep -v '##' DownloadData/tempus.vcf | head -1 | cut -f10- > ./tmp/SampleName
sed 's/\</DP_locus./g' ./tmp/SampleName > ./tmp/DP_locus.txt
sed 's/\</DP_alt./g' ./tmp/SampleName > ./tmp/DP_alt.txt
sed 's/\</VAF./g' ./tmp/SampleName > ./tmp/VAF.txt
sed 's/\</GT./g' ./tmp/SampleName > ./tmp/GT.txt
```
A python program was written to extract the depth of coverage and calcualte VAF
```
python tempus_ExtractCoverage.py -inputData ./tmp/tempus.avinput
cat ./tmp/temp_DP_locus.txt >> ./tmp/DP_locus.txt
cat ./tmp/temp_DP_alt.txt >> ./tmp/DP_alt.txt
cat ./tmp/temp_VAF.txt >> ./tmp/VAF.txt
cat ./tmp/temp_GT.txt >> ./tmp/GT.txt
```

###combine all files together and save the final file in the folder of "finalResult"
```
paste -d '\t' ./tmp/tempus.anno.hg19_multianno.txt ./tmp/tempus.VariantType ./tmp/vcf_sample.txt ./tmp/GT.txt ./tmp/DP_locus.txt ./tmp/DP_alt.txt ./tmp/VAF.txt> ./finalResult/TempusAnnotated.txt
```

###To keep the variant detected at least one of the sample, a R program was written. Run the R program to obtain the file of "TempusAnnotated_short.txt"


