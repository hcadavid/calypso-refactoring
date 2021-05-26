c.svm<-function(cal,groupBy="group"){
	library(e1071)

	taxa<-c.taxa(cal)
	ca<-c.annotatedCounts(cal)

	x<-as.matrix(ca[,taxa])
	y<-as.factor(c.groups(cal,groupBy=groupBy))

#	y<-sample(y)

        print(unique(y))
        
	if(length(unique(y)) != 2){
		     errm<-"ERROR: exactly two groups required"
		     warning(errm)
		     textplot(errm)
		     return(1)
	}

	t<-0
	tA<-0
	fA<-0
	tB<-0
	fB<-0

	groupA<-unique(y)[1]
	groupB<-unique(y)[2]

	gridSearch<-T

	gamma<-1
	cost<-1
	
	n<-dim(x)[1]
	for(i in 1:n){
	      test.x<-subset(x,1:n==i)
	      test.y<-y[i]
	
		train.x<-x[-i,]
		train.y<-y[-i]

		if(gridSearch){
		gridSearch<-F
		g.default<-floor(log2(1/ncol(train.x)))
		cat("Grid search for gamma and cost ...")
		mod<-.c.tune(svm,train.x,train.y,scale=T,
			ranges = list(gamma = 2^((g.default-4):(g.default+3)), cost = 2^(-2:3)))$best.model
		cat(" Done.\n")
		gamma<-mod$gamma
		cost<-mod$cost
		print(paste("Gamma:",gamma,"Cost:",cost))
		}
		else mod<-svm(train.x,train.y,scale=T,cost=cost,gamma=gamma)
		print(gamma)
		print(cost)

		predict.y<-as.character(predict(mod,test.x))
		if(predict.y==test.y){
			t<-t+1
			if(test.y==groupA) tA<-tA+1
			else tB<-tB+1
		}
		else{
			if(test.y==groupA) fA<-fA+1
			else fB<-fB+1
		}

	}

	sensA<-signif(tA/(tA+fA),2)
	sensB<-signif(tB/(tB+fB),2)

	specA<-signif(tA/(tA+fB),2)
	specB<-signif(tB/(tB+fA),2)

	acc<-signif((t)/n,2)
	print(paste("Accuracy:",acc))
		textplot(paste("Leave-one-out crossvalidation of SVM classifer:\n\n","Accuracy:",acc,"\nSensitivity group",
					      groupA,sensA,
					      "\nSensitivity group",groupB,sensB,"\nSpecificity group",groupA,specA,
					      "\nSpecificity group",groupB,specB))
	return(1)
}





.c.tune <- function(method, train.x, train.y = NULL, data = list(),
                 validation.x = NULL, validation.y = NULL,
                 ranges = NULL, predict.func = predict,
                 tunecontrol = tune.control(),
                 ...
                 ) {
    call <- match.call()

    ## internal helper functions
    resp <- function(formula, data) {
        
        model.response(model.frame(formula, data))
    }

    classAgreement <- function (tab) {
        n <- sum(tab)
        if (!is.null(dimnames(tab))) {
            lev <- intersect(colnames(tab), rownames(tab))
            p0 <- sum(diag(tab[lev, lev])) / n
        } else {
            m <- min(dim(tab))
            p0 <- sum(diag(tab[1:m, 1:m])) / n
        }
        p0
    }

    ## parameter handling
    if (tunecontrol$sampling == "cross")
        validation.x <- validation.y <- NULL
    useFormula <- is.null(train.y)
    if (useFormula && (is.null(data) || length(data) == 0))
        data <- model.frame(train.x)
    if (is.vector(train.x)) train.x <- t(t(train.x))
    if (is.data.frame(train.y))
        train.y <- as.matrix(train.y)

    ## prepare training indices
    if (!is.null(validation.x)) tunecontrol$fix <- 1
    n <- nrow(if (useFormula) data else train.x)
    perm.ind <- sample(n)
    if (tunecontrol$sampling == "cross") {
        if (tunecontrol$cross > n)
            stop(sQuote("cross"), " must not exceed sampling size!")
        if (tunecontrol$cross == 1)
            stop(sQuote("cross"), " must be greater than 1!")
    }
    train.ind <- if (tunecontrol$sampling == "cross")
        tapply(1:n, cut(1:n, breaks = tunecontrol$cross), function(x) perm.ind[-x])
    else if (tunecontrol$sampling == "fix")
        list(perm.ind[1:trunc(n * tunecontrol$fix)])
    else ## bootstrap
        lapply(1:tunecontrol$nboot,
               function(x) sample(n, n * tunecontrol$boot.size, replace = TRUE))

    ## find best model
    parameters <- if (is.null(ranges))
        data.frame(dummyparameter = 0)
    else
        expand.grid(ranges)
    p <- nrow(parameters)
    if (!is.logical(tunecontrol$random)) {
        if (tunecontrol$random < 1)
            stop("random must be a strictly positive integer")
        if (tunecontrol$random > p) tunecontrol$random <- p
        parameters <- parameters[sample(1:p, tunecontrol$random),]
    }
    model.variances <- model.errors <- c()

    ## - loop over all models
    for (para.set in 1:p) {
        sampling.errors <- c()

        ## - loop over all training samples
        for (sample in 1:length(train.ind)) {
            repeat.errors <- c()

            ## - repeat training `nrepeat' times
            for (reps in 1:tunecontrol$nrepeat) {

                ## train one model
                pars <- if (is.null(ranges))
                    NULL
                else
                    lapply(parameters[para.set,,drop = FALSE], unlist)

                model <- if (useFormula)
                    do.call(method, c(list(train.x,
                                           data = data,
                                           subset = train.ind[[sample]]),
                                      pars, list(...)
                                      )
                            )
                else
                    do.call(method, c(list(train.x[train.ind[[sample]],],
                                           y = train.y[train.ind[[sample]]]),
                                      pars, list(...)
                                      )
                            )

                ## predict validation set
                pred <- predict.func(model,
                                     if (!is.null(validation.x))
                                     validation.x
                                     else if (useFormula)
                                     data[-train.ind[[sample]],,drop = FALSE]
                                     else
                                     train.x[-train.ind[[sample]],,drop = FALSE]
                                     )

                ## compute performance measure
                true.y <- if (!is.null(validation.y))
                    validation.y
                else if (useFormula) {
                    if (!is.null(validation.x))
                        resp(train.x, validation.x)
                    else
                        resp(train.x, data[-train.ind[[sample]],])
                } else
                    train.y[-train.ind[[sample]]]

                if (is.null(true.y)) true.y <- rep(TRUE, length(pred))

                repeat.errors[reps] <- if (!is.null(tunecontrol$error.fun))
                    tunecontrol$error.fun(true.y, pred)
                else if ((is.logical(true.y) || is.factor(true.y)) && (is.logical(pred) || is.factor(pred) || is.character(pred))) ## classification error
                    1 - classAgreement(table(pred, true.y))
                else if (is.numeric(true.y) && is.numeric(pred)) ## mean squared error
                    crossprod(pred - true.y) / length(pred)
                else
                    stop("Dependent variable has wrong type!")
            }
            sampling.errors[sample] <- tunecontrol$repeat.aggregate(repeat.errors)
        }
        model.errors[para.set] <- tunecontrol$sampling.aggregate(sampling.errors)

 #    model.variances[para.set] <- tunecontrol$sampling.dispersion(sampling.errors)
         }

    ## return results
    best <- which.min(model.errors)
    pars <- if (is.null(ranges))
        NULL
    else
        lapply(parameters[best,,drop = FALSE], unlist)
    structure(list(best.parameters  = parameters[best,,drop = FALSE],
                   best.performance = model.errors[best],
                   method           = if (!is.character(method))
                   deparse(substitute(method)) else method,
                   nparcomb         = nrow(parameters),
                   train.ind        = train.ind,
                   sampling         = switch(tunecontrol$sampling,
                   fix = "fixed training/validation set",
                   bootstrap = "bootstrapping",
                   cross = if (tunecontrol$cross == n) "leave-one-out" else
                   paste(tunecontrol$cross,"-fold cross validation", sep="")
                   ),
                   performances     = if (tunecontrol$performances) cbind(parameters, error = model.errors),
                   best.model       = if (tunecontrol$best.model) {
                       modeltmp <- if (useFormula)
                           do.call(method, c(list(train.x, data = data),
                                             pars, list(...)))
                       else
                           do.call(method, c(list(x = train.x,
                                                  y = train.y),
                                             pars, list(...)))
                       call[[1]] <- as.symbol("best.tune")
                       modeltmp$call <- call
                       modeltmp
                   }
                   ),
              class = "tune"
              )
}



envTaxaCorMatrix<-function(cal,col="heat",title="Pearson's cor"){

    cal<-env2numeric(cal)
  en<-c.environment.vars(cal)
  taxa<-c.taxa(cal)
  a<-c.annotatedCounts(cal,na.omit=T)
    en<-en[en%in%names(a)]

    
    if(dim(a)[1]==0){
        errorm<-"ERROR: empdy data matrix after removing rows with undefined values"
        textplot(errorm)
        return(-1)
    }
    
  en.new<-c()
  
  for (e in en){
    if(is.numeric(a[,e])){
      en.new<-c(en.new,e)
    }
  }

  en<-en.new
  
  ncol<-length(taxa)
  nrow<-length(en)
  m<-matrix(nrow=nrow,ncol=ncol)

  for (i in 1:ncol){
    for (j in 1:nrow){
      t<-taxa[i]
      e<-en[j]

      c<-cor(a[,t],a[,e])
      m[j,i]<-c
    }
  }
  rownames(m)<-en
  colnames(m)<-taxa

  col<-getColors(col,40)

  # remove taxa with only na

  m<-m[,apply(is.na(m),2,sum) < dim(m)[1]]

  m<-na.omit(m)

  if(is.null(dim(m))){
    warning("Warning: heatmap requires at least 2 rows")
    stop(1)
  }
  
  heatmap.3(m, Rowv=T, Colv=T, dendrogram="both",col=col,scale="none",trace="none",symbreaks=T,cexRow=0.8,cexCol=0.8,main=title,margins=c(15,20),
  	       lwid=c(1,4.5))

  return(m)
}


c.filter.p<-function(cal,p=0.05,groupBy="group"){

	if(p<1){		
		ctmp<-c.counts(cal)
		groups<-c.groups(cal,groupBy)
		taxa<-c.taxa(cal)

		if(length(unique(groups)) < 2){				
		     stop("ERROR: Only one group defined, at least two groups required")
		}

		exclude<-c()
		for(t in taxa){
		      c<-ctmp[,t]

		      a<-aov(c ~ groups)
		      pa<-anova(a)$"Pr(>F)"[1]	
		      if(pa>p) exclude<-c(exclude,t)
		}     

		taxa<-taxa[! taxa %in% exclude]
		cal$taxa<-taxa
		cal[[cal$rank]]<-ctmp[,taxa]
	}
	return(cal)
}

c.dapc<-function(cal,title="",labels=F,color="default",groupSymbols=T,groupBy="group",
	scale=F){

   library("adegenet")

   cal<-setColorsAndSymbols(cal,colorBy=groupBy,color=color)


  ac<-c.annotatedCounts(cal,na.omit=F)
  groups<-c.groups(cal,groupBy=groupBy)

  if(length(unique(groups)) < 2){
  	errm<-"ERROR: less than 2 groups"
	warning(errm)
	textplot(errm)
	return(0)
  }

  taxa<-c.taxa(cal)
  counts<-ac[,taxa]

  
    layout(matrix(c(1,2), 1, 2, byrow = TRUE),widths=c(1,1) )

    n.da<-dim(counts)[1]
    n.pca<-floor(n.da/3)


  d<-dapc(counts,grp=groups,n.pca=n.pca,n.da=n.da,scale=scale)
  scatter(d, cell=1, cstar=1, mstree=F, lwd=2, lty=2)
  loadingplot(d$var.contr)

}

c.betadisper<-function(cal,method=method,groupBy="group"){
	library(vegan)

	taxa<-c.taxa(cal)
	ca<-c.annotatedCounts(cal)

        dis<-1
        if(method=="distFile") dis<-as.dist(c.distanceMatrix(cal),diag=F,upper=F)
	else dis<-distWrapper(ca[,taxa],diag=F,upper=F,method=method)	

	groups<-c.groups(cal,groupBy=groupBy)

	mod<-betadisper(dis,groups)
	p<-signif(anova(mod)$"Pr(>F)"[1],4)
	plot(mod,main=paste("PERMDISP2 (betadisper) P = ",p,",",method,"distance"))
}

c.adonis<-function(cal,type="group",scale=F,groupBy="group"){
	require(vegan)

	print("Running adonis")

        ca<-c.annotatedCounts(cal,orderBy="GST")
	taxa<-c.taxa(cal)
        groups<-ca$group
        counts<-ca[,c.taxa(cal)]
	

	if(scale){
		counts<-scale(counts)
	}

	ad<-1
	if(type == "group"){          
		attach(ca)
		f<-as.formula(paste("ca[,taxa] ~",groupBy))
		ad<-adonis(f,permutations=1500)
	}	
	else if(type == "group+"){
	attach(ca)
	  ad<-adonis(ca[,taxa] ~ group * pair * time,permutations=1500)
	}	
	else if(type == "env"){
 	 envs<-c.environment.vars(cal)
	 
	  f<-as.formula(paste("ca[,taxa] ~ ",paste(envs,collapse=" * ")))

	  for(e in envs) ca<-ca[!is.na(ca[,e]),]

	  attach(ca)

	  ad<-adonis(f,permutations=1500)
	  
	}
	at<-ad$aov.tab

	names<-rownames(at)
	p<-at$"Pr(>F)"

	select<-1:(dim(at)[1]-2)

	df<-data.frame(P=p[select])
	rownames(df)<-names[select]

	textplot(signif(df,3))
	return(ad)
}

c.anosim<-function(cal,out,groupBy="group",scale=F,method="jaccard",figureFormat="png",width=600,height=600,res=300,color="default"){
  
	require(vegan)

        cal<-c.setGroups(cal,groupBy=groupBy)

        groups<-1
        
        dist<-1
        if(method=="distFile"){
            dist<-as.dist(c.distanceMatrix(cal),diag=F,upper=F)
            groups<-c.groups(cal)
        }
        else{
            counts<-c.annotatedCounts(cal,orderBy="GST")
            groups<-counts$group
            counts<-counts[,c.taxa(cal)]
            
            if(scale){
		counts<-scale(counts)
            }
            
                                        # get distance matrix
            dist<-distWrapper(counts,diag=F,upper=F,method=method)
        }

        if(any(is.na(groups))) groups[is.na(groups)]<-"NA"

        an<-anosim(dist,groups)

        
        plotFigure<-T
        
	if(is.na(figureFormat)) plotFigure <-F

	  else if(figureFormat == "pdf"){
            pdf(out,width=width,height=height)
          }
	  else if(figureFormat == "svg"){
            svg(out,width=width,height=height)
	  }
	  else{
             png(out,width=width,height=height,res=res,units="mm")
	   }	

	 
	colors<-getColors(color,length(unique(groups)) + 1)
	plot(an,col=colors)

	if(plotFigure) dev.off()

	return(an)
}

c.distplot<-function(cal,out,groupBy="group",scale=F,method="jaccard",figureFormat="png",width=600,height=600,res=300,color="default"){
  
	require(vegan)

        cal<-c.setGroups(cal,groupBy=groupBy)

        dist<-1
        groups<-1
        if(method=="distFile"){
            dist<-as.matrix(as.dist(c.distanceMatrix(cal),diag=T,upper=T))
            groups<-c.groups(cal)
        }
        else{
            counts<-c.annotatedCounts(cal,orderBy="GST")
            groups<-counts$group
            counts<-counts[,c.taxa(cal)]
            
            if(scale) counts<-scale(counts)
            
            
                                        # get distance matrix
            dist<-as.matrix(distWrapper(counts,diag=T,upper=T,method=method))
        }

        if(any(is.na(groups))) groups[is.na(groups)]<-"NA"
        
	plotFigure<-T
	
	if(is.na(figureFormat)) plotFigure <-F

	  else if(figureFormat == "pdf"){
            pdf(out,width=width,height=height)
          }
	  else if(figureFormat == "svg"){
            svg(out,width=width,height=height)
	  }
	  else{
             png(out,width=width,height=height,res=res,units="mm")
	   }	

	 
	colors<-getColors(color,length(unique(groups)) + 1)

	samples<-c.labels(cal)
	sampleN<-length(samples)
	
	dc<-c()
	gc<-c()
	for(i in 1:(sampleN-1)){
	   for(j in (i+1):sampleN){
	     sA<-samples[i]
	     gA<-groups[i]
	     sB<-samples[j]
	     gB<-groups[j]
	     d<-dist[sA,sB]

             
	     gr<-"Between"
	     if(gA == gB) gr<-gA
	     dc<-c(dc,d)
	     gc<-c(gc,gr)
	   }

	}	
	df<-data.frame(Dist=dc,Group=gc)
	between<-df[df$Group=="Between",]$Dist
	intra<-df[df$Group!="Between",]$Dist


	p<-signif(t.test(between,intra)$p.value,4)

	layout(matrix(c(1,2,2), 1, 3, byrow = TRUE))
	boxplot(list(Between=between,Intra=intra),notch=TRUE,varwidth=TRUE,col=colors,main=paste0("P=",p," (t-test)"))
	boxplot(Dist~Group,df,notch=TRUE,varwidth=TRUE,col=colors,las=2)

	if(plotFigure) dev.off()

	return(df)
}


c.stratify<-function(cal,stratify=c()){
  if(! length(stratify) > 0) return(cal$stratify)

  stratify<-make.names(stratify)

  if(sum(stratify %in% cal$envs) < length(stratify)) stop("ERROR: all stratify vars have to be defined in envs")

  cal$stratify<-stratify

  return(cal)
}

# make sure taxa don't start with number
c.safe.taxa<-function(cal){
  ranks<-cal$ranks

  for(r in ranks){
    d<-cal[[r]]
    colnames(d)<-make.names(colnames(d))
    cal[[r]]<-d
  }

  return(cal)
}

env2numeric<-function(cal){
	annot<-cal$annot

	envs<-c.environment.vars(cal)
	envs.new<-c()

	for(e in envs){
	  v<-annot[,e]
    	  if(is.numeric(v)){
		envs.new<-c(envs.new,e)
	  }
	  else{
	      annot[,e]<-NULL
	      groups<-unique(v)

	      if(length(groups) == 2) groups<-sort(groups)[1]

		for(g in groups){
	          name<-make.names(paste(e,g,sep="."))
		  envs.new<-c(envs.new,name)
	      	  annot[,name]<-0
		  annot[which(v==g),name]<-1
	      	  }
		  
	  }
  	}
	cal$annot<-annot
	cal$envs<-envs.new
	return(cal)
}

parnet<-function(cal,type="graph+",method="pearson",grid=c(4,3),ctype="black",corMatrix=NA,...){
	cal<-env2numeric(cal)

  ca<-c.annotatedCounts(cal)
#  ca<-c.annotatedCounts(cal)
  envs<-c.environment.vars(cal)
  taxa<-c.taxa(cal)

  incl<-c()
  for(e in envs){
    if(is.numeric(ca[,e])) incl<-c(incl,e)
  }
  ca<-ca[,c(incl,taxa)]

  # remove NAs
  ca<-ca[,apply(apply(ca,2,is.na),2,sum) < dim(ca)[1]]
  ca<-na.omit(ca)

  if(type %in% c("som","som+")){
    require("kohonen")

    if(type == "som") ca<-ca[,taxa]

    if(dim(ca)[2] > 14){
       ca.mean<-apply(ca[,taxa],2,mean)
       taxaN<-14
       if(type=="som+") taxaN<-14-length(incl)
       taxa.incl<-sort(taxa[order(ca.mean,decreasing=T)[1:taxaN]])
       
       if(type=="som+") ca<-ca[,c(incl,taxa.incl)]
       else ca<-ca[,taxa.incl]
    }

    if(grid[1]*grid[2] > dim(ca)[1]) grid<-c(4,4)
    if(grid[1]*grid[2] > dim(ca)[1]) grid<-c(4,3)
    if(grid[1]*grid[2] > dim(ca)[1]) grid<-c(3,3)
    if(grid[1]*grid[2] > dim(ca)[1]) grid<-c(3,2)
    if(grid[1]*grid[2] > dim(ca)[1]) grid<-c(2,2)
    if(grid[1]*grid[2] > dim(ca)[1]) stop("ERROR: insufficient samples")

    ca.som<-som(data=scale(as.matrix(ca)),grid=somgrid(grid[1],grid[2]))

    layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE),heights=c(2,1))
    plot(ca.som)
    plot(ca.som,type="counts",main="Number of assigned samples\n(Empty nodes in grey)")
    plot(ca.som,type="quality",main="Mean distance to\nrepresentative vector of node")

    return(1)
  }

  co<-cor(ca,method=method)

  groups<-as.numeric(names(ca) %in% envs)
  colors<-rep("lightblue",length(groups))
  colors[groups=1]<-"red"
  lcolor<-"white"
  if(ctype=="white") lcolor<-"black"
  vCol<-rep(lcolor,length(groups))
  vCol[groups==1]<-"red"
  
  freq<-as.numeric(apply(ca,2,mean))
  freq[names(ca) %in% envs]<-5
  
  if((! is.na(corMatrix)) && type=="graph+"){
        write.csv(file=corMatrix,co,quote=F,row.names=T) 
  }   
  correlation.network(co,colors=colors,freq=freq,vCol=vCol,ctype=ctype,...)
  
  return(co)
}

# downloaded from https://raw.githubusercontent.com/obigriffith/biostar-tutorials/master/Heatmaps/heatmap.3.R
heatmap.3x <- function(x,
                      Rowv = TRUE, Colv = if (symm) "Rowv" else TRUE,
                      distfun = dist,
                      hclustfun = hclust,
                      dendrogram = c("both","row", "column", "none"),
                      symm = FALSE,
                      scale = c("none","row", "column"),
                      na.rm = TRUE,
                      revC = identical(Colv,"Rowv"),
                      add.expr,
                      breaks,
                      symbreaks = max(x < 0, na.rm = TRUE) || scale != "none",
                      col = "heat.colors",
                      colsep,
                      rowsep,
                      sepcolor = "white",
                      sepwidth = c(0.05, 0.05),
                      cellnote,
                      notecex = 1,
                      notecol = "cyan",
                      na.color = par("bg"),
                      trace = c("none", "column","row", "both"),
                      tracecol = "cyan",
                      hline = median(breaks),
                      vline = median(breaks),
                      linecol = tracecol,
                      margins = c(5,5),
                      ColSideColors,
                      RowSideColors,
                      side.height.fraction=0.3,
                      cexRow = 0.2 + 1/log10(nr),
                      cexCol = 0.2 + 1/log10(nc),
                      labRow = NULL,
                      labCol = NULL,
                      key = TRUE,
                      keysize = 1.5,
                      density.info = c("none", "histogram", "density"),
                      denscol = tracecol,
                      symkey = max(x < 0, na.rm = TRUE) || symbreaks,
                      densadj = 0.25,
                      main = NULL,
                      xlab = NULL,
                      ylab = NULL,
                      lmat = NULL,
                      lhei = NULL,
                      lwid = NULL,
                      ColSideColorsSize = 1,
                      RowSideColorsSize = 1,
                      KeyValueName="Value",...){
 
    invalid <- function (x) {
      if (missing(x) || is.null(x) || length(x) == 0)
          return(TRUE)
      if (is.list(x))
          return(all(sapply(x, invalid)))
      else if (is.vector(x))
          return(all(is.na(x)))
      else return(FALSE)
    }
 
    x <- as.matrix(x)
    scale01 <- function(x, low = min(x), high = max(x)) {
        x <- (x - low)/(high - low)
        x
    }
    retval <- list()
    scale <- if (symm && missing(scale))
        "none"
    else match.arg(scale)
    dendrogram <- match.arg(dendrogram)
    trace <- match.arg(trace)
    density.info <- match.arg(density.info)
    if (length(col) == 1 && is.character(col))
        col <- get(col, mode = "function")
    if (!missing(breaks) && (scale != "none"))
        warning("Using scale=\"row\" or scale=\"column\" when breaks are",
            "specified can produce unpredictable results.", "Please consider using only one or the other.")
    if (is.null(Rowv) || is.na(Rowv))
        Rowv <- FALSE
    if (is.null(Colv) || is.na(Colv))
        Colv <- FALSE
    else if (Colv == "Rowv" && !isTRUE(Rowv))
        Colv <- FALSE
    if (length(di <- dim(x)) != 2 || !is.numeric(x))
        stop("`x' must be a numeric matrix")
    nr <- di[1]
    nc <- di[2]
    if (nr <= 1 || nc <= 1)
        stop("`x' must have at least 2 rows and 2 columns")
    if (!is.numeric(margins) || length(margins) != 2)
        stop("`margins' must be a numeric vector of length 2")
    if (missing(cellnote))
        cellnote <- matrix("", ncol = ncol(x), nrow = nrow(x))
    if (!inherits(Rowv, "dendrogram")) {
        if (((!isTRUE(Rowv)) || (is.null(Rowv))) && (dendrogram %in%
            c("both", "row"))) {
            if (is.logical(Colv) && (Colv))
                dendrogram <- "column"
            else dedrogram <- "none"
            warning("Discrepancy: Rowv is FALSE, while dendrogram is `",
                dendrogram, "'. Omitting row dendogram.")
        }
    }
    if (!inherits(Colv, "dendrogram")) {
        if (((!isTRUE(Colv)) || (is.null(Colv))) && (dendrogram %in%
            c("both", "column"))) {
            if (is.logical(Rowv) && (Rowv))
                dendrogram <- "row"
            else dendrogram <- "none"
            warning("Discrepancy: Colv is FALSE, while dendrogram is `",
                dendrogram, "'. Omitting column dendogram.")
        }
    }
    if (inherits(Rowv, "dendrogram")) {
        ddr <- Rowv
        rowInd <- order.dendrogram(ddr)
    }
    else if (is.integer(Rowv)) {
        hcr <- hclustfun(distfun(x))
        ddr <- as.dendrogram(hcr)
        ddr <- reorder(ddr, Rowv)
        rowInd <- order.dendrogram(ddr)
        if (nr != length(rowInd))
            stop("row dendrogram ordering gave index of wrong length")
    }
    else if (isTRUE(Rowv)) {
        Rowv <- rowMeans(x, na.rm = na.rm)
        hcr <- hclustfun(distfun(x))
        ddr <- as.dendrogram(hcr)
        ddr <- reorder(ddr, Rowv)
        rowInd <- order.dendrogram(ddr)
        if (nr != length(rowInd))
            stop("row dendrogram ordering gave index of wrong length")
    }
    else {
        rowInd <- nr:1
    }
    if (inherits(Colv, "dendrogram")) {
        ddc <- Colv
        colInd <- order.dendrogram(ddc)
    }
    else if (identical(Colv, "Rowv")) {
        if (nr != nc)
            stop("Colv = \"Rowv\" but nrow(x) != ncol(x)")
        if (exists("ddr")) {
            ddc <- ddr
            colInd <- order.dendrogram(ddc)
        }
        else colInd <- rowInd
    }
    else if (is.integer(Colv)) {
        hcc <- hclustfun(distfun(if (symm)
            x
        else t(x)))
        ddc <- as.dendrogram(hcc)
        ddc <- reorder(ddc, Colv)
        colInd <- order.dendrogram(ddc)
        if (nc != length(colInd))
            stop("column dendrogram ordering gave index of wrong length")
    }
    else if (isTRUE(Colv)) {
        Colv <- colMeans(x, na.rm = na.rm)
        hcc <- hclustfun(distfun(if (symm)
            x
        else t(x)))
        ddc <- as.dendrogram(hcc)
        ddc <- reorder(ddc, Colv)
        colInd <- order.dendrogram(ddc)
        if (nc != length(colInd))
            stop("column dendrogram ordering gave index of wrong length")
    }
    else {
        colInd <- 1:nc
    }
    retval$rowInd <- rowInd
    retval$colInd <- colInd
    retval$call <- match.call()
    x <- x[rowInd, colInd]
    x.unscaled <- x
    cellnote <- cellnote[rowInd, colInd]
    if (is.null(labRow))
        labRow <- if (is.null(rownames(x)))
            (1:nr)[rowInd]
        else rownames(x)
    else labRow <- labRow[rowInd]
    if (is.null(labCol))
        labCol <- if (is.null(colnames(x)))
            (1:nc)[colInd]
        else colnames(x)
    else labCol <- labCol[colInd]
    if (scale == "row") {
        retval$rowMeans <- rm <- rowMeans(x, na.rm = na.rm)
        x <- sweep(x, 1, rm)
        retval$rowSDs <- sx <- apply(x, 1, sd, na.rm = na.rm)
        x <- sweep(x, 1, sx, "/")
    }
    else if (scale == "column") {
        retval$colMeans <- rm <- colMeans(x, na.rm = na.rm)
        x <- sweep(x, 2, rm)
        retval$colSDs <- sx <- apply(x, 2, sd, na.rm = na.rm)
        x <- sweep(x, 2, sx, "/")
    }
    if (missing(breaks) || is.null(breaks) || length(breaks) < 1) {
        if (missing(col) || is.function(col))
            breaks <- 16
        else breaks <- length(col) + 1
    }
    if (length(breaks) == 1) {
        if (!symbreaks)
            breaks <- seq(min(x, na.rm = na.rm), max(x, na.rm = na.rm),
                length = breaks)
        else {
            extreme <- max(abs(x), na.rm = TRUE)
            breaks <- seq(-extreme, extreme, length = breaks)
        }
    }
    nbr <- length(breaks)
    ncol <- length(breaks) - 1
    if (class(col) == "function")
        col <- col(ncol)
    min.breaks <- min(breaks)
    max.breaks <- max(breaks)
    x[x < min.breaks] <- min.breaks
    x[x > max.breaks] <- max.breaks
    if (missing(lhei) || is.null(lhei))
        lhei <- c(keysize, 4)
    if (missing(lwid) || is.null(lwid))
        lwid <- c(keysize, 4)
    if (missing(lmat) || is.null(lmat)) {
        lmat <- rbind(4:3, 2:1)
 
        if (!missing(ColSideColors)) {
           #if (!is.matrix(ColSideColors))
           #stop("'ColSideColors' must be a matrix")
            if (!is.character(ColSideColors) || nrow(ColSideColors) != nc)
                stop("'ColSideColors' must be a matrix of nrow(x) rows")
            lmat <- rbind(lmat[1, ] + 1, c(NA, 1), lmat[2, ] + 1)
            #lhei <- c(lhei[1], 0.2, lhei[2])
             lhei=c(lhei[1], side.height.fraction*ColSideColorsSize/2, lhei[2])
        }
 
        if (!missing(RowSideColors)) {
            #if (!is.matrix(RowSideColors))
            #stop("'RowSideColors' must be a matrix")
            if (!is.character(RowSideColors) || ncol(RowSideColors) != nr)
                stop("'RowSideColors' must be a matrix of ncol(x) columns")
            lmat <- cbind(lmat[, 1] + 1, c(rep(NA, nrow(lmat) - 1), 1), lmat[,2] + 1)
            #lwid <- c(lwid[1], 0.2, lwid[2])
            lwid <- c(lwid[1], side.height.fraction*RowSideColorsSize/2, lwid[2])
        }
        lmat[is.na(lmat)] <- 0
    }
 
    if (length(lhei) != nrow(lmat))
        stop("lhei must have length = nrow(lmat) = ", nrow(lmat))
    if (length(lwid) != ncol(lmat))
        stop("lwid must have length = ncol(lmat) =", ncol(lmat))
    op <- par(no.readonly = TRUE)
    on.exit(par(op))
 
    layout(lmat, widths = lwid, heights = lhei, respect = FALSE)
 
    if (!missing(RowSideColors)) {
        if (!is.matrix(RowSideColors)){
                par(mar = c(margins[1], 0, 0, 0.5))
                image(rbind(1:nr), col = RowSideColors[rowInd], axes = FALSE)
        } else {
            par(mar = c(margins[1], 0, 0, 0.5))
            rsc = t(RowSideColors[,rowInd, drop=F])
            rsc.colors = matrix()
            rsc.names = names(table(rsc))
            rsc.i = 1
            for (rsc.name in rsc.names) {
                rsc.colors[rsc.i] = rsc.name
                rsc[rsc == rsc.name] = rsc.i
                rsc.i = rsc.i + 1
            }
            rsc = matrix(as.numeric(rsc), nrow = dim(rsc)[1])
            image(t(rsc), col = as.vector(rsc.colors), axes = FALSE)
            if (length(rownames(RowSideColors)) > 0) {
                axis(1, 0:(dim(rsc)[2] - 1)/max(1,(dim(rsc)[2] - 1)), rownames(RowSideColors), las = 2, tick = FALSE)
            }
        }
    }
 
    if (!missing(ColSideColors)) {
 
        if (!is.matrix(ColSideColors)){
            par(mar = c(0.5, 0, 0, margins[2]))
            image(cbind(1:nc), col = ColSideColors[colInd], axes = FALSE)
        } else {
            par(mar = c(0.5, 0, 0, margins[2]))
            csc = ColSideColors[colInd, , drop=F]
            csc.colors = matrix()
            csc.names = names(table(csc))
            csc.i = 1
            for (csc.name in csc.names) {
                csc.colors[csc.i] = csc.name
                csc[csc == csc.name] = csc.i
                csc.i = csc.i + 1
            }
            csc = matrix(as.numeric(csc), nrow = dim(csc)[1])
            image(csc, col = as.vector(csc.colors), axes = FALSE)
            if (length(colnames(ColSideColors)) > 0) {
                axis(2, 0:(dim(csc)[2] - 1)/max(1,(dim(csc)[2] - 1)), colnames(ColSideColors), las = 2, tick = FALSE)
            }
        }
    }
 
    par(mar = c(margins[1], 0, 0, margins[2]))
    x <- t(x)
    cellnote <- t(cellnote)
    if (revC) {
        iy <- nr:1
        if (exists("ddr"))
            ddr <- rev(ddr)
        x <- x[, iy]
        cellnote <- cellnote[, iy]
    }
    else iy <- 1:nr
    image(1:nc, 1:nr, x, xlim = 0.5 + c(0, nc), ylim = 0.5 + c(0, nr), axes = FALSE, xlab = "", ylab = "", col = col, breaks = breaks, ...)
    retval$carpet <- x
    if (exists("ddr"))
        retval$rowDendrogram <- ddr
    if (exists("ddc"))
        retval$colDendrogram <- ddc
    retval$breaks <- breaks
    retval$col <- col
    if (!invalid(na.color) & any(is.na(x))) { # load library(gplots)
        mmat <- ifelse(is.na(x), 1, NA)
        image(1:nc, 1:nr, mmat, axes = FALSE, xlab = "", ylab = "",
            col = na.color, add = TRUE)
    }
    axis(1, 1:nc, labels = labCol, las = 2, line = -0.5, tick = 0,
        cex.axis = cexCol)
    if (!is.null(xlab))
        mtext(xlab, side = 1, line = margins[1] - 1.25)
    axis(4, iy, labels = labRow, las = 2, line = -0.5, tick = 0,
        cex.axis = cexRow)
    if (!is.null(ylab))
        mtext(ylab, side = 4, line = margins[2] - 1.25)
    if (!missing(add.expr))
        eval(substitute(add.expr))
    if (!missing(colsep))
        for (csep in colsep) rect(xleft = csep + 0.5, ybottom = rep(0, length(csep)), xright = csep + 0.5 + sepwidth[1], ytop = rep(ncol(x) + 1, csep), lty = 1, lwd = 1, col = sepcolor, border = sepcolor)
    if (!missing(rowsep))
        for (rsep in rowsep) rect(xleft = 0, ybottom = (ncol(x) + 1 - rsep) - 0.5, xright = nrow(x) + 1, ytop = (ncol(x) + 1 - rsep) - 0.5 - sepwidth[2], lty = 1, lwd = 1, col = sepcolor, border = sepcolor)
    min.scale <- min(breaks)
    max.scale <- max(breaks)
    x.scaled <- scale01(t(x), min.scale, max.scale)
    if (trace %in% c("both", "column")) {
        retval$vline <- vline
        vline.vals <- scale01(vline, min.scale, max.scale)
        for (i in colInd) {
            if (!is.null(vline)) {
                abline(v = i - 0.5 + vline.vals, col = linecol,
                  lty = 2)
            }
            xv <- rep(i, nrow(x.scaled)) + x.scaled[, i] - 0.5
            xv <- c(xv[1], xv)
            yv <- 1:length(xv) - 0.5
            lines(x = xv, y = yv, lwd = 1, col = tracecol, type = "s")
        }
    }
    if (trace %in% c("both", "row")) {
        retval$hline <- hline
        hline.vals <- scale01(hline, min.scale, max.scale)
        for (i in rowInd) {
            if (!is.null(hline)) {
                abline(h = i + hline, col = linecol, lty = 2)
            }
            yv <- rep(i, ncol(x.scaled)) + x.scaled[i, ] - 0.5
            yv <- rev(c(yv[1], yv))
            xv <- length(yv):1 - 0.5
            lines(x = xv, y = yv, lwd = 1, col = tracecol, type = "s")
        }
    }
    if (!missing(cellnote))
        text(x = c(row(cellnote)), y = c(col(cellnote)), labels = c(cellnote),
            col = notecol, cex = notecex)
    par(mar = c(margins[1], 0, 0, 0))
    if (dendrogram %in% c("both", "row")) {
        plot(ddr, horiz = TRUE, axes = FALSE, yaxs = "i", leaflab = "none")
    }
    else plot.new()
    par(mar = c(0, 0, if (!is.null(main)) 5 else 0, margins[2]))
    if (dendrogram %in% c("both", "column")) {
        plot(ddc, axes = FALSE, xaxs = "i", leaflab = "none")
    }
    else plot.new()
    if (!is.null(main))
        title(main, cex.main = 1.5 * op[["cex.main"]])
    if (key) {
        par(mar = c(5, 4, 2, 1), cex = 0.75)
        tmpbreaks <- breaks
        if (symkey) {
            max.raw <- max(abs(c(x, breaks)), na.rm = TRUE)
            min.raw <- -max.raw
            tmpbreaks[1] <- -max(abs(x), na.rm = TRUE)
            tmpbreaks[length(tmpbreaks)] <- max(abs(x), na.rm = TRUE)
        }
        else {
            min.raw <- min(x, na.rm = TRUE)
            max.raw <- max(x, na.rm = TRUE)
        }
 
        z <- seq(min.raw, max.raw, length = length(col))
        image(z = matrix(z, ncol = 1), col = col, breaks = tmpbreaks,
            xaxt = "n", yaxt = "n")
        par(usr = c(0, 1, 0, 1))
        lv <- pretty(breaks)
        xv <- scale01(as.numeric(lv), min.raw, max.raw)
        axis(1, at = xv, labels = lv)
        if (scale == "row")
            mtext(side = 1, "Row Z-Score", line = 2)
        else if (scale == "column")
            mtext(side = 1, "Column Z-Score", line = 2)
        else mtext(side = 1, KeyValueName, line = 2)
        if (density.info == "density") {
            dens <- density(x, adjust = densadj, na.rm = TRUE)
            omit <- dens$x < min(breaks) | dens$x > max(breaks)
            dens$x <- dens$x[-omit]
            dens$y <- dens$y[-omit]
            dens$x <- scale01(dens$x, min.raw, max.raw)
            lines(dens$x, dens$y/max(dens$y) * 0.95, col = denscol,
                lwd = 1)
            axis(2, at = pretty(dens$y)/max(dens$y) * 0.95, pretty(dens$y))
            title("Color Key\nand Density Plot")
            par(cex = 0.5)
            mtext(side = 2, "Density", line = 2)
        }
        else if (density.info == "histogram") {
            h <- hist(x, plot = FALSE, breaks = breaks)
            hx <- scale01(breaks, min.raw, max.raw)
            hy <- c(h$counts, h$counts[length(h$counts)])
            lines(hx, hy/max(hy) * 0.95, lwd = 1, type = "s",
                col = denscol)
            axis(2, at = pretty(hy)/max(hy) * 0.95, pretty(hy))
            title("Color Key\nand Histogram")
            par(cex = 0.5)
            mtext(side = 2, "Count", line = 2)
        }
        else title("Color Key")
    }
    else plot.new()
    retval$colorTable <- data.frame(low = retval$breaks[-length(retval$breaks)],
        high = retval$breaks[-1], color = retval$col)
    invisible(retval)
}

heatmap.3<-function (x, colormatrix, Rowv = TRUE, Colv = if (symm) "Rowv" else TRUE, 
    distfun = dist, hclustfun = hclust, dendrogram = c("both", 
        "row", "column", "none"), symm = FALSE, scale = c("none", 
        "row", "column"), na.rm = TRUE, revC = identical(Colv, 
        "Rowv"), add.expr, breaks, symbreaks = min(x < 0, na.rm = TRUE) || 
        scale != "none", col = "heat.colors", colsep, rowsep, 
    sepcolor = "white", sepwidth = c(0.05, 0.05), cellnote, notecex = 1, 
    notecol = "cyan", na.color = par("bg"), trace = c("column", 
        "row", "both", "none"), tracecol = "cyan", hline = median(breaks), 
    vline = median(breaks), linecol = tracecol, margins = c(5, 
        5), ColSideColors, RowSideColors, cexRow = 0.2 + 1/log10(nr), 
    cexCol = 0.2 + 1/log10(nc), labRow = NULL, labCol = NULL, keysize = 1.5, 
    density.info = c("histogram","density", "none"), denscol = tracecol, symkey = min(x < 
        0, na.rm = TRUE) || symbreaks, densadj = 0.25, main = NULL, 
    xlab = NULL, ylab = NULL, lmat = NULL, lhei = NULL, lwid = NULL, 
    ...) 
{

    scale01 <- function(x, low = min(x), high = max(x)) {
        x <- (x - low)/(high - low)
        x
    }

    retval <- list()
    scale <- if (symm && missing(scale)) 
        "none"
    else match.arg(scale)
    dendrogram <- match.arg(dendrogram)
    trace <- match.arg(trace)
    density.info <- match.arg(density.info)

    if (length(col) == 1 && is.character(col)) 
        col <- get(col, mode = "function")
    if (!missing(breaks) && (scale != "none")) 
        warning("Using scale=\"row\" or scale=\"column\" when breaks are", 
            "specified can produce unpredictable results.", "Please consider using only one or the other.")
    if (is.null(Rowv) || is.na(Rowv)) 
        Rowv <- FALSE
    if (is.null(Colv) || is.na(Colv)) 
        Colv <- FALSE
    else if (Colv == "Rowv" && !isTRUE(Rowv)) 
        Colv <- FALSE
    if (length(di <- dim(x)) != 2 || !is.numeric(x)) 
        stop("`x' must be a numeric matrix")
    nr <- di[1]
    nc <- di[2]
    if (nr <= 1 || nc <= 1) 
        stop("`x' must have at least 2 rows and 2 columns")
    if (!is.numeric(margins) || length(margins) != 2) 
        stop("`margins' must be a numeric vector of length 2")
    if (missing(cellnote)) 
        cellnote <- matrix("", ncol = ncol(x), nrow = nrow(x))
    if (!inherits(Rowv, "dendrogram")) {
        if (((!isTRUE(Rowv)) || (is.null(Rowv))) && (dendrogram %in% 
            c("both", "row"))) {
            if (is.logical(Colv) && (Colv)) 
                dendrogram <- "column"
            else dendrogram <- "none"
            warning("Discrepancy: Rowv is FALSE, while dendrogram is `", 
                dendrogram, "'. Omitting row dendogram.")
        }
    }
    if (!inherits(Colv, "dendrogram")) {
        if (((!isTRUE(Colv)) || (is.null(Colv))) && (dendrogram %in% 
            c("both", "column"))) {
            if (is.logical(Rowv) && (Rowv)) 
                dendrogram <- "row"
            else dendrogram <- "none"
            warning("Discrepancy: Colv is FALSE, while dendrogram is `", 
                dendrogram, "'. Omitting column dendogram.")
        }
    }
    if (inherits(Rowv, "dendrogram")) {
        ddr <- Rowv
        rowInd <- order.dendrogram(ddr)
    }
    else if (is.integer(Rowv)) {
        hcr <- hclustfun(distfun(x))
        ddr <- as.dendrogram(hcr)
        ddr <- reorder(ddr, Rowv)
        rowInd <- order.dendrogram(ddr)
        if (nr != length(rowInd)) 
            stop("row dendrogram ordering gave index of wrong length")
    }
    else if (isTRUE(Rowv)) {
        Rowv <- rowMeans(x, na.rm = na.rm)
        hcr <- hclustfun(distfun(x))
        ddr <- as.dendrogram(hcr)
        ddr <- reorder(ddr, Rowv)
        rowInd <- order.dendrogram(ddr)
        if (nr != length(rowInd)) 
            stop("row dendrogram ordering gave index of wrong length")
    }
    else {
        rowInd <- nr:1
    }
    if (inherits(Colv, "dendrogram")) {
        ddc <- Colv
        colInd <- order.dendrogram(ddc)
    }
    else if (identical(Colv, "Rowv")) {
        if (nr != nc) 
            stop("Colv = \"Rowv\" but nrow(x) != ncol(x)")
        if (exists("ddr")) {
            ddc <- ddr
            colInd <- order.dendrogram(ddc)
        }
        else colInd <- rowInd
    }
    else if (is.integer(Colv)) {
        hcc <- hclustfun(distfun(if (symm) 
            x
        else t(x)))
        ddc <- as.dendrogram(hcc)
        ddc <- reorder(ddc, Colv)
        colInd <- order.dendrogram(ddc)
        if (nc != length(colInd)) 
            stop("column dendrogram ordering gave index of wrong length")
    }
    else if (isTRUE(Colv)) {
        Colv <- colMeans(x, na.rm = na.rm)
        hcc <- hclustfun(distfun(if (symm) 
            x
        else t(x)))
        ddc <- as.dendrogram(hcc)
        ddc <- reorder(ddc, Colv)
        colInd <- order.dendrogram(ddc)
        if (nc != length(colInd)) 
            stop("column dendrogram ordering gave index of wrong length")
    }
    else {
        colInd <- 1:nc
    }
    retval$rowInd <- rowInd
    retval$colInd <- colInd
    retval$call <- match.call()
    x <- x[rowInd, colInd]

    # @@@
    if(! missing(colormatrix)) colormatrix <- colormatrix[rowInd, colInd]
    x.unscaled <- x
    cellnote <- cellnote[rowInd, colInd]
    if (is.null(labRow)) 
        labRow <- if (is.null(rownames(x))) 
            (1:nr)[rowInd]
        else rownames(x)
    else labRow <- labRow[rowInd]
    if (is.null(labCol)) 
        labCol <- if (is.null(colnames(x))) 
            (1:nc)[colInd]
        else colnames(x)
    else labCol <- labCol[colInd]
    if (scale == "row") {
        retval$rowMeans <- rm <- rowMeans(x, na.rm = na.rm)
        x <- sweep(x, 1, rm)
        retval$rowSDs <- sx <- apply(x, 1, sd, na.rm = na.rm)
        x <- sweep(x, 1, sx, "/")
    }
    else if (scale == "column") {
        retval$colMeans <- rm <- colMeans(x, na.rm = na.rm)
        x <- sweep(x, 2, rm)
        retval$colSDs <- sx <- apply(x, 2, sd, na.rm = na.rm)
        x <- sweep(x, 2, sx, "/")
    }
    if (missing(breaks) || is.null(breaks) || length(breaks) < 
        1) {
        if (missing(col) || is.function(col)) 
            breaks <- 16
        else breaks <- length(col) + 1
    }
    if (length(breaks) == 1) {
        if (!symbreaks) 
            breaks <- seq(min(x, na.rm = na.rm), max(x, na.rm = na.rm), 
                length = breaks)
        else {
            extreme <- max(abs(x), na.rm = TRUE)
            breaks <- seq(-extreme, extreme, length = breaks)
        }
      }
    nbr <- length(breaks)
    ncol <- length(breaks) - 1
    if (class(col) == "function") 
        col <- col(ncol)
    min.breaks <- min(breaks)
    max.breaks <- max(breaks)
    x[x < min.breaks] <- min.breaks
    x[x > max.breaks] <- max.breaks
    if (missing(lhei) || is.null(lhei)) 
        lhei <- c(keysize, 4)
    if (missing(lwid) || is.null(lwid)) 
        lwid <- c(keysize, 4)
    if (missing(lmat) || is.null(lmat)) {
        lmat <- rbind(4:3, 2:1)
	#@@@
        if (!missing(ColSideColors)) {
	   lmat<-rbind(lmat[1,]+1,c(0,1),lmat[2,]+1)
	   lhei<-c(lhei[1],0.15*length(ColSideColors),lhei[2])
        }
        if (!missing(RowSideColors)) {
            if (!is.character(RowSideColors) || length(RowSideColors) != 
                nr) 
                stop("'RowSideColors' must be a character vector of length nrow(x)")
            lmat <- cbind(lmat[, 1] + 1, c(rep(NA, nrow(lmat) - 
                1), 1), lmat[, 2] + 1)
            lwid <- c(lwid[1], 0.2, lwid[2])
        }
        lmat[is.na(lmat)] <- 0
    }
    if (length(lhei) != nrow(lmat)) 
        stop("lhei must have length = nrow(lmat) = ", nrow(lmat))
    if (length(lwid) != ncol(lmat)) 
        stop("lwid must have length = ncol(lmat) =", ncol(lmat))
    op <- par(no.readonly = TRUE)
    on.exit(par(op))
    layout(lmat, widths = lwid, heights = lhei, respect = FALSE)
    if (!missing(RowSideColors)) {
        par(mar = c(margins[1], 0, 0, 0.5))
        image(rbind(1:nr), col = RowSideColors[rowInd], axes = FALSE)
    }
    if (!missing(ColSideColors)) {
        par(mar = c(0.5, 0, 0, margins[2]))

	ma<-matrix(1:(length(ColSideColors)*length(ColSideColors[[1]])),byrow=T,nrow=length(ColSideColors))
	colc<-c()
	for(csc in ColSideColors){
		colc<-c(colc,csc[colInd])
	}	
	image(t(ma),col=colc,axes=F)
	cscN<-length(ColSideColors)
	at<- (0:(cscN-1))/(cscN-1)
	if(length(ColSideColors)==1) at<-c(0)
	axis(4,labels=names(ColSideColors),at=at,las=2,tick=0,cex.axis=cexCol)
    }
    par(mar = c(margins[1], 0, 0, margins[2]))
    x <- t(x)

    # @@@
    if(!missing(colormatrix)) colormatrix <- t(colormatrix)
    cellnote <- t(cellnote)
    if (revC) {
        iy <- nr:1
        if (exists("ddr")) 
            ddr <- rev(ddr)
        x <- x[, iy]
        # @@@
        if(!missing(colormatrix)) colormatrix <- colormatrix[, iy]
        cellnote <- cellnote[, iy]
    }
    else iy <- 1:nr



    ## display the main carpet


#@@@
   if(missing(colormatrix)){
image(1:nc, 1:nr, x, xlim = 0.5 + c(0, nc), ylim = 0.5 + 
        c(0, nr), axes = FALSE, xlab = "", ylab = "", col = col, 
        breaks = breaks, ...)
   }

   else{
    # iterate over rows
    c.nrow<-dim(colormatrix)[1]
    c.ncol<-dim(colormatrix)[2]

    nam<-matrix(ncol=nr,nrow=nc)
    image(1:nc, 1:nr, nam, xlim = 0.5 + c(0, nc), ylim = 0.5 + 
        c(0, nr), axes = FALSE, xlab = "", ylab = "", col = col, 
        breaks = breaks, ...)


    for(ci in 1:c.nrow){
      # iterate over columns
      for(cj in 1:c.ncol){
        cmat<-matrix(ncol=nr,nrow=nc)
        cmat[ci,cj]<-1
        c.col<-c[ci,cj]
        image(1:nc,1:nr, cmat, axes = FALSE, xlab = "", ylab="",col=c.col,add=TRUE)
      }
    }
    }

    retval$carpet <- x
    if (exists("ddr")) 
        retval$rowDendrogram <- ddr
    if (exists("ddc")) 
        retval$colDendrogram <- ddc
    retval$breaks <- breaks
    retval$col <- col
    if (!gtools::invalid(na.color) & any(is.na(x))) {
        mmat <- ifelse(is.na(x), 1, NA)
        image(1:nc, 1:nr, mmat, axes = FALSE, xlab = "", ylab = "", 
            col = na.color, add = TRUE)
    }
    axis(1, 1:nc, labels = labCol, las = 2, line = -0.5, tick = 0, 
        cex.axis = cexCol)
    if (!is.null(xlab)) 
        mtext(xlab, side = 1, line = margins[1] - 1.25)
    axis(4, iy, labels = labRow, las = 2, line = -0.5, tick = 0, 
        cex.axis = cexRow)
    if (!is.null(ylab)) 
        mtext(ylab, side = 4, line = margins[2] - 1.25)
    if (!missing(add.expr)) 
        eval(substitute(add.expr))
    if (!missing(colsep)) 
        for (csep in colsep) rect(xleft = csep + 0.5, ybottom = rep(0, 
            length(csep)), xright = csep + 0.5 + sepwidth[1], 
            ytop = rep(ncol(x) + 1, csep), lty = 1, lwd = 1, 
            col = sepcolor, border = sepcolor)
    if (!missing(rowsep)) 
      for (rsep in rowsep) rect(xleft = 0, ybottom = (ncol(x) + 
            1 - rsep) - 0.5, xright = nrow(x) + 1, ytop = (ncol(x) + 
            1 - rsep) - 0.5 - sepwidth[2], lty = 1, lwd = 1, 
            col = sepcolor, border = sepcolor)
    min.scale <- min(breaks)
    max.scale <- max(breaks)
    x.scaled <- scale01(t(x), min.scale, max.scale)

    if (trace %in% c("both", "column")) {
        retval$vline <- vline
        vline.vals <- scale01(vline, min.scale, max.scale)
        for (i in colInd) {
            if (!is.null(vline)) {
                abline(v = i - 0.5 + vline.vals, col = linecol, 
                  lty = 2)
            }
            xv <- rep(i, nrow(x.scaled)) + x.scaled[, i] - 0.5
            xv <- c(xv[1], xv)
            yv <- 1:length(xv) - 0.5
            lines(x = xv, y = yv, lwd = 1, col = tracecol, type = "s")
        }
    }
    if (trace %in% c("both", "row")) {
        retval$hline <- hline
        hline.vals <- scale01(hline, min.scale, max.scale)
        for (i in rowInd) {
            if (!is.null(hline)) {
                abline(h = i + hline, col = linecol, lty = 2)
            }
            yv <- rep(i, ncol(x.scaled)) + x.scaled[i, ] - 0.5
            yv <- rev(c(yv[1], yv))
            xv <- length(yv):1 - 0.5
            lines(x = xv, y = yv, lwd = 1, col = tracecol, type = "s")
        }
    }
    if (!missing(cellnote)) 
        text(x = c(row(cellnote)), y = c(col(cellnote)), labels = c(cellnote), 
            col = notecol, cex = notecex)
    par(mar = c(margins[1], 0, 0, 0))
    if (dendrogram %in% c("both", "row")) {
        plot(ddr, horiz = TRUE, axes = FALSE, yaxs = "i", leaflab = "none")

    }
    else plot.new()
    par(mar = c(0, 0, if (!is.null(main)) 5 else 0, margins[2]))
    if (dendrogram %in% c("both", "column")) {
        plot(ddc, axes = FALSE, xaxs = "i", leaflab = "none")
    }
    else plot.new()
    if (!is.null(main)) 
        title(main, cex.main = 1.5 * op[["cex.main"]])

	#@@@
	key<-T
	if(!missing(colormatrix)) key<-F
	if(density.info=="none") key<-F

    if (key) {
        par(mar = c(5, 4, 2, 1), cex = 0.75)
        tmpbreaks <- breaks
        if (symkey) {
            max.raw <- max(abs(c(x, breaks)), na.rm = TRUE)
            min.raw <- -max.raw
            tmpbreaks[1] <- -max(abs(x), na.rm = TRUE)
            tmpbreaks[length(tmpbreaks)] <- max(abs(x), na.rm = TRUE)
        }
        else {
            min.raw <- min(x, na.rm = TRUE)
            max.raw <- max(x, na.rm = TRUE)
        }
        z <- seq(min.raw, max.raw, length = length(col))
        image(z = matrix(z, ncol = 1), col = col, breaks = tmpbreaks, 
            xaxt = "n", yaxt = "n")
        par(usr = c(0, 1, 0, 1))
        lv <- pretty(breaks)
        xv <- scale01(as.numeric(lv), min.raw, max.raw)
        axis(1, at = xv, labels = lv,cex.axis=0.7)
        if (scale == "row") 
            mtext(side = 1, "Row Z-Score", line = 2,cex=0.7)
        else if (scale == "column") 
            mtext(side = 1, "Column Z-Score", line = 2)
        else mtext(side = 1, "Value", line = 2,cex=0.7)
        if (density.info == "density") {
            dens <- density(x, adjust = densadj, na.rm = TRUE)
            omit <- dens$x < min(breaks) | dens$x > max(breaks)
            dens$x <- dens$x[-omit]
            dens$y <- dens$y[-omit]
            dens$x <- scale01(dens$x, min.raw, max.raw)
            lines(dens$x, dens$y/max(dens$y) * 0.95, col = denscol, 
                lwd = 1)
#            axis(2, at = pretty(dens$y)/max(dens$y) * 0.95, pretty(dens$y),cex.axis=0.7)
#            title("Color Key\nand Density Plot")
            par(cex = 0.5)
#            mtext(side = 2, "Density", line = 2,cex=0.7)
        }
        else if (density.info == "histogram") {
            h <- hist(x, plot = FALSE, breaks = breaks)
            hx <- scale01(breaks, min.raw, max.raw)
            hy <- c(h$counts, h$counts[length(h$counts)])
            lines(hx, hy/max(hy) * 0.95, lwd = 1, type = "s", 
                col = denscol)
            axis(2, at = pretty(hy)/max(hy) * 0.95, pretty(hy))
#            title("Color Key\nand Histogram")
            par(cex = 0.5)
            mtext(side = 2, "Count", line = 2,cex=0.7)
        }
        else title("Color Key")
    }
    else plot.new()
    retval$colorTable <- data.frame(low = retval$breaks[-length(retval$breaks)], 
        high = retval$breaks[-1], color = retval$col)
    invisible(retval)
}

heat.bubble.plot<-function (df, dfb=NULL,dfr=NULL,dfg=NULL,
    x = 1:ncol(df), y = nrow(df):1, row.labels = row.names(df), 
    col.labels = names(df), clabel.row = 1, clabel.col = 1, csize = 1, 
    clegend = 1, grid = TRUE) 
{
    opar <- par(mai = par("mai"), srt = par("srt"))
    on.exit(par(opar))
    table.prepare(x = x, y = y, row.labels = row.labels, col.labels = col.labels, 
        clabel.row = clabel.row, clabel.col = clabel.col, grid = grid, 
        pos = "righttop")
    xtot <- x[col(as.matrix(df))]
    ytot <- y[row(as.matrix(df))]
    coeff <- diff(range(xtot))/15
    z <- unlist(df)
    sq <- sqrt(abs(z))
    w1 <- max(sq)
    sq <- csize * coeff * sq/w1

    blue<-unlist(dfb)
    blue<-blue / max(blue)
    red<-unlist(dfr)
    red<-red / max(red)
    green<-unlist(dfg)
    green<-green / max(green)

    for (i in 1:length(z)) {
        if (sign(z[i]) >= 0) {
          bg<-rgb(blue[i],red[i],green[i],maxColorValue=1)
          symbols(xtot[i], ytot[i], squares = sq[i], bg = bg, 
                fg = 0, add = TRUE, inch = FALSE)
        }
        else {
          bg<-rgb(blue[i],red[i],green[i],maxColorValue=1)
            symbols(xtot[i], ytot[i], squares = sq[i], bg = bg, 
                fg = 1, add = TRUE, inch = FALSE)
        }
    }
    br0 <- pretty(z, 4)
    l0 <- length(br0)
    br0 <- (br0[1:(l0 - 1)] + br0[2:l0])/2
    sq0 <- sqrt(abs(br0))
    sq0 <- csize * coeff * sq0/w1
    sig0 <- sign(br0)
    if (clegend > 0) 
        scatterutil.legend.bw.square(br0, sq0, sig0, clegend)
}

c.normChart<-function(cal,out,method,tss,res=120,width=200,height=200,title="",orderBy="GST",csv,calypso=T,level="level"){
    cal.norm<-c.norm(cal,method,tss)

    raw<-c.annotatedCounts(cal,orderBy=orderBy)
    norm<-c.annotatedCounts(cal.norm,orderBy=orderBy)

    if(any(raw$sample != norm$sample)) stop("ERROR: order mismatch!!")
    
    taxa<-c.taxa(cal)
    
    x<-as.vector(as.matrix(raw[,taxa]))
    y<-as.vector(as.matrix(norm[,taxa]))
    
    png(out,res=res,width=width,height=height)
    layout(matrix(c(1,1,1,2,2,2,3,4,5), 3, 3,byrow=T))
    boxplot(t(raw[,taxa]),col=raw$color,las=2,main="Raw",names=NA)
    print(1)
    boxplot(t(norm[,taxa]),col=norm$color,las=2,main=paste("Normalized",method),
            names=NA)
    plot(x,y,xlab="Raw",ylab="Normalized",pch=16,col=rgb(0.4,0.4,0.6,0.3),cex=0.7,main=title)

    dev.off()

    if(! missing(csv)) calypso2csv(cal.norm,csv,calypso=calypso,level=level)
}


calypso2csv<-function(cal,file,calypso=F,level,annot=F){
	ra<-c.rank(cal)

        if(annot){
            ca<-as.data.frame(c.annotatedCounts(cal))

            envs<-c.environment.vars(cal)
            taxa<-c.taxa(cal)
            ca<-ca[c("label","pair","group","time",envs,taxa)]
            na<-names(ca)
            na[na=="time"]<-"secondary group"
            names(ca)<-na
            
            ca<-as.data.frame(t(ca))

            feature<-as.character(rownames(ca))


            names<-names(ca)
            names<-sub("X$","",names)
            names(ca)<-names
            
            ca$Feature<-feature
            ca<-ca[,c("Feature",names)]

            write.csv(ca,file=file,quote=F,row.names=F)
            return(ca)
        }
        
	counts<-as.data.frame(t(c.counts(cal)))
	counts<-round(counts,3)
        
	samples<-names(counts)
	if(calypso){
            counts$Header<-rownames(counts)
            if(missing(level)) level<-"level"
            counts[,level]<-rep(level,dim(counts)[1])
            counts<-counts[,c(level,"Header",samples)]	        
        }
        else{
            counts$Feature<-rownames(counts)
            counts<-counts[,c("Feature",samples)]	        
        }

        write.csv(counts,file=file,quote=F,row.names=F)

        invisible(counts)
    }

