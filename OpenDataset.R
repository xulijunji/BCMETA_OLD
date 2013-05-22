OpenDataset <- function(config.file){
  #Open every GSE, specify in the configuration CSV, from InsilicoDB and create a list of Eset
  #structure call gselist
  #
  # Args:
  #   config.file: The string name of the configuration CSV file
  #
  # Returns:
  #   The GSE list of the specify GSE number in the configuraiton CSV file
  library(inSilicoDb2)
  
  InSilicoLogin(login="bhaibeka@gmail.com", password="747779bec8a754b91076d6cc1f700831")
  
  FTO=read.csv(config.file) #File To Open (FTO)
  gselist <- list()
  expr.rowname <- NULL
  #Opening all dataset from InsilicoDB
  for (i in 1:nrow(FTO)){
    GPL <- getPlatforms(dataset=as.character(FTO[i,2]))[1]
    gselist[[i]] <- getDataset(dataset=as.character(FTO[i,2]), curation=FTO[i,3], platform=GPL)
    expr.rowname <- c(expr.rowname, rownames(exprs(gselist[[i]])))
  } 
  #Eliminating all doubles to create a master gene vector
  expr.rowname <- unique(expr.rowname)
  
  #Merging all the gene expression of all GSE for all sample into
  #one master matrix whom each row are matching with the master gene vector
  for (i in 1:length(gselist)){
    temp <- matrix(NA,length(expr.rowname),ncol(exprs(gselist[[i]])))
    rownames(temp) <- expr.rowname
    colnames(temp) <- colnames(exprs(gselist[[i]]))
    matcher <- match(rownames(exprs(gselist[[i]])),expr.rowname)  
    temp[matcher,1:ncol(exprs(gselist[[i]]))]=exprs(gselist[[i]])
    if (i==1){
      matrix.exprs <- temp
    } else{
      matrix.exprs <- cbind(matrix.exprs,temp)
    }
  }
  InSilicoLogout()
  
  #Clinical Info Standard (CIS)
  CIS <- c("tissue", "age", "node", "treatment", "pgr", "grade", "platform", 
        "size", "er", "t.rfs", "e.rfs", "id", "series", "her2", "t.dmfs", 
        "e.dmfs")
  # Error handling
  for (i in 1:length(gselist)){    
    if (any(varLabels(gselist[[i]]) != CIS) == TRUE){
      warning(sprintf("the %s dataset as been incorrectly curated", FTO[i,2]))
    }
  }
  
  return(list("gselist"=gselist, "matrix.exprs"=matrix.exprs))
}