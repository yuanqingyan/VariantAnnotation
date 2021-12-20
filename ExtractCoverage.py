# !/usr/bin/env python
import os
import sys
import re



currentPath=os.getcwd()
#####################################################################################
help_menu='''\nUsage: python ExtractCoverage.py -inputData xxxxx
**parameters**
'''

args=sys.argv
if '-h' in args or '-help' in args or len(args)==1:
    print (help_menu)
    sys.exit(0)
	
if '-inputData' not in sys.argv:
    sys.exit('input data is required')
else:
    i=sys.argv.index('-inputData')
    inData=(sys.argv[i+1])

#####################################################################################

def getDPandVAF(item):
	DicAlt={}
	itemSplit=item.split(":")
	
	GT=itemSplit[0]
	DP_site=itemSplit[2]
	DP_alt=itemSplit[6]	
	vaf=round(int(DP_alt)/int(DP_site),5)
	
	DicAlt['DP']=DP_site
	DicAlt['ALT']=DP_alt
	DicAlt['VAF']=vaf
	DicAlt['GT']=GT

	return(DicAlt)

	
		
def ExtractCoverage():	
	ReadFile = open("%s" %(inData), "r")
	
	target_DP_locus = open("./tmp/temp_DP_locus.txt", "w")
	target_DP_alt = open("./tmp/temp_DP_alt.txt", "w")
	target_VAF = open("./tmp/temp_VAF.txt", "w")
	target_GT = open("./tmp/temp_GT.txt", "w")
	
	for line in ReadFile:
		SplitItem=line.strip().split('\t')

		for i in range(17,len(SplitItem)):
			Result=getDPandVAF(item=SplitItem[i])
			
			if i==(len(SplitItem)-1):
				target_DP_locus.write('%s\n' %Result['DP'])
				target_DP_alt.write('%s\n' %Result['ALT'])
				target_VAF.write('%s\n' %Result['VAF'])
				target_GT.write('%s\n' %Result['GT'])
			else:
				target_DP_locus.write('%s\t' %Result['DP'])
				target_DP_alt.write('%s\t' %Result['ALT'])
				target_VAF.write('%s\t' %Result['VAF'])	
				target_GT.write('%s\t' %Result['GT'])
				
	ReadFile.close()
	target_DP_locus.close()
	target_DP_alt.close()
	target_VAF.close()
	target_GT.close()

	

			

	
ExtractCoverage()