c.mcpHill<-function(cal,groupBy="group"){
    library(simboot)

    cal<-c.setGroups(cal,groupBy=groupBy,groupNumeric=T)

    ca<-c.annotatedCounts(cal)
    taxa<-c.taxa(cal)
    mc<-mcpHill(data=ca[,taxa],fact=as.factor(ca$group),boot=1000,
                mattype="Tukey")

    groups<-unique(ca$group)
    rn<-rownames(mc)
    for(i in 1:length(groups)){
        pattern<-paste(c("^",i," -"),collapse="")
        repl<-as.character(paste(c(as.character(groups[i])," -"),collapse=""))
        print(pattern)
        print(repl)
        rn<-sub(pattern,repl,rn)
        print(1)
        
        pattern<-paste(c("- ",i,"$"),collapse="")
        repl<-paste(c("- ",groups[i]),collapse="")
        
        print(pattern)
        rn<-sub(pattern,repl,rn)

    }

    tmp<-data.frame(Comparison=rn,q=mc[,1],p.value=mc[,2])
    names(tmp)<-c("Comparison","q (Oder of Hill no.)","p-value")
    print(tmp)
    tmp<-tmp[order(tmp$Comparison),]
    
    textplot(tmp,show.rownames=F)
}

c.norm<-function(cal,method="clr",relative=T,minFrac=0){

	if(method=="clr") require(rgr)

      totals<-c.totals(cal)

        ps.count<-0.0000000001
        
      .rel<-function(counts){
	  if(! length(totals) == dim(counts)[1]){
          stop("ERROR length mismatch")
      	  }
      
         for(i in 1:dim(counts)[1]){
           tot<-totals[[i]]
           if(tot==0) counts[i,]<-0
           else counts[i,]<-counts[i,]/tot*100
         }
	 return(counts)
       }
	.transf<-function(data){		
	   if(method == "none") return(data)
	   else if(method == "sqrt") return(sqrt(data))
	   else if(method == "clr") return(clr(data))
           else if(method == "log2") return(log2(data))	   
	   else if(method == "log10") return(log10(data))           
	   else if(method == "log") return(log(data))            
           else if(method == "asinh") return(asinh(data))	   
	   else if(method == "quantile"){
	   	library(preprocessCore)
	   	no<-t(normalize.quantiles(t(data)))
                colnames(no)<-colnames(data)
		rownames(no)<-rownames(data)
		return(no)
            }
           else if(method == "logit"){
               library(gtools)               
               data<-data/(max(data)+0.0000001)
               return(logit(data))
           }
	   else if(method == "vsn"){
               library(vsn)
               if(any(data==0)) data[data==0]<-min(data[data>0])/100
               print(range(data))
               norm<-t(justvsn(t(data)))
               return(norm)
	   }		   	   
		   else stop(paste("ERROR: Unknown format ",format))
	}

	for(ra in cal$ranks){
		 counts<-c.counts(cal,ra=ra,id=T)
		 if(relative) counts<-.rel(counts)


                 if(method %in% c("clr","log2","log10","log","logit")){
                     min<-min(counts)
                     if(min==0) counts<-counts+0.000000001
                     else if(min < 0) counts<-counts - min + 0.000000001
                 }
                 else if(method =="sqrt"){
                                          min<-min(counts)
                     if(min < 0) counts<-counts - min
                 }
                 
                 if(method!="none") counts<-.transf(counts)

		 counts<-round(counts,5)

		 cal[[ra]]<-counts

	}	 
	return(cal)
}


convert2calypso<-function(file,delim=",",rank="OTU"){

    stop("almost functional, but not quite")

    tmp<-read.csv(file,sep=delim)

    header<-which(tmp$Header=="Header")

    for(i in 1:length(header)){
        h<-header[i]
        skip<-h
        nrow<-NULL
        if(i<length(header)){
            nrow<-header[i+1] - 1 - skip
            d<-read.csv(file,sep=delim,skip=skip,nrow=nrow,header=T)
        }
        else d<-read.csv(file,sep=delim,skip=skip,header=T)

        rank<-d[,1]
        rank<-unique(rank[rank!=""])
        if(length(rank) != 1) stop("ERROR: non unique rank")
        
        for(z in 3:dim(d)[2]){
            if(! is.numeric(d[,z])){
                stop("ERROR: data not numeric column ", z, " ",names(d)[z] , " " , rank)
            }
        }


    }
    
}

calypso<-function(countsFile,annotationFile,rank="default",color="default",colorBy="group",taxFilter=0,time="all",unclassified=T,taxa=NULL,format="simple",
                  dist=NULL,ds="\t",errorM){


    
  if(! is.null(taxa)){	
       taxFilter<-0
       }
  # Read sample annotation
  an<-read.csv(annotationFile,na.string="NA")

  na<-names(an)
  na[1:6]<-c("sample","label","pair","group","time","keep")
  names(an)<-na

 rownames(an)<-an$label
 an.names<-names(an)

 # convert annotation variables to characters
 for(f in c("group","time","label","sample","pair")){
     tmp<-an[,f]
     tmp<-as.character(tmp)
     if(any(is.na(tmp))) tmp[is.na(tmp)]<-"NA"
     an[,f]<-tmp
 }

 if(! length(an$label) == length(unique(an$label))){
   stop("ERROR: labels in annotation file not unique")
 }


 
 # get names of environmental variables
 print("Environmental variables:")
 envs<-c()
 for(n in an.names){
   if(! n %in% c("group","time","total","label","sample","pair","color","symbol","legendLabel","keep")){
     envs<-c(envs,n)
     if(! is.numeric(an[,n])){
       print(paste("Converting",n,"to factor"))
       an[,n]<-as.factor(an[,n])
     }
   }
 }

 # order annotation

 an<-an[order(an$sample),]

  
  calyp<-list()

    # Read counts file
    d<-1
    if(format=="simple"){
        d<-read.table(countsFile,sep=",",header=T,check.names=F)
	na<-names(d)
	na[1]<-"Taxa"
	names(d)<-na
	ranks<-c(rank)
    }
    else{
        d<-read.table(countsFile,sep=",",header=F,check.names=F)
    	na<-names(d)
    	na[1]<-"Rank"
    	na[2]<-"Taxa"
    	names(d)<-na
  
	ranks<-unique(as.character(d$Rank))
  	ranks<-ranks[nchar(ranks) > 0]
	if(rank == "default") rank<-ranks[1]
   }

  samples.ref<-c()
  total.ref<-c()
  rank.ref<-"del"

  for(r in ranks){
    dr<-1
    if(format=="simple"){
	dr<-d
    }
    else{
        dr<-as.matrix(d[d$Rank==r,])
    	header<-dr[1,]
    	dr<-dr[-1,]
	dr.new<-data.frame(Taxa=dr[,2])
    	for(i in 3:dim(dr)[2]){
      	      dr.new[,header[i]]<-as.numeric(dr[,i])
    	}

    	dr<-dr.new
    	dr.new<-NULL
    }
    samples<-names(dr)[-1]

    total<-(dr[tolower(dr$Taxa) == "total",])

    if(dim(total)[1] > 0){
      sel<-tolower(dr$Taxa) != "total"
      dr<-subset(dr,sel)
      total$Taxa<-NULL	
      total$Rank<-NULL	    
    }
    else{
      total<-apply(dr[,samples],2,sum)
    }
  
    dr$Taxa<-sub(";","_",dr$Taxa)

    if(dim(dr)[1] ==0 ) stop("ERROR no data")

    if(! is.null(taxa)){
    dr<-subset(dr,dr$Taxa == taxa)
  }
  
  dr<-dr[order(dr$Taxa,decreasing=T),]
  # replace / by _ in taxa
  dr$Taxa<-sub("/","_",dr$Taxa)
  dr$Taxa<-make.names(dr$Taxa)

   rownames(dr)<-dr$Taxa
   dr$Taxa<-NULL

    
  
  if(dim(dr)[2] != length(total)){
    stop("ERROR: length mismatch")
  }
  # if(minFrac > 0) dr<-subset(dr,apply(dr,1,max.tot,total) > minFrac)

  if(dim(dr)[2] <1) stop("ERROR no data (col) 123")
    
  if(taxFilter > 0 & dim(dr)[1] > taxFilter){
  	  sum<-apply(dr,1,sum)
	  dr<-dr[order(sum,decreasing=T)[1:taxFilter],]
  }

  dr<-t(dr)
  if(dim(dr)[2] <1) stop("ERROR no data (col)")
  if(dim(dr)[1] <1) stop("ERROR no data (row)")
  
 # exclude unknown
  if(! unclassified){
        dr<-dr[,! tolower(colnames(dr)) == "unclassified"]
  }
 # order counts 
 ord<-order(rownames(dr))

  if(dim(dr)[2] == 1){
    d.cn<-colnames(dr)
    dr<-as.data.frame(dr[ord,])
    colnames(dr)<-d.cn
  }
  else{
    dr<-dr[ord,]
  }
 total<-total[ord]
  dr.rownames<-rownames(dr)


    if(length(samples.ref) == 0){	
    			   samples.ref<-rownames(dr)
			   total.ref<-total
			   rank.ref<-r

			    # remove samples of annotation file not contained in counts file
 			    select<-tolower(an$sample) %in% tolower(samples.ref)
 			    an<-an[select,]
    }
    else{
	if(! all(rownames(dr) == samples.ref)) stop("sample mismatch")
     	if(! all(total == total.ref)) stop("Total mismatch",rank.ref,r)
     }


 # check that annotation is defined for all samples of counts file  
  if(! all(tolower(rownames(dr)) == tolower(an$sample))){
       stop("ERROR: sample names in annotation and counts file don't match!")
  }
  
 # replace samples by labels
 rownames(dr)<-an$label

 if(dim(dr)[1] < 1) stop("ERROR: empty data matrix")

 calyp[[r]]<-dr
}
 # set totals
  if(dim(an)[1] != length(total.ref)){
    stop(paste("ERROR dim mismatch",length(total.ref),collapse=" "))
  }

  if(! all(tolower(names(total.ref)) == tolower(an$sample))){
    stop("ERROR: sample mismatch")
  }

  an$total<-as.numeric(total.ref)
  
 # remove samples with keep == 0
 select<-an$keep == 1


 if(! any(select)) stop ("ERROR: no samples included")

  # remove samples not matching time 
  if(time != "all"){
    time.select<-an$time == time
    select <- select & time.select
  }

  an<-subset(an,select)

  for(r in ranks){
    dr<-calyp[[r]]
    dr<-subset(dr,select)

    if(dim(dr)[1] < 1) stop("ERROR: empty data matrix")

 if(dim(dr)[1] != dim(an)[1]){
   stop("ERROR dimension  mismatch!!!")
 }

    calyp[[rank]]<-dr
  }	   

 an$legendLabel<-an$label	
 an$group.orig<-an$group
 calyp[["annot"]]<-an

 calyp$rank <- rank
 calyp$ranks <- ranks
  calyp$envs <- envs

  calyp<-setColorsAndSymbols(calyp,colorBy=colorBy,color=color)

  library(gdata)

  calyp<-drop.levels(calyp)


  if(! is.null(dist)){
      d<-read.csv(dist,sep=ds,row.names=1)

      if(dim(d)[1] != dim(d)[2]) stop("ERROR: col/row mismatch")

      .getN<-function(x){
          nam<-paste0(tolower(make.names(x)),"X")
          return(nam)
      }

      if(any(names(d) != rownames(d))) stop("ERROR names mismatch")

      nam<-.getN(names(d))
      names(d)<-nam
      rownames(d)<-nam

      if(! all(rownames(d) == names(d))) stop("ERROR: name mismatch distance matrix")

      samples<-calyp$annot$sample
      
      if(! all(samples %in% names(d))){
          print(names(d))
          sel<-! samples %in% names(d)
          print("Missing samples:")
          print(samples[sel])
          stop("ERROR: missing sample in dist matrix")
      }
      d<-d[samples,samples]

      if(any(samples != names(d))) stop("ERROR names mismatch")
      
      labels<-calyp$annot$label
      names(d)<-labels
      rownames(d)<-labels
      
      calyp$distM<-as.dist(d)
  }

  if(! missing(errorM)) calyp$errorM<-errorM
  
  return(calyp)

}

c.clearError<-function(cal){
    unlink(cal$errorM)
}

c.writeError<-function(cal,err){
    file<-cal$errorM
    if(is.null(file)){
        warning(err)
        warning("ERROR: empty error file")
    }
    else writeLines(err,file)
}

c.errorM<-function(cal){
    return(cal$errorM)
}

c.distanceMatrix<-function(cal){
    return(cal$distM)
}

calypso2matrix<-function(cal,groupBy="group"){
  ma<-list()
  
  ma$matrix<-t(c.counts(cal))
  ma$groups<-c.groups(cal)
  ma$groupso<-ma$groups
  ma$times<-c.times(cal)
  ma$subjects<-c.pairs(cal)
  ma$colors<-c.colors(cal)
  ma$symbols<-c.symbols(cal)
  ma$labels<-c.labels(cal)
  ma$samples<-c.samples(cal)
  ma$totals<-c.totals(cal)
  ma$taxa<-c.taxa(cal)
  
  envs<-c.environment.vars(cal)

  for(e in envs){
    ma[[e]]<-c.environment.var(cal,e)
  }
  
  return(ma)
}


