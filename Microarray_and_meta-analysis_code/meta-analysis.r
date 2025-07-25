#https://r-mirror.zim.uni-due.de/web/packages/MetaIntegrator/vignettes/MetaIntegrator.html

install.packages("https://cran.r-project.org/src/contrib/Archive/COCONUT/COCONUT_1.0.2.tar.gz",repos = NULL, type = "source")
install.packages("https://cran.r-project.org/src/contrib/Archive/manhattanly/manhattanly_0.2.0.tar.gz", repos = NULL, type = "source")
install.packages("https://cran.r-project.org/src/contrib/Archive/MetaIntegrator/MetaIntegrator_2.1.3.tar.gz", repos = NULL, type = "source")

library(MetaIntegrator)
#creating metaintegrator list
caseGSE6955 <- read_csv("GSE6955/caseGSE6955.csv")
ID1<-list()
ID1$formattedName<-'RTT'
ID1$class<-setNames(caseGSE6955$state,colnames(GSE6955_filteredb))

ID1$expr<-GSE6955_filteredb
ID1$pheno<-caseGSE6955
g103965<-GSE6955_final@featureData@data[["SYMBOL"]]
keys103<-setNames(g103965, GSE6955_final@featureData@data[["PROBEID"]])
ID1$keys<-keys103
checkDataObject(ID1, "Dataset")


#finaland create the metaObject
discovery_datasets <- list(ID1, ID2,ID3)
names(discovery_datasets) = c(ID1$formattedName, ID2$formattedName,ID3$formattedName)
MetaObj=list() 
MetaObj$originalData <- discovery_datasets
checkDataObject(MetaObj, "Meta", "Pre-Analysis")
library(MetaIntegrator)
finalll<-geneSymbolCorrection(MetaObj)
sMetaObj <- runMetaAnalysis(finalll,maxCores = 1)


#filter at FDR=0.05
leMetaAnalysis <- filterGenes(sMetaObj, isLeaveOneOut = F, effectSizeThresh = 1, FDRThresh = 0.05)
#extraction of effect size
effectsize<-data.table::data.table(summarizeFilterResults(leMetaAnalysis, "FDR0.05_es1_nStudies1_looaFALSE_hetero0"))

#forwardsearch for more accurate selection (featureselection)
forwardRes <- forwardSearch(leMetaAnalysis, leMetaAnalysis$filterResults[[1]], forwardThresh = 0)
up<-effectsize[[1]][[1]]
down<-effectsize[[1]][[2]]
positive<-forwardRes[["posGeneNames"]]
negative<-forwardRes[["negGeneNames"]]
write.csv(positive,"forwardfilteredup.csv")
write.csv(negative,"forwardfiltereddown.csv")
#subsetting the up and down regulating gene after feature selection
upfiltered<-subset(up, rownames(up) %in% positive)
downfilterd<-subset(down, rownames(down) %in% negative)
write.csv(upfiltered,"upregulated.csv")
write.csv(downfilterd,"downregulated.csv")

h<-leMetaAnalysis
h[["filterResults"]][["FDR0.05_es1_nStudies1_looaFALSE_hetero0"]][["posGeneNames"]]<-upp$gene
h[["filterResults"]][["FDR0.05_es1_nStudies1_looaFALSE_hetero0"]][["negGeneNames"]]<-downn$gene

lincsHits <- lincsCorrelate( metaObject = h, filterObject = h$filterResults[[1]], dataset = "CP", direction = "reverse",cor.method = "pearson")

lincsHits <- lincsCorrelate( metaObject = h, filterObject = h$filterResults[[1]], dataset = "SH", direction = "reverse",cor.method = "pearson")

lincsHits <- lincsCorrelate( metaObject = sMetaObj, filterObject = leMetaAnalysis$filterResults[[1]], dataset = "LIG", direction = "reverse",cor.method = "pearson")
