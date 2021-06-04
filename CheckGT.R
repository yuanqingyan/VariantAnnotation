
dat<-read.delim("./finalResult/TempusAnnotated.txt",header=T,sep="\t",stringsAsFactors=F)
whichGT<-which(colnames(dat)=="GT.normal")

#####remove the variant with variant allele fraction not larger than 0.05 ########
dat_GT<-dat[,whichGT:(whichGT+1)]
idx<-apply(dat_GT,1,function(x) {sum(x=="0/0/0")<2})

dat_filter<-dat[idx,]

write.table(dat_filter,file="./finalResult/TempusAnnotated_short.txt",row.names=F,col.names=T,sep="\t")