setColorsAndSymbols<-function(cal,colorBy="group",color="default",sample=F, symbolby=F,symbolBy=NULL){
  annot<-cal$annot

  if(is.null(symbolBy)) symbolBy<-colorBy

  gr<-c.groups(cal,groupBy=symbolBy)  

  symbols<-symbolByGroup(gr)
  annot$symbol<-symbols
  annot$symbolLabel<-gr

  gr<-c.groups(cal,groupBy=colorBy)  


  col<-colorByGroup(gr,color,sample)
  annot$color<-col
  annot$legendLabel<-gr
  cal$annot<-annot
  

  return(cal)
}

c.legendLabels<-function(cal){
  return(cal$annot$legendLabel)
}

c.byGroup<-function(cal,group){
  groups<-c.groups(cal)
  select<-which(groups == group)

  cal$annot<-cal$annot[select,]

  for (r in cal$ranks){
    counts<-cal[[r]]
    counts<-counts[select,]
    cal[[r]]<-counts
  }
  
  return(cal)
}


                                        # set and get active rank
c.rank<-function(cal,ra=NULL){

  # query rank
  if(is.null(ra)){    
    return(cal$rank)
  }

  # set rank
  cal$rank<-ra
  return(cal)  
}

c.taxa<-function(cal){
  ra<-c.rank(cal)
  matrix<-cal[[ra]]
  taxa<-colnames(matrix)

 return(taxa)
}


c.counts<-function(cal,er="N",unclassified=T,ra=c.rank(cal),id=F){

  if(er == "N"){
    counts<-cal[[ra]]

    if(id==T) rownames(counts)<-cal$annot$sample
   
    
    # exclude unknown
    if(! unclassified){
      counts<-counts[,! tolower(names(counts))=="unclassified"]
    }

    return(counts)
  }
  else{
    ac<-c.annotatedCounts(cal,er=er,unclassified=unclassified)
    c<-ac[,taxa(cal)]
    return(t(c))
  }
}

c.samples<-function(cal){
  samples<-cal$annot$sample

  return(samples)
}

c.totals<-function(cal){
  ra<-c.rank(cal)
  totals<-cal$annot$total
  return(totals)
}

c.annot2paired<-function(ca,cal,tA,tB){
  pairs<-ca$pair
  taxa<-c.taxa(cal)
  envs<-c.environment.vars(cal)

  nam<-c(taxa,envs)
  ncol<-length(nam)
  
  ca.pair<-data.frame(matrix(ncol=ncol,nrow=0))
  names(ca.pair)<-nam
  
  for(p in pairs){
    dA<-subset(ca,ca$pair==p & ca$time == tA)
    dB<-subset(ca,ca$pair==p & ca$time == tB)
    
    # exclßude unpaired data
    if(dim(dA)[1] != 1) next
    if(dim(dB)[1] != 1) next

    pi<-data.frame(matrix(nrow=1,ncol=ncol))
    names(pi)<-nam
    rname<-paste(rownames(dA)[1],rownames(dB),sep="-")
    rownames(pi)<-rname
    
    for(t in taxa){
      t.diff<-dA[1,t] - dB[1,t]
      pi[1,t]<-t.diff
    }

    for(e in envs){
      e.diff<-NA
      # set diff for numeric variables
      # diff should be 0 for categorical variables!!!!
      if(is.numeric(dA[1,e])){
        if(! (is.na(dA[1,e]) | is.na(dB[1,e]) ) ) e.diff<-dA[1,e] - dB[1,e]
      }
      pi[1,e]<-e.diff
    }
    ca.pair<-rbind(ca.pair,pi)
    
  }
  return(ca.pair)
}

# get combined counts and annotation table
c.annotatedCounts<-function(cal,er="N",unclassified=T,orderBy=NA,median=F,
timesInclude=c(),na.omit=F){
  counts<-c.counts(cal)
  
  combined<-cbind(counts,cal$annot)


  if(! is.na(orderBy)){
    groups<-combined$group
    times<-combined$time
    pairs<-combined$pair
    lab<-combined$label
   
    if(orderBy == "GST"){
      or<-order(groups,pairs,times)
    }
    else if(orderBy == "GTS"){
      or<-order(groups,times,pairs)
    }
    else if(orderBy == "SGT"){
      or<-order(pairs,groups,times)
    }
    
    else if(orderBy == "STG"){
      or<-order(pairs,times,groups)
    }
    
    else if(orderBy == "TGS"){
      or<-order(times,groups,pairs)
    }
    
    else if(orderBy == "TSG"){
      or<-order(times,pairs,groups)
    }
    
    else if(orderBy == "LSTG"){
      or<-order(lab,pairs,times,groups)
    }
    else if(orderBy == "SSGT"){
      or<-order(samples,pairs,groups,times)
    }
    else{
	stop("Unknown order by ",orderBy)
    }   
     
    combined<-combined[or,]
  }

  if(er != "N"){
    combined<-c.addEmptyRows(combined,er)
  }

  
   # exclude unknown
  if(! unclassified){
   combined<-combined[,! tolower(names(combined))=="unclassified"]
 }

  if(median){
    groups<-unique(combined$group)
    nrow<-length(groups)
    ncol<-dim(combined[2])
    taxa<-c.taxa(cal)
    envs<-c.environment.vars(cal)
    median.from<-taxa

    for(e in envs){
      if(is.numeric(combined[,e])){
        median.from<-c(median.from,e)
      }
    }

    c.new.names<-c(median.from,"group","keep","legendLabel","symbol","color","label")
    
    c.new<-data.frame(matrix(nrow=nrow,ncol=length(c.new.names)))
    colnames(c.new)<-c.new.names
    c.new$group<-groups
    rownames(c.new)<-groups
    
    for(g in groups){
      group.data<-subset(combined,combined$group == g)
      symbol<-group.data$symbol[1]
      color<-group.data$color[1]
      medians<-apply(group.data[,median.from],2,median)
      c.new[c.new$group == g,]<-c(medians,g,1,g,symbol,color,g)            
    }
    for(f in median.from){
      c.new[,f]<-as.numeric(c.new[,f])
    }
    combined<-c.new
  }

  ac<-as.data.frame(combined)
  
  if(length(timesInclude) > 0){
    ac<-subset(ac,ac$time %in% timesInclude)
  }

  if(na.omit){
      for(na in names(ac)) if(all(is.na(ac[,na]))) ac[,na]<-NULL
      ac<-na.omit(ac)
  }
  return(ac)
}

c.labels<-function(cal){
  return(cal$annot$label)
}


c.num2cat<-function(cal){
	annot<-cal$annot
	na<-names(annot)
	na<-na[! na %in% c("total")]
	for(n in na){
	      annot[,n]<-c.asCategorical(annot[,n])
	}
	cal$annot<-annot
	return(cal)
}

c.asCategorical<-function(x){
	if(! is.numeric(x)) return(x)
	
	val<-x
    shift<-0
    if(min(val,na.rm=T) < 0){
      shift<-abs(min(val))
      val<-val + shift
    }
    
    breaks<-as.integer(exp(hist(log(val[!is.na(val)]),breaks=3)$breaks[-1]))

    breaks<-breaks[- length(breaks)]
    
    prev<-min(val)
    grp<-c()
    for(b in breaks){
      grp[val >= prev & val < b]<-paste(prev-shift,"-",b-shift,sep="")
      prev<-b
    }
    grp[val >= prev ]<-paste(prev-shift,"-",max(val,na.rm=T)-shift,sep="")

    if(length(grp) != length(val)){
      stop("ERROR LENGTH")
    }

    grp[is.na(grp)]<-"NA"


    return(grp)
}

c.groups<-function(cal,groupBy="group",groupNumeric=T){

  val<-1

  groupBy<-make.names(groupBy)


  if(groupBy %in% c("pair","time","group")){
#    return(cal$annot[,groupBy])
  }

  val<-cal$annot[,groupBy]

  if(groupNumeric & ((groupBy == "total") | (is.numeric(val) & (length(unique(val)) > 4)))){
    grp<-c.asCategorical(val)

    return(grp)
  }
  else{    
    return(cal$annot[,groupBy])
  }

}


c.resetGroup<-function(cal){
 cal$annot$group<-cal$annot$group.orig
 return(cal)
}


c.setGroups<-function(cal,groupBy=NULL,setColorsAndSymbols=T,color="default",groupNumeric=T,symbolBy=NULL){   

    cal<-c.resetGroup(cal)

    if(is.null(groupBy)) groupBy<-"group"

    if(setColorsAndSymbols) cal<-setColorsAndSymbols(cal,colorBy=groupBy,color=color,symbolBy=symbolBy)
    

  groups<-c.groups(cal,groupBy=groupBy,groupNumeric=groupNumeric)
  
  if(is.null(groups)) stop("ERROR groups == NA")
  
  cal$annot$group<-groups

  return(cal)
}

c.times<-function(cal){
  return(cal$annot$time)
}



c.pairs<-function(cal){
  return(cal$annot$pair)
}

c.environment.var<-function(cal,var){
  return(cal$an[,var])
}

c.environment.vars<-function(cal,nominal=F,nonUnique=F,numeric=F){
	envs<-NA

        if(numeric){
	  envs<-cal$envs	
	  ret<-c()
	  for(e in envs){
              if(is.numeric(cal$annot[[e]])){
                  ret<-c(ret,e)
              }
          }
	  envs<-ret

      }

        else if(nominal){
	  envs<-cal$envs	
	  ret<-c()
	  for(e in envs){
	  	if(all(cal$annot[[e]] %in% c(0,1))) ret<-c(ret,e)
	  	else if(! is.numeric(cal$annot[[e]])) ret<-c(ret,e)
	  }
	  envs<-ret
	}
	else envs<-cal$envs

        
	if(nonUnique){  
		ca<-c.annotatedCounts(cal)
  		tmp<-c()
  		for(e in envs) if(length(unique(ca[,e])) > 1) tmp<-c(tmp,e)
  		envs<-tmp
	}
	return(envs)
}

c.environment.matrix<-function(cal){

  return(subset(cal$annot,T,colnames(cal$annot) %in% c$envs))
}

c.symbols<-function(cal){
  return(cal$annot$symbol)
}



c.colors<-function(cal){
  return(cal$annot$color)
}

# add empty rows to combined table
c.addEmptyRows<-function(ct,er){
  if(er=="N"){
    return(ct)
  }

  ncol<-dim(ct)[2]

  # init new data frame
 new<-as.data.frame(matrix(nrow=0,ncol=dim(ct)[2]))

  na<-names(ct)
  names(new)<-na

  if(er == "G"){
    v<-"group"
  } else if(er == "P"){
    v<-"pair"
  } else if(er == "T"){
    v<-"time"
  }
  else{
    stop(paste("ERROR: unknown er mode ",er))
  }


  if(any(is.na(ct[,v]))) {
      tmp<-ct[,v]
      if(is.factor(tmp)) tmp<-as.character(tmp)
      tmp[is.na(tmp)]<-"NA"
      ct[,v]<-tmp
  }

  rN<-dim(ct)[1]
  current<-NA

  # iterate over each row of ct (combined table)
  # add to new data frame + new empty row if required
  for(i in 1:rN){      
    ct.i<-ct[i,]
    la<-ct.i[,v][1]

    if(is.na(current)){
      current<-la
    }
    # add new empty row
    else if(current != la){
      m<-matrix(data=rep(0,ncol),nrow=1,ncol=ncol)
      empty<-as.data.frame(m)        
      names(empty)<-na
      empty$color<-"white"
      empty$label<-""

      new<-rbind(new,empty)
      current<-la
    }

    # add current row of ct to new combined table
    new<-rbind(new,ct.i)
  }

  return(new)
}


diversity.regression<-function(cal,index="shannon",paired=F,corIndex){
  require(vegan)

  ca<-c.annotatedCounts(cal)

  pair<-ca$pair

  taxa<-c.taxa(cal)

  # get diversity
  div<-getDiv(as.matrix(ca[,taxa]),index=index)

  if(! is.null(ca$DDIV)){
    stop("ERROR: DDIV defined")
  }
  
  ca$DDIV<-as.numeric(div)
  

  envs<-c.environment.vars(cal)
  
  if(paired){
    nam<-c("DDIV",envs)
    ncol<-length(nam)
    ca.new<-data.frame(matrix(nrow=0,ncol=ncol))
    names(ca.new)<-nam

    # iterate over all pairs
    for(p in pair){
      dp<-ca[ca$pair==p,]

      # exclude pairs with less than 2 samples
      if(dim(dp)[1] < 2) next

      # iterate over all pairwise combinations of pair
      pN<-dim(dp)[1]
      for(i in 1:(pN-1)){
        for(j in (i+1):pN){
      
          dA<-dp[i,]
          dB<-dp[j,]

          div.diff<-dA[1,]$DDIV - dB[1,]$DDIV
          
          p.df<-data.frame(matrix(ncol=ncol,nrow=1))
          names(p.df)<-nam
          p.df$DDIV<-div.diff

          # iterate over all environmental variables
          for (e in envs){
            
            e.diff<-0
                                        # set diff for numeric variables
                                        # should be 0 for categorical variables!!!!!
            if(is.numeric(dA[1,e])){
              e.diff<-dA[1,e] - dB[1,e]
            }
            p.df[1,e]<-e.diff
          }
          ca.new<-rbind(ca.new,p.df)          
        }
      }            
    }
    ca<-ca.new
  }
  
  
  # build regression formula
  f<-as.formula(paste("DDIV ~ ",paste(envs,collapse=" + ")))
  fo<-(paste(index," ~ ",paste(envs,collapse=" + ")))
  nfo<-nchar(fo)
  if(nfo>41) fo<-paste0(substr(fo,1,40),"\n",substr(fo,41,nfo))

  mod<-glm(f,data=ca)

  envsN<-length(envs) + 1
  nrow<-envsN*2/ 3

  if(nrow %% 3 != 0){
    nrow<-as.integer(nrow) + 1
  }
  
  par<-par(mfrow=c(max(nrow,5),3))

  ylab<-index

  if(paired) ylab<-paste("Diff.",index,"(paired)")

  ca.na<-na.omit(ca[,c("DDIV",envs)])

  s<-summary(mod)
  cof<-as.data.frame(s$coefficients[,c(1,2,4)])
  cof<-cof[-1,]
  names(cof)[3]<-"P"
  names(cof)[1]<-"Coefficient"
  cof<-cof[,c(1,3)]
#  cof<-cof[order(cof$P),]


   cof$Signif<-""

  cof[(!is.na(cof$P)) & cof$P<=0.05,"Signif"]<-"*"
  cof[(!is.na(cof$P)) & cof$P<=0.01,"Signif"]<-"**"
  cof[(!is.na(cof$P)) & cof$P<=0.001,"Signif"]<-"***"

  cof$P<-signif(cof$P,3)

  textplot(cof)

  title(paste(c("Multivariate linear regression model:\n",fo)))

  # plot results
  for(e in envs){

    dobox<-T
    if(is.numeric(ca[,e])) dobox<-F
    
    
    p<-1
    main<-e
    fit<-1

    if(! dobox){
        cot<-cor.test(ca[,"DDIV"],ca[,e],method=corIndex)
   	co<-signif(cot$estimate[[1]],2)
    	p<-signif(cot$p.value[[1]],2)


      fit<-glm(as.formula(paste("DDIV~",e)),data=ca)
#      p<-signif(anova(aov(fit))$"Pr(>F)"[1],5)
          main<-paste(e," R=",co," p=",p,sep="")
    }
    else{
	df<-data.frame(Group=ca[,e],Div=ca$DDIV)
	a<-anova(aov(Div ~ Group,df))
	p<-signif(a$"Pr(>F)"[1],4)	
        main<-paste0(e,", p = ",p," (anova)")
	}
    
    xlab<-e
    if(paired) xlab<-paste("Diff.",e,"(paired)")
          
    plot(ca[,e],ca$DDIV,pch=16,main=main,xlab=xlab,ylab=ylab,col=rgb(0.1,0.1,0.6,0.6))
    grid()

    if(! dobox){
      if (! is.na(fit$coefficients[2])) abline(fit,col="red",lty=3)
    }
    
    if(length(envs) > 1){
      fit2<-lm(as.formula(paste("DDIV~",paste(envs[envs!=e],collapse="+"))),
          data=ca.na)

      fit3<-1
      p<-1
      main<-e
      if(! dobox){
        fit3<-lm(as.numeric(fit2$residuals) ~ as.numeric(ca.na[,e]))

	cot<-cor.test(fit2$residuals,as.numeric(ca.na[,e]),method=corIndex)
   	co<-signif(cot$estimate[[1]],2)
    	p<-signif(cot$p.value[[1]],2)

        main<-paste(e," R=",co," p=",p,sep="")
      }
      else{
        df<-data.frame(Group=ca.na[,e],Div=fit2$residuals)
	a<-anova(aov(Div ~ Group,df))
	p<-signif(a$"Pr(>F)"[1],4)	
        main<-paste0(e,", p = ",p," (anova)")
      }     
        plot(ca.na[,e],fit2$residuals,pch=16,main=main,xlab=xlab,ylab=paste("Controlled",ylab),col=rgb(0.1,0.1,0.6,0.6))
      grid()
      if(! dobox) if(! is.na(fit3$coefficients[2])) abline(fit3,col="red",lty=3)
    }
  }
  par(par)
  return(ca)
}


c.pls<-function(cal,out,width=500,height=500,res=120){
    library(plsdepot)

    ca<-c.annotatedCounts(cal)
    env<-c.environment.vars(cal,numeric=T)
    taxa<-c.taxa(cal)

    ca<-na.omit(ca[,c(taxa,env)])
    
    if(!missing(out)) png(out,res=res,width=width,height=height)

    X<-ca[,taxa]
    Y<-ca[,env]

    print(head(X))
    print("Y")
    print(head(Y))
    
    if(length(env) < 1){
        em<-"ERROR: no numeric factor"
        print(em)
        textplot(em)
    }
    else if(length(env) == 1){
        pls<-plsreg1(X,Y,comps=2,crosval=T)
    }
    else{
        pls<-plsreg2(X,Y,comps=2,crosval=T)
    }

    plot(pls)
    
    if(!missing(out)) dev.off(out)
}


c.FactorAnalysis<-function(cal,heatBasis,heatCoef,basisFile,coefFile,
                           factors=20,
                           width=500,height=500,res=120,title="",level,
                           calypso=T,color="blueGoldRed",...){

    library(NMF)

    ca<-c.annotatedCounts(cal)
    rownames(ca)<-ca$sample
    taxa<-c.taxa(cal)
    counts<-ca[,taxa]

    min<-min(counts)
    if(min<0) counts<-counts + abs(min)
    
 col<-getColors(color,40)
    
    cat("Running nmf ...")
    nm<-nmf(counts,factors,...)
    cat(" Done.\n")
    
    basis<-basis(nm)    


    tmp<-as.data.frame(t(basis))
    fa<-paste("Factor",1:(dim(tmp)[1]),sep="")
    nam<-names(tmp)
    tmp$Factor<-fa
    write.csv(tmp[,c("Factor",nam)],basisFile,quote=F,row.names=F)
    
    coef<-coef(nm)
    colnames(coef)[1]<-"Factor"
    write.csv(coef,coefFile,quote=F,row.names=F)

    csc<-data.frame(matrix(ncol=0,nrow=dim(ca)[1]))

        envs<-c.environment.vars(cal)
        for(e in envs){

            v<-ca[,e]
            colors<-1

            if(is.numeric(v)) colors<-getContCol(v,F)
            else colors<-heatAnnotationCol(v)

            if(length(unique(v)) > 1) csc[,e]<-colors
        }
    
    png(heatBasis,res=res,width=width,height=height)

    
    
    heatmap.3(t(basis),col=col,
              scale="none",trace="none",cexRow=0.8,cexCol=0.8,
              symbreaks=F,main=title,margins=c(30,10),density.info="density",
              keysize=1.5,lwid=c(1,4.5),ColSideColors=csc)

    dev.off()

    png(heatCoef,res=res,width=width,height=height)

    heatmap.3(coef,col=col,
              scale="none",trace="none",cexRow=0.8,cexCol=0.8,
              symbreaks=F,main=title,margins=c(30,10),density.info="density",
              keysize=1.5,lwid=c(1,4.5))


    
    dev.off()
    
    return(1)    
}

# possible types: distance and diversity
distance.regression<-function(cal,type="distance",index="jaccard",paired=F){
  require(vegan)  

  ca<-1
  if(type == "distance"){
    ca<-c.annotatedCounts(cal)
  }
  else{
    ca<-c.annotatedCounts(cal)
  }
 
  # get distance
  taxa<-c.taxa(cal)


  counts.d<-as.matrix(distWrapper(as.matrix(ca[,taxa]),method=index,type=type))

  envs<-c.environment.vars(cal)

  
  sampleN<-dim(ca)[1]
  comb<-data.frame(combinations(sampleN,2,1:sampleN))

  if(paired){
    pA<-ca[comb[,1],]$pair
    pB<-ca[comb[,2],]$pair
    comb<-comb[pA == pB,]
  }
  
  di<-as.data.frame(counts.d)

  if(any(rownames(ca) != names(di))) stop(paste("ARGGGHH",paste(names(di))))
  if(any(rownames(ca) != colnames(di))) stop("ARGGGHH")

  if(any(envs == "dddist")) stop("ARGGGHH")
  nam<-c("labelA","labelB","dddist",envs)
  ncol<-length(nam)
  nrow<-dim(comb)[1]
  d.df<-data.frame(matrix(nrow=nrow,ncol=ncol))
  names(d.df)<-nam

  d.df$labelA<-names(di)[comb[,1]]
  d.df$labelB<-names(di)[comb[,2]]

  cat("Getting distances ...")
  d.helper<-function(x) return(counts.d[x[1],x[2]])
  
  d.df$dddist<-apply(comb,1,d.helper)

  for(e in envs){
    if(is.numeric(ca[,e])){
      d.tmp<-abs(ca[comb[,1],e] - ca[comb[,2],e])
      d.df[,e]<-d.tmp
    }
    else{
      d.tmp<-ca[comb[,1],e] != ca[comb[,2],e]
      d.df[,e]<-as.numeric(d.tmp)
    }
  }

  cat(" Done.\n")

  new<-c()
  
  # remove env par that where all samples have the same value
  for(e in envs){
    if(length(unique(d.df[,e])) < 2) d.df[,e]<-NULL
    else new<-c(new,e)
  }

  envs<-new

  # build regression formula  
  ft<-paste("dddist ~ ",paste(envs,collapse=" + "))
  f<-as.formula(ft)

  mod<-glm(f,data=d.df)
  
  envsN<-length(envs) + 1
  nrow<-envsN * 2/ 3

  if(nrow %% 3 != 0){
    nrow<-as.integer(nrow) + 1
  }
  
  par<-par(mfrow=c(nrow,3))

  s<-summary(mod)
  cof<-as.data.frame(s$coefficients[,c(1,2,4)])
  names(cof)[3]<-"P"

  cof<-round(cof,3)
  cof$S<-""
  
  cof[(!is.na(cof$P)) & cof$P<=0.05,"S"]<-"*"
  cof[(!is.na(cof$P)) & cof$P<=0.01,"S"]<-"**"
  cof[(!is.na(cof$P)) & cof$P<=0.001,"S"]<-"***"
 
  textplot(cof)
  title(paste("Multivariate linear regression model:\n",ft))

  
  d.df.na<-na.omit(d.df[,c("dddist",envs)])
  
  # plot results
  for(e in envs){
    fit<-glm(as.formula(paste("dddist~",e)),data=d.df)
    p<-signif(anova(aov(fit))$"Pr(>F)"[1],2)
    c<-fit$coefficients[[2]]
    si<-sign(c)
    c<-round(c,3)
    if(si==-1) si<-"-"
    else if(si==1) si<-"+"
    if(c==0)c<-paste(si,c,sep="")

    if(length(unique(na.omit(d.df[,e])))==2) boxplot(d.df$dddist ~ d.df[,e],pch=16,main=paste(e,", p=",p," c=",c,sep=""),xlab=paste(e,"difference"),ylab=paste(index,"distance"),col=c("lightblue",rgb(0.1,0.1,0.6)))
    else plot(d.df[,e],d.df$dddist,pch=16,main=paste(e,", p=",p," c=",c,sep=""),xlab=paste(e,"difference"),ylab=paste(index,"distance"),col=rgb(0.1,0.1,0.6,0.3))

    grid()
    if(! is.na(fit$coefficients[2])) abline(fit,col="red",lty=3)


    if(length(envs) > 1){
      fmla <- as.formula(paste("dddist ~ ",paste(envs[envs != e],collapse="+")))
      fit2 <- lm(fmla,data=d.df.na)
      res2<-fit2$residuals
      fit3<-lm(as.numeric(res2) ~ as.numeric(d.df.na[,e]))
      p<-signif(anova(aov(fit3))$"Pr(>F)"[1],2)
      c<-fit3$coefficients[[2]]
      si<-sign(c)
      c<-round(c,3)
      if(si==-1) si<-"-"
      else if(si==1) si<-"+"
      if(c==0)c<-paste(si,c,sep="")
      
      if(length(unique(d.df.na[,e]))==2) boxplot(res2 ~ d.df.na[,e],pch=16,
                 col=c("lightblue",rgb(0.1,0.1,0.6)),ylab=paste("Controlled",index,"distance"),xlab=paste(e,"difference"),
                 main=paste("Partial Correlation p=",p," c=",c,sep=""))
      else plot(d.df.na[,e],res2,pch=16,col=rgb(0.1,0.1,0.6,0.3),ylab=paste("Controlled",index,"distance"),xlab=paste(e,"difference"),
           main=paste("Controlled ",e," p=",p," c=",c,sep=""))
      grid()
      if(! is.na(fit3$coefficients[2])) abline(fit3,col="red",lty=3)
    }
  }
  par(par)

  
  return(d.df)
}

