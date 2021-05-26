library(gplots)
library(Cairo)


FACTORS<-c("groups","groupso","colors","times","response","subjects","symbols","totals","labels","matrix","samples")


if(! exists("anyNA")) anyNA<-function(x){any(is.na(x))}

png<-function(filename,res=75,width=200,height=200,units="mm",bg="white",
              pos=13){
    CairoPNG(filename=filename, width = width, height = height, bg = bg, units=units,dpi=res,pointsize=pos)
                                        #	CairoPDF(file=filename, width = width, height = height, bg = "white")
}

pdf<-function(filename,width=200,height=200,bg="white"){
    width=width/20
    height=height/20
    CairoPDF(file=filename, width = width, height = height, bg = bg)
}

svg<-function(filename,width=200,height=200,bg="white"){
    width=width/20
    height=height/20
    CairoSVG(file=filename, width = width, height = height, bg = bg)
}




toPNG<-function(out,width,height,res,func,...){
    png(out,width=width,height=height,res=res,units="mm")
    func(...)
    dev.off()
}

lsd<-function(dfct,sign=0.05){
    a<-aov(Count ~ Group, dfct)
    p<-anova(a)$"Pr(>F)"[1]
    dfr<-(length(dfct$Sample))/length(unique(dfct$Group))
    lsd<-qt(1-sign/2,dfr - 1)*sqrt(2*anova(a)$Mean [2] / dfr)
    return(c(lsd,p))
}

correlation.network<-function(corm,legend=T,min.sim=0.9,labels=T,title="",vSize=20,colors=c(),
                              groups=NA,keep.isolates=T,ctype="white",freq=NULL,layoutByDist=F,adjustVldist=T,vCol=c(),avoidOverlap=T,layoutMatrix=NA){

    max<-max(freq,na.rm=T)
    if(max > 1){
        if(max>100) freq<-log10(freq)
        else if(max > 10) freq<-log(freq)
        else freq<-log2(freq)
    }
    # scale freq
    min<-min(freq,na.rm=T)
    freq<-freq - min
    max<-max(freq,na.rm=T)
    freq<-freq/max
    
    corm<-replace(corm,is.na(corm),0)
    
    lay<-NULL

    if(max(abs(corm)) > 1.00000000001){
        ma<-max(abs(corm))

        stop(paste("ERROR: similarity matrix has to be in the range -1 to 1!!!",ma))
    }

    corm[corm > 1]<-1
    corm[corm < -1]<- -1

    
                                        # layout by distance using cmdscale
    if(layoutByDist){
                                        # bring correlation matrix from range -1-1 to range 0-1 and convert to dist
        di<-1 - (corm + 1) /2
        
        lay<-cmdscale(di)
    }

    
    require(igraph)
    require(vegan)

    
                                        # set diagonal and lower triangle to 0
    corm[ lower.tri(corm, diag=TRUE) ]<- 0

                                        # set sim to 0 if sim < min.sim
    corm[ abs(corm) < min.sim]<- 0

                                        #  if(! sum(abs(corm)) > 0){
                                        #    plot(1,type="n",axes=F,ylab="",xlab="")
                                        #    return()
                                        #  }
    
                                        # unweighted
                                        #ig<-graph.adjacency(corm > 0.5, mode="upper",weighted=NULL,diag=F)
    
                                        # weighted
    ig<-graph.adjacency(corm, mode="upper",weighted=T,diag=F)

                                        #ig<-graph.adjacency(corm > 0.5,weighted=NULL)
                                        #ig$layout <- layout.fruchterman.reingold

                                        # set weight of graph
    w<-t(corm)[abs(t(corm))>min.sim]

    
    if(length(w) > 0){
        E(ig)$weight<-w
    }

    if(is.null(colnames(corm))) labels = F
    
    if(labels){
        V(ig)$label<-colnames(corm)
    }
    else{
        V(ig)$label<-rep("",dim(corm)[2])
    }

                                        #  V(ig)$label<-""

                                        # set colors of vertices
    if(length(colors)>0){
        V(ig)$color<-colors
    }

                                        #ig$layout <- layout.fruchterman.reingold

                                        # set node size
    if(is.vector(freq)){
        vSize<-vSize * log(freq + 1) / 2

        maxL<-50
        if(length(freq) > maxL){
            freq.sorted<-sort(freq,decreasing=T)
            minFreq<-freq.sorted[maxL]
            V(ig)[freq < minFreq]$label<-""
        }
    }
    
    V(ig)$size<-vSize

                                        # node frame color
    vfcolor<-"black"

                                        # node label distance
    vldist<-0

                                        # set distance of labels to vertices
    if(adjustVldist){    
        if(max(vSize) < 11){
            vldist<-0.4
        }
        
        if(max(vSize) <= 5){
            if(length(colors) > 0){
                vfcolor<-colors
            }
            vldist<-0.3
        }
    }


                                        # remove isolate vertices
    if(! keep.isolates){
        excl<-degree(ig) == 0
        isolates <- V(ig)[excl]
        ig <- delete.vertices(ig, isolates)

        if(! is.null(lay)){
            lay<-lay[! excl,]
            
            if(length(V(ig)) != dim(lay)[1]){
                stop(paste("ERROR: dim of layout doeson't match number of vertices",dim(lay)[1],length(V(ig))))
            }
        }
    }

                                        # plot legend if vertices are colored by groups
    if( (length(colors) > 0) | is.na(groups) ){
        legend<-F
    }

                                        # set layout of legend is plotted
    if(legend){
        layout(matrix(c(1,2), 1,2), widths=c(3,1))
    }

                                        # set positively correlated edges to black
                                        # set all weights to red, this is just a check
    E(ig)$color<-"red"

    if(length(w) > 0){ 
                                        # get positive weights
        pweights<-E(ig)[ E(ig)$weight > 0]$weight
        cv<-1-pweights
                                        # set positvely correlated edges to black/grey
        E(ig)[ E(ig)$weight > 0 ]$color <- rgb(cv,cv/4,cv/4,maxColorValue=1)
        
        if(max(E(ig)$weight > 1)){
            stop("ERROR: weights have to be in the range 0 to 1!!!!")
        }
    }
    
    vlc<-"black"
    bg<-"white"
    col.main<-"black"

                                        # set colors if background is black
    if(ctype == "black"){
        vlc<-"white"
        bg<-"black"
        col.main<-"white"

                                        # set color of positively correlated
        if(length(w) > 0){
            cv<-0.2+abs(E(ig)[E(ig)$weight > 0]$weight)
            E(ig)[E(ig)$weight > 0]$color<-rgb(cv,cv,0,maxColorValue=1.2)
        }
    }

                                        # set color of neg. correlated edges to blue, strenth based on correlation value
    if(length(w) > 0){
        E(ig)[ E(ig)$weight < 0 ]$color <- rgb(0,0,0.2+abs(E(ig)[E(ig)$weight < 0]$weight),maxColorValue=1.2)
    }
    par<-par(bg=bg,col.main=col.main)

    if(! is.null(lay)){
        if(length(V(ig)) != dim(lay)[1]){
            stop(paste("ERROR: dim of layout doeson't match number of vertices",dim(lay)[1],length(V(ig))))
        }
    }

    if(length(vCol) > 0) vlc<-vCol

    resc<-T
    xlim<-c(-1,1)
    ylim<-c(-1,1)

    if(avoidOverlap){

        if(F){
            lay<-layout.auto(ig)
            di.min<-min(dist(lay))

            fa<-1.5
            if(di.min > 0) fa<-30/di.min

            if(fa < 1) fa<-1
            
            lay<-lay * fa
            resc<-F
            xlim<-range(lay[,1])
            ylim<-range(lay[,2])
            vm<-max(xlim[2]-xlim[1],ylim[2]-ylim[1]) / 2
            V(ig)$size<-V(ig)$size * vm
            vldist<-vldist * vm
        }
        else{
            ig2<-ig
            ig<-delete.edges(ig,E(ig)[E(ig)$weight<0])

            msm<-0.12
            
            set.seed(1123)
            if(is.null(lay)){
                lay <- layout.norm(layout.random(ig), -1,1,-1,1)
                msm<-0.2
            }
            lay2 <- layout.graphopt(ig, niter=1000, start=lay, max.sa.movement=msm)
            lay2 <- layout.norm(lay2, -1,1, -1,1)
            lay<-lay2
            ig<-ig2
        }
    }


    if(! is.na(layoutMatrix)){
        if(length(V(ig)) != dim(lay)[1]){
            stop(paste("ERROR: dim of layout doeson't match number of vertices",dim(lay)[1],length(V(ig))))
        }

        rownames(lay)<-V(ig)$label

        write.csv(file=layoutMatrix,lay,quote=F,row.names=T)
    }
    
    plot(ig,vertex.label.cex=0.5,vertex.label.color=vlc,vertex.label.dist=vldist,vertex.frame.color=vfcolor,frame=F,
         vertex.shape="circle",layout=lay,edge.width=3,rescale=resc,xlim=xlim,ylim=ylim)
    title(title)

    if(legend){
        plot.new()
        legend("center",legend=unique(groups), col=unique(colors), pch=19,title="Groups")
    }
    par(par)
    return(list(lay,ig))
    return(1)  
}




lsdPlot<-function(dfc,out="lsd.png",png=T,color="blue1",height,width,res,sign=0.05,filterSig=T,horiz=F,diff.from.median=F,title=""){

    taxa<-as.character(unique(dfc$Taxa))
    groups<-as.character(unique(dfc$Group))
    nT<-length(taxa)
    nG<-length(groups)

    data<-as.data.frame(matrix(ncol=nT,nrow=nG + 2))
    rownames(data)<-c(groups,"LSD","P")
    names(data)<-taxa


                                        # iterate over all taxa
    for(t in unique(dfc$Taxa)){
        dfct<-dfc[dfc$Taxa==t,]
        lsd<-lsd(dfct,sign)
        data["LSD",t]<-lsd[1]
        data["P",t]<-lsd[2]
        for(g in as.character(unique(dfct$Group))){
            m<-mean(dfct[dfct$Group == g,]$Count)
            data[g,t]<-m
        }
    }


    if(filterSig){
        sigN<-length(which(data["P",] < sign))
        if(sigN > 0){
            data<-subset(data,T,data["P",]<sign)
        }
    }

    data.o<-data

    lsd<-data["LSD",]
    p<-data["P",]
    
    data<-subset(data,rownames(data) %in% groups)

    medians<-apply(data,2,median)

    
    lsd.matrix<-lsd
    medians.matrix<-medians

    for(i in 1:(nG - 1)){
        lsd.matrix<-rbind(lsd.matrix,lsd)
        medians.matrix<-rbind(medians.matrix,medians)
    }

    lsd.matrix<-data.matrix(lsd.matrix)
    medians.matrix<-data.matrix(medians.matrix)

    data<-data.matrix(data)

    if(diff.from.median){
        data<-(data-medians.matrix)
    }
    errU<-data.matrix(data + lsd.matrix/2)
    errL<-data.matrix(data - lsd.matrix/2)

    if(png){
        png(out,width=width,height=height,res=res,units="mm")
    }
    if(horiz){
	par<-par(fig=c(0.3,1,0,1))
    }
    else{
	par<-par(fig=c(0,1,0.2,1))
    }

    labels<-groups
    col<-getColors(color,nG)
    gridG<-nG


    b<-c()

    if(diff.from.median){
	title<-"Difference from Median (%)\n"
    }

    title<-paste(title,"Errorbars: LSD/2, p <",sign)

    if(horiz){
	b<-barplot(data,beside=T,horiz=horiz,las=2,main=title,col=col)
    }
    else{
	ma<-max(data)
	ylim<-c(0,ma + 0.2 * ma)
	b<-barplot(data,beside=T,horiz=horiz,las=2,main=title,col=col,ylim=ylim)
    }

    j<-0
    for(i in b){
        j<-j+1
        if(j%%gridG == 0){
            if(horiz){
                abline(i+0.5,0,lty=2,col="grey")
            }
            else{
                abline(v=i+0.5,lty=2,col="grey")
            }
        }
    }


    if(horiz){
	segments(data,b,errU,b)
	segments(data,b,errL,b)
    }
    else{
        error.bar(b,data,lsd.matrix/2)
                                        #	segments(b,data,b,errU)
                                        #	segments(b,data,b,errL)
    }

    legend("right", legend=rev(labels), cex=0.9, fill=rev(col));
    par(par)
    if(png){
        dev.off();
    }
    return(data.o)
}

rh<-function(n,tot){
    num<-c()
    for(i in 1:n){
        r<-round(runif(1,0,tot),0)
        tot<-tot - r
        num<-c(num,r)
    }

    return(num)
}

rhg<-function(totals,tN){
    gN<-length(totals)
    m<-matrix(nrow=tN,ncol=gN)
    for(i in 1:gN){
        to<-totals[i]
        nu<-rh(tN,to)
        m[,i]<-sample(nu)
    }
    m<-m[apply(m,1,sum) > 0,]
    return(m)
    pc<-c()
    vc<-c()
    
    for(i in 1:tN){
        t<-matrix(nrow=2,ncol=gN)
        t[1,]<-m[i,]
        t[2,]<-totals
        v<-var(m[i,])
        vc<-c(vc,v)

        if(v > 5000) print(m[i,])
                                        #p<-chisq.test(t)$p.value
                                        #pc<-c(pc,p)
    }
    
    return(vc)
}

calypso2dfc<-function(cal){
    ca<-c.annotatedCounts(cal)

    taxa<-c.taxa(cal)
    samples<-rownames(ca)
    groups<-ca$group
    time<-ca$time
    pair<-ca$pair

    taxa.c<-c()
    count.c<-c()

    n<-dim(ca)[1]
    for(t in taxa){
        count.c<-c(count.c,ca[,t])	      
        taxa.c<-c(taxa.c,rep(t,n))
    }
    
    tN<-length(taxa)
    df<-data.frame(Sample=rep(samples,tN),Pair=rep(pair,tN),Group=rep(groups,tN),
                   Time=rep(time,tN),Taxa=taxa.c,Count=count.c)

    return(df)	
}

rankPlot<-function(cal,out="plot.png",color="blue1",height,width,res,sign=0.05,filterSig=T,title="",sigDiff=T,type="rankplot",groupBy="group",figureFormat="png"){
    

    cal<-c.setGroups(cal,groupBy=groupBy)
    dfc<-calypso2dfc(cal)

    dfc<-dfc[!is.na(dfc$Group),]
    cal<-NULL


                                        # order dataframe by group
    dfc<-dfc[order(dfc$Group),]


    if(type=="rankplot") title<-paste0(title," (p<",sign,", rank test)")
    else if(type=="nestedanova") title<-paste0(title," (p<",sign,", Nested Anova)")
    else title<-paste0(title," (p<",sign,", anova)")
    
    
    taxa<-as.character(unique(dfc$Taxa))
    groups<-as.character(unique(dfc$Group))
    location<-as.character(unique(dfc$Time))
    nT<-length(taxa)
    nG<-length(groups)

    if(figureFormat == "png"){
        png(out,width=width,height=height,res=res,units="mm")
    }
    else if(figureFormat == "pdf"){
        pdf(out,width=width,height=height)
    }
    else if(figureFormat == "svg"){
        svg(out,width=width,height=height)
    }


    if(nG < 2){
        errm<-"ERROR: less than 2 groups defined"
        frame()
        text(0.5,0.5,errm,font=2,,col="red",cex=1.5)
        dev.off()
        print(errm)
        return(0)
    }
    
                                        # new empty dataframe
    data<-data.frame(matrix(ncol=nT,nrow=nG + 1))


    rownames(data)<-c(groups,"P.value")

    names(data)<-taxa

                                        # new empty dataframe
    vari<-data.frame(matrix(ncol=nT,nrow=nG))

    rownames(vari)<-c(groups)

    names(vari)<-taxa
    
                                        # iterate over all taxa and do test
    for(t in unique(dfc$Taxa)){
        dfct<-dfc[dfc$Taxa==t,]

        p<-0
                                        # do rank test
        if(type=="rankplot"){
            if(nG == 2){
                p<-wilcox.test(Count ~ Group,dfct)$p.value
            }
            else{
                p<-kruskal.test(Count ~ Group,dfct)$p.value
            }
        }
                                        # do nested anova
        else if(type=="nestedanova"){
            if(length(unique(dfct$Time))<2){
                errm<-"ERROR: less than 2 nested groups defined"
                frame()	   
                text(0.5,0.5,errm,font=2,,col="red",cex=1.5)
                dev.off()
                print(errm)
                return(0)			   
            }
            a<-aov(Count ~ as.factor(Group)/as.factor(Time),dfct)
            p<-as.numeric(unlist(summary(a))[13])
        } 
                                        # do ttest or anova
        else{
            a<-aov(Count ~ Group,dfct)
            p<-as.numeric(unlist(summary(a))[9])
        }

        data["P.value",t]<-p
        for(g in as.character(unique(dfct$Group))){
            
            counts<-dfct[dfct$Group == g,]$Count
            
            m<-0
            if(type=="rankplot"){
                m<-median(counts)
            }
            else{
                m<-mean(counts)
            }
            v<-sd(counts)/sqrt(length(counts))
            data[g,t]<-m
            vari[g,t]<-v
        }
    }


    if(filterSig){    
        filter<-as.logical(data["P.value",] <= sign)
        filter[which(is.na(filter))]<-F

        if(sum(filter,na.rm=T) > 0){
            data<-subset(data,select=filter)
            vari<-subset(vari,select=filter)
        }
        else{
            textplot(paste("No feature with p <",sign))
            return(1)
        }   
    }
    p<-data["P.value",]
    
    data<-subset(data,subset=c(rep(T,length(groups)),F))
    data<-data.matrix(data)
    vari<-data.matrix(vari)
    
    or<-par(fig=c(0,1,0.3,1))
    layout(matrix(c(1,2,3,2), 2, 2),heights=c(4,2), widths=c(2.2,1) ) 
    
    labels<-groups
    col<-getColors(color,nG)
    gridG<-nG
    
    
    b<-c()
    
    
    ma<-max(data)
    ylim<-c(0,ma + 0.5 * ma)
    
    ylab<-1
    
    if(type=="rankplot"){
        ylab<-""
    }
    else{
        ylab<-""
    }

    print("barplot")
    b<-barplot(data,beside=T,horiz=F,las=2,main=title,col=col,ylim=ylim,
               ylab=ylab)

    error.bar(b,data,vari)

                                        #		arrows(b,data+vari,b,data-vari,code=3,angle=90)
                                        #		segments(b,data+vari,b,data-vari)
                                        #		si<-(b[2]-b[1])*0.3
                                        #		segments(b-si,data+vari,b+si,data+vari)
                                        #		segments(b-si,data-vari,b+si,data-vari)
    

    
    taxa<-colnames(data)

    offset<-ma * 0.04

                                        # print * for sign. different groups
    if(sigDiff){
        cI<-0
        for(t in taxa){
            cI<-cI+1

            dfct<-dfc[dfc$Taxa==t,]
            y<-ma+0.3*ma

            y<-max(max(data[,t])+offset + 0,ma/3)

            for(i in 1:(nG-1)){
                gA<-groups[i]

                for(j in (i+1):nG){
                    gB<-groups[j]

                    p<-1
                    if(type=="rankplot"){
                        p<-wilcox.test(dfct[dfct$Group==gA,]$Count,dfct[dfct$Group==gB,]$Count)$p.value
                        if(is.na(p)) p<-2                  
                    }
                    else{                  
                        a<-aov(Count ~ Group,dfct[dfct$Group==gA | dfct$Group==gB,])
                        p<-as.numeric(unlist(summary(a))[9])
                                        #                  p<-as.numeric(t.test(dfct[dfct$Group==gA,]$Count,dfct[dfct$Group==gB,]$Count)$p.value)
                        if(is.na(p)) p<-2                                    
                    }

                    if((! is.na(p)) & p<0.05){
                        x1<-b[i,cI]
                        x2<-b[j,cI]
                        lines(c(x1,x2),c(y,y))
                        lines(c(x1,x1),c(y-offset/4,y))
                        lines(c(x2,x2),c(y-offset/4,y))

                        label<-"*"
                        if(p<0.01){
                            label<-"**"
                        }
                        if(p<0.001){
                            label<-"***"
                        }
                        text(x1 + (x2-x1)/2,y+offset/3,labels=c(label))
                        y<-y+offset
                    }
                }
            }
        }
    }

    j<-0
    for(i in b){
        j<-j+1
        if(j%%gridG == 0){
            abline(v=i+0.5,lty=2,col="grey")
        }
    }
    frame()
    frame()
    legend("left", legend=rev(labels), cex=0.9, fill=rev(col),bg="white");

    dev.off();
    return(data)
}

error.bar <- function(b,data,serr){
    segments(b,data+serr,b,data-serr)
    si<-(b[2]-b[1])*0.3
    segments(b-si,data+serr,b+si,data+serr)
    segments(b-si,data-serr,b+si,data-serr)
}



matrix2dfcompact<-function(m){
    df<-as.data.frame(t(m$matrix))

    for(n in names(m)){
        if(! n %in% c("matrix","taxa")){
            df[,n]<-(m[[n]])
        }
    }

                                        #  df$response<-as.numeric(m$response)
    df$subjects<-m$subjects
    df$symbols<-m$symbols
    return(df)
}

taxaDFC<-function(df,factors=c()){
    df.names<-colnames(df)

    if(length(factors) == 0){
        factors<-FACTORS
    }

    taxa<-df.names[! df.names %in% FACTORS]

    return(taxa)
    
    for (c in factors){
        i<-which(taxa == c)
        if(length(i) > 0){
            taxa<-taxa[-i]
        }
    }
    
    return(taxa)
}


test.pairwise<-function(counts,method="wilcox",allgroups=T,alternative="two.sided"){

    groups<-unique(counts$Group)
    p.c<-data.frame(Group="delme1",p=-1)

    for(g in groups){
        c<-counts[counts$Group==g,]
        p<-t.pair(c,method,alternative=alternative)
        p.c<-rbind(p.c,data.frame(Group=g,p=signif(p,2)))
    }
    if(allgroups){
        p<-signif(t.pair(counts,method,alternative=alternative),2)
        p.c<-rbind(p.c,data.frame(Group="AllGroups",p=p))
    }
    p.c<-p.c[-1,]

    return(p.c)
}

t.pair<-function(counts,method="wilcox",alternative="two.sided"){
    w<-1
    if(method == "wilcox"){
        w<-wilcox.test(counts$A,counts$B,paired=T,alternative=alternative)
    }
    else if (method == "ttest"){
        w<-t.test(counts$A,counts$B,paired=T)
    }
    else{
        stop("ERROR: undefined test")
        return(-1)
    }

    return(w$p.value)
}

plotPairwiseP<-function(table,file,tA,tB,tC,tD,title="",log=T){
    png(file,res=150,width=110,height=120,units="mm")
    xlab<-paste("P-value distribution (",tC," vs ",tD,")",sep="")
    ylab<-paste("P-value distribution (",tA," vs ",tB,")",sep="")

    x<-table$Pb[order(table$Pbc)]
    y<-table$P[order(table$P)]

    s.d<-length(which(x<0.05))
    ns.d<-length(x)-s.d
    col<-c(rep(rgb(0.7,0.1,0.1,0.5),s.d),rep(rgb(0.2,0.2,0.7,0.5),ns.d))

    lim<-c(0,1)

    if(log){
        x<-log10(x)
        y<-log10(y)
        xlab<-paste(xlab," log10(p)")
        ylab<-paste(ylab," log10(p)")
        lim<-c(min(c(x,y),na.rm=T),max(c(x,y),na.rm=T))
    }
    title<-paste("QQ Plot",title)
    plot(x,y,pch=16,col=col,xlab=xlab,ylab=ylab,xlim=lim,ylim=lim,main=title)
    abline(0,1,col="red")
    dev.off()
}

c.pairwise<-function(cal,outF,outP,tA,tB,tC,tD,type="divs",index="shannon",test="wilcox",color="default",title="",tax="",labels=T,legend=T,width=700,height=600,res=75,png=T,alternative="two.sided"){

    if(type=="scatter"){
        if(png) png(outF,width=width,height=height,res=res,units="mm")
        paired.scatter(cal,tA,tB,test,alternative)
        if(png) dev.off()
        return(1)
    }

    require(vegan)
    require(gdata)


    m<-1
    if(type=="divs" | type=="divb"){
        m<-calypso2matrix(cal)
    }
    else{
        m<-calypso2matrix(cal)
    }

    counts<-0

    if(type == "table"){
        table<-alltax.pairwise.test(m,tA,tB,test)
        write.csv(file=outP,table,quote=F,row.names=F)
        pHist(table$P,outF)
        return(table)
    }

    if(type == "table3"){
        table<-alltax.pairwise.test(m,tA,tB,test,tC=tC,tD=tD)

        plotPairwiseP(table,outF,tA,tB,tC,tD,title=title)

                                        #table.o<-table
                                        #table$Pbc<-NULL
        write.csv(file=outP,table,quote=F,row.names=F)

        return(table)
    }
    else if(type == "taxas" | type == "taxab"){
        title<-paste(title,tax)
        counts<-tax.pairwise(m,tax,tA,tB)

    }
    else if(type == "bubble"){
        counts<-tax.pairwise.diff(m,tA,tB)

        
        require(ade4)

        if(png){
            png(outF,width=width,height=height,res=res,units="mm")
        }

        leg<-0.8
        if(! legend){
            leg<-0
        }

        table.value(counts,clegend=0,csize=1.1)

        if(png){
            dev.off()
        }
        return(counts)
    }
    else if(type=="divs" | type=="divb"){
        title<-paste(title," Diversity (",index,")",sep="")
        counts<-div.pairwise(m,tA,tB,index)
        if(! dim(counts)[1] > 0){
            png(outF)
            textplot("ERROR: no paired data available")
            dev.off()
     
            return(1)
        }


    }
    else if(type=="dist"){
        title<-paste(title," Distance",sep="")
        counts<-dist.pairwise(m,tA,tB,tC,tD)
    }
    else{
        stop(paste("ERROR: unknown type ",type))
    }


    if(dim(counts)[1] == 0){
        errm<-paste("ERROR: no paired samples for groups:\n",tA,"and",tB)
        warning(errm)
        png(outF)
        textplot(errm)
        dev.off()

               tmp<-data.frame(matrix(nrow=0,ncol=3))
            write.csv(file=outP,tmp,quote=F)

        return(-1)
    }
    
    p.c<-test.pairwise(counts,test,alternative=alternative)
    print("Writing results ...")
    write.csv(file=outP,p.c,quote=F)

    if(png){
        png(outF,width=width,height=height,res=res,units="mm")
    }
    if(type=="taxas" | type=="divs" | type=="dist"){
        p<-signif(p.c[p.c$Group=="AllGroups",]$p,2)
        plot.pairwise(counts,tA,tB,tC,tD,color,paste(title," p=",p,sep=""),labels,type
                    , legend=legend)
    }
    else{
        boxplot.pairwise(counts,color,title,labels,ylab=paste(index," (",tB," - ",tA,")",sep=""))
    }
    if(png){
        dev.off()
    }

    return(counts)
}

paired.scatter<-function(cal,tA,tB,test="wilcox",alternative="two.sided"){

    groups<-unique(c.groups(cal))

    ca<-c.annotatedCounts(cal)
    taxa<-c.taxa(cal)

    max<-max(ca[,taxa],na.rm=T)
    min<-min(ca[,taxa],na.rm=T)

    layout(matrix(c(1,2), 1, 2, byrow = TRUE),widths=c(1.8,1))
     
    plot(1,xlim=c(min,max),ylim=c(min,max),col="white",xlab=tA,ylab=tB)

    pc<-c()


    col<-c(rgb(0.5,0.5,0.7,0.4),rgb(0.7,0.5,0.5,0.4),rgb(0.5,0.7,0.5,0.4))
    
    for(i in 1:length(groups)){
        group<-groups[i]
        
        ca1<-ca[ca$group==group,]
        ca2<-ca1
        
        ca1<-ca1[ca1$time==tA,]
        ca2<-ca2[ca2$time==tB,]
        
        ca1<-ca1[ca1$pair %in% ca2$pair,]
        ca2<-ca2[ca2$pair %in% ca1$pair,]

        if(dim(ca1)[1] == 0){
            errm<-paste("ERROR: no paired samples for group",group)
            warning(errm)
            textplot(errm)
            return(1)
        }
        
        ca1<-ca1[order(ca1$pair),]
        ca2<-ca2[order(ca2$pair),]

        if(any(ca1$pair != ca2$pair)) stop("pair mismatch")

        v1<-c()
        v2<-c()
        
        for(t in taxa){
            points(ca1[,t],ca2[,t],pch=16,col=col[i],cex=0.3)
            v1<-c(v1,ca1[,t])
            v2<-c(v2,ca2[,t])
        }
        p<-wilcox.test(v1,v2,alternative=alternative)$p.value
        pc<-c(pc,signif(p,2))
    }

    abline(0,1,lty=2,col="darkred")

   title<-paste0("\n\nSignficance of shift (",test,"):\n",paste(paste0(groups," p ="),pc,collapse="; "))
    
    title(title,outer=T)
    
    frame()
    legend("left", legend=groups,lty=0,fill=col,cex=0.9)
    
}

div.pairwise<-function(m,tA,tB,index="shannon"){
    library(gdata)

    dfc<-matrix2dfcompact(m)
    
    subjects<-unique(m$subjects)

    counts<-data.frame(Subject="del2",A=0,B=0,Group="del2",BdiffA=0)

    taxa<-rownames(m$matrix)

    groups<-unique(dfc$groups)

                                        # iterate over each group
    for(g in groups){
                                        # iterate over each sample
        for(s in subjects){
            cA<-dfc[dfc$subjects==s & dfc$times==tA & dfc$groups==g,taxa]
            cB<-dfc[dfc$subjects==s & dfc$times==tB & dfc$groups==g,taxa]

            mi<-min(dim(cA)[1],dim(cB)[1])
            ma<-max(dim(cA)[1],dim(cB)[1])

            if(mi < 1){
                next()
            }

            if(ma > 1){
                stop(paste("ERROR: div.pairwise, max > 1 (",ma,")"))
                return();
            }
            
            tmp<-as.matrix(rbind(cA,cB))
            div<-getDiv(tmp,index=index)
            
            divA<-as.numeric(div[1]) 
            divB<-as.numeric(div[2]) 
            divBA<-divB - divA
            counts<-rbind(counts,data.frame(Subject=s,A=divA,B=divB,Group=g,BdiffA=divBA))
        }
    }
    counts<-counts[-1,]


    counts<-drop.levels(counts)

    return(counts)
}


alltax.pairwise.test<-function(m,tA,tB,test="wilcox",tC=NA,tD=NA){

    taxa<-rownames(m$matrix)
    tN<-length(taxa)

    res<-c()

    if(is.na(tC)){
        res<-data.frame(Taxa="del3",P=-1,Group="del3",MeanA=1,MeanB=1)
    }
    else{
        res<-data.frame(Taxa="del3",P=-1,Pbc=-1,Group="del3",MeanA=1,MeanB=1)
    }

    for(i in 1:tN){
        t<-taxa[i]
        counts<-tax.pairwise(m,t,tA,tB)
        p.groups<-test.pairwise(counts,test,allgroups=F)


        countsBC<-c()
        p.groups.BC<-c()

        if(!is.na(tC)){
            countsBC<-tax.pairwise(m,t,tC,tD)
            p.groups.BC<-test.pairwise(countsBC,test,allgroups=F)
        }

        for(j in 1:dim(p.groups)[1]){
            ps<-p.groups[j,]
            g<-as.character(ps$Group)
            p<-ps$p

            meanA<-mean(counts[counts$Group==g,"A"])
            meanB<-mean(counts[counts$Group==g,"B"])


            if(is.na(tC)){
                res<-rbind(res,data.frame(Taxa=t,P=p,Group=g,MeanA=meanA,MeanB=meanB))
            }
            else{
                ps<-p.groups.BC[j,]
                gBC<-ps$Group
                pBC<-ps$p

                if(! g==gBC){
                    stop(paste("ERROR: group mismatch",g,gBC))
                    return(0)
                }

                res<-rbind(res,data.frame(Taxa=t,P=p,Pbc=pBC,Group=g,MeanA=meanA,MeanB=meanB))
            }
        }

    }

    res<-res[-1,]

    res$BONF<-3
    res$FDR<-3
    for(g in unique(res$Group)){
        p<-res[res$Group==g,]$P
        p.adj<-p.adjust(p)
        res[res$Group==g,]$BONF<-p.adj
        p.adj<-p.adjust(p,method="fdr")
        res[res$Group==g,]$FDR<-p.adj
    }

                                        # make sure that MeanA and MeanB are lest columns of res
    tmp<-res$MeanA
    res$MeanA<-NULL
    res$MeanA<-tmp
    tmp<-res$MeanB
    res$MeanB<-NULL
    res$MeanB<-tmp

    drop.levels(res)
    return(res)
}

tax.pairwise.diff<-function(m,tA,tB){

    taxa<-rownames(m$matrix)
    tN<-length(taxa)

    dfc<-matrix2dfcompact(m)

    subjects<-unique(m$subjects)
    sN<-length(subjects)

                                        # init new matrix
    counts<-matrix(nrow = tN, ncol = sN)

                                        # iterate over all taxa
    for(i in 1:tN){

        tax<-taxa[i]

                                        # itearte over subjects
        for(j in 1:sN){
            s<-subjects[j]

            cA<-dfc[dfc$subjects==s & dfc$times==tA,tax]
            cB<-dfc[dfc$subjects==s & dfc$times==tB,tax]


                                        # check
            ma<-max(length(cA),length(cB))      
            if(ma > 1){
                stop("ERROR: tax.pairwise.diff, ma > 1")
            }

            d<-0

            if(length(cA) == 1){
                if(length(cB) == 1){
                    d<-cB-cA
                }
            }

            counts[i,j]<-d
        }
    }
    colnames(counts)<-subjects
    rownames(counts)<-taxa

    return(as.data.frame(counts))
}


tax.pairwise<-function(m,tax,tA,tB){
    tax<-make.names(tax)
    library(gdata)

    dfc<-matrix2dfcompact(m)

    subjects<-unique(m$subjects)
    sN<-length(subjects)

    counts<-data.frame(Subject="del4",A=0,B=0,Group="del4",BdiffA=0)
    groups<-unique(m$groups)

    for(g in groups){
        for(s in subjects){
            cA<-dfc[dfc$subjects==s & dfc$times==tA & dfc$groups==g,tax]
            cB<-dfc[dfc$subjects==s & dfc$times==tB & dfc$groups==g,tax]


            if(length(c(cA,cB)) < 2){
                next;
            }
            
            ma<-max(length(cA),length(cB))

            if(ma > 1){
                stop("ERROR: tax.pairwise, ma > 1")
            }
            diff<-cB-cA
            counts<-rbind(counts,data.frame(Subject=s,A=cA,B=cB,Group=g,BdiffA=diff))
        }
    }
    counts<-counts[-1,]
    counts<-drop.levels(counts)
    return(counts)
}


matrix2dfc.pair<-function(m,tA,tB,tC){
    library(gdata)

    dfc<-matrix2dfcompact(m)

    taxa<-rownames(m$matrix)

    subjects<-unique(m$subjects)
    sN<-length(subjects)

    counts<-data.frame(Subject="del4",Group="del4",Taxa="del",ID=-1,A=0,B=0,C=0)
    groups<-unique(m$groups)

    id<-0
    for(g in groups){
        for(t in taxa){
            for(s in subjects){
                cA<-dfc[dfc$subjects==s & dfc$times==tA & dfc$groups==g,t]
                cB<-dfc[dfc$subjects==s & dfc$times==tB & dfc$groups==g,t]
                cC<-dfc[dfc$subjects==s & dfc$times==tC & dfc$groups==g,t]

                if(length(cC) == 0){
                    cC<-NA
                }

                if(length(cB) == 0){
                    cB<-NA
                }

                if(length(cA) == 0){
                    cA<-NA
                }

                id<-id+1
                counts<-rbind(counts,data.frame(Subject=s,Group=g,Taxa=t,ID=id,A=cA,B=cB,C=cC))

            }}}
    counts<-counts[-1,]
    counts<-drop.levels(counts)
    return(counts)
}


dist.pairwise<-function(m,tA,tB,tC,tD){

    dfc<-matrix2dfcompact(m)

    taxa<-rownames(m$matrix)

    subjects<-unique(m$subjects)
    sN<-length(subjects)

    counts<-data.frame(Subject="del4",Group="del4",A=0,B=0)
    groups<-unique(m$groups)

    for(g in groups){
        for(s in subjects){
            cA<-dfc[dfc$subjects==s & dfc$times==tA & dfc$groups==g,taxa]
            cB<-dfc[dfc$subjects==s & dfc$times==tB & dfc$groups==g,taxa]
            cC<-dfc[dfc$subjects==s & dfc$times==tC & dfc$groups==g,taxa]
            cD<-dfc[dfc$subjects==s & dfc$times==tD & dfc$groups==g,taxa]

            mi<-min(dim(cA)[1],dim(cB)[1],dim(cC)[1],dim(cD)[1])

            if(mi > 0){

                d.cA.cB<-vegdist(rbind(cA,cB))[1]
                d.cC.cD<-vegdist(rbind(cC,cD))[1]

                if(is.na(d.cC.cD)){
                    return(list(g=g,s=s,cA=cA,cB=cB,cC=cC,cD=cD))
                }

                counts<-rbind(counts,data.frame(Subject=s,Group=g,A=d.cA.cB,B=d.cC.cD))
            }
            else{
                print(paste("Warning: excluding subject",s))
            }
        }}
    counts<-counts[-1,]
    counts<-drop.levels(counts)
    return(counts)
}


plot.pairwise<-function(counts,tA,tB,tC,tD,color="default",title="",labels=T,type="default", legend = F){

    ra<-range(counts$A,counts$B,na.rm=T)

    layout(matrix(c(1,2), 1, 2, byrow = TRUE),widths=c(1.8,1) )

    xlab<-tA
    ylab<-tB

    if(type=="dist"){
        xlab<-paste("Distance",tA,"vs",tB)
        ylab<-paste("Distance",tC,"vs",tD)
    }

    plot(ra,ra,type="n",xlab=xlab,ylab=ylab,main=title)

    abline(0,1,col="darkgrey")
    grid()

    groups<-unique(counts$Group)
    gN<-length(groups)
    colors<-getColors(color,gN)

    symbols<-getSymbols(gN)
    
    for(i in 1:gN){
        g<-groups[i]
        col<-colors[i]
        sy<-symbols[i]
        c<-counts[counts$Group==g,]
        points(c$A,c$B,col=col,pch=sy)

        if(labels){
            text(c$A,c$B,labels=c$Subject,col=col,cex=0.7,pos=3)
        }
    }
    if(legend)  {
        frame()
        legend("right", legend=groups,lty=0,fill=colors,cex=0.9)
    }

}

boxplot.pairwise<-function(counts,color="default",title="",labels=T,ylab=""){

    groups<-unique(counts$Group)
    gN<-length(groups)
    colors<-getColors(color,gN)

    boxplot(BdiffA ~ Group,counts,main=title,col=colors,ylab=ylab)
    return(1)
}

getContCol<-function(x,white=T){
    ramp<-1

    if(white) ramp <- colorRamp(c("white", "darkblue"))
                                        #else ramp <- colorRamp(c("red", "darkblue"))
                                        #  else ramp <- colorRamp(c("yellow","blue"))
    else ramp <- colorRamp(c("grey95","black"))

                                        #        ramp <- colorRamp(c("cadetblue1","burlywood1"))
                                        #else ramp <- colorRamp(c("red","green"))
                                        #  else ramp <- colorRamp(c("red","blue"))
                                        #  else ramp <- colorRamp(c("red","blue"))
    
    ra<-range(x,na.rm=T)

    if(ra[1] == ra[2]) return(rep("lightblue",length(x)))
    
                                        # scale to range 0-1
    mi<-min(x,na.rm=T)  
    
    x<-x - mi
    x<-x/max(x,na.rm=T)
    
    x.col<-rep("grey",length(x))

    select<- ! is.na(x)
                                        # get color
    x.col[select]<-rgb(ramp(x[select]),max=255)

    return(x.col)
}

doDendro<-function(cal,title="",ylim=NULL,method="jaccard",scale=F,color="default",legend=T,
                   type="dendro")
{
    require("squash")
    require(vegan)


    taxa<-c.taxa(cal)


                                        #	data<-data[order(rownames(data)),order(colnames(data))]

    ca<-c.annotatedCounts(cal)
    groups<-c.groups(cal)
    colors<-c.colors(cal)
    times<-c.times(cal)
    pairs<-c.pairs(cal)
    labels<-c.labels(cal)

    if(any(ca$group != groups)) stop("data order ERROR")
    
    d<-1

    if(method=="distFile") d<-as.dist(c.distanceMatrix(cal),
                                                    diag=T,upper=T)
    else{
        taxa<-c.taxa(cal)
        data<-ca[,taxa]
        if(scale) data<-scale(data)
        
        d<-distWrapper(as.matrix(data),diag=T,upper=T,method=method)
    }


    hc <- hclust(d,"ave")

    groups.col<-colorByGroup(groups,color,F)
    times.col<-colorByGroup(times,color,F)
    pairs.col<-colorByGroup(pairs,color,F)

    an<-1

    if(type == "dendro"){
        an<-data.frame(Group=groups.col,SecondaryGroup=times.col,Pair=pairs.col)
        rownames(an)<-labels

        if(length(unique(pairs.col)) == length(pairs.col)) an$Pair<-NULL
    } 	  
    else{
        envs<-c.environment.vars(cal)

        an<-data.frame(del=1:dim(ca)[1])

                                        # set colors for enviromental variables
        for(e in envs){
            ev<-ca[,e]
            ev.col<-1
            if(is.numeric(ev)) ev.col<-getContCol(ev)
            else ev.col<-colorByGroup(ev,"blue1")

            an[,e]<-ev.col
            
        }
        an$del<-NULL
    }

    for(n in names(an)){
  	if(length(unique(an[,n]))==1) an[,n]<-NULL
    }

    par<-par(mar = c(10,10,3,3))
    if(is.null(ylim)){
        dendromat(hc,an,main=title,cex.lab=0.8,labRow=hc$labels,ylab="Distance")

        if(legend){
            legend("topright",bty="n",legend=c("Groups",unique(groups),"","Secondary Group",unique(times)),text.col=as.character(c("black",unique(groups.col),
                                                                                                               "white","black",unique(times.col))),border="white",horiz=F)
        }

    }
    else{
        dendromat(hc,colors,main=title,cex.lab=0.5,ylim=ylim)
    }
    par(par)

    return(1)
}



doPCOA<-function(cal,method="jaccard",title="",scale=F,labels=T,legend=T,colorlegend=F,color="bluered",groupSymbols=T,colorBy="group",components=c(1,2),symbolBy=NULL){
    

    require(vegan)

    symbolLegend <-T
    
    if(is.null(symbolBy)) symbolBy<-colorBy

    if(symbolBy == colorBy){ 
        symbolBy <- NULL 
        symbolLegend <-F 
    }

    cal<-c.setGroups(cal,groupBy=colorBy,color=color,groupNumeric=F,symbolBy=symbolBy)
    data<-c.annotatedCounts(cal)
#    row.order<-order(rownames(data))
 #   col.order<-order(colnames(data))
 #   data<-data[row.order,col.order]

    taxa<-c.taxa(cal)
    
    counts<-data[,taxa]

    if(scale){
        counts<-scale(counts)
    }

    dist<-1
    if(method=="distFile"){
        dist<-as.matrix(c.distanceMatrix(cal))   
  #      dist<-dist[row.order,col.order]
        if(any(names(dist) != data$label)) stop("ERROR name mismatch")
    }   else dist<-as.matrix((distWrapper(as.matrix(counts),diag=T,upper=T,method=method)))

                                        # check if matrix
    for(i in 1:dim(dist)[1]){
        if(dist[i,i] != 0){
            print("ERROR: diagonal value != 0")
            return(0)
        }
    }
    
    
    k<-min(7,dim(dist)[1] - 1,na.rm=T)
    pcoa<-cmdscale(dist,k=k)

                                        #op<-par(fig=c(0,0.8,0,1))
                                        #op<-par(fig=c(0,0.6,0.15,0.8))

    colval<-data$group
    symbols<-16

    if(is.numeric(colval)) {
        colors<-getContCol(colval,F)
        colorlegend<-T
        data$color<-colors

        if(is.null(symbolBy)){
            groupSymbols<-F
            symbolLegend<-F
        }

    }else{ 
        if(! is.null(symbolBy)){ 
            symbolLegend<-T  
        }
    }
    title<-paste("PCoA",title)

    if(legend){
        layout(matrix(c(1,2), 1, 2, byrow = TRUE),widths=c(1.8,1) )
    }
    if(groupSymbols){  
        symbols<-data$symbol 
    }  
    plot(pcoa[,components],col=data$color,main=title,xlab=paste0("P",components[1]),ylab=paste0("P",components[2]),pch=symbols)
    abline(h=0,col="grey")
    abline(v=0,col="grey")

    if(labels){
        text(pcoa[,components],labels=rownames(pcoa),col=data$color,cex=0.7,pos=3)
    }


    leg <- data    

    if(colorlegend){

        legend<-F
        require(shape)
        mi<-min(as.integer(colval))
        ma<-max(as.integer(colval))
        frame()

                                        
        if(symbolLegend){  
            leg2 <- data
          leg2<-leg2[order(leg2$symbolLabel),]

            legend("center", title="Symbol", legend=as.character(unique(leg2$symbolLabel)), lty = 0,col=as.character(c("black")),pch=unique(leg2$symbol),cex=0.9)
        }
                                        
        require(shape)
        colorlegend(col=sort(data$color,decreasing=T),title(colorBy), zlim=c(mi,ma),zval=c(mi,ma),left=F,posx=c(0,0.05))
        
    }

                                        # generate legend
    if(legend){
        leg<-leg[order(leg$legendLabel),]

        frame()

                                        
        if(symbolLegend){    
            legend("topleft", title="Color", title.col="black",legend=as.character(unique(leg$legendLabel)), lty = 0,text.col=as.character(unique(leg$color)),cex=0.9)

            leg2 <- data
            leg2<-leg2[order(leg2$symbolLabel),]

            legend("bottomleft", title="Symbol", legend=as.character(unique(leg2$symbolLabel)), lty = 0,col=as.character(c("black")),pch=unique(leg2$symbol),cex=0.9)
        }else{
                                        
            legend("left",  legend=as.character(unique(leg$legendLabel)), lty = 0,col=as.character(unique(leg$color)),pch=unique(leg$symbol),cex=0.9)
        }  

    }
    return(1)
}


taxa.anova<-function(d,out,hist,pCF=1,title=""){
    groups<-unique(d$Group)
    groupN<-length(groups)


    taxa<-unique(d$Taxa)
    taxaN<-length(taxa)

    res<-data.frame(t="",p=1,p.adj=1)

    for(t in taxa){

        p<-1

        if(sum(d[d$Taxa == t,]$Count) > 0){
            a<-aov(Count ~ Group,d[d$Taxa==t,])
            p<-as.numeric(unlist(summary(a))[9])
        }
        res<-rbind(res,data.frame(t=t,p=p,p.adj=1))
    }

    res<-res[-1,]

    if(test != "ANCOM") pHist(res$p,hist,title)

    res$p.adj<-p.adjust(res$p,method="bonferroni")
    res$fdr<-p.adjust(res$p,method="fdr")

                                        # print to file
    sink(out)
    cat(paste("Taxa,P,P.adj,FDR"))
    for(g in groups){
        cat(paste(",",g,sep=""))
    }
    cat("\n")
    for(t in res$t){
        p<-res[res$t == t,]$p[1]

        if(is.na(p)){
            p <- 2
        }

        if(p <= pCF){
            p.adj<-res[res$t == t,]$p.adj[1]
            fdr<-res[res$t == t,]$fdr[1]
            cat(paste(t,signif(p,2),signif(p.adj,2),signif(fdr,2),sep=","))

                                        # get median for each group
            for(g in groups){
                med<-median(d[d$Group == g &
                                  d$Taxa == t,]$Count)
                cat(paste(",",med,sep=""))
            }
            cat("\n")
        }
    }
    sink()
    return(res)
}

taxa.rankTest.sample<-function(d,out,hFile,pCF=1,title=""){
    p<-taxa.rankTest.single(d)

    pSA <-c()

    for(i in 1:100){
        d.s<-d
        d.s$Group<-sample(d$Group)
        pS<-taxa.rankTest.single(d.s)
        pSA<-c(pSA,pS)
    }
    print("creating file for")
    print(hFile)
    png(hFile)
    qqplot(p,pSA,main=title)
    abline(0,1)
    dev.off()
    return(pSA)
}

taxa.rankTest.single<-function(d){
    groups<-unique(d$Group)
    groupN<-length(groups)

    taxa<-unique(d$Taxa)
    taxaN<-length(taxa)

    pA<-c()

    for(t in taxa){
        p<-1

                                        # wilcox test
        if(sum(d[d$Taxa == t,]$Count) > 0){
            if(groupN <= 2){
                k<-wilcox.test(Count ~ Group,d[d$Taxa == t,])
            }
            else{
                k<-kruskal.test(Count ~ Group,d[d$Taxa == t,])
            }

            p<-signif(k$p.value,2)
        }

        pA<-c(pA,p)

    }
    return(pA)
}

dfByGroup<-function(df,g){
    return(df[which(df$Group == g),])
}


symbolByGroup<-function(grp){
    groups<-unique(grp)
    gN<-length(groups)

    sym<-getSymbols(gN)
    
    sym.ord<-c()

    df<-data.frame(Group=groups)

    df$Symbol<-sym[1]

    for(i in 1:gN){
        s<-sym[i]
        g<-groups[i]
        select<-which(df$Group == g)
        if(is.na(g)) select<-which(is.na(df$Group))
        df[select,]$Symbol<-s
    }

    symbols<-c()
    for(g in grp){
        select<-which(df$Group == g)
        if(is.na(g)) select<-which(is.na(df$Group))
        s<-df[select,]$Symbol[1]
        symbols<-c(symbols,s)
    }
    return(symbols)
}




colorByGroup<-function(grp,color="default",sample="F"){
    groups<-(unique(grp))
    gN<-length(groups)

    col<-getColors(color,gN,sample=sample)

    col.ord<-c()

    df<-data.frame(Group=groups)

    df$Color<-"white"

    for(i in 1:gN){
        c<-col[i]
        g<-groups[i]
        select<-which(df$Group == g)
        if(is.na(g)) select<-which(is.na(df$Group))
        df[select,]$Color<-c
    }

    colors<-c()
    for(g in grp){
        select<-which(df$Group == g)
        if(is.na(g)) select<-which(is.na(df$Group))
        c<-df[select,]$Color[1]
        colors<-c(colors,c)
    }
    return(colors)
}

                                        # get groups for list of samples
getGroups<-function(samples,df){
    d<-data.frame(Sample=samples)
    d$Group<-"del5"

    for(s in samples){
        g<-as.character(df[df$Sample == s,]$Group[1])
        d[d$Sample == s,]$Group<-g
    }
    return(d)
}

getAnnot<-function(file,color="default",sample=F){
    annot<-read.csv(file)

    groups<-annot$Group
    colors<-colorByGroup(groups,color=color,sample=sample)
    annot$Color<-colors
    return(annot)
}

dfToMatrix<-function(d,color="default",sample=F){
    t<-table(d[,c("Sample","Taxa")])
    m<-max(t)
    if(m != 1){
        stop("ERROR: max != 1 in dfToMatrix!!!!")
        return();
    }

    taxa<-unique(d$Taxa)
    tN<-length(taxa)
    samples<-unique(d$Sample)
    sN<-length(samples)

    m<-matrix(nrow=tN,ncol=sN)

    colnames(m)<-samples

    rownames(m)<-taxa

    print("iteratate over taxa")
                                        # iterate over taxa
    for(i in 1:tN){
        t<-as.character(taxa[i])

                                        # iterate over samples
        for(j in 1:sN){
            s<-samples[j]
            cs<-subset(d,Taxa == t & Sample == s)$Count

                                        #	      	    cs<-d[d$Taxa == t & d$Sample == s,]$Count
            c<-0
            if(length(cs) > 0){
                c<-cs[1]
            }
            m[i,j]<-c
        }
    }
    print("iteratate over taxa done")

    groups<-c()

    samples<-colnames(m)
    for(s in samples){
        g<-as.character(d[d$Sample == s,]$Group[1])
        groups<-c(groups,g)
    }

    colors<-colorByGroup(groups,color=color,sample=sample)

    l<-list(matrix=m,samples=samples,groups=groups,col=colors)
    return(l)
}

anovaFormula<-function(y,x,type,data){

    select<-c()
    for(f in x){
        d<-data[,f]
        un<-unique(d)
        if(length(un) < 2) select<-c(select,F)
        else select<-c(select,T)
    }
    x<-x[select]
    if(length(x)<1) stop("ERROR: need at least one factor with more than one group")

    f<-1
    xN<-length(x)
    if(xN==1) f<-as.formula(paste(y,"~",x))
    else if(xN == 0) return(0)
    else if(type=="anova+") f<-as.formula(paste(y,"~", paste(x, collapse= "*")))
    else if(type=="anova+Add") f<-as.formula(paste(y,"~", paste(x, collapse= "+")))
    else if(type=="anova+TwoWayInt") f<-twoWayInteractions(y,x)
    else stop("Unknown type",type)

    return(f)
}

twoWayInteractions<-function(y,x){
    f<-paste(y,"~")

    xN<-length(x)	

    if(xN == 1) f<-paste(f,"+",x)
    else if(xN == 2) f<-paste(f,paste(x, collapse= "*"))
    else{
        terms<-x
        for(i in 1:(xN-1)){
            xI<-x[i]
            for(j in (i+1):xN){
                xJ<-x[j]   
                term<-
                    terms<-c(terms,paste(xI,xJ,sep=":")) 		  

            }
        }
    }
    f<-paste(f,paste(terms,collapse="+"))
    f<-as.formula(f)
    return(f)
}

taxa.test.matrix<-function(cal,out=null,hist=null,title="",test="rank"){

    c.clearError(cal)
    
    if(test %in% c("anova+","anova+Add","anova+TwoWayInt")){
        cal<-c.num2cat(cal)
        ret<-NA
        ca<-c.annotatedCounts(cal)
        taxa<-c.taxa(cal)
        envs<-c.environment.vars(cal,nominal=T)	

        t<-taxa[1]
        
        fmla <- anovaFormula(t,envs,test,ca)

        a<-anova(aov(fmla,ca))
        
        eni<-rownames(a)
        eni<-eni[-1*length(eni)]

        pm<-data.frame(matrix(nrow=0,ncol=2*length(eni)+1))
        na<-c("Taxa")
        for(e in eni){
            na<-c(na,e,"FDR")
        }

        names(pm)<-na	

        for(t in taxa){

            fmla <- anovaFormula(t,envs,test,ca)

            a<-anova(aov(fmla,ca))
            p<-a$"Pr(>F)"
            p<-p[-1*length(p)]
            en<-rownames(a)
            en<-en[-1*length(en)]

            ndf<-data.frame(matrix(nrow=1,ncol=2*length(en) + 1))
            na<-c("Taxa")
            va<-c(t)
            for(i in 1:length(en)){
                na<-c(na,en[i],"FDR")
                va<-c(va,p[i],-1)
            }
            names(ndf)<-na		
            ndf[1,]<-va


            pm<-rbind(pm,ndf)
        }

                                        # get FDR	
        for(i in 1:length(eni)){
            e<-eni[i]
            v<-pm[,e]
            fdr<-p.adjust(v,method="fdr")
            pm[,(2*i+1)]<-fdr

        }


        print("writing results...")
        print(out)
        write.csv(pm,file=out,quote=F,row.names=F)

        return(pm)
    }

    

    m<-1
    matrix<-1
    groups<-1
    location<-1
    gN<-1
    nT<-1
    ca<-1
    

    if(test=="nestedanova"){
        warning("Using Group as group variable and Location as nested variable")
        cal<-c.setGroups(cal,groupBy="group")
    }
    
    if(! (test=="chi")){
        
        m<-calypso2matrix(cal)
        
        matrix<-m$matrix
        taxa<-rownames(m$matrix)
        groups<-m$groups

        nested<-m$time
        gN<-length(unique(groups))
        
        nT<-length(taxa)

        if(gN < 2){
            stop("ERROR: less than 2 groups")
            stop(1)
        }    
    }
    
    res<-data.frame(t="Remove",p=1,p.adj=1)
    
    
    if(test=="anova" | test=="nestedanova"){

        for(i in 1:nT){
            dat<-matrix[i,]

            tax<-taxa[i]


            p<-1
            a<-1

                                        # anova
            if(sum(dat) > 0){
                if(test=="nestedanova"){
                    dat.df<-data.frame(Count=dat,Group=groups,Nested=nested)
                    a<-(aov(Count ~ as.factor(Group)/as.factor(Nested),dat.df))
                    a<-anova(a)
                    p<-signif(as.numeric(a$"Pr(>F)"[1]),2)
                }
                else{
                    dat.df<-data.frame(Count=dat,Group=groups)
                    a<-aov(Count ~ Group,dat.df)
                    p<-signif(as.numeric(unlist(summary(a))[9]),2)
                }
            }
            res<-rbind(res,data.frame(t=tax,p=p,p.adj=1))
        }
    }
    else if(test == "aldex"){
        library(ALDEx2)

        ca<-c.annotatedCounts(cal)
        taxa<-c.taxa(cal)

        group<-ca$group

        counts<-data.frame(t(ca[,taxa]))

        if(any(counts != round(counts))){
            errorm<-"ERROR: ALDEx2 only applicable for raw count data."
            c.writeError(cal,errorm)
            stop(errorm)
            
        }
              

        
        x <- aldex.clr(counts, mc.samples=16, verbose=TRUE)

        n<-length(unique(group))

        print("n:")
        print(n)
        
        if(n>2) res <- aldex.glm(x, group)
        else res <- aldex.ttest(x, group, paired.test=F)

        taxa<-rownames(res)
        tmp<-names(res)
        res$Taxa<-taxa
        res<-res[,c("Taxa",tmp)]
        
        for(g in unique(groups)){
            me<-c()
            for(t in res$Taxa){
                me<-c(me,median(ca[ca$group==g,t]))
            }
            res[,paste(g,".median",sep="")]<-me
        }

        write.csv(res,file=out,quote=F,row.names=F)
        
        return(res)
    }

    
    else if(test =="ANCOM"){
        library(ancom.R)

        
        ca<-c.annotatedCounts(cal)
        taxa<-c.taxa(cal)

        ancom<-ANCOM( real.data = ca[,c(taxa,"group")], sig = 0.05,
                     multcorr = 2 )

        detected<-ancom$detected

        print(detected)
        
        if(length(detected) == 0 | detected[1]=="No significant OTUs detected"){
            res<-data.frame(matrix(nrow=0,ncol=2))
            names(res)<-c("t","p")
        }
        else res<-data.frame(t=detected,p=rep(NA,length(detected)))        
    }
    
    else if(test=="DESeq2"){
        library(DESeq2)

        ca<-c.annotatedCounts(cal)

           groups<-as.factor(ca$group)
           if(length(unique(groups)) != 2){
               errorm<-"ERROR: DESeq2 only applicable for datasets with exactly two groups"
               c.writeError(cal,errorm)
               stop(errorm)
           }

           taxa<-c.taxa(cal)
           matrix<-t(ca[,taxa])
           print(dim(matrix))

           if(length(which(as.integer(matrix) != matrix)) > 0){
               errorm<-"ERROR: DESeq2 only applicable for raw count data."
               c.writeError(cal,errorm)
               stop(errorm)
           }


           matrix<-round(matrix)

           print(head(matrix))
           
           matrix<-as.data.frame(matrix)

           colData<-data.frame(condition=as.factor(groups))

        dds <- DESeqDataSetFromMatrix(matrix, colData, formula(~ condition))
           ddsLRT <- DESeq(dds, test="Wald", fitType="parametric")
           p<-results(ddsLRT,cooksCutoff=F)$pvalue
           res<-data.frame(t=taxa,p=p)

           print(head(res))

       }
    else if(test=="bayes"){
        ca<-c.annotatedCounts(cal)
        
	order<-order(ca$group)
	ca<-ca[order,]

	groups<-ca$group
	gn<-length(unique(ca$group))
       	taxa<-c.taxa(cal)

	.get.ws<-function(matrix){
            ws<-101
            if(dim(matrix)[1] < 101) ws<-dim(matrix)[1] - 10
            if(ws <= 3) ws<-dim(matrix)[1] - 1
            if(ws %% 2 == 0) ws<- ws - 1
            return(ws)
	}

        if(gn > 2){	
            .he<-function(g) return(sum(groups==g))
            numVec<-unlist(lapply(unique(groups),.he))

            matrix<-t(ca[,taxa])

            ws<-.get.ws(matrix)

            ba<-bayesAnova(matrix,numVec=numVec,winSize=ws)    
            p<-as.data.frame(ba)$pVal
            res<-data.frame(t=rownames(ba),p=p)
        }
        else if(gn==2){
            ga<-unique(groups)[1]
            gb<-unique(groups)[2]
            gan<-sum(groups==ga)
            gbn<-sum(groups==gb)
            matrix<-ca[,taxa]
            matrix<-t(matrix)


            ws<-.get.ws(matrix)

            bt<-bayesT(matrix,numC=gan,numE=gbn,winSize=ws)
            p<-as.data.frame(bt)$pVal
            res<-data.frame(t=rownames(bt),p=p)
        }
        else stop("ERROR: less than 2 groups")


    }
    else if(test == "randomForest"){
        library(randomForest)
        ca<-c.annotatedCounts(cal)
        names(ca)<-make.names(names(ca))
        taxa<-make.names(c.taxa(cal))
        ca<-ca[,c("group",taxa)]

        if(!is.numeric(ca$group)) ca$group<-as.factor(ca$group)

        rf<-NA
        tmp<-try(rf<-randomForest(group~.,data=ca,importance=T,proximity=F,ntree=10000,mtry=20))

        if(! is.list(rf)){
       	    warning("ERROR running randomForest")
	    sink(stderr())
	    sink()
	    stop(tmp)	    
        }

        im<-as.data.frame(importance(rf))
        

        da<-im$MeanDecreaseAccuracy

        res<-data.frame(t=rownames(im),p=da)
        res$p.adj<-1

        png(hist,width=240,res=300,height=100,units="mm")
        plot(sort(da),pch=16,col="black",ylab="Mean Drecrease Accuracy")
        dev.off()
    }
    else if(test=="chi"){
        ca<-c.annotatedCounts(cal)
        taxa<-c.taxa(cal)
        groups<-ca$group    
        nT<-length(taxa)
        
        groups.unique<-unique(groups)

        gN<-length(groups.unique)
        
        for(tax in taxa){
            m<-matrix(nrow=2,ncol=gN)
            
            p<-1
            
            if(sum(ca[,tax]) > 0){ 
                for(i in 1:gN){
                    g<-groups.unique[i]
                    tot<-sum(ca[ca$group == g,]$total)
                    val<-sum(ca[ca$group == g,tax])
                    m[,i]<-c(val,tot)
                }        
                p<-chisq.test(m)$p.value
            }
            
            res<-rbind(res,data.frame(t=tax,p=p,p.adj=1))
        }
    }
    else if(gN == 2){
        groups.unique<-unique(groups)
        first.sel<-which(groups == groups.unique[1])
        second.sel<-which(groups == groups.unique[2])

        for(i in 1:nT){
            dat<-matrix[i,]
            tax<-taxa[i]


            p<-1
            k<-1

                                        # wilcox test
            if(sum(dat) > 0){
                k<-wilcox.test(dat[first.sel],dat[second.sel])
                p<-signif(k$p.value,2)
            }

            res<-rbind(res,data.frame(t=tax,p=p,p.adj=1))
        }
    }
    else{
        for(i in 1:nT){
            dat<-matrix[i,]
            tax<-taxa[i]

            p<-1
            k<-1

                                        # kruskal wallis test
            if(sum(dat) > 0){
                k<-kruskal.test(dat,as.factor(groups))
                p<-signif(k$p.value,2)
            }

            res<-rbind(res,data.frame(t=tax,p=p,p.adj=1))
        }
    }
    res<-res[-1,]
    
    if(! test %in% c("randomForest","ANCOM","aldex")) pHist(res$p,hist,title)

    
    res$p.adj<-signif(p.adjust(res$p,method="bonferroni"),2)
    res$fdr<-signif(p.adjust(res$p,method="fdr"),2)
    res$bh<-signif(p.adjust(res$p,method="hochberg"),2)

    zz<-file(out,"w")

    cat(paste("Taxa,P,P.adj,FDR,BH"),file=zz)

    
    groups<-unique(groups)
    for(g in groups){
        cat(paste(",",paste0(g,".median"),sep=""),file=zz)
    }

    for(g in groups){
        cat(paste(",",paste0(g,".mean"),sep=""),file=zz)
    }
    cat("\n",file=zz)


    tN<-length(unique(res$t))

    if(tN > 0){
    for(i in 1:tN){
        tax<-as.character(res$t[i])
        p<-res[res$t == tax,]$p[1]

       
       
            p.adj<-res[res$t == tax,]$p.adj[1]
            fdr<-res[res$t == tax,]$fdr[1]
            bh<-res[res$t == tax,]$bh[1]
            cat(paste(tax,p,p.adj,fdr,bh,sep=","),file=zz)

            dat<-1

            if(test != "chi" & test != "bayes" &
               test != "DESeq2") dat<-matrix[i,]
            
                                        # get median for each group
            for(g in groups){
                mea<-1


                if(test == "chi" | test=="bayes"
                   | test=="DESeq2") med<-median(ca[ca$group == g ,tax])
                else med<-median(dat[m$groups==g])
		mea<-mean(dat[m$groups==g])
                
                cat(paste(",",med,sep=""),file=zz)
            }
                                        # get median for each group
            for(g in groups){
                mea<-1

                if(test == "chi" | test=="bayes"
                   | test=="DESeq2") mea<-mean(ca[ca$group == g,tax])		      		      
                else mea<-mean(dat[m$groups==g])
                
                cat(paste(",",mea,sep=""),file=zz)
            }

            cat("\n",file=zz)
        
    }}
    close(zz)
    return(1)
}

taxa.rankTest<-function(d,out,hist,pCF=1,title=""){

    groups<-unique(d$Group)
    groupN<-length(groups)

    taxa<-unique(d$Taxa)
    taxaN<-length(taxa)

    res<-data.frame(t="Remove",p=1,p.adj=1)

    for(t in taxa){
        k<-NA

        p<-1

                                        # wilcox test
        if(sum(d[d$Taxa == t,]$Count) > 0){
            if(groupN <= 2){
                k<-wilcox.test(Count ~ Group,d[d$Taxa == t,])
            }
            else{
                k<-kruskal.test(Count ~ as.factor(Group),d[d$Taxa == t,])
            }
            p<-signif(k$p.value,2)
        }

        res<-rbind(res,data.frame(t=t,p=p,p.adj=1))
    }

    res<-res[-1,]

    pHist(res$p,hist,title)

    res$p.adj<-p.adjust(res$p,method="bonferroni")
    res$fdr<-p.adjust(res$p,method="fdr")

    sink(out)
    cat(paste("Taxa,P,P.adj,FDR"))

    for(g in groups){
        cat(paste(",",g,sep=""))
    }
    cat("\n")
    for(t in res$t){
        p<-res[res$t == t,]$p[1]

        if(is.na(p)){
            p<-2
        }

        if(p < pCF){
            p.adj<-res[res$t == t,]$p.adj[1]
            fdr<-res[res$t == t,]$fdr[1]
            cat(paste(t,p,p.adj,fdr,sep=","))

                                        # get median for each group
            for(g in groups){
                med<-median(d[d$Group == g &
                                  d$Taxa == t,]$Count)
                cat(paste(",",med,sep=""))
            }
            cat("\n")
        }
    }
    sink()
    return(1)
}

getDiv<-function(matrix,index="shannon"){
    if(length(which(as.integer(matrix) != matrix)) > 0){
        min<-min(matrix[matrix>0])
        fa<-10000
        matrix<-matrix * fa
        warning("WARNING: relative counts in getDiv, assuming ",fa," reads / sample!")
        matrix<-round(matrix)
    }
    
    if(index == "fa"){
	return(fisher.alpha(matrix))
    }

    if(index == "richness"){
        sum<-((apply(matrix,1,sum,na.rm=T)))
        min<-min(sum[sum>0])
        ri<-rarefy(matrix,min)
        na<-names(ri)
        ri<-as.numeric(ri)
        names(ri)<-na
                                        #		 ri<-specnumber(matrix)

        return(ri)
    }

    if(index == "evenness"){
        h<-diversity(matrix)
        s<-specnumber(matrix)
        j<-h/log(s)
        return(j)
    }

    else if(index == "chao1"){
        return(estimateR(matrix,index="chao")[2,])
    }    

    else if(index == "ace"){
        return(estimateR(matrix,index="chao")[4,])
    }

    return(diversity(matrix,index=index))
}

matrixByGroup<-function(m,group){
    sel<-m$groups == group

    matrix<-m$matrix[,sel]
    groups<-m$groups[sel]
    times<-m$times[sel]
    subjects<-m$subjects[sel]
    colors<-m$color[sel]

    return(list(matrix=matrix,groups=groups,times=times,subjects=subjects,colors=colors))
}


diversityRAR<-function(cal,index="shannon",mode="group",step,main=""){
    require(vegan)

    samples<-c.labels(cal)
    groups<-c.groups(cal)
    totals<-c.totals(cal)

    if(missing(step)) step<-max(totals)/60

    counts<-c.counts(cal)
    mat<-counts

    di<-data.frame(s="del6",i=0,d=0,g="del6")

    max.tot<-max(apply(counts,1,sum))

    if(any(round(mat) != mat)) mat<-round(mat * 1000)

    
                                        # step over different sample sizes from step to max.tot, step size step
    for(i in seq(step,max.tot,step)){

        if(index=="richness"){
            d<-rarefy(mat,i)
            tmp<-data.frame(s=names(d))
            tmp$i<-i
            d<-as.numeric(d)
            d[i>totals]<-NA
            tmp$d<-d
            tmp$g<-groups
            di<-rbind(di,tmp)
        }

        else{
            
                                        # iterate over each sample
            for(j in 1:length(samples)){
                s<-samples[j]
                g<-groups[j]

                d<-divRAR.sub(mat,i,s,index)

                                        # s: sample, i: sample size, d: diversity, g: group
                di<-rbind(di,data.frame(s=s,i=i,d=d,g=g))
            }

        }
    }

    di<-di[-1,]

    plotRAR(cal,di,mode,index,step,main=main)

    return(di)
}

plotRAR<-function(cal,di,mode="group",index,step,main=main){
    if(mode=="box"){
	groups<-unique(c.groups(cal))
	colors<-unique(c.colors(cal))

                                        #plot(range(di$i,na.rm=T),range(di$d,na.rm=T),type="n",xlab="Reads Sampled",ylab=index)

	da<-di[di$g==groups[1],]
	max<-max(di$i,na.rm=T)
	boxplot(d~i,da,col=colors[1],ylim=range(di$d,na.rm=T),xlim=c(0,max/step + 1,main=main))
	grid()
	for(j in 2:length(groups)){
            g<-groups[j]
            col<-colors[j]
            boxplot(d ~ i,di[di$g==g,],col=col,add=T)
	}
        legend("bottomright", legend=groups, cex=0.9, fill=colors);
    }

    if(mode=="indiv"){

	colors<-c.colors(cal)
	samples<-c.labels(cal)
	symbols<-c.symbols(cal)


	plot(range(di$i,na.rm=T),range(di$d,na.rm=T),type="n",xlab="Reads Sampled",ylab=index,main=main)
	grid()
	for(j in 1:length(samples)){
            s<-samples[j]
            col<-colors[j]
            pch<-symbols[j]
            points(d ~ i,di[di$s==s,],col=col,type="b",pch=pch)
        }
        legend("bottomright", legend=unique(c.groups(cal)), cex=0.9, col=unique(colors),colors,pch=unique(symbols));
    }

    if(mode == "group"){
        groups<-unique(c.groups(cal))
        colors<-unique(c.colors(cal))
        symbols<-unique(c.symbols(cal))
        is<-unique(di$i)

        d.g<-data.frame(g="del7",i=0,d=0)

                                        # iterate over all groups
        for(g in groups){
                                        # iterate over all sub samples
            for(i in is){
                di.i.g<-di[di$g==g & di$i == i & !is.na(di$d),]

                d.mean<-NA

                                        # only plot if at least 2 samples are available with this sub-sample size
                if(dim(di.i.g)[1] > 2){
                    d.mean<-mean(di.i.g$d)
                }
                d.g<-rbind(d.g,data.frame(g=g,i=i,d=d.mean))
            }
        }

                                        # setup plot
        plot(range(di$i,na.rm=T),range(di$d,na.rm=T),type="n",xlab="Reads Sampled",ylab=index,main=main)

        grid()
        for(i in 1:length(groups)){
            g<-groups[i]
            col<-colors[i]
            pch<-symbols[i]
            points(d~i,d.g[d.g$g==g,],col=col,pch=pch,type="b")
        }
        
        legend("bottomright", legend=(groups), cex=1, col=(colors),pch=(symbols));

    }

}

                                        # params: matrix, sub-sample size, sample, diversity index
divRAR.sub<-function(matrix,i,sample,index){


    sc<-matrix[sample,]

    tot<-sum(sc)

    if(tot < i){
        return(NA)
    }

    if(index=="richness"){
	d<-rarefy(sc,i)
	return(d)
    } 

    data<-rbind(sc,sc,sc,sc,sc,sc,sc)
    
                                        # take x sub-samples and rarefy them, final return mean of diversity measured for all sub-samples
    ra<-rrarefy(data,i)

    d<-getDiv(ra,index)
    return(mean(d))
}

getDiversity<-function(cal,out,outP,index="shannon",main="",width=1000,
                       height=1000,res=75,
                       plot="bar",color="default",groupBy="group",orderBy="GST",
                       figureFormat="png"){

    require(vegan)

    if(plot=="mcpHill"){
        png(out,width=width,height=height,res=res)
        c.mcpHill(cal,groupBy)
        dev.off()
        return(1)
    }
    
    method<-index
    title<-main
    ylab<-paste(index,"index")
    
    writeFig<-F

    if(figureFormat == "png"){
        writeFig<-T		  
        png(out,width=width,height=height,res=res,units="mm")
    }
    else if(figureFormat == "pdf"){
        writeFig<-T		  
        pdf(out,width=width,height=height)
    }
    else if(figureFormat == "svg"){
        writeFig<-T		  
        svg(out,width=width,height=height)
    }

    if(plot %in% c("anova+","anova+Add","anova+TwoWayInt")){
	cal<-c.num2cat(cal)
	cal<-c.setGroups(cal,groupBy=groupBy,groupNumeric=T)
        ca<-c.annotatedCounts(cal)
        groups<-ca$group
        groups<-sort(unique(groups))
        taxa<-c.taxa(cal)

        if(length(unique(groups)) < 2){
            errm<-"ERROR: less than 2 groups defined"
            frame()
            write.csv(file=outP,2,quote=F)
            text(0.5,0.5,errm,font=2,,col="red",cex=1.5)
            if (writeFig) dev.off()
            print(errm)
            return(0)
        }
                                        # get diversity
        div<-getDiv(as.matrix(ca[,taxa]),index=index)

        if(! is.null(ca$DDIV)){
            stop("ERROR: DDIV defined")
        }
        
        ca$DIVERSITY<-as.numeric(div)
        envs<-c.environment.vars(cal)

                                        # build regression formula
        f<-anovaFormula("DIVERSITY",envs,plot,ca)
        fo<-anovaFormula(index,envs,plot,ca)

        an<-anova(aov(f,ca))

                                        # remove residuals row
        an<-an[-1*dim(an)[1],]
        par<-par(mfrow=c(2,2))
        textplot(data.frame(Variable=rownames(an),P=signif(an[,5],2)),show.rownames=F)	
        par(par)
        title(paste(c("Multivariate anova model:\n",fo)))
        write.csv(file=outP,1,quote=F)

    }
    
    else if(plot %in% c("box","box+")){
        cal<-c.setGroups(cal,groupBy=groupBy,groupNumeric=T)
        ca<-c.annotatedCounts(cal)
        groups<-ca$group
        groups<-sort(unique(groups))
        taxa<-c.taxa(cal)

        if(length(unique(groups)) < 2){
            errm<-"ERROR: less than 2 groups defined"
            frame()
            write.csv(file=outP,2,quote=F)
            text(0.5,0.5,errm,font=2,,col="red",cex=1.5)
            if (writeFig) dev.off()
            print(errm)
            return(0)
        }

        v<-c()
        gr<-c()
        counts<-as.matrix(ca[,taxa])
        h<-getDiv(counts,index=index)
        

        
        for(g in groups){
            hd<-h[as.character(ca[ca$group==g,]$label)]
            hd<-as.numeric(hd)
            
            v<-c(v,hd)
            if(is.factor(ca$group)){
                gr<-c(gr,as.character.factor(ca[ca$group==g,]$group))
            }else{
                gr<-c(gr,ca[ca$group==g,]$group)
            }
        }

        if(length(v) != length(gr)){
            stop("length mismatch")
        }

        df<-data.frame(Div=v,Group=gr)

        colors<-getColors(color,length(groups))
        par<-par(fig=c(0,1,0.2,1))

                                        # do stats
        p<-2
        k<-aov(Div ~ Group,df)
        p<-anova(k)$"Pr(>F)"[1]	
        p<-signif(p,3)

        if(plot=="box+") do.stripchart(df,y="Div",groups="Group",main=paste0(title," p=",p," (anova)"),col=colors,ylab=ylab,las=1)
        else boxplot(Div~Group,df,col=colors,main=paste0(title," p=",p," (anova)"),ylab=ylab,las=2)

        write.csv(file=outP,p,quote=F)
    }
    else if(plot == "rarG"){
        diversityRAR(cal,index=index,mode="group",main=title)
    }
    else if(plot == "rarI"){
        diversityRAR(cal,index=index,mode="indiv",main=title)
    }
    else if(plot == "rarB"){
        diversityRAR(cal,index=index,mode="box",main=title)
    }

    else if(plot == "abundance"){
        counts<-t(c.counts(cal))
        par<-par(fig=c(0,1,0.2,1))
        on.exit(par(par))
        boxplot(counts,las=2,col=c.colors(cal),ylab="Number of Reads (%)",main=paste("Reads per Taxon/OTU,",main))
        grid()
    }
    else if(plot == "bar"){
        cal<-c.setGroups(cal,groupBy=groupBy)
        countsDF<-c.annotatedCounts(cal,er="G",orderBy=orderBy)
        
        taxa<-c.taxa(cal)
        
        h<-getDiv(as.matrix(countsDF[,taxa]),index=index)

        index<-which(countsDF$group=="0")
        
        if(length(index) > 0) h[index]<-0
        
        par<-par(fig=c(0,0.8,0.2,0.9))
        barplot(h,names.arg=countsDF$label,col=countsDF$color,las=2,main=title,ylab=ylab)
        labels<-unique(c.groups(cal))
        par(par)
        legend("right", legend=rev(labels), cex=0.9, fill=rev(unique(c.colors(cal))));
    }
    else{
        if (writeFig) dev.off()
        stop(paste("ERROR unknown plot type "),plot)
    }
    if (writeFig)	dev.off()
}

checkP<-function(p){
    if(is.na(p)){
        return(2)
    }
    if(p == 0){
        p<-10^-200
    }
    return(p)
}

pQQ<-function(p,file=NULL){
    if(! is.null(file)){
        png(file)
    }

    o<-sapply(p,checkP)
    oN<-length(o)
    e<-1:oN/oN
    e<-sapply(e,checkP)

    lp<-log10(o)
    le<-log10(e)

                                        #	mi<-min(lp,le)
                                        #	ma<-max(lp,le)
                                        #	qo<-quantile(lp,seq(0,1,0.1))
                                        #	qe<-quantile(le,seq(0,1,0.1))

    qqplot(lp,le,pch=16,col="darkblue",main="QQ Plot",ylab="log10(p) Expected",xlab="log10(p) Observed")#, xlim=c(mi,ma),ylim=c(mi,ma))
    grid()
    abline(0,1,lty=2,col="red")

    if(! is.null(file)){
        dev.off()
    }
}

pHist<-function(p,file=NULL,title=""){
    if(! is.null(file)){
        png(file,width=240,res=300,height=120,units="mm")
    }


    if(is.null(p)){
        textplot("NA")
        if(! is.null(file)) dev.off()
    }
    
    op<-par(mfrow=c(1,2),oma = c( 0, 0, 2, 0 ))

    phist(p)

    pQQ(p)

    title(title, outer = TRUE )

    if(! is.null(file)){
        dev.off()
    }

    par(op)
}


matrix2median<-function(m){
    matrix<-m$matrix
    taxa<-rownames(matrix)
    tN<-length(taxa)
    groups<-unique(m$groups)
    gN<-length(groups)
    labels<-groups
    samples<-groups
    symbols<-unique(m$symbols)
    colors<-unique(m$colors)

    if(! (length(symbols) == gN)){
        stop("length(symbols) != length(groups)")
        return()
    }

    if(! (length(colors) == gN)){
        stop("length(symbols) != length(groups)")
        return()
    }

    medians<-data.frame(del=character(tN))

    median.select<-function(row,sel){median(row[sel])}

    for(g in groups){
        sel<-which(m$groups==g)
        med<-apply(matrix,1,median.select,sel=sel)
        medians[,g]<-med
    }

    medians$del<-NULL

    matrix.new<-as.matrix(medians)
    rownames(matrix.new)<-taxa
    m.new<-list(matrix=matrix.new,groups=groups,colors=colors,symbols=symbols,labels=labels,samples=samples)

    return(m.new)
}


max.tot<-function(li,tot){
    return(max(li/tot) * 100)
}

df.select<-function(file,taxFilter=0,grpmode="allG",taxa=NULL,groupS="all"){
    library(gdata)

                                        #stop("Not implementing relative!!!")

    print("Running df.select")
    warning("Running df.select")
    d<-read.table(file,header=T,sep=",")

    if(! is.null(taxa)){
        print("selecting taxa")
        d<-d[d$Taxa == taxa,]
        taxFilter<-0
    }

    taxa<-unique(d$Taxa)

    t.keep<-c()

    if(taxFilter >0 & dim(d)[1] > taxFilter){
        sum<-NA
        for(t in taxa){
            sum<-c(sum,sum(d[d$Taxa == t,]$Count))
        }
        warning("Removing low abundant taxa done")
        d<-d[order(sum,decreasing=T)[1:taxFilter],]
    }
    d$Group.orig<-d$Group	

    if(grpmode == "time"){
        d$Group<-d$Time
    }
    else if(grpmode == "pair"){
        d$Group<-d$Pair
    }
    else if (grpmode == "gt"){
        d$Group<-paste(d$Group,d$Time)
    }

    if(! groupS == "all"){
        d<-d[d$Time==groupS,]
    }

    d<-drop.levels(d)

    warning("df select done")


    return(d)
}

regression<-function(cal,out,title="",width=300,height=300,res=75,color="default",taxa="all",outCoef=NA,outList=NA,gA=NA,gB=NA,rby="group",paired=T,index="shannon",dist="jaccard",timeBy=timeBy,corIndex="pearson"){

                                        # ensure taxa do not start with number
    if(taxa != "all") taxa<-make.names(taxa)

    cal<-c.safe.taxa(cal)

    
    ct<-c.annotatedCounts(cal)

    ct$rvar<-0
    
    if(! dim(ct)[1] > 1){
        stop("ERROR: no data (annotatedCounts)!!!")
    }
    

    logit<-F

    if(rby %in% c("diversity","diversityDist","distance")){
        envs<-c.environment.vars(cal)
        envsN<-length(envs)
        nrow<-(envsN *2 + 1)/ 3
        height<-height * max(nrow,1)
        
        png(out,width=width,height=height,res=res,units="mm")
    }
                                        # run gregression model for each taxa
    if(rby=="taxa"){
        mcl<-regressionTaxaAll(cal,outCoef=outCoef,taxa=taxa,outPNG=out,
                               paired=paired,res=res,width=width,height=height,tA=gA,tB=gB,
                               corIndex=corIndex)
        return(mcl)
    }
                                        # linear mixed effect model
    if(rby %in% c("taxaLMEM","taxaTS")){
        mcl<-1
        ts<-F
        if(rby=="taxaTS"){
            ts<-T
            taxa=="all"
        }
        mcl<-regressionTaxaAll.lmer(cal,outCoef=outCoef,outPNG=out,taxa=taxa,width=width,height=height,timeseries=ts,timeBy=timeBy,corIndex=corIndex)
        return(mcl)
    }
    
    else if(rby == "diversity"){
        diversity.regression(cal,index=index,paired=paired,corIndex=corIndex)
        dev.off()
        return(1)
    }
    else if(rby == "diversityDist"){
        distance.regression(cal,type="diversity",index=index,paired=paired,corIndex=corIndex)
        dev.off()
        return(1)
    }
    
    else if(rby == "distance"){
        d<-distance.regression(cal,index=dist,paired=paired,corIndex=corIndex)
        dev.off()
        return(1)
    }
    
    else if(! is.na(gA)){
        if(is.na(gB)){
            stop("ERROR: gA defined but not gB")
        }

        rby<-make.names(rby)
        
        if(! dim(ct[ct[,rby] == gA,])[1] > 1){
            stop(paste("ERROR: no data!!! group",gA))
        }
        
        if(! dim(ct[ct[,rby] == gB,])[1] > 1){
            stop(paste("ERROR: no data!!! Group"),gB)
        }
        

        ct[ct[,rby] == gA,]$rvar<-1
        ct[ct[,rby] == gB,]$rvar<-0
        ct<-ct[ct[,rby] == gA | ct[,rby] == gB,]
        logit<-T
        title<-paste("\n",gA,"=1 ",gB,"=0",sep="")
    }
    else{
        rby<-make.names(rby)
        if(rby == "reads") ct$rvar<-ct$total
        else ct$rvar<-ct[,rby]
    }
    ct<-ct[!is.na(ct$rvar),]
    
    if(! dim(ct)[1] > 1){
        stop("ERROR: no data!!! Response!!!")
    }
    
    
    if(taxa == "all"){
        li<-regression.list(ct,out,logit=logit,title=title,resolution=res,height=height,width=width,taxa=c.taxa(cal),rby=rby,corIndex=corIndex)
        
        if(! is.list(li)) return(li)

        if(! is.na(outList)){

            li$list$p<-format(li$list$p,scientific=F)
            write.csv(file=outList,li$list,quote=F,row.names=F)
        }
        
        if(! is.na(outCoef)){
            fit<-li$fit
            c<-coef(summary(fit))
            p<-signif(c[,4],2)
            
                                        #cof<-round(fit$coefficients,5)
            cof<-signif(c[,1],2)
            
            di<-length(cof) - length(p)
            
            
            p<-data.frame(P=p)
            rownames(p)<-rownames(c)
            
            cof<-data.frame(Coefficient=as.numeric(cof))
            
            rownames(cof)<-rownames(c)
            
            cof<-cbind(cof,p)

            cof<-cof[-1,]
            write.csv(file=outCoef,cof,quote=F,row.names=T)
        }
        return(li)
    }
    else{
        regression.taxa(ct,taxa,taxAll=c.taxa(cal),out,title=title,res,width,height,rby=rby,corIndex=corIndex)
    }
    
    return(1)
}


phist<-function(p,main=""){

    if(! any(! is.na(p))){
        return(1)
    }

    if(! main == "") main <- paste(main,"\n")
    
    breaks<-seq(0,1,0.05)
    
    pv<-signif(wilcox.test(p,1:1000/1000,alternative="less")$p.value,2)
                                        #pv<-round(ks.test(p,1:10000/10000)$p.value,4)
    h<-hist(p,breaks,main=paste(main,"Histogram of p-values"),freq=T,col="lightblue")
    e<-length(p)/ (length(breaks) - 1)
    abline(e,0,col="red",lty=2)
    max<-max(h$counts)
    text(0.5,e - (max / 40),"Expected",col="red")
}

make.form<-function(t,envs,paired){
    fmla<-1
    if(paired) fmla <- as.formula(paste(t,"~", paste(c(envs,"(1|pair)"), collapse= "+"))) 
    else fmla <- as.formula(paste(t,"~", paste(envs, collapse= "+")))

    return(fmla)
}


regressionTaxaAll.lmer<-function(cal,outCoef,outPNG,timeseries=F,taxa="all",res=200,height=200,width=200,timeBy="time",corIndex){
    ca<-1
    
    print("regressionTaxaAll.lmer...")

    library(lme4)

    ca<-c.annotatedCounts(cal)

    cal.taxa<-c.taxa(cal)

    if(taxa != "all") cal.taxa<-taxa
    
    envs<-1

    if(timeseries){
        envs<-c(timeBy)
        ca$time<-as.factor(ca[,timeBy])
        ca[order(ca[,timeBy]),]
    }
    else envs<-c.environment.vars(cal)

    pnam<-1
    cnam<-1

    pnam<-paste(envs,collate=".p",sep="")
    cnam<-paste(envs,collate=".c",sep="")

    
    nam<-c("Taxa",pnam,cnam)
    ncol<-length(nam)

    mc<-data.frame(matrix(nrow=length(cal.taxa),ncol=ncol))
    names(mc)<-nam

    l<-0
    for(t in cal.taxa){
        l<-l + 1


        v<-1

        fmla<-make.form(t,envs,paired=T)

        if(length(ca$pair) == length(unique(ca$pair))){
            errm<-"ERROR: no paired sample"
            warning(errm)
            png(outPNG)
            textplot(errm)
            dev.off()
            return(-1)
        }

        full<-lmer(fmla,data=ca)

        full.beta<-fixef(full)

        pv<-c()
        bv<-c()
        for(e in envs){
            fmla<-make.form(t,envs[envs != e],paired=T)
            null<-lmer(fmla,data=ca)

            p<-signif(anova(null, full)$Pr[2],2)
            pv<-c(pv,p)
            
            beta<-"-"
            if((! timeseries) & is.numeric(ca[,e])){
                beta<-as.numeric(signif(full.beta[names(full.beta) == e],2))
                if(length(beta) != 1) stop(paste("ERROR 99987",beta,paste(full.beta,collapse=" "),paste(names(beta),collapse=" "),collapse=" "))
            }
            bv<-c(bv,beta)
        }
        v<-c(t,pv,bv)

        if(length(v) != dim(mc)[2]) stop(paste("ERROR: dim mismatch",length(v),dim(mc)[2],paste(names(mc),collapse=" ")))
        
        mc[l,]<-v

    }

    print("Writing csv ...")

    write.csv(file=outCoef,mc,quote=F,row.names=T)

    if(taxa == "all") height<-max(height,height * (length(envs) /8))
    else if(timeseries) height<-height
    else height<-height * (length(envs) * 2/4)

    print("Generating png ...")
    png(file=outPNG,width=width,height=height,res=res)
    
                                        # Note that categorical varialbles have more than one p-value histogram!!!!!
    if(taxa == "all") par<-par(mfrow=c(max(length(envs) / 2,3),4))
    else if (timeseries) par<-par()
    else  par<-par(mfrow=c(max(length(envs) * 2/4 + 1,3),4))

    if(taxa == "all"){
        for(i in pnam){
            p<-as.numeric(mc[,i])
            phist(p,i)
        }
    }
    else if(timeseries){
        xlim<-range(as.numeric(ca[,timeBy]))
        ylim<-range(ca[,taxa])

        ca[,timeBy]<-as.factor(ca[,timeBy])
        ca[order(ca[,timeBy]),]


        fmla<-make.form(t,timeBy,paired=T)
        full<-lmer(fmla,data=ca)

        fmla<-make.form(t,c(),paired=T)
        null<-lmer(fmla,data=ca)

        p<-signif(anova(null, full)$Pr[2],2)


        plot(ca[,timeBy],ca[,taxa],col="lightgrey",xlab="Time point",ylab=paste(taxa,"(%)"),main=paste("P:",p,"(Fixed Effect Linear Regression)"))

        pairs<-unique(ca$pair)
        for(pair in pairs){
            ca.pair<-ca[ca$pair==pair,]
            ca.pair<-ca.pair[order(ca.pair[,timeBy]),]
            points(ca.pair[,timeBy],ca.pair[,taxa],type="b",col=rgb(0.1,0.1,0.5,0.6),pch=16)
            text(ca.pair[,timeBy][1],ca.pair[,taxa][1],labels=pair,offset=0.5,pos=3)
        }

    }
    else{
        plotEnvScatter(ca,envs,taxa,paired=T)
    }
    par(par)    
    dev.off()

    return(list(mc=mc,p=pnam,c=cnam))
}

plotEnvScatter<-function(ca,envs,taxa,paired=F,corIndex){
    
    if(paired){
        ncol<-dim(ca)[2]
        ca.new<-data.frame(matrix(nrow=0,ncol=ncol))
        names<-names(ca)
        names(ca.new)<-names

        pairs<-unique(ca$pair)
        
        for(p in pairs){
                                        # exclude pairs with less than 2 samples
            ca.p<-ca[ca$pair == p,]
            if(dim(ca.p)[1] < 2) next

            pN<-dim(ca.p)[1]

            for(i in 1:(pN-1)){
                for(j in (i+1):pN){
                    dfp<-data.frame(matrix(nrow=1,ncol=ncol))
                    dfp$pair<-p
                    names(dfp)<-names
                    rownames(dfp)<-paste(i,j,sep="-")

                    for(t in taxa){
                        dfp[1,t]<-ca.p[i,t] - ca.p[j,t]
                    }

                    for(e in envs){
                        dfp[1,e]<-ca.p[i,e] - ca.p[j,e]
                    }
                    ca.new<-rbind(ca.new,dfp)
                }
            }
        }
        
        ca<-ca.new
    }

    ca.na<-na.omit(ca[,c(taxa,envs)])

    
    for(e in envs){    
        if(! is.numeric(ca[,e])) next    

        cot<-cor.test(ca[,e],ca[,taxa],method=corIndex)
        
        co<-signif(cot$estimate[[1]],2)
        p<-signif(cot$p.value[[1]],2)
        
        
        main<-paste("Correlation\nR=",co," p=",p,sep="")

        xlab<-e
        ylab<-taxa

        if(paired){
            xlab<-paste("Difference in",xlab)
            ylab<-paste("Difference in",ylab)
        }
        
        plot(ca[,e],ca[,taxa],pch=16,col=rgb(0.1,0.1,0.7,0.3),ylab=ylab,xlab=xlab,main=main)

        fita<-lm(as.numeric(ca[,taxa]) ~ as.numeric(ca[,e]))
        if(! is.na(fita$coefficients[2])) abline(fita,col="red",lty=3)
        grid()

                                        # partial correlation
        ienvs<-envs[envs != e]
        fmla<-make.form(taxa,ienvs,paired=F)
        fit<-glm(fmla,data=ca.na)
        s<-summary(fit)

        cot<-cor.test(ca.na[,e],fit$residuals,method=corIndex)
        co<-signif(cot$estimate[[1]],2)
        p<-signif(cot$p.value[[1]],2)
        main<-paste("Partial Correlation\nR=",co," p=",p,sep="")
        yl<-paste("Contr.",taxa)
        if(paired) yl<-paste("Difference in",yl)
        plot(ca.na[,e],fit$residuals,pch=16,col=rgb(0.1,0.1,0.7,0.3),ylab=yl,xlab=xlab,main=main)

        fita<-lm(as.numeric(fit$residuals) ~ as.numeric(ca.na[,e]))

        if(! is.na(fita$coefficients[2])) abline(fita,col="red",lty=3)
        grid()
    }
}



regressionTaxaAll<-function(cal,outCoef,outPNG,taxa="all",paired=F,res=200,height=200,width=200,tA=NA,tB=NA,corIndex){

    print("regressionTaxaAll...")

    ca<-1

    if(! is.na(tA)){
        if(is.na(tB)) stop("ERROR tA set but not tB!")

        ca<-c.annotatedCounts(cal,timesInclude=c(tA,tB))
    }
    else ca<-c.annotatedCounts(cal)
    
    if(paired){
        ca<-c.annot2paired(ca,cal,tA,tB)
    }

    cal.taxa<-c()
    if(taxa == "all") cal.taxa<-make.names(c.taxa(cal))
    
    else{
        taxa<-make.names(taxa)
        cal.taxa<-c(taxa)
    }


    
    envs<-c.environment.vars(cal,nonUnique=T)

                                        # get dim of output
    t<-cal.taxa[1]

    
    fmla<-make.form(t,envs,paired=F)
    fit<-glm(fmla,data=ca)
    s<-summary(fit)
    pnam<-paste(names(s$coefficients[,4])[-1],collate=".p",sep="")
    cnam<-paste(names(s$coefficients[,1]),collate=".c",sep="")
    
    nam<-c("Taxa",pnam,cnam)
    ncol<-length(nam)

    mc<-data.frame(matrix(nrow=length(cal.taxa),ncol=ncol))
    names(mc)<-nam

    l<-0
    for(t in cal.taxa){
        l<-l + 1
        
        fmla<-make.form(t,envs,paired=F)
        fit<-glm(fmla,data=ca)
        s<-summary(fit)

        v<-c(t,round(s$coefficients[-1,4],3),round(s$coefficients[,1],3))

        if(length(v) != dim(mc)[2]) stop(paste("ERROR: dim mismatch",length(v),dim(mc)[2]))
        
        mc[l,]<-v

    }

    for(pn in pnam){
        fd<-p.adjust(mc[,pn],method="fdr")
        mc[,paste0(pn,".fdr")]<-signif(fd,5)
    }

    write.csv(file=outCoef,mc,quote=F,row.names=T)

    if(taxa == "all") height<-max(height,height * (length(envs) /8))
    else height<-height*2

    png(file=outPNG,width=width,height=height,res=res)

                                        # Note that categorical varialbles have more than one p-value histogram!!!!!
    if(taxa == "all") par<-par(mfrow=c(max(length(envs) / 2,3),4))
    else par<-par(mfrow=c(max(length(envs) * 2/4 + 1,3),4))

    if(taxa == "all"){
        for(i in pnam){
            p<-as.numeric(mc[,i])
            phist(p,i)
        }
    }
    else{

        ca.na<-na.omit(ca[,c(taxa,envs)])
        for(e in envs){

            p<-"NA"
            main<-""

            numeric<-F
            if(is.numeric(ca[,e])) numeric<-T

            if(numeric){
                

                cot<-cor.test(ca[,e],ca[,taxa],method=corIndex)
                
		co<-round(cot$estimate[[1]],3)
      	 	p<-signif(cot$p.value[[1]],2)
		main<-paste("Correlation\nR=",co," p=",p,sep="")
            }      
            


            xlab<-e
            ylab<-taxa
            if(paired){
                xlab<-paste("Diff.",e,"(paired)")
                ylab<-paste("Diff.",taxa)
            }
            
            print("plotting ...")
            if(numeric)  plot(ca[,e],ca[,taxa],pch=16,col=rgb(0.1,0.1,0.7,0.3),ylab=ylab,xlab=xlab,main=main)
            else  boxplot(ca[,taxa]~ca[,e],col=rgb(0.1,0.1,0.7,0.3),ylab=ylab,xlab=xlab,main=main)

            if(numeric){
                fita<-lm(as.numeric(ca[,taxa]) ~ as.numeric(ca[,e]))
                if(! is.na(fita$coefficients[2])) abline(fita,col="red",lty=3)
            }
            grid()

            if(! numeric) next

                                        # partial correlation
            ienvs<-envs[envs != e]
            fmla<-make.form(taxa,ienvs,paired=F)
            fit<-glm(fmla,data=ca.na)
            s<-summary(fit)

            cot<-cor.test(ca.na[,e],fit$residuals,method=corIndex)
            co<-round(cot$estimate[[1]],3)
            p<-signif(cot$p.value[[1]],2)
            main<-paste("Partial Correlation\nR=",co," p=",p,sep="")
            plot(ca.na[,e],fit$residuals,pch=16,col=rgb(0.1,0.1,0.7,0.3),ylab=paste("Contr.",taxa),xlab=xlab,main=main)

            fita<-lm(as.numeric(fit$residuals) ~ as.numeric(ca.na[,e]))

            if(! is.na(fita$coefficients[2])) abline(fita,col="red",lty=3)
            grid()
        }
    }
    par(par)    
    dev.off()

    return(list(mc=mc,p=pnam,c=cnam))
}


regression.taxa<-function(dfc,taxa,taxAll,out=NA,title="",res=75,width=300,height=300,rby="group",paired=F,corIndex){

    if(! is.numeric(dfc$rvar)){
        errm<-"ERROR: dependent variable must be numeric."
        warning(errm)
        if(!is.na(out)) png(out)
        textplot(errm)
        if(!is.na(out)) dev.off()
        return(0)
    }
    
    taxa<-make.names(taxa)

    if(dim(dfc)[1] == 0){
        stop("no data values")
        return()
    }
    cot<-cor.test(dfc[,taxa],as.numeric(dfc$rvar),method=corIndex)

    co<-round(cot$estimate[[1]],3)
    p<-signif(cot$p.value[[1]],2)
    if(! is.na(out)){
        png(file=out,width=width,height=height,res=res)
    }

    par(mfrow=c(1,2))
    plot(dfc[,taxa],dfc$rvar,xlab="Signal intensity",ylab=rby,main=paste(taxa,"\nR=",co," P=",p,sep=""),pch=16,col=rgb(0.1,0.1,0.7,1))
    fit<-lm(as.numeric(dfc$rvar) ~ dfc[,taxa])

    if(! is.na(fit$coefficients[2])) abline(fit,col="red",lty=3)
    grid()

    fmla <- as.formula(paste("rvar ~ ",taxa))

    
    fit6 <- lm(fmla,data=dfc)
    ra<-range(dfc$rvar,fitted(fit6))

    
    
    plot(dfc$rvar,fitted(fit6),pch=16,xlim=ra,ylim=ra,col=rgb(0.1,0.1,0.7,1),xlab=paste(rby),ylab=paste("Predicted",rby),main=paste("Performance of predictive regression model\n",rby,"=",taxa,"+","c"))
    fit4<-lm(as.numeric(fitted(fit6)) ~ dfc$rvar)

    
    if(! is.na(fit4$coefficients[2])){
        abline(fit4,col="red",lty=3)
    }
    grid()

    if(! is.na(out)){
        dev.off()
    }
    return(fit)
}


get.DAIC.glm<-function(y,data,family){
    features<-names(data)

    ca<-c()

    for(f in features){
        tmp<-data
        tmp[,f]<-NULL
        m<-glm(y~.,data=tmp,family = family)
        aic<-extractAIC(m)[2]

        ca<-c(ca,aic)
    }

    return(ca)
}



feature.selection<-function(cal,out,method="step",title="",resolution=220,width=250,height=450,rby="group",corIndex="pearson",top=100,direction="forward",
                            sig=1){

    rby<-make.names(rby)
    
    .png<-function(){png(file=out,res=resolution,width=width,height=height,
                            unit="mm")}
    
    taxa<-c.taxa(cal)
    ca<-c.annotatedCounts(cal)


    if(method %in% c("glmnet","step","stepAIC")){
        y<-ca[,rby]
        y.n<-y
        
        if(! is.numeric(y) ){
            y.u<-unique(y)
            if(length( y.u ) == 2){
                y.n<-rep(0,length(y))
                y.n[y==y.u[1]]<-1
            }
            else if(! method == "randomForest"){
                errm<-"ERROR: group must be numeric or exactly two classes for regression based feature selection"
                .png()
                textplot(errm)
                dev.off()
                print(errm)
                return(0)
            }
        }
        
        pc<-c()
        for(ta in taxa){
            x<-ca[,ta]
            
            p<-cor.test(x,y.n,method=corIndex)$p.value
            pc<-c(pc,p)
        }
        
        if(sig<1){
            include<-pc<=sig
            pc<-pc[include]
            taxa<-taxa[include]
        }
        or<-order(pc,decreasing=F)
        pc<-pc[or]
        taxa<-taxa[or]
        
        if(length(taxa)==0){
            errm<-"ERROR: no feature significantly associated with factor"
            .png()
            textplot(errm)
            dev.off()
            return(0)
        }
        
        if((! missing(top))) {if(length(taxa) > top) taxa<-taxa[1:top]}
        
        full.model<-1
        min.model<-1
        
        
        results<-""
        
        x<-ca[,taxa]                        
        family<-1
        
        
        if(method == "glmnet"){
            library(glmnet)
            xm<-as.matrix(x)
            glmnet1<-cv.glmnet(x=xm,y=y.n,type.measure='mse',nfolds=5,alpha=.5)
            
            coef<-coef(glmnet1)
            selected<-rownames(coef)[which(coef != 0)]
            selected<-as.character(selected[-1])
            
            x<-x[,selected]
            
            
            if(is.numeric(y)) family<-gaussian
            else family=binomial(link='logit')
            
            model<-glm(y.n ~ ., data=x, family=family)
        }
        else if(method %in% c("step","stepAIC")){
            if(is.numeric(y)) family<-gaussian
            else family<-binomial(link='logit')
            
            full.model<-glm(y.n ~ .,data=x,family=family)
            min.model<-glm(y.n ~ 1,data=x,family=family)
            
            if(method == "step"){
                model = step(min.model, direction=direction,
                    scope=list(lower=min.model,upper=full.model))
            }
            else if(method == "stepAIC"){
                library(MASS)
                model <- stepAIC(full.model, direction=direction)
                print(model$anova) # display results
            }
        }
        
        library(pROC)
        
        .png()
        lma<-matrix(c(1,2,3,3,3,3,4,5), 4, 2, byrow = TRUE)
        layout(lma)      
        auc<-round(roc(model$y,model$fitted.values)$auc,2)
        
        p<-signif(summary(model)$coefficients[,4],2)
        selected<-names(p)[-1]

        selected.aic<-get.DAIC.glm(y.n,x[,selected],family)  

        
        aic<-model$aic
        
        if(length(selected)==0) auc<-"-"
        
        
        title<-"Selected features and feature importance:"
        
        rm<-paste("Included features: ",length(taxa),
                  "\nSelected features: ",length(selected),
                  "\nModel AIC: ",signif(aic,2),
                  "\nModel AUC: ",auc,"\n\n",title,
                  sep="")
        
        par<-par(mar=c(0,5,0,0))
        textplot(rm,show.rownames=F,show.colnames=F)
        par(par)
        
        frame()
        
        if(length(selected)>0){
            if(F){
                tmp<-selected
                n<-length(tmp)
                if(n<=15) tmp<-c(selected,rep("",15-n))
                results<-data.frame(Features=tmp)
                results<-subset(results,1:dim(results)[1]>1)
                textplot(results,show.rownames=F,show.colnames=F)
            }
            else{
                pa<-par(mar=c(8,25,0,5))

                importance<-1
                lab<-1
                
                if(method=="glmnet"){
                    library(caret)
                    importance<-varImp(model)
                    lab<-rownames(importance)
                    importance<-importance$Overall
                    
                    od<-order(importance,decreasing=T)
                    importance<-importance[od]
                    lab<-lab[od]
                                        
                    xlab<-"Importance (abs of t-statistic)"
                }
                else{
                    importance<-selected.aic
                    lab<-selected
                    
                    od<-order(importance,decreasing=T)
                    importance<-importance[od]
                    lab<-lab[od]
                    
                    importance<-c(importance,aic)
                    lab<-c(lab,"Complete model")                    
                    xlab<-"AIC"
                }
                                
                barplot(importance,horiz=T,col="lightblue",
                        names.arg=lab,las=2,
                        xlab=xlab,
                        cex.names=1.3,
                        cex.axis=1.3,
                        cex.main=1.3,
                        cex.lab=1.5)
                abline(v=aic,col="darkred",lty=2)
                par(pa)
            }
            
        }
        else textplot("No feature selected")
        
        main<-paste("Regression model of selected features\nAUC: ",auc)
        xlab<-rby
        if(xlab=="time") xlab<-"Secondary Group"
        if(is.numeric(y)) plot(model$y,model$fitted.values,xlab=xlab,ylab="Fitted values",main=main)
        else{
            groups<-unique(model$y)
            li<-list()
            
        my<-as.character(model$y)
        for(g in unique(my)){
            fv<-model$fitted.values[my==g]
            li[[g]]<-fv

        }
        boxplot(li,xlab=xlab,ylab="Fitted values",main=main)
    }

    frame()
    
    dev.off()
    return(model)
    
}
    else if(method == "randomForest"){
        library(randomForest)
        y<-as.factor(ca[,rby])
            x<-ca[,taxa]                        
        if(is.numeric(y)) y<-c.asCategorical(y)

        rf<-1
        tmp<-try(rf<-randomForest(y~.,data=x,importance=T,proximity=F,
                                  ntree=10000,mtry=20))

        if(! is.list(rf)){
       	    errm<-"ERROR running randomForest"
            .png()
            textplot(errm)
            dev.off()
            warning(errm)
            return(1)
        }

        
        im<-as.data.frame(importance(rf))        
        da<-im$MeanDecreaseAccuracy

        res<-data.frame(Feature=rownames(im),MeanDecreaseAccuracy=da)
        res<-res[order(res$MeanDecreaseAccuracy,decreasing=T),]
        res<-res[res$MeanDecreaseAccuracy>0,]
        
        .png()
        pa<-par(fig=c(0.25,1,0.1,1))

        col<-rep("darkblue",dim(res)[1])
        col[res$MeanDecreaseAccuracy < 0]<-"darkred"
        
        barplot(res$MeanDecreaseAccuracy,horiz=T,col=col,
                names.arg=res$Feature,las=2,
                main="Importance of selected features",
                xlab="Importance")
        par(pa)
        dev.off()
        return(res)
    }
        

}


regression.list<-function(ct,out,logit=F,title="",resolution=75,width=300,height=300,taxa,rby="group",corIndex){  

    df<-data.frame(p=-1,cor=-1,taxa="del",mean=-1,present=-1)
    
    n<-dim(ct)[1]
    
    include<-c()

    if(! is.numeric(ct$rvar)){
        rvar.un<-as.character((unique(ct$rvar)))

        if(length(rvar.un) < 2){
            errm<-"ERROR: less than 2 groups for dependant variable"
            warning(errm)
            png(out)
            textplot(errm)
            dev.off()
            return(-1)
        }
        if(length(rvar.un) > 2){
            warning(paste("ERROR: unique(ct$rvar) > 2!!!",paste(ct$rvar,collapse=" , ")))
            
            errm<-"ERROR: factor must be numeric or\nhave exactly 2 different values\n(e.g. yes/no or case/control or high/low, ...)"
            png(out)
            textplot(errm)
            dev.off()
            return(-1)

        }
        else{
            gA<-rvar.un[[1]]
            gB<-rvar.un[[2]]
            tmp<-ct$rvar
            ct$rvar<-1
            ct[tmp == gA,]$rvar<-1
            ct[tmp == gB,]$rvar<-0
        }
    }

    for(t in taxa){
        cot<-cor.test(ct[,t],ct$rvar,method=corIndex)
        co<-round(cot$estimate[[1]],4)
        p<-signif(cot$p.value[[1]],2)
        
        present<-length(which(ct[,t] > 0))
        me<-round(mean(ct[,t]),3)
        
        df<-rbind(df,data.frame(p=p,cor=co,taxa=t,mean=me,present=present))
    }

    df<-df[-1,]

    if(dim(df)[1]>4){
	tmp<-df
	mp<-max(df$present)
	if(mp>10) tmp<-tmp[tmp$present>=0.1*mp,]
	if(dim(tmp)[1] < 4) tmp<-df
	include<-tmp[order(tmp$p),][1:4,]$taxa
    }
    else include<-df$taxa
    
    fmla <- as.formula(paste(paste("rvar ~ ", paste(include, collapse= "+")),""))
    fit<-0
    

    if(logit){
                                        #    fit <- glm(fmla,data=ct,family = binomial("logit"))
        fit <- glm(fmla,data=ct)
    }
    else{
        fit <- lm(fmla,data=ct)
    }
    
    res<-ct$rvar - fit$fitted.values
    mi<-round(min(res),3)
    ma<-round(max(res),3)
    me<-round(mean(abs(res)),3)
    
    s<-summary(fit)

                                        #  title<-paste("Residuals: Mean abslute=",me,"\nMax=",ma," Min=",mi," ",
                                        #  			   title,sep="")

    if(! logit){    
        fs<-s$fstatistic
        p<-signif(1-pf(fs[1],fs[2],fs[3]),2)
        title<-paste("Signif. of model: p=",p,sep="")
    }

    png(out,width=width,height=height,res=resolution,unit="mm")

    plotTax<-F
    if(length(include) <= 15){
        plotTax<-T
    }

    par<-1

    if(plotTax){
        nrow=(length(include) + 3) / 3
        if(as.integer(nrow) != nrow){
            nrow<-as.integer(nrow) + 1
        }
        par<-par(mfrow=c(nrow,3))
        on.exit(par(par))
    }
    else{
        par<-par(mfrow=c(1,2))
        on.exit(par(par))
    }

    
    ra<-range(ct$rvar,fitted(fit))
    plot(ct$rvar,fitted(fit),xlim=ra,ylim=ra,pch=16,col=rgb(0.2,0.2,0.6),xlab=paste(rby),ylab=paste("Modelled",rby),main=title)
    
    grid()

    modl<-lm(as.numeric(ct$rvar) ~ fitted(fit))
    abline(modl,col="red",lty=3)
    
                                        #  abline(10,1,col="gray60",lty=3)
                                        #abline(0,1,col="red")
                                        #  abline(-10,1,col="gray60",lty=3)


    
    if(plotTax){
        s<-summary(fit)
        cof<-as.data.frame(s$coefficients[,c(1,2,4)])
        cof<-cof[-1,]
        names(cof)[3]<-"P"
        tp<-data.frame(P=cof$P)
        rownames(tp)<-rownames(cof)

        textplot(round(tp,3))
        title("Multivariable linear regression model:")
        
        for(t in include){
            p<-df[df$taxa == t,"p"]
            co<-df[df$taxa == t,"cor"]
            
            plot(ct[,t],ct$rvar,xlab=paste(t),ylab=rby,main=paste("R=",co," P=",p,sep=""),pch=16,col=rgb(0.1,0.1,0.7,1))
            mod<-lm(as.numeric(ct$rvar) ~ ct[,t])
            abline(mod,col="red",lty=3)
            grid()
        }
    }

    dev.off()

    return(list(fit=fit,list=df))
}



taxa.boxplot<-function(cal,out,color="heat",log=F,horiz=T,plotGrid=T,title="",
                       width=1000,height=500,res=75,groupBy="group",p=1,
                       figureFormat="png",
                       stripchart=F,
                       tax=NA){

    if(!is.na(tax)) tax<-make.names(tax)

    if(!is.na(tax)) p=1

    devOFF<-T
    
    if(figureFormat == "png"){
        png(out,width=width,height=height,res=res,units="mm")
    }
    else if(figureFormat == "pdf"){
        pdf(out,width=width,height=height)
    }
    else if(figureFormat == "svg"){
        svg(out,width=width,height=height)
    }
    else devOFF <-F
    
    if(groupBy != "group"){
        cal<-c.setGroups(cal,groupBy=groupBy,color=color)
    }

    
    c.a<-c.annotatedCounts(cal)


    
                                        #sort matrix
    taxa<-c.taxa(cal)
    taxa<-sort(taxa)
    c.a<-c.a[order(rownames(c.a)),]	

    groups.all<-c.a$group
    c.a<-subset(c.a,select=names(c.a) %in% taxa)	
    c.a$group<-groups.all
    groups.all<-NULL
    
    c.a<-c.a[!is.na(c.a$group),]
    cal<-NULL
    

    groups<-sort(unique(c.a$group))

    

    groupN<-length(groups)


    if(groupN < 2){
        errm<-"ERROR: less than 2 groups defined"
        frame()
        text(0.5,0.5,errm,font=2,,col="red",cex=1.5)
        dev.off()
        print(errm)
        return(0)
    }
    
    cols<-getColors(color,groupN)

    taxa.include<-c()

    if(p < 1){
        gA<-1
        gB<-1
        kruskal<-T


        if(groupN == 2){
            kruskal<-F
            gA<-groups[1]
            gB<-groups[2]
        }
        
        for(t in taxa){
            t.p<-1

            if(kruskal) t.p<-kruskal.test(c.a[,t],as.factor(c.a$group))$p.value
            else t.p<-wilcox.test(c.a[c.a$group==gA,t],c.a[c.a$group==gB,t])$p.value
            
	    if(is.null(t.p)) t.p<-1
	    if(is.na(t.p)) t.p<-1


            if(t.p < p){
                taxa.include<-c(taxa.include,t)
            }
        }
    }
    else if(!is.na(tax)) taxa.include<-c(tax)
    else{
        taxa.include<-taxa
    }

    taxaN<-length(unique(taxa.include))
    

                                        # init data list
    data.list<-list()


                                        # generate data list
    for(t in taxa.include){
        for(g in groups){
            id<-1
            if(taxaN == 1){
                id<-g
            }
            else{                
                id<-paste(t,g)
            }
            v<-c.a[c.a$group==g,t]
            if(log) v<-log10(v)
            
            data.list[[id]]<-v
        }
    }

    logS<-""
    if(log) logS<-"x"
    

    pa<-NA

    label=c(1:10)
    b<-1

    
    if(taxaN == 1){
        ylab<-taxa.include

        if(log){
            if(relative) ylab<-"Log10(Percentage)"
            else ylab<-paste0("Log10 ",taxa.include)
        }
        
        pa<-par(fig=c(0,1,0.25,1))

        p<-1
        if(length(data.list) == 2) p<-wilcox.test(data.list[[1]],data.list[[2]])$p.value
        else p<-kruskal.test(data.list)$p.value
        
        p<-signif(p,2)

        if(stripchart){
            print("do.stripchart")
            do.stripchart(data.list,ylab=ylab,col=cols,main=paste(title,"\np=",p," (rank test)",sep=""))

        }
        else{
            b<-boxplot(data.list,horizontal=horiz,ylab=ylab,col=cols,main=paste(title,"\np=",p," (rank test)",sep=""),las=2)
        }
        if(devOFF) dev.off()
        return(1)
        
    }

    if(length(taxa.include) < 1){
        m<-paste("No feature with p <",p)
        textplot(m)
        if(devOFF) dev.off()
        return(1)
    }
    else{
        pa<-NULL
        if(horiz){
            pa<-par(fig=c(0.25,1,0.1,1))
        }
        else{
            pa<-par(fig=c(0,1,0.25,1))
        }

        ylab<-""
        if(log) ylab="Log10"

        ylim<-1
        if(log){
            v.log<-log10(c.a[,taxa.include])
            v.log<-v.log[v.log > -Inf]
            ylim<-range(v.log)
        }
        else{
            ylim<-range(c.a[,taxa.include])
        }
        if(log) ylim[2]<-ylim[2] + ylim[2] 
        else ylim[2]<-ylim[2] + ylim[2] * 0.3
        

        b<-1
        label<-taxa.include
        at<-seq(1 + (groupN - 1) / 2,taxaN * groupN - groupN + 1 + (groupN - 1) / 2,groupN)

        if(horiz){
            b<-boxplot(data.list,las=2,horizontal=horiz,xlab=ylab,col=cols,main=title,yaxt="n",xlim=c(0.9,taxaN*groupN + 0.1),ylim=ylim)
            axis(2,at=at,label=label,las=2,tick=T)
        }
        else{

            b<-boxplot(data.list,las=2,horizontal=horiz,ylab=ylab,col=cols,main=title,xaxt="n",xlim=c(0.9,taxaN*groupN + 0.1),ylim=ylim,cex=0.5)
            axis(1,at=at,label=label,las=2,tick=T)
        }

        if(p < 1 & ! horiz){
            i<-1
            ma<-max(c.a[,taxa.include])
            for(t in taxa.include){
                ia<-i
                if(log) offset<-0.5
                else offset<-ma * 0.04
                y<-1
                y<-max(max(c.a[,t])+2*offset,ma/3)
                if(log) y<-log10(y) + 0.5

                for(a in 1:(groupN -1)){                
                    ib<-ia+1
                    for(b in (a+1):groupN){
                        gA<-groups[a]
                        gB<-groups[b]                  
                    
                        p.g<-wilcox.test(c.a[c.a$group==gA,t],c.a[c.a$group==gB,t])$p.value
                        
                        if(is.na(p.g)) p.g<-2                

                        if(p.g < 0.05){

                            label<-"*"

                            if(p.g < 0.001) label<-"***"
                            else if(p.g < 0.01) label<-"**"
                            
                            text(ia + (ib-ia)/2,y+offset/3,labels=c(label))
                            
                            lines(c(ia,ib),c(y,y))
                            lines(c(ia,ia),c(y-offset/4,y))
                            lines(c(ib,ib),c(y-offset/4,y))
                            y<-y+offset
                        }
                        ib<-ib+1
                    }
                    ia<-ia+1
                }
                i<-i+groupN
            }
        }
    }
    
    if(plotGrid){
        gN<-length(groups)

        tmp<-seq(gN,taxaN*gN - 1,gN)
        for(i in tmp) abline(v=i+0.5,col="lightgrey",lty="dotted")
        grid(nx=NA,ny=NULL)

    }
    if(taxaN != 1){
        lp<-sample(c("top","topleft","topright"))[1]
        legend(lp, legend=groups, cex=0.9, fill=cols);
        par(pa)
    }
    if(devOFF) dev.off()

    return(data.list)
}

do.stripchart<-function(data,y=NA,groups=NA,color="black",...){

    if(is.data.frame(data)){
        tmp<-list()
        grp<-unique(data[,groups])
        for(g in grp){
            tmp[[as.character(g)]]<-data[data[,groups] == g,y]
        }
        data<-tmp
    }	

    groups<-names(data)
    sym<-getSymbols(length(groups))

    jitter<-0.25

    stripchart(data,vertical=T,method="jitter",pch=sym,jitter=jitter,col="white",cex=0.01,...)
    
    for(i in 1:length(groups)){
        g<-groups[i]	

        v<-data[[g]]

        m<-mean(v)

        lines(c(i-0.4,i+0.4),c(m,m),lwd=3)
        s<-sd(v)
        lines(c(i,i),c(m-s,m+s),lwd=2)
        lines(c(i-jitter,i+jitter),c(m-s,m-s),lwd=2)
        lines(c(i-jitter,i+jitter),c(m+s,m+s),lwd=2)
    }	
    stripchart(data,vertical=T,method="jitter",pch=sym,jitter=jitter,add=T,col=color,cex=1.4,...)
}

taxa.stripchart<-function(cal,out,color="heat",log=F,horiz=T,plotGrid=T,height=1000,width=1000,res=70,
                          figureFormat="png"){

    d<-calypso2dfc(cal)

    if(figureFormat == "png"){
        png(out,width=width,height=height,res=res,units="mm")
    }
    else if(figureFormat == "pdf"){
        pdf(out,width=width,height=height)
    }
    else if(figureFormat == "svg"){
        svg(out,width=width,height=height)
    }



    groups<-unique(d$Group)
    groupN<-length(groups)

    cols<-getColors(color,groupN,0.85,greyEnd=0.8)

    logS<-""

    if(log){
        logS<-"x"
    }

    g<-groups[1]
    c<-cols[1]

    sym<-getSymbols(groupN)

    vert<-T

    par<-1

    if(horiz){
        vert<-F
        par<-par(fig=c(0.25,1,0,1))
    }
    else{
        par<-par(fig=c(0,1,0.25,1))
    }

    f<-formula(Count ~ Taxa)
    ylab<-"Signal intensity"
    count.range<-range(d$Count)

    
    if(log){
        f<-formula(log10(Count) ~ Taxa)
        ylab<-"log10(Signal intensity)"
        count.range<-range(log10(d$Count))
        count.range[1]<--1
    }


    stripchart(f,d,method="jitter",vertical=vert,col=c,pch=sym[1],las=2,subset = Group==groups[1],
               xlab="",ylab=ylab,ylim=count.range,jitter=0.3)
    
    for(i in 2:groupN){
        g<-groups[i]
        c<-cols[i]

        stripchart(f,d,method="jitter",vertical=vert,
                   col=c,pch=sym[i],las=2,subset = Group==g,ylim=count.range,add=T)

    }

    taxaN<-length(unique(d$Taxa))

    if(plotGrid){
        grid(taxaN)
    }
    legend("right", legend=groups, pch=sym, cex=0.9, col=cols);
    dev.off()
    par(par)
}


taxa.chart<-function(cal,out,type="bar",color="heat",transpose=F,beside=F,width=500,height=1000,res=75,reorder=T,title="",er="G",
                     orderBy=NA,medianPlot=F,groupBy="group",legend=T,
                     figureFormat="png",p=1,scale=T,trim=0,center=NA){

    if(groupBy != "group"){
        cal<-c.setGroups(cal,groupBy=groupBy)
    }

    tmp<-cal$annot$group
    if(any(is.na(tmp))){
        tmp[is.na(tmp)]<-"NA"
        cal$annot$group<-tmp
    }
    
    if(figureFormat == "png"){
        png(out,width=width,height=height,res=res,units="mm")
    }
    else if(figureFormat == "pdf"){
        pdf(out,width=width,height=height)
    }
    else if(figureFormat == "svg"){
        svg(out,width=width,height=height)
    }

    if(p<1){		
        groups<-c.groups(cal,groupBy)

        if(length(unique(groups)) < 2){				
            textplot("ERROR: Only one group defined, at least two groups required")
            dev.off()
            return(1)
        }
        cal<-c.filter.p(cal,p=p,groupBy=groupBy)
        taxa<-c.taxa(cal)
        if(length(taxa) < 1){
            textplot(paste0("ERROR: No items with p<",p))
            dev.off()
            return(1)
        }

    }

    
    if(type == "bar"){
        taxa.barplot(cal,color,beside,title=title,transpose=transpose,er=er,orderBy=orderBy,medianPlot=medianPlot,legend=legend)
    }
    else if(type %in% c("heat","heatp")){
        taxa.heatplot(cal,color,reorder,title=title,type=type,transpose=transpose,
                      medianPlot=medianPlot,orderBy=orderBy,scale=scale,trim=trim,center=center)
    }
    else if(type == "bubble") taxa.bubbleplot(cal,er=er,transpose=transpose,
                orderBy=orderBy,medianPlot=medianPlot,legend=legend)
    else if(type == "boxplot") overview.boxplot(cal,orderBy=orderBy,
                legend=legend)
    else stop("unknown type ",type)
    dev.off()
}

overview.boxplot<-function(cal,er="N",orderBy="GST",legend=T){
    ca<-c.annotatedCounts(cal,er=er,orderBy=orderBy)


    if(substring(orderBy, 1,1) == "S"){ 
        grl<-unique(ca$pair)
        colors<-colorByGroup(ca$pair,"lessbright",F)
    }else if(substring(orderBy, 1,1) == "T"){ 
        grl<-unique(ca$time)
        colors<-colorByGroup(ca$time,"lessbright",F)
    }else {    
        grl<-unique(ca$group)
        colors<-colorByGroup(ca$group,"lessbright",F)
    }
    taxa<-c.taxa(cal)	
    m<-ca[,taxa]
    m<-as.matrix(m)
 
    
    if(dim(m)[1] != length(colors)) stop("ERROR: color-dim mismatch")
    
    boxplot(t(m),las=2,col=colors,cex=0.3,notch=T)

    if(legend) legend("topright", legend=grl, cex=0.9, 
                      fill=unique(colors))
    return(m)
}

calypso.summary<-function(cal,out,type="bar",png=T,color="blue",width=500,height=1000,res=75,title="",log=F,box=F){
    if(png){
        png(out,width=width,height=height,res=res,units="mm")
    }
    else{
        pdf(out,width=14)
    }


    if(type == "readsBySample"){        
        labels<-c.labels(cal)
        tot<-c.totals(cal)

        xlab<-""
        ylab<-"Number of Samples"
        mi<-min(tot)
        ma<-max(tot)

        i<-which(tot == mi)
        mi.s<-labels[i][1]
        i<-which(tot == ma)
        ma.s<-labels[i][1]


        if(log){
            tot<-log10(tot)
            xlab<-paste("Log10",xlab)
        }
        main<-paste("Reads per sample\nMin=",mi," (",mi.s,")","\nMax=",ma," (",ma.s,")",sep="")

        if(box){
            par(mar=c(8,4,5,4))  
            groups<-c.groups(cal)
            a<-aov(tot ~ groups)
            p<-signif(anova(a)$"Pr(>F)"[1],4)
            main<-paste(main,"\np =",p,"(anova)")

            boxplot(tot~groups,col=getColors(color,length(unique(groups))),xlab=xlab,ylab="",main=main,las=2)
        }
        else{
            line.hist(tot,40,xlab,ylab,main)
        }
        grid()
    }
    else if(type == "readsBySampleBC"){        
        countsDF<-c.annotatedCounts(cal,er="G",orderBy="GST")


        total<-countsDF$total
        names(total)<-countsDF$label
        if(log) total<log(total)          

        par<-par(fig=c(0,0.8,0,1))
        main<-"Reads per sample"
        if(log) ylab<-"Reads per sample (log)"


        barplot(total,names.arg=countsDF$label,col=countsDF$color,las=2,main=main,ylab="")
        labels<-unique(c.groups(cal))
        par(par)
        legend("right", legend=rev(labels), cex=0.9, fill=rev(unique(c.colors(cal))));
    }
    else if(type == "readsByTaxa"){
        ma<-t(c.counts(cal))

        me<-round(mean(ma),4)
        med<-round(median(ma),4)

        xlab<-"Number of Reads"

        ylab<-"Number of Taxa/OTUs"
        if(log){
            ma<-log10(ma)
            xlab<-paste("Log10",xlab)
        }

        title<-paste(title," Mean=",me," Median=",med,sep="")

        if(box){
            boxplot(ma,col=getColors(color,1),xlab=xlab,ylab=ylab,main=title,las=2)
        }
        else{
            line.hist(ma,40,xlab,ylab,title)
        }
        grid()
    }
    else if(type == "detectDist"){
        counts<-t(c.counts(cal))
        det<-as.numeric(apply(counts,1,detectP))

        if(box){
            boxplot(det,ylab="Positive Samples",main=title,col=m$colors[1])
        }
        else{
            line.hist(det,20,xlab="Positive Samples",ylab="Number of Taxa/OTUs",title)
        }
    }
    else{
        stop("Don't know what to do, unknown type!")
    }
    dev.off()
}

detectP<-function(l){
    return(length(which(l > 0)))
}

line.hist<-function(ma,breaks,xlab,ylab,title,col=rgb(0.2,0.5,1,0.3),adjust=0.3){
    h<-hist(ma,breaks=breaks,col=col,xlab=xlab,ylab=ylab,main=title)
    d<-density(ma,adjust=adjust)

                                        # compute factor for scaling densities
                                        # such that max(dens) = max(hist) / 2
    mx<-max(h$counts)
    dy.max<-max(d$y)
    c<-(mx/2) / dy.max

    lines(d$x,d$y * c,col="darkred")
}

correlationplot<-function(cal,outFile,color="heat",title="",width=600,height=600,res=75,type="plot",orderBy=NA,figureFormat="png",grid=c(4,3),first="group",second="time",third=NA){

    if(figureFormat == "png"){
        png(outFile,width=width,height=height,res=res,units="mm")
    }
    else if(figureFormat == "pdf"){
        pdf(outFile,width=width,height=height)
    }
    else if(figureFormat == "svg"){
        svg(outFile,width=width,height=height)
    }

    ca<-c.annotatedCounts(cal)
                                        #x-axis
    firstVec <- cal$annot[,first]
    if(!is.numeric(firstVec)){
        firstVecFactor <- factor(firstVec)
        firstVec <- as.numeric(firstVecFactor)
    }

                                        #y-axis
    if(second %in% colnames(cal$annot)){
        secVec <- cal$annot[,second]
        if(!is.numeric(secVec)){
            secVecFactor <- factor(secVec)
            secVec <- as.numeric(secVecFactor)
        }
    }else if(second %in% colnames(cal$default)){ 
        secVec <- ca[,second]
    }


    if(is.na(third) || third == "--"){
        result <-cor.test(firstVec,secVec,method=corIndex)
        pvalue <-signif(result$p.value,2)
        estimate<-round(result$estimate,3)
        plot(firstVec,secVec,ylab=second,xlab=first,pch=19,col="blue",main=paste0("p=",pvalue,",r=",estimate))
        abline(reg=lm(secVec~firstVec),col="red")
                                        # lines(lowess(firstVec,secVec),col="lightblue",add=T)
        grid()
        
    }else{
        thirdVec <-ca[,third]
        radius <- sqrt( thirdVec / pi )
        layout(matrix(c(1,1,1,2), 1, 4, byrow = TRUE))      
        symbols(firstVec,secVec,circles=radius,bg="lightblue",inche=0.35,ylab=second,xlab=first)
        abline(reg=lm(secVec~firstVec),col="red")
        grid()
        mylims <- par("usr")
                                        #create legend
        legPop <- c(min(thirdVec),(max(thirdVec)-min(thirdVec))/2+min(thirdVec),max(thirdVec))
        legPop <-round(legPop)
        legPopRad <-sqrt( legPop / pi )
        legRad <- sqrt( legPop / pi )
        hin <- par('pin')[2]
        burgPerInch <- ( mylims[4] - mylims[3] ) / hin
        radPerInch <- max(radius)/0.35
        heightAdj <- legRad/radPerInch*burgPerInch
        
        symbols( rep(0,3), rep(0,3) + heightAdj +mylims[3], circles = legRad, inches = 0.35,xlab="",ylim = c(mylims[3],mylims[4]),ylab="",axes=F)
        mtext(third,side=1)
        tAdj <- strheight('40m', cex = 0.9)
        text(rep(0,3), rep(0,3) + heightAdj*2 - tAdj +mylims[3] , legPop, cex = 0.9)


	
    }

}
taxa.bubbleplot<-function(cal,er="N",transpose=F,orderBy=NA,medianPlot=F,legend=T,p=1,groupBy="group"){
    require(ade4)
    
    counts<-c.annotatedCounts(cal,er=er,orderBy=orderBy,median=medianPlot)

    taxa<-c.taxa(cal)
    
    if(p<1){		
        ctmp<-c.annotatedCounts(cal,median=medianPlot)
        groups<-c.groups(cal,groupBy)

        if(length(unique(groups)) < 2){				
            textplot("ERROR: Only one group defined, at least two groups required")
            return(1)
        }

        exclude<-c()
        for(t in taxa){
            c<-ctmp[,t]

            a<-aov(c ~ groups)
            pa<-anova(a)$"Pr(>F)"[1]	
            if(pa>p) exclude<-c(exclude,t)
        }     
        
        for(t in exclude){
            counts[,t]<-NULL
        }

        taxa<-taxa[! taxa %in% exclude]

    }	

    rowlabels<-1
    collabels<-1

    
    if(! transpose){        
        rowlabels<-taxa
        collabels<-counts$label
        counts<-t(counts[,taxa])
    }
    else{
        rowlabels<-counts$label
        collabels<-taxa
        counts<-counts[,taxa]
    }
    counts<-as.data.frame(counts)
    
    names(counts)<-colnames(counts)
    
    N<-max(dim(counts)[1],dim(counts)[2])

    size<- 0.8 - 0.005 * N
    if(size < 0.2){
        size<-0.2
    }

    par<-par(fig=c(0,0.94,0,0.92))

    table.value(counts,csize=size,clegend=legend,col.labels=collabels,row.labels=rowlabels)

    par(par)

    return(1)
}

heatAnnotationCol<-function(x) {
    if(length(unique(x)) > 3) return(colorByGroup(x,"lessbright",F))
    return(colorByGroup(x,"grey",F))
}

taxa.heatplot<-function(cal,color="heat",colv=T,rowcex=0.9,colcex=0.9,
                        title="",type="heat",
                        medianPlot=F,orderBy="GST",transpose=F,scale=T,trim=0,
                        center=NA,legend=T){

    if(scale) center<-NA

    ca<-c.annotatedCounts(cal,orderBy=orderBy,median=medianPlot)
    taxa<-c.taxa(cal)
    counts<-ca[,taxa]

    if(! transpose){
        counts<-t(counts)
    }

    tN<-dim(counts)[1]
    col<-getColors(color,100)

    csc<-data.frame(matrix(ncol=0,nrow=dim(counts)[2]))
    if(type =="heatp"){

        envs<-c.environment.vars(cal)
        for(e in envs){

            v<-ca[,e]
            colors<-1

            if(is.numeric(v)) colors<-getContCol(v,F)
            else colors<-heatAnnotationCol(v)

            if(length(unique(v)) > 1) csc[,e]<-colors
        }
    }
    else{
        for(g in c("group","time","pair")){
            groups<-ca[,g]
            if(is.numeric(groups)) group.colors<-getContCol(groups,F)
            else group.colors<-heatAnnotationCol(groups)
            na<-"Primary"
            if(g=="time") na<-"Secondary"
            if(g=="pair") na<-"Pair"
            if(length(unique(groups)) > 1 & length(unique(groups)) < length(groups)) csc[,na]<-group.colors
        }
    }		


    if(scale) scale<-"row"
    else scale<-"none" 

    if(trim > 0){
        counts[counts>trim]<-trim
        counts[counts < -trim]<- -trim
    }	

    breaks<-NULL
    if(!is.na(center)){
        print("center color ...")
        n<-length(col)
        range<-range(counts,na.rm=T)
        breaks<-c(seq(range[1],center,length.out=n/2+1),seq(center + 0.1,range[2],length.out=n/2))
    }

    clab<-data.frame(matrix(nrow=length(c)))

    heatmap.3(counts, col=col,Rowv=T, Colv=colv, dendrogram="both",scale=scale,trace="none",cexRow=rowcex,cexCol=colcex,main=title,margins=c(10,30),ColSideColors=csc,density.info="density",keysize=1.5,lwid=c(1,4.5),breaks=breaks)

    if(legend){
	if(type =="heatp"){
            lab<-c()
            fill<-c()

            envs<-c.environment.vars(cal)

            for(e in envs){

		v<-unique(ca[,e])


		if(is.numeric(v)){
		 colors<-getContCol(1:3,F)

                 mean<-signif(mean(v,na.rm=T),1)
                 mean.col<-colors[2]
                 if(length(unique(v)) <= 2){
                     mean<-NULL
                     mean.col<-NULL
                 }
                     lab<-c(lab,e,min(v,na.rm=T),mean,max(v),"")
                     fill<-c(fill,"white",colors[1],mean.col,colors[3],
                             "white")
                 }
		else{
                    v<-as.character(v)
                    colors<-heatAnnotationCol(v)

                    if(length(unique(v)) > 1){
                        lab<-c(lab,e,v,"")
                        fill<-c(fill,"white",colors,"white")
                    }
                }
            }


            legend("topright",legend=lab,fill=fill,border=F,cex=0.7)
	}
	else{
            lab<-c()
            fill<-c()
            for(g in c("group","time","pair")){

                na<-"Primary"
                if(g=="time") na<-"Secondary"
                if(g=="pair") na<-"Pair"

		groups<-(ca[,g])
		if(is.numeric(groups)){
                    min<-min(groups,na.rm=T)
                    max<-max(groups,na.rm=T)
                    gc<-getContCol(c(min,max),F)
                    if(length(unique(groups)) > 1 ) {
			lab<-c(lab,na,min,max,"")
			fill<-c(fill,"white",gc[1],gc[2],"white")
                    }
                }
		else{
                    gu<-unique(groups)
                    gc<-heatAnnotationCol(gu)
                    if(length(gu) > 1 & length(gu) < length(groups) ) {
			lab<-c(lab,na,gu,"")
			fill<-c(fill,"white",gc,"white")
                    }
		}
            }
            legend("topright",legend=lab,fill=fill,border=F,cex=0.7)
	}

    }
}

taxaIndByGroup<-function(groups,gA){
    return(which(groups == gA))
}

oddsratioWald.proc <- function(x,groups,alpha=0.05){

    gr<-unique(groups)
    groupA<-gr[1]
    groupB<-gr[2]
    xA<-x[groups==groupA]
    xB<-x[groups==groupB]
    cf<-(mean(xA)+mean(xB))/2
    x[x<=cf]<-0
    x[x>cf]<-1

    n11<-sum(xA>cf,na.rm=T)
    n10<-sum(xA<=cf,na.rm=T)
    n01<-sum(xB>cf,na.rm=T)
    n00<-sum(xB<=cf,na.rm=T)

    pc<-0.5
    if(n01<1) n01<-pc
    if(n10<1) n10<-pc
    if(n00<1) n00<-pc
    if(n11<1) n11<-pc

                                        #    n00 = number of cases where x = 0 and y = 0
                                        #    n01 = number of cases where x = 0 and y = 1
                                        #    n10 = number of cases where x = 1 and y = 0
                                        #    n11 = number of cases where x = 1 and y = 1
                                        #
    OR <- (n00 * n11)/(n01 * n10)
                                        #
                                        #  Compute the Wald confidence intervals:
                                        #
    siglog <- sqrt((1/n00) + (1/n01) + (1/n10) + (1/n11))
    zalph <- qnorm(1 - alpha/2)
    logOR <- log(OR)
    loglo <- logOR - zalph * siglog
    loghi <- logOR + zalph * siglog
                                        #
    ORlo <- exp(loglo)
    ORhi <- exp(loghi)
                                        #
    oframe <- data.frame(LowerCI = ORlo, OR = OR, UpperCI = ORhi)

    return(oframe)
}


auc.resampled<-function(case.scores,control.scores){

    response<-c(rep(1,length(case.scores)),rep(0,length(control.scores)))
    scores<-c(case.scores,control.scores)

    result<-c()

    for(i in 1:length(response)){
        training.resp<-response[-i]
        training.scores<-scores[-i]

        test.resp<-response[i]
        test.score<-scores[i]

        dat<-data.frame(response=training.resp,scores=training.scores)
        model<-glm(as.factor(response)~scores,family=binomial(logit),data=dat)
        predict<-predict(model,newdata=data.frame(scores=test.score))
        result<-c(result,as.numeric(predict))
    }

    auc<-as.numeric(roc(response,result)$auc)

    return(auc)
}

text.png<-function(x,file=NA){
    warning(x)

    if(is.na(file)) return(1)
    png(file)
    textplot(x)
    dev.off()
}

.replace.group<-function(group){
    if(group=="group") group<-"Primary Group"
    else if(group=="time") group<-"Secondary Group"
    return(group)
}

biomarker<-function(cal,out,histFile=NA,orFile=NA,groupBy="group",test="ttest",invertGroups=F){

    if(test=="nestedanova") groupBy="group"

    cal<-c.setGroups(cal,groupBy=groupBy)

    ca<-c.annotatedCounts(cal,na.omit=T)

                                        # make sure data is ordered by group; glm will use ordered groups
    ca<-ca[order(ca$group),]

    groups<-ca$group
    groups.unique<-unique(groups)
    nested.groups<-ca$time


    if(length(groups.unique) != 2){
        errm<-"ERROR: biomarker discovery requires exactly two groups\nTry secondary group for the example data."
        warning(errm)
        if(!missing(orFile)) text.png(errm,orFile)
        
        return(1)
    }


    taxa<-c.taxa(cal)


    if(test=="regression"){
        envs<-c.environment.vars(cal)
        envs<-envs[!envs==groupBy]
        for(e in envs){
            print(data.frame(groups,ca[,e]))
            print(e)

            if(all(as.character(groups) == as.character(ca[,e]))){
                tmp<-.replace.group(groupBy)
                errm<-paste("ERROR:",tmp,"and",e,"are identical!")
                warning(errm)
                if(!missing(orFile)) text.png(errm,orFile)
                
                return(1)		      
            }
        }
    }


    library(pROC)
    library(randomForest)
    library(metafor)


    groupA<-groups.unique[1]
    groupB<-groups.unique[2]

    meanA.c<-c()
    meanB.c<-c()

    result<-data.frame(Taxa="del",P=1,FDR=1,BH=1,Bonferroni=1,
                       AUC=1,
                       AUC.LowerCI=1,
                       AUC.UpperCI=1,
                       OR=1,
                       LowerCI=1,
                       UpperCI=1,Delta=1,FoldChange=1)

    for(t in taxa){
        x<-ca[,t]

        xA<-x[groups==groupA]
        xB<-x[groups==groupB]

        meanA<-mean(xA)
        meanB<-mean(xB)
        meanA.c<-c(meanA.c,meanA)
        meanB.c<-c(meanB.c,meanB)

                                        # adjust values for covariates
        if(test=="regression"){
            f<-paste("x ~",paste(envs,collapse="+"))
            model<- glm(as.formula(f),data=ca)

            x.adj<-model$residuals

            xA.adj<-x.adj[groups==groupA]
            xB.adj<-x.adj[groups==groupB]

            meanA.adj<-mean(xA.adj)
            meanB.adj<-mean(xB.adj)		   
        }
        else{
            xA.adj<-xA
            xB.adj<-xB
            meanA.adj<-meanA
            meanB.adj<-meanB
            x.adj<-x
        }

            roc<-roc(groups,x.adj)
            ci<-ci(roc)	
            auc<-roc$auc     
            auc<-as.numeric(auc)
                                        #	      auc.resampled<-auc.resampled(xA,xB)

        
                                        # odds ratio
        cf<-(meanA+meanB)/2
        x.or<-x
        x.or[x.or<=cf]<-0
        x.or[x.or>cf]<-1

        if(test=="regression"){
            f<-paste("as.factor(groups) ~ ",paste(c("x.or",envs),collapse="+"))
            if("x" %in% envs) stop("ARGGGHH")
            if("groups" %in% envs) stop("ARGGHH")
            fit<-glm(as.formula(f),family=binomial(logit),data=ca)
        }
        else{
            fit<-glm(as.factor(groups) ~ x.or,family=binomial(logit))
        }



        or<-1/exp(coef(fit)[2])

        tmp<-confint(fit)

        confint<-1/as.numeric(exp(confint(fit)[2,]))

        lci<-confint[2]
        uci<-confint[1]
                                        #	      or<-oddsratioWald.proc(x.adj,groups)

        
        formula<-""	      

        p<-1
        if(test=="randomForest"){
                                        # random forest
            rf<-randomForest(as.factor(groups)~x.adj,importance=T,proximity=F,ntree=10000,mtry=20)
            im<-as.data.frame(importance(rf))
            p<-im$MeanDecreaseAccuracy

        }
        else if(test=="ttest"){
            p<-t.test(xA,xB)$p.value
        }
        else if(test=="nestedanova"){
            a<-aov(x ~ as.factor(groups)/as.factor(nested.groups))
            p<-as.numeric(unlist(summary(a))[13])
            formula<-paste("Group: Primary Group; Nested Group: Secondary Group")
        }
        else if(test=="rank"){
            p<-wilcox.test(xA,xB)$p.value
        }
        else if (test=="regression"){
            f<-paste("as.factor(groups) ~",paste(c("x",envs),collapse="+"))
            fit<- glm(as.formula(f),data=ca,family=binomial(logit))
            formula<-paste("Regression model:",.replace.group(groupBy),"~",paste(c("x",envs),collapse="+"))

            s<-summary(fit)
            p<-s$coefficients[2,4]
        }
        else if(test =="bayes") p<- 2

        else{
            stop("unknown test ",test)
        }
        
        delta<-abs(meanA - meanB) / ( (sd(xA) + sd(xB)) / 2)

        fc<-meanA/meanB

        result<-rbind(result,data.frame(Taxa=t,P=p,FDR=1,BH=1,Bonferroni=1,
                                        AUC=auc,
                                        AUC.LowerCI=ci[1],
                                        AUC.UpperCI=ci[3],                      
                                        OR=or,
                                        LowerCI=lci,
                                        UpperCI=uci,                            
                                        Delta=delta,FoldChange=fc))

    }
    result<-result[-1,]

    
    if(test=="bayes"){
        groups<-ca$group
        gn<-length(unique(ca$group))
        taxa<-c.taxa(cal)

        ga<-unique(groups)[1]
        gb<-unique(groups)[2]
        gan<-sum(groups==ga)
        gbn<-sum(groups==gb)
        matrix<-ca[,taxa]
        matrix<-t(matrix)

        ws<-101
        if(dim(matrix)[1] < 101) ws<-dim(matrix)[1] - 10
        if(ws <= 3) ws<-dim(matrix)[1] - 1
        if(ws %% 2 == 0) ws<- ws - 1

        bt<-bayesT(matrix,numC=gan,numE=gbn,winSize=ws)
        p<-as.data.frame(bt)$pVal
        result$P<-p
    }

    if(invertGroups){
        result$OR<-1/result$OR
        tmp<-result$UpperCI
        result$UpperCI<-1/result$LowerCI
        result$LowerCI<-1/tmp
        result$Delta<-1/result$Delta
        result$FoldChange<-1/result$FoldChange
    }

    if(test=="randomForest"){
        names<-names(result)
        names[names=="P"]<-"MeanDecreasingAccuracy"
        names(result)<-names
        result$FDR<-NULL
        result$BH<-NULL
        result$Bonferroni<-NULL
    }
    else{
	result$FDR<-p.adjust(result$P,method="fdr")
	result$BH<-p.adjust(result$P,method="hochberg")
	result$Bonferroni<-p.adjust(result$P)
    }

    if((! test=="randomForest") & ! missing(orFile)){
	tmp<-result

	tmp<-tmp[!is.na(tmp$OR),]
	tmp<-tmp[!is.na(tmp$LowerCI),]
	tmp<-tmp[!is.na(tmp$UpperCI),]

        tmp<-tmp[order(tmp$P),]

	if(dim(tmp)[1] > 30) tmp<-tmp[1:30,]
	
	x<-log10(tmp$OR)
	lb<-log10(tmp$LowerCI)
	ub<-log10(tmp$UpperCI)

        
	maxOR<-floor(max(max(x,na.rm=T),-2) + 2)
	minOR<-ceiling(min(min(x,na.rm=T),2) - 2)
	size<-(maxOR-minOR)
	xlim<-c(minOR-1.5*size,maxOR+0.7*size)

	alim<-c(minOR,maxOR)
	ilab.xpos<-c(minOR-0.65*size,minOR-0.4*size,minOR-0.15*size)

        if(invertGroups) title<-paste0("OddsRatio ",groupB,"/",groupA)
        else             title<-paste0("OddsRatio ",groupA,"/",groupB)
        title<-paste0(title,"\n","Top 30 biomarker candidates\n"
                     ,formula)

        png(orFile,res=300,width=200,height=200)
        forest(x=x,ci.lb=lb,ci.ub=ub,slab=tmp$Taxa,refline=0,xlim=xlim,
               alim=alim,
               ilab=cbind(format(signif(tmp$P,2)),format(signif(tmp$FDR,2)),signif(tmp$AUC,2)),
               ilab.xpos=ilab.xpos
              ,cex=0.7,xlab="log10(OR)",at=-100:100,main=title,cex.main=0.9)


	hy<-dim(tmp)[1] + 2
	par<-par(font=2)
                                        #	la<-paste(signif(tmp$OR,2)," [",signif(tmp$LowerCI,2),", ",signif(tmp$UpperCI,2),"]")
                                        #	text(x=maxOR+0.15*size,y=1:length(la),la,pos=4,cex=0.7)

	text(ilab.xpos,hy,c("P","FDR","AUC",""),cex=0.7)
        
	text(xlim[2],hy, "Log10 Odds ratio [95% CI]", pos=2,cex=0.7)

	dev.off()
	par(par)
    }

    if((! test=="randomForest") & ! missing(histFile)){
        pHist(result$P,histFile)
    }

    tmp<-result

    result$AUC<-format(result$AUC,scientific=F,digits=2)
    result$AUC.UpperCI<-format(result$AUC.UpperCI,scientific=F,digits=2)
    result$AUC.LowerCI<-format(result$AUC.LowerCI,scientific=F,digits=2)

    result$UpperCI<-format(round(result$UpperCI,2),scientific=F)
    result$LowerCI<-format(round(result$LowerCI,2),scientific=F)

    result[,paste("Mean",groupA)]<-format(round(meanA.c,2),scientific=F)
    result[,paste("Mean",groupB)]<-format(round(meanB.c,2),scientific=F)

    if(test!="randomForest"){
	result$FDR<-format(signif(result$FDR,2),scientific=F)
	result$BH<-format(signif(result$BH,2),scientific=F)
	result$P<-format(signif(result$P,2),scientific=F)
	result$Bonferroni<-format(signif(result$Bonferroni,2),scientific=F)
    }

    result$Delta<-round(result$Delta,2)
    result$FoldChange<-round(result$FoldChange,2)

    result$OR<-round(result$OR,2)
    result$OR<-format(result$OR,digits=2,scientific=F)
    names<-names(result)
    if(invertGroups) names[names=="OR"]<-paste0("OddsRatio ",groupB,"/",groupA)
    else names[names=="OR"]<-paste0("OddsRatio ",groupA,"/",groupB)

    names(result)<-names

    write.csv(result,file=out,quote=F,row.names=F)
    return(tmp)
}



distByGroup<-function(dist,groups,gA,gB){

                                        # get all samples for groupA
    tA<-taxaIndByGroup(groups,gA)

                                        # get all samples of groupB
    tB<-taxaIndByGroup(groups,gB)

    d.all<-c()

                                        # loop over samples in groupA
    for(t.a in tA){
                                        # loop over samples in groupB
        for(t.b in tB){
            if(t.b == t.a){
                next
            }
            d<-dist[t.a,t.b]
            d.all<-c(d.all,d)
        }
    }
    return(d.all)
}

distWrapper<-function(matrix,method="jaccard",upper=T,diag=T,type="distance"){
    
    di<-1
    
    if(type=="distance"){
	if(any(matrix<0,na.rm=T)){
            if(! method %in% c("inv-pearson","inv-spearmain","categorical","euclidian","manhattan","chao")) method="inv-pearson"
	}


        if((method == "inv-pearson") | (method == "inv-spearman")){
            
            met<-"pearson"
            if(method == "inv-spearman"){
                met<-"spearman"
            }
            di<- (1 - cor(t(as.matrix(matrix)),method=met))/2
            di<-as.dist(di,upper=upper,diag=diag)
        }
        else if(method == "yueclayton"){

            matrix<-matrix/100

            labels<-rownames(matrix)

            lN<-length(labels)
            di<-matrix(nrow=lN,ncol=lN)

            nc<-dim(matrix)[2]
            for(i in 1:(lN-1)){
                for(j in (i+1):lN){
                    av<-matrix[i,]
                    bv<-matrix[j,]

                    d<- 1 - ( sum(av * bv) / ( sum( (av-bv)^2 ) + sum(av*bv)  ) )

                    if(d > 1) stop(paste("ARRGGGGHH d",d))
                    if(d < 0) stop("ARRGGGGHH d",d)
                    di[i,j]<-d
                    di[j,i]<-d
                }
            }
            
            diag(di)<-0
            rownames(di)<-labels
            colnames(di)<-labels
            di<-as.dist(di,upper=upper,diag=diag)

            return(di)

            
        }
        else if(method == "categorical"){
            labels<-rownames(matrix)

            lN<-length(labels)
            di<-matrix(nrow=lN,ncol=lN)

            no<-dim(matrix)[2]
            for(i in 1:(lN-1)){
                for(j in (i+1):lN){
                    d<-sum(matrix[i,] != matrix[j,]) / no
                    if(d > 1) stop(paste("ARRGGGGHH d",d,no))
                    if(d < 0) stop("ARRGGGGHH d")
                    di[i,j]<-d
                    di[j,i]<-d
                }
            }
            
            diag(di)<-0
            rownames(di)<-labels
            colnames(di)<-labels
            di<-as.dist(di,upper=upper,diag=diag)
            return(di)
        }
        else{
            di<-vegdist(matrix,diag=diag,upper=upper,method=method,na.rm=T)
        }    
    }
    else if(type == "diversity"){

        div<-getDiv(matrix,index=method)      

        labels<-names(div)
        lN<-length(labels)
        di<-matrix(nrow=lN,ncol=lN)
        
        for(i in 1:(lN-1)){
            for(j in (i + 1):lN){
                d<-abs(div[i] - div[j])
                di[i,j]<-d
                di[j,i]<-d
            }
        }
        diag(di)<-0
        rownames(di)<-labels
        colnames(di)<-labels
    }
    else{
        stop(paste("ERROR, unknown type",type))
    }

    return(di)
}


correlation<-function(cal,outFile,color="heat",title="",width=600,height=600,res=75,
                      type="dendro",minSim=0.5,vSize=5,method="pearson",lbd=T,orderBy=NA,avoidOverlap=T,corMatrix=NA,layoutMatrix=NA,abundanceMatrix=NA,
                      figureFormat="png",grid=c(4,3)){
    
    bg<-color
    if(! bg %in% c("white","black") ) bg<-"black"

    m<-calypso2matrix(cal)
    
    df<-matrix2dfcompact(m)
    taxa<-m$taxa
    dfc<-df[,taxa]
    
    m.c<-cor(dfc,method=method)

    if(! is.na(corMatrix)){
        m.tmp<-m.c
                                        #     m.tmp[abs(m.tmp) < minSim] <- 0
        write.csv(file=corMatrix,m.tmp,quote=F,row.names=T)   
    }

    if(! is.na(abundanceMatrix)){
        am<-apply(c.counts(cal),2,mean)   
        write.csv(file=abundanceMatrix,am,quote=F,row.names=T)   
    }
    
    if(is.na(outFile) & is.na(layoutMatrix)){
        return(1)
    }
    
    dev.off<-F

    if(type %in% c("graph","graph+","som+","som")){
        if(type %in% c("som+","som")) bg<-"white"

        if(figureFormat == "png"){
            png(outFile,width=width,height=height,res=res,units="mm",bg=bg)
            dev.off<-T
        }
        else if(figureFormat == "pdf"){
            pdf(outFile,width=width,height=height,bg=bg)
            dev.off<-T
        }
        else if(figureFormat == "svg"){
            svg(outFile,width=width,height=height,bg=bg)
            dev.off<-T
        }

        freq<-as.numeric(apply(dfc,2,mean))
        
        if(type %in% c("graph+","som+","som")) parnet(cal,legend=T,min.sim=minSim,labels=T,vSize=vSize,keep.isolates=T,
                                                      ctype=bg,layoutByDist=lbd, avoidOverlap=avoidOverlap,method=method,layoutMatrix=layoutMatrix,type=type,grid=grid,
                                                      corMatrix=corMatrix)
        else correlation.network(m.c,legend=T,min.sim=minSim,labels=T,title=title,keep.isolates=F,vSize=vSize,ctype="black",freq=freq,
                                 adjustVldist=F,layoutByDist=lbd,avoidOverlap=avoidOverlap,layoutMatrix=layoutMatrix)
    }else{
        if(figureFormat == "png"){
            png(outFile,width=width,height=height,res=res,units="mm",bg="white")
	    dev.off<-T
        }
        else if(figureFormat == "pdf"){
            pdf(outFile,width=width,height=height,bg="white")
	    dev.off<-T
        }
        else if(figureFormat == "svg"){
            svg(outFile,width=width,height=height,bg="white")
	    dev.off<-T
        }
        col<-getColors(color,80)
        heatmap.2(m.c, Rowv=T, Colv=T, dendrogram="both",symm=T,scale="none",col=col,trace="none",symbreaks=T,cexRow=0.9,cexCol=0.9,main=title,margins=c(12,12))
    }
    if(dev.off){
        dev.off()
    }
}



distance.helper<- function(dist,groups){
    gN<-length(groups)

                                        # generate data-frame of pair-wise distances        
    nrow<-sum(1:(gN-1))
    d.sum<-data.frame(matrix(ncol=4,nrow=nrow))
                                        #  d.sum<-data.frame(gA="del",gB="del",dist=-1,same=-1)
                                        #        d.sum<-d.sum[-1,]

    names(d.sum)<-c("gA","gB","dist","same")

    ri<-0
    
    for(i in 1:(gN-1)){
        
                                        #	first group
        gA<-groups[i]
        
                                        # loop over all samples
        for(j in (i+1):gN){
            
                                        # get second group
            gB<-groups[j]
            
                                        # get intra group distance for second group
            d<-dist[i,j]

            same<-1
            if(gA != gB){
                same<-0
            }
            ri<-ri + 1
            d.sum[ri,]<-c(gA,gB,d,same)
                                        #            new <- data.frame(gA=gA,gB=gB,dist=d,same=same)
                                        #            d.sum<-rbind(d.sum,new)
        }
    }

    d.sum$dist<-as.numeric(d.sum$dist)
    
    if(! ri == nrow){
        stop("ARGGGHHH")
    }
    
    return(d.sum)
}


distance.helper.backup <- function(dist,groups){
    gN<-length(groups)

                                        # generate data-frame of pair-wise distances        
    d.sum<-data.frame(gA="del",gB="del",dist=-1,same=-1)
    d.sum<-d.sum[-1,]
    for(i in 1:(gN-1)){
        
                                        #	first group
        gA<-groups[i]
        
                                        # loop over all samples
        for(j in (i+1):gN){
            
                                        # get second group
            gB<-groups[j]
            
                                        # get intra group distance for second group
            d<-dist[i,j]

            same<-1
            if(gA != gB){
                same<-0
            }
            
            new <- data.frame(gA=gA,gB=gB,dist=d,same=same)
            d.sum<-rbind(d.sum,new)
        }
    }
    return(d.sum)
}

multivariat<-function(cal,plotFile,type="pcoa",color="heat",method="jaccard",title="",loadings=T,labels=T,width=600,height=600,res=300,components=c(1,2),scale=F,legend=T,colorlegend=F,groupSymbols=T,minSim=0.9,vSize=30,groupBy="group",ccaTableFile=NULL,figureFormat="png",hull="ellipse",symbolBy=NULL){
    require(vegan)
    
    if(figureFormat=="pdf"){
        pdf(plotFile,width=width,height=height)
    }
    else if(figureFormat=="svg"){
        svg(plotFile,width=width,height=height)
    }
    else{
        png(plotFile,width=width,height=height,res=res,units="mm")
    }


    if(type == "heatmap"){
        distHeatmap(cal,color,method,title,scale=scale)
    }
    else if(type == "pls"){
        c.pls(cal)
    }
    else if(type == "svm"){
        c.svm(cal,groupBy=groupBy)
    }
    else if(type == "envheatmap"){
        envTaxaCorMatrix(cal,col=color)
    }
    else if(type %in% c("cca","ccap")){
        doCcaPCA(cal,type=type,components=components,scale=F,title=title,labels=labels,loadings=loadings,legend=legend,colorlegend=colorlegend,color=color,groupSymbols=groupSymbols,ccaTableFile=ccaTableFile,groupBy=groupBy,hull=hull)
    }
    else if(type == "dapc"){
        c.dapc(cal,title=tile,labels=labels,color=color,groupBy=groupBy)
    }
    else if(type %in% c("rda","dca","metaMDS","rdap","rdaF","ccaF")){
        doCcaPCA(cal,type=type,components=components,scale=F,title=title,labels=labels,loadings=loadings,legend=legend,colorlegend=colorlegend,color=color,groupSymbols=groupSymbols,ccaTableFile=ccaTableFile,groupBy=groupBy,hull=hull)
    }
    else if (type == "pcoa"){
        doPCOA(cal,method,title,scale=scale,labels=labels,legend=legend,colorlegend=colorlegend,color=color,groupSymbols=groupSymbols,colorBy=groupBy,components=components,symbolBy=symbolBy)
    }
    else if (type == "lda"){
        if(groupBy != "group"){
            cal<-c.setGroups(cal,groupBy=groupBy,color=color)
        }
        doLDA(cal,color,title=title,loadings=loadings)
    }
    else if (type %in% c("dendro","dendrop")){
        doDendro(cal,title,method=method,scale=scale,color=color,legend=legend,type=type)
    }
    else if(type == "graph"){
        cal<-c.setGroups(cal,groupBy=groupBy,color=color)
        colors<-c.colors(cal)
        groups<-c.groups(cal)


        d<-1

        if(method=="distFile") d<-as.dist(c.distanceMatrix(cal),diag=T,
               upper=T)
        else{
            data<-c.counts(cal)
            if(scale) data<-scale(data)
            
            d<-distWrapper(as.matrix(data),diag=T,upper=T,method=method)
        }


        d.m<-as.matrix(d)
        
                                        #scale d to range 0-1
        d.m<-d.m/max(abs(d.m))
        sim<-1-d.m

                                        # check if abs(sim) == sim
        l<-length(which(abs(sim) == sim))
        if(! (l == dim(sim)[1] * dim(sim)[2])){
            stop("ERROR length")
        }    
        
        correlation.network(sim,legend=legend,min.sim=minSim,labels=labels,title=title,colors=colors,
                            groups=c.legendLabels(cal),vSize=vSize,layoutByDist=T)
    }


    else if (type == "pcao"){
        doCcaPCA(cal,type="pcao",components=components,scale=scale,title=title,
                 labels=labels,legend=legend,groupBy=groupBy,hull=hull)
    }

    else if (type %in% c("pca","pcap")){
        doCcaPCA(cal,type=type,labels=labels,loadings=loadings,components=components,
                 scale=scale,title=title,legend=legend,colorlegend=colorlegend,
                 color=color,groupSymbols=groupSymbols,groupBy=groupBy,hull=hull)
    }

    else if(type == "betadisper"){             
        c.betadisper(cal,method=method,groupBy=groupBy)
    }
    else if(type == "anosim"){
        c.anosim(cal,scale=scale,method=method,figureFormat=NA,groupBy=groupBy,color=color)
    }	
    else if(type %in% c("adonis","adonisF","adonis+")){

        at<-"group"
        if(type == "adonisF") at<-"group+"
        else if(type == "adonis+") at<-"env"

        c.adonis(cal,type=at,scale=scale,groupBy=groupBy)
    }
    else{
        stop(paste("Unknown type ",type))
        return(1)
    }
    dev.off()


    return(1)
}


ggdhs<-function(cal,file,height,width,res){
    ca<-c.annotatedCounts(cal)
    groups<-unique(ca$group)
    gN<-length(groups)

    m<-matrix(ncol=gN,nrow=gN)
    rownames(m)<-groups
    colnames(m)<-groups

    taxa<-c.taxa(cal)
    
    for(i in 1:(gN - 1)){
        gi<-groups[i]
        for(j in (i+1):gN){
            gj<-groups[j]

            vi<-as.numeric(apply(ca[ca$group==gi,taxa],2,sum))
            vj<-as.numeric(apply(ca[ca$group==gj,taxa],2,sum))

            tab<-rbind(vi,vj)
            tab<-tab[,apply(tab,2,sum)>0]
            
            p<-chisq.test(tab)$p.value
            m[i,j]<-p
        }
    }

    
    m<-subset(m,subset=c(rep(T,gN-1),F))

    
    width<-(160 + gN * 20)
    height<-(120 + gN * 20) / 2
    png(file,width=width,height=height)
    textplot(m)
    title(paste("P-Values that composition is different on whole community level\n(intra group distances < inter group distances),"))
    dev.off()
    return(1)
}

global.group.difference<-function(cal,statsFile,distFile,corFile,
                                  method="jaccard",title="",width=600,
                                  height=600,res=300,scale=F,groupBy="group",
                                  chis=F){
    
    require(vegan)

    cal<-c.setGroups(cal,groupBy=groupBy)

    if(chis) return(ggdhs(cal,statsFile,height,width,res))
    
    
    counts<-c.annotatedCounts(cal,orderBy="GST")
    counts<-counts[!is.na(counts$group),]
    taxa<-c.taxa(cal)
    cal<-NULL
    
    groups<-counts$group
    counts<-counts[,taxa]

    if(scale) counts<-scale(counts)

    print(head(counts))
    
                                        # get distance matrix
    dist<-as.matrix(distWrapper(counts,diag=T,upper=T,method=method))

    gN<-length(groups)

    d.sum<-distance.helper(dist,groups)

                                        # test if inter group differences are sign. differnt
                                        # from intra group differences
                                        # loop over all samples
    groups.u<-unique(groups)
    ugN<-length(groups.u)

    d.mp<-matrix(nrow=ugN,ncol=ugN)

    for(i in 1:(ugN-1)){
        gA<-groups.u[i]
        for(j in (i+1):ugN){
            gB<-groups.u[j]
            int<-d.sum[d.sum$same ==1,]
            
            intra<-c(int[int$gA == gA,]$dist,int[int$gA==gB,]$dist)

            inter<-c(d.sum[d.sum$gA == gA & d.sum$gB == gB,]$dist,
                     d.sum[d.sum$gA == gB & d.sum$gB == gA,]$dist)
            
	    p<-1
            if(is.null(intra)){
                p<-1
            }
            else{
                if(length(intra) > 0) p<-wilcox.test(intra,inter,alternative="less")$p.value
            }
            d.mp[i,j]<-signif(p,2)
        }
    }

    d.mp<-as.data.frame(d.mp)
    names(d.mp)<-unique(groups)
    rownames(d.mp)<-unique(groups)
    
    if(ugN > 2){
        d.mp<-d.mp[,-1]
    }
    
    d.mp<-d.mp[-ugN,]
    
                                        # @@@
    width<-(160 + ugN * 20)
    height<-(120 + ugN * 20) / 2
    png(statsFile,width=width,height=height)
    textplot(signif(d.mp,2))
    title(paste("P-Values that composition is different on whole community level\n(intra group distances < inter group distances),",title))
    dev.off()

################################
                                        # pairwise median distance
################################
    d.md<-matrix(nrow=ugN,ncol=ugN)
    d.mdv<-matrix(nrow=ugN,ncol=ugN)

    for(i in 1:(ugN)){
        gA<-groups.u[i]

        for(j in 1:ugN){
            gB<-groups.u[j]

            d.AB<-1

            if(gA == gB){
                d.AB<-d.sum[d.sum$gA == gA & d.sum$gB == gA,]$dist
            }
            else{                
                d.AB<-c(d.sum[d.sum$gA == gA & d.sum$gB == gB,]$dist,
                        d.sum[d.sum$gA == gB & d.sum$gB == gA,]$dist)
            }
            
            d.md[i,j]<-round(mean(d.AB),5)
            d.mdv[i,j]<-round(var(d.AB),5)
        }
    }
    d.md<-as.data.frame(d.md)
    names(d.md)<-groups.u
    rownames(d.md)<-groups.u        

    d.mdv<-as.data.frame(d.mdv)
    names(d.mdv)<-groups.u
    rownames(d.mdv)<-groups.u

    
    width<-160 + ugN * 20
    height<-120 + ugN * 20
    png(distFile,width=width,height=height)
    layout(matrix(c(1,2), 2, 1, byrow = TRUE))
    textplot(round(d.md,2))
    title(paste("Pairwise median distances",title))
    textplot(signif(d.mdv,2))
    title("Variance")
    dev.off()

################
                                        # get pairwise pearson correlation
################
    dist.cor<-as.matrix(distWrapper(counts,diag=T,upper=T,method="inv-pearson"))

    d.sum<-distance.helper(dist.cor,groups)
    
                                        # pairwise pearson correlation
    d.m<-matrix(nrow=ugN,ncol=ugN)
    d.mv<-matrix(nrow=ugN,ncol=ugN)

    
    for(i in 1:(ugN)){
        gA<-groups.u[i]
        
        for(j in 1:ugN){
            gB<-groups.u[j]
            
            if(gA == gB){
                d.AB<-d.sum[d.sum$gA == gA & d.sum$gB == gA,]$dist
            }
            else{                
                d.AB<-c(d.sum[d.sum$gA == gA & d.sum$gB == gB,]$dist,
                        d.sum[d.sum$gA == gB & d.sum$gB == gA,]$dist)
            }

            d.m[i,j]<-round(mean(1-d.AB),5)
            d.mv[i,j]<-round(var(1-d.AB),5)
        }
    }

    
                                        # pairwise median pearson correlation
    d.m<-as.data.frame(d.m)
    names(d.m)<-groups.u
    rownames(d.m)<-groups.u

    d.mv<-as.data.frame(d.mv)
    names(d.mv)<-groups.u
    rownames(d.mv)<-groups.u


    width<-120 + ugN * 20
    height<-120 + ugN * 20
    png(corFile,width=width,height=height)
    layout(matrix(c(1,2), 2, 1, byrow = TRUE))
    textplot(round(d.m,2))
    title("Pairwise median Pearson correlation")
    textplot(signif(d.mv,2))
    title("Variance")
    dev.off()

    return(list(d.m=d.m,d.md=d.md,d.mp=d.mp))
}


distHeatmap<-function(cal,color="heat",method="jaccard",title="",scale=F){
    require(vegan)


    di<-1
    if(method=="distFile") di<-as.matrix(c.distanceMatrix(cal))
    else{
        counts<-c.counts(cal)

        if(scale){
            counts<-scale(counts)
        }

        di<-as.matrix((distWrapper(counts,diag=T,upper=T,method=method)))
    }
        
    col<-getColors(color,80)

    heatmap.2(di,Colv=F,Rowv=F,margins=c(10,10),symm=T,scale="none",dendrogram="none",trace="none",symbreaks=F,col=rev(col),main=title)

    return(1)
}

doLDA<-function(cal,color="default",title="",loadings=T){
    require(MASS)

    if(loadings) warning("Loadings is deprecated!!!")
    loadings<-F
    
    counts<-c.counts(cal)
    groups<-c.groups(cal)

    l<-lda(counts,groups)
    gN<-length(unique(groups))

    colors<-c.colors(cal)

    if(gN < 3){
        colors<-colors[1]
    }


    if(gN < 3){
	plot(l,col=colors,dimen=2,main=paste("LDA",title))
    }
    else{
                                        # get plot dimensions
	plot(l,dimen=2)
	lim<-par("usr")

                                        #	plot(l,col=colors,dimen=2,main="LDA",xlim=c(-70,70),ylim=c(-70,70))
        plot(l,col=colors,dimen=2,main=paste("LDA",title))
        
	if(loadings){
            xv<-l$scaling[,1]
            yv<-l$scaling[,2]
            
            xrange<-range(xv)
            yrange<-range(yv)

            if(xrange[1] < lim[1]) xv<-xv * (lim[1] / xrange[1])
            if(range(xv)[2] > lim[2]) xv<-xv * (lim[2] / range(xv)[2])

            if(yrange[1] < lim[3]) yv<-yv * (lim[3] / yrange[1])
            if(range(yv)[2] > lim[4]) yv<-yv * (lim[4] / range(yv)[2])

            xv<-xv * 0.9
            yv <- yv * 0.9
            
            text(xv,yv,labels=rownames(l$scaling),cex=0.8)

        }
    }
    return(l)
}



doCcaPCA<-function(cal,type="cca",loadings=F,labels=F,components=c(1,2),
                   scale=F,title="",legend=T,colorlegend=F,
                   color="bluered",groupSymbols=T,ccaTableFile=NULL,groupBy="group",
                   hull="ellipseF"){



    if(type == "metaMDS" ){
        components<-c(1,2)
    }

    cal<-setColorsAndSymbols(cal,colorBy=groupBy,color=color)


    ac<-1
    ac<-c.annotatedCounts(cal)
    
    ac$colorGroup<-c.groups(cal,groupBy=groupBy)
    ac$secondaryGroup<-ac$time

    taxa<-c.taxa(cal)

         envs<-c.environment.vars(cal)
    
    if(type %in% c("dca","cca","ccap")){
        ac<-ac[ac$total>0,]
    }

    if(type %in% c("ccap","rdap")){
        for(na in names(ac)) if(all(is.na(ac[,na]))) ac[,na] <- NULL
        ac<-na.omit(ac)
        envs<-envs[envs %in% names(ac)]
        taxa<-taxa[taxa%in%names(ac)]
    }
  
    if(dim(ac)[1]==0){
            errm<-"ERROR: empty data matrix after removing rows with undefined values"
            warning(errm)
            textplot(errm)
            return(-1)
    }
    
    ac$time<-NULL
    if(groupBy=="time") groupBy<-"secondaryGroup"

    counts<-ac[,taxa]

    if(type == "dca" ){
        if(min(counts,na.rm=T)<0){
            errm<-"ERROR: data values must not be < 0 for DCA and DCA+"
            warning(errm)
            textplot(errm)
            return(-1)
            
        }
    }

    if(scale){
        counts<-scale(counts)
    }
    mod<-1
    oh<-TRUE
    
    ti<-""
    pC<-F

    
    if(legend){
        layout(matrix(c(1,2), 1, 2, byrow = TRUE),widths=c(1.8,1) )
    }

    if(type %in% c("pca","pcap")){
        mod<-rda(counts,scale=FALSE,na.action="na.omit")
        oh<-FALSE
        ti<-"PCA"
    }
    else if(type == "metaMDS" ){
        mod<-metaMDS(counts)
        oh<-FALSE
        ti<-"NMDS"
    }
    else if(type == "dca" ){
        mod<-decorana(counts)
        oh<-FALSE
        ti<-"DCA"
    }

    else if(type == "pcao"){
        mod<-rda(counts,scale=FALSE)
        ti<-"PCA"
    }
    
    else if(type %in% c("cca","ccap","rda","rdap","ccaF","rdaF")){

        ac$Group<-as.factor(ac$group)
        ac$SecondaryGroup<-as.factor(ac$secondaryGroup)
        ac$Pair<-as.factor(ac$pair)
        
        vars<-paste(envs,collapse=" + ")

        for(v in envs){
            if(! is.numeric(ac[,v])){
                ac[,v]<-as.factor(ac[,v])
            }
        }

        f<-1
        if(type == "ccap" | type == "rdap"){
            f<-paste("counts.global.cca ~ ",paste(vars,sep=" + "))
        }
        else if(type == "ccaF" | type == "rdaF"){
            f<-"counts.global.cca ~ Group + SecondaryGroup + Pair"
        }
        else{
            f<-paste("counts.global.cca ~ ",groupBy)
        }

        f<-as.formula(f)

        assign("ac.global.cca",ac,inherits=T)
        assign("counts.global.cca",counts,inherits=T)


        ti<-"CCA"
        oh<-FALSE
        pC<-F

        if(type == "rda" | type == "rdap" | type == "rdaF"){
            ti<-"RDA"
            mod<-rda(f,data=ac.global.cca,scale=T,na.action="na.omit")
        }
        else{
            mod<-cca(f,data=ac.global.cca,scale=T,na.action="na.omit")
        }

        if(! is.null(ccaTableFile)){
            png(ccaTableFile,res=200,width=180,height=180,units="mm")
            a<-anova.cca(mod,by="term",perm=2000,perm.max=99999999999)
            dma<-data.matrix(a)
            dma<-signif(dma,4)

            dma<-as.data.frame(dma)

            dma$"Signif"<-""

            dma<-dma[,c("Pr(>F)","Signif")]

            dma<-dma[1:(dim(dma)[1]-1),]

            names(dma)[1]<-"P"      


            dma[(!is.na(dma$P)) & dma$P<=0.05,"Signif"]<-"*"
            dma[(!is.na(dma$P)) & dma$P<=0.01,"Signif"]<-"**"
            dma[(!is.na(dma$P)) & dma$P<=0.001,"Signif"]<-"***"

            textplot(dma)
            title(ti)
            dev.off()
        }
    }
    else{
        stop("unknown type")
        return()
    }

    title=paste(ti,title)
    
    symbols<-16
    
    if(groupSymbols){
        symbols<-ac$symbols
    }

    ploto<-1
    xlim<-1
    ylim<-1
    if(type %in% c("pca","pcap","rda","rdap","cca","ccap")){

        s<-summary(mod)

        if(! dim(s$cont$importance)[1] == 3) stop("ERROR: wrong dimension")

        vpcx<-paste(round(s$cont$importance[2,components[1]] * 100,0),"%",sep="")
        nx<-names(s$cont$importance[1,])[components[1]]
        vpcy<-paste(round(s$cont$importance[2,components[2]] * 100,0),"%",sep="")
        ny<-names(s$cont$importance[1,])[components[2]]
        
        
        xlab<-paste(nx," (",vpcx,")",sep="")
        ylab<-paste(ny," (",vpcy,")",sep="")

        print("plotting model type none")
        ploto<-plot(mod,type="none",choices=components,main=title,xlab=xlab,ylab=ylab)

        xv<-c(ploto$species[,1],ploto$sites[,1])
        yv<-c(ploto$species[,2],ploto$sites[,2])
        xlim<-1.2*range(xv)
        ylim<-1.2*range(yv)
        frame()

        print("plotting model none")
        ploto<-plot(mod,type="none",xlim=xlim,ylim=ylim,choices=components,main=title,xlab=xlab,ylab=ylab)
    }
    else{  
        print("empty plot")
                                        # empty plot
        ploto<-plot(mod,type="none",choices=components,main=title)
    }
                                        # plot samples 

    
    if(type %in% c("pcap")){
        ac$g<-as.factor(ac$group)
        ac$t<-as.factor(ac$secondaryGroup)
        ac$p<-as.factor(ac$pair)

        for(v in envs){
            if(! is.numeric(ac[,v])){
                ac[,v]<-as.factor(ac[,v])
            }
        }
        
        vars<-paste(envs,collapse=" + ")
        fo<-paste("mod ~ ",vars,sep=" + ")
        fo<-as.formula(fo)
        mod.fit<-envfit(fo, data=ac,perm=1000,choices=components,na.rm=T)
        plot(mod.fit)
    }

    if(type %in% c("pca","rda","dca","metaMDS","pcap") ){
        points(mod,display="sites",col=ac$color,pch=ac$symbol,choices=components)

        if(labels){
            text(mod,display="sites",col=ac$color,cex=0.8,pos=3,choices=components)
        }
    }
    
    else if(labels){
        text(mod,display="sites",col=ac$color,cex=0.8,choices=components)
    }
    else{
        points(mod,display="sites",col=ac$color,pch=ac$symbol,choices=components)
    }


    if(loadings){
                                        # plot the 10 most different loadings

        sdf<-as.data.frame(ploto$species)
        nS<-min(10,dim(sdf)[1])
        max.diff.species<-names(sort(apply(abs(sdf),1,max),decreasing=T))[1:nS]
        text(ploto$species[max.diff.species,],labels=rownames(ploto$species[max.diff.species,]),cex=0.8,col="black") #rgb(0.6,0.2,0.2))
    }
                                        # plot constraining variables

    if(type %in% c("rdap","ccap")) pC<-F

    if(pC){
        text(mod,col=rgb(0.2,0.2,0.8),display="cn",cex=0.9,choices=components)
                                        #    text(mod,arrow.mul=10,col="black",display="cn",cex=0.9,choices=components)
                                        #    sc<-scores(mod,display="bp",choices=components)
                                        #    text(sc,labels=rownames(sc))
                                        #    points(sc)
                                        #    warning(scores(mod,col="black",display="cn",cex=0.9,choices=components))
    }



    if(hull != "none"){
        draw<-"lines"	 	  

        if(hull %in% c("ellipseF","hullF","spiderF")) draw<-"polygon"
        
        gtmp<-ac$colorGroup

        og<-unique(gtmp)
        if(is.factor(og)){
            og<-as.character.factor(og)
        }
        oc<-unique(ac$color)
        for(i in 1:length(og)){	
            ci<-oc[i]
            gi<-og[i]



            if(grepl("spider",hull)) ordispider(mod, gtmp, col=ci, show.groups=c(gi),label = F,choices=components) 
            if(hull=="cluster") ordicluster(mod,hclust(vegdist(counts)),col="blue",prune=3)
            else if(grepl("ellipse",hull)) ordiellipse(mod, gtmp, col=ci, show.groups=c(gi),label = F,choices=components,draw=draw,alpha=40)    
            else ordihull(mod, gtmp, col=ci, show.groups=c(gi),label = F,choices=components,draw=draw,alpha=40,lty=2)
            
        }

    }

    

    if(colorlegend){
        require(shape)
        mi<-min(as.integer(ac$group))
        ma<-max(as.integer(ac$group))
        colorlegend(col=getColors(color,20),zlim=c(mi,ma),zval=c(mi,ma))
    }
    
    if(legend){
        frame()
        label<-as.character(unique(ac$legendLabel))
        ord<-order(label)
        label<-label[ord]
        
        legend("left", legend=label, lty = 0,col=as.character(unique(ac$color))[ord],pch=unique(ac$symbol)[ord],cex=0.9)
    }

    print("returning")
    return(1)
}

taxa.barplot<-function(cal,color="heat",beside=F,title="",transpose=F,er="G",orderBy=NA,medianPlot=F,legend=T){

    if(medianPlot) orderBy<-"GST"

    
    ac<-c.annotatedCounts(cal,er=er,orderBy=orderBy,median=medianPlot)

    d<-subset(ac,select=c.taxa(cal))


    names<-colnames(d)

    if(! transpose){
        d<-t(d)
        names<-ac$label
    }

    labels<-rownames(d)

    if(is.null(labels)) stop("ERROR: null labels")
    
    labels.l<-max(nchar(labels))
    
    sN<-dim(d)[2]
    
    main.width<-min(sN / 10,0.6) + 0.5 - 0.007 * labels.l
    
    if(main.width > 0.8){
        main.width<-0.8
    }
    
    if(main.width < 0.4){
        main.width<-0.4
    }


    tN<-length(labels)
    col<-getColors(color,tN,greyEnd=1,sample=T)
    
    par<-1
    if(legend){
	par<-par(fig=c(0,main.width,0.2,0.9),mar=c(10,4,1,2))
    }
    else 	par<-par(fig=c(0,1,0.2,0.9))
    
                                        #	par(xpd=T, mar=par()$mar+c(5,4,1,4))
                                        #par<-par(las=2,mar=c(8, 4, 1, 2) + 0.1)
    
    ylab<-""


    barplot(as.matrix(d),names.arg=names,las=2,col=col,beside=beside,main=title,ylab=ylab)
    
    par(par)
    if(legend) legend("right", legend=rev(labels), cex=0.9, fill=rev(col));
}

getSymbols<-function(n){
    if(n>20) return(rep(16,n))

    sym<-c(16,17,15,18:20,1:14,21:25)
    sym<-c(sym,sym,sym,sym,sym,sym)
    return(sym[1:n])
}

getColors<-function(color,tN,al=1,greyEnd=0.9,sample=F){
    col<-NA
    if(color=="heat") col<-heat.colors(tN,alpha=al)
    else if(color=="heat2") col<-colorpanel(tN,"yellow","black","red")
    else if(color=="heat3") col<-colorpanel(tN,"darkblue","yellow","red")
    else if(color=="lessbright"){
        colors<-c("darkblue","red","gold","grey","purple","green","lightblue","orange","black",
                  "salmon","pink","lightgreen","aquamarine4","yellow","darkred","lightgrey")
        if(tN > length(colors)) warning("WARNING: tN > ",length(colors))
        else col<-colors[1:tN]
    }
    else if(color=="bright"){
        colors<-c("blue","red","yellow","grey","purple","green","lightblue","orange","black",
                  "salmon","pink","lightgreen","aquamarine4","gold")
        if(tN > length(colors)) warning("WARNING: tN > ",length(colors))
        else col<-colors[1:tN]
    }
    else if(color=="black"){
        col<-rep("black",tN)
    }
    else if(color=="rainbow"){
        col<-rainbow(tN,alpha=al)
    }
    else if(color=="bluered"){
        if(tN == 2){
            col<-(c("lightblue","#EE6A50"))
        }
        else{
            col<-colorpanel(tN,"lightblue","white","#EE6A50")
        }

    }
    else if(color=="bluered2"){
        if(tN == 2){
            col<-(c("lightblue","darkred"))
        }
        else{
            col<-colorpanel(tN,"lightblue",rgb(1,1,1),"darkred")
        }
    }
    else if(color=="brb"){
        col<-colorpanel(tN,"lightblue",rgb(0.2,0.2,0.2),rgb(1,0.6,0.6))
    }
    else if(color=="gbr"){
        col<-colorpanel(tN,"green","black","red")
    }
    else if(color=="ybgbr"){
        col<-colorRampPalette(c("yellow","blue", "green","black",
                                "red"))( tN )
    }	
    else if(color=="bluered3"){
        if(tN == 2){
            col<-(c("darkblue","darkred"))
        }
        col<-colorpanel(tN,"darkblue",rgb(1,1,1),"darkred")
    }
    else if(color=="bluered4"){
        if(tN == 2){
            col<-(c("blue","red"))
        }
        else{
            col<-bluered(tN)
        }
                                        #  col<-colorpanel(tN,"lightblue",rgb(1,1,1),"darkred")
    }
    else if(color=="bluered5"){
        if(tN == 2){
            col<-(c("blue","red"))
        }
        else{
            col<-c("white",colorpanel(tN - 1,"lightblue",rgb(0.2,0.2,0.2),rgb(1,0.6,0.6)))
        }
                                        #  col<-colorpanel(tN,"lightblue",rgb(1,1,1),"darkred")
    }
    else if(color=="yellowblue"){
        if(tN == 2){
            col<-(c("yellow","lightblue"))
        }
        else{
            col<-c(colorpanel(tN,
                              "lightblue",rgb(0.2,0.2,0.2),"yellow"))

        }
    }
    else if(color=="blueGoldRed"){
        if(tN == 2) col<-(c("darkblue","darkred"))
        else{
            cn<-as.integer(tN/2)
            col<-c(colorpanel(cn
                             ,"darkblue","lightblue","gold"),
                   colorpanel(tN-cn,"gold","red","darkred"))
        }

    }

    else if(color=="blueYellowRed"){
        if(tN == 2){
            col<-(c("yellow","darkblue"))
        }
        else{
            cn<-as.integer(tN/2)
            col<-c(colorpanel(cn
                             ,"darkblue","lightblue","yellow"),
                   colorpanel(tN-cn,"yellow","red","darkred"))
        }
    }
    else if(color=="yellowblue2"){
        if(tN == 2){
            col<-(c("yellow","lightblue"))
        }
        else{
            col<-c(colorpanel(tN,"darkblue","lightgrey","yellow"))
        }
    }
    else if(color=="redgreen"){
        if(tN == 2){
            col<-(c("red","darkgreen"))
        }
        else{
            col<-redgreen(tN)
        }
    }
    else if(color=="redblack"){
        if(tN==2) col<-c("darkred","black")
        else col<-colorpanel(tN,"red","black")
    }

    else if(color=="greenblack"){
        col<-colorpanel(tN,"green","black")
    }

    else if(color=="redwhite"){
        col<-colorpanel(tN,"red","white")
    }
    else if(color=="bluered6"){
        col<-(colorpanel(tN,"#F0F8FF","#FFEBCD"))
    }

    else if(color=="lb"){
        col<-colorpanel(tN,rgb(0.15,0.15,0.3),"lightblue","white")
    }
    else if(color=="db"){
        col<-colorpanel(tN,rgb(0.1,0.1,0.2),rgb(0.7,0.8,1),"white")
    }
    else if(color=="bgy"){
        col<-topo.colors(tN)
    }
    else if(color=="blue3"){
        col<-colorpanel(tN,"lightblue","white")
                                        #col<-c("lightblue","white")
    }
    else if(color=="green"){
        col<-colorpanel(tN,"lightgreen","darkgreen")
                                        #col<-c("lightblue","white")
    }
    else if(color=="blue4"){
        col<-colorpanel(tN,"lightblue","darkblue")
                                        #col<-c("lightblue","white")
    }
    else if(color=="bw"){
        if(tN == 2){
            col=c(rgb(0.1,0.1,0.1),"white")
        }
        else{
            col<-grey.colors(tN, start = greyEnd, end = 0.05, gamma = 2.2)
        }
    }
    else if(color=="grey"){
        col<-grey.colors(tN, start = greyEnd, end = 0.05, gamma = 2.2)
    }

    if( (length(col) ==1) & is.na(col)){
        col<-c("darkred","darkblue","darkgrey","orange","salmon","black","gold","darkgreen","blue","red","lightblue","pink","#CCFF00FF","#6600FFFF","#0066FFFF","#00FFCCFF","yellow","aquamarine4","green","grey","lightgoldenrod1","orangered","lightsalmon2","tan2")

        if(tN <= length(col)) col<-col[1:tN]
        else col<-col<-c("white",sample(rainbow(tN - 2,alpha=al)),"black")
        

    }

    if(sample){
        col<-sample(col)
    }

    return(col)
}

raref<-function(df){
    dfc<-cleanDFC(df)
    sampleN<-dim(dfc)[1]

    rar<-matrix(data=NA, ncol=sampleN,nrow=length(select))


                                        # loop over each cample
    for(s in 1:sampleN){

    }


}

rarefaction<-function(cal,rank="",width=1000,height=600,res=75,pngFile,groupBy="group"){

    cal<-c.setGroups(cal,groupBy=groupBy)

    if(!missing(pngFile)) png(pngFile,width=width,height=height,res=res,units="mm")

    taxa<-c.taxa(cal)

    if(length(taxa) < 2){
        errm<-"ERROR: less than 2 taxa"
        warning(errm)
        if(! missing(pngFile)) textplot(errm)
    }
    else diversityRAR(cal,index="richness",mode="indiv",main=paste("Rarefaction Analysis",rank))
    if(!missing(pngFile)) dev.off()
    
}

##This function creates true individual based rarefaction curves
###
##Author: Joshua Jacobs   email@joshuajacobs.org  www.joshuajacobs.org/R/rarefaction.html
###
##Usage rarefaction(x,y), x is the community matrix with species as columns
###
rarefaction.deprecated<-function(cal,subsample=5, plot=TRUE, color=TRUE, error=FALSE, legend=TRUE, symbol=c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18),width=1000,height=600,res=75,png=TRUE,file=NA,rank=""){

    library(vegan)

    m<-calypso2matrix(cal)
    df<-matrix2dfcompact(m)
    taxa<-m$taxa
    dfc<-df[,taxa]

    x<-dfc

    x <- as.matrix(x)
    y1<-apply(x, 1, sum)
    rare.data<-x

    select<-unique(sort(c((apply(x, 1, sum)), (seq(0,(max(y1)), by=subsample)), recursive=TRUE)))

    sampleN<-dim(dfc)[1]

    colors<-df$colors
    symbols<-df$symbols

    storesummary.e<-matrix(data=NA, ncol=length(rare.data[,1]),nrow=length(select))
    rownames(storesummary.e)<-c(select)
    colnames(storesummary.e)<-rownames(x)
    storesummary.se<-matrix(data=NA, ncol=length(rare.data[,1]),nrow=length(select))
    rownames(storesummary.se)<-c(select)
    colnames(storesummary.se)<-rownames(x)




    for(i in 1:length(select))                      #the for loop
        {
            select.c<-select[i]                     #assigns the 'i'th element of select to select.c
            foo<-rarefy(x,select.c, se=T)           #use whatever vegan fn you want

            storesummary.e[i,]<-foo[1,]
            storesummary.se[i,]<-foo[2,]

        }

    storesummary.e<-as.data.frame(storesummary.e)
    richness.error<<-storesummary.se

    for (i in 1:(length(storesummary.e)))
        {
            storesummary.e[,i]<-ifelse(select>sum(x[i,]), NA, storesummary.e[,i])
        }



###############plot result################################
    if(png){
	png(file,width=width,height=height,res=res,units="mm")
    }

    if (plot==TRUE)
        {
            if(color==TRUE){

                layout(matrix(c(1,2), 1, 2, byrow = TRUE),
                       widths=c(1.7,1) )
                plot(select,storesummary.e[,1], xlab="Reads Sampled",
                     xlim=c(0,max(select)), ylim=c(0, 5+(max(storesummary.e[,1:(length(storesummary.e))], na.rm=TRUE))),
                     ylab=paste("Mean ",rank," Richness",sep=""), pch =16, col=2, type="n",main="Rarefaction Analysis")
                grid()

                for (j in 1:(length(storesummary.e))){
                    c<-colors[j]
                    s<-symbols[j]
                    points(select, storesummary.e[,j], pch=s, col=c, type="b", lty=1,cex=0.8)
                }

                if(error==TRUE){
                    for (m in 1:(length(storesummary.e))){
                        segments(select, storesummary.e[,m]+storesummary.se[,m],select, storesummary.e[,m]-storesummary.se[,m])
                    }
                }
                if (legend==TRUE){
                    frame()
                    legend("center", colnames(storesummary.e), inset=0.05, lty=1, col=colors, lwd=2,cex=0.9,pch=symbols)
                }
            }
            else
                {
                    plot(select,storesummary.e[,1], xlab="Reads Sampled",
                         xlim=c(0,max(select)), ylim=c(0, 5+(max(storesummary.e[,1:(length(storesummary.e))], na.rm=TRUE))),
                         ylab=paste("Mean",rank,"Richness",sep=""), pch =16, col=2, type="n")

                    for (j in 1:(length(storesummary.e))){
                        points(select, storesummary.e[,j], type="l", lty=1)}

                    for (k in 1:(length(storesummary.e))){
                        symbol<-ifelse(symbol<length(storesummary.e),rep(symbol,2),symbol)
                        points(as.numeric(rownames(subset(storesummary.e, storesummary.e[,k]==max(storesummary.e[,k],na.rm=TRUE)))), max(storesummary.e[,k],na.rm=TRUE), pch=symbol[k], cex=1.5)}

                    if(error==TRUE){
                        for (m in 1:(length(storesummary.e))){
                            points(select, storesummary.e[,m]+storesummary.se[,m], type="l", lty=2)
                            points(select, storesummary.e[,m]-storesummary.se[,m], type="l", lty=2)}}

                    k<-1:(length(storesummary.e))
                    if (legend==TRUE){
                        legend("bottomright", colnames(storesummary.e), pch=symbol[k], inset=0.05, cex=1.3)
                    }
                }
        }
    print("rarefaction by J. Jacobs, last update April 17, 2009")
    if(error==TRUE)(print("errors around lines are the se of the iterations, not true se of the means")  )
    list("richness"= storesummary.e, "SE"=richness.error, "subsample"=select)
    if(png){
	dev.off()
    }
}

coreAnalysis<-function(cal,out, outtable, color="default",plotGrid=T, title="", width=1000,height=500,res=75, coreMin=0.4,groupBy="group",figureFormat){
    cal<-c.setGroups(cal,groupBy=groupBy)
    dfc<-calypso2dfc(cal)
    thres<-coreMin

    library("VennDiagram")
    dfc<-dfc[order(dfc$Group),] 
    taxa<-as.character(unique(dfc$Taxa))
    groups<-as.character(unique(dfc$Group))
    location<-as.character(unique(dfc$Time))

    if(figureFormat == "png"){
        png(out,width=width,height=height,res=res,units="mm")
    }
    else if(figureFormat == "pdf"){
        pdf(out,width=width,height=height)
    }
    else if(figureFormat == "svg"){
        svg(out,width=width,height=height)
    }
    nT<-length(taxa)
    nG<-length(groups)

    if(nG < 2){
        errm<-"ERROR: less than 2 groups defined"
        frame()
        text(0.5,0.5,errm,font=2,,col="red",cex=1.5)
        dev.off()
        print(errm)
        return(0)
    }else if(nG > 5){
        dev.off()
    }
    
                                        # new empty dataframe
    data<-data.frame(matrix(ncol=nT,nrow=nG))
    rownames(data)<-c(groups)
    names(data)<-taxa

                                        # new empty dataframe
    info<-data.frame(matrix(ncol=nT,nrow=(nG*2)+2))
    groups.abundance <- c()
    groups.occurence <- c()
    for(i in groups){
        groups.abundance <- c(groups.abundance, paste0(i,".abu"))
        groups.occurence <- c(groups.occurence, paste0(i,".occ"))
    }
    rownames(info)<-c("type","details", groups.abundance, groups.occurence)
    names(info)<-taxa

    combinations <- c()
    for(i in 1:nG){
        combs <- combn(1:nG, i)
        for(j in 1:ncol(combs)){
            combinations <- c(combinations, paste(combs[,j], collapse=""))
        }
    }

    core<-data.frame(matrix(ncol=1,nrow=length(combinations)))
    names(core)<-c("values")
    rownames(core)<-combinations
    for(i in combinations){
        core[i,"values"]<-0
    }
    for(t in unique(dfc$Taxa)){
        
        dfct<-dfc[dfc$Taxa==t,]

                                        #goes through each group and calculates how many samples within one group have the observed taxon
        for(g in as.character(unique(dfct$Group))){
            counts<-dfct[dfct$Group == g,]$Count
            m<-round(mean(counts),3)
            data[g,t]<-length(counts[counts>0])/length(counts)  
                                        #stores mean value
            info[paste0(g,".abu"),t]<-m
            info[paste0(g,".occ"),t]<-round(data[g,t],2)
        }
        
        if(sum(data[,t] >= thres) > 1) {
            hits <- which(data[,t]>=thres)
            info["details",t] <- paste(rownames(data)[hits], collapse="&")
            hits.length <- length(hits)
            
            matches <-c()
            for(i in 1:hits.length){
                
                match <- combn(hits,i)
                for(j in 1:ncol(match)){
                    matches <- c(matches, paste(match[,j], collapse=""))
                }
            }
            for(i in matches){
                core[as.character(i),"values"] <-core[as.character(i),"values"]+1
            }
            
            if(hits.length == nG){
                info["type",t] <- "core"
            }else{
                info["type",t] <- "pan"
            }

        }               
        else if(sum(data[,t] >= thres) == 1) {
            hits <- which(data[,t]>=thres)
            core[as.character(hits[1]),"values"] <-  core[as.character(hits[1]),"values"] + 1
            info["type",t] <- "unique"                       
            info["details",t] <- rownames(data)[hits]
        }
    }
    info["type",which(is.na(info["type",]))] <-"ignore"
    write.csv(t(info[,which(info["type",]!="ignore")]), file=outtable, quote = FALSE)
    col<-getColors(color,nG)
    if(nG == 2){
        venn.plot <- draw.pairwise.venn(core["1","values"], core["2","values"],core["12","values"], groups, fill=col,cex=2, cat.cex=2,cat.col=col,alpha=0.4); 
    }else if(nG == 3){
        venn.plot <- draw.triple.venn(core["1","values"], core["2","values"],core["3","values"], core["12","values"],core["23","values"],core["13","values"],core["123","values"],groups, fill=col,cex=4, cat.cex=2,cat.col=col,alpha=0.4); 
    }else if(nG == 4){
        venn.plot <- draw.quad.venn(core["1","values"], core["2","values"],core["3","values"], core["4","values"],core["12","values"],core["13","values"],core["14","values"],core["23","values"],core["24","values"],core["34","values"],core["123","values"],core["124","values"],core["134","values"],core["234","values"],core["1234","values"],groups, fill=col,cex=2, cat.cex=2,cat.col=col,alpha=0.4);
    }else if(nG == 5){
         venn.plot <- draw.quintuple.venn(core["1","values"], core["2","values"],core["3","values"], core["4","values"],core["5","values"],core["12","values"],core["13","values"],core["14","values"],core["15","values"],core["23","values"],core["24","values"],core["25","values"],core["34","values"],core["35","values"],core["45","values"],core["123","values"],core["124","values"],core["125","values"],core["134","values"],core["135","values"],core["145","values"],core["234","values"],core["235","values"],core["245","values"],core["345","values"],core["1234","values"],core["1235","values"],core["1245","values"],core["1345","values"],core["2345","values"],core["12345","values"],groups, fill=col,cex=2, cat.cex=2,cat.col=col,alpha=0.4); 
    }
    if(nG < 6){
        grid.draw(venn.plot); 
        dev.off()
    }
    return(data)
}


writeAnorm<-function(cal,out,groupBy,er="group",what="sum"){
    cal<-c.setGroups(cal,er)
    if(what=="sum"){
        cal$default<-round(cal$default*cal$annot$total/100)
    }

    dfc<-calypso2dfc(cal)

    # order dataframe by group
    dfc<-dfc[order(dfc$Group),]


    taxa<-as.character(unique(dfc$Taxa))
    nT<-length(taxa)

    index <-3
    nG <- c()
    df.names <- c()
    df.rownames <- c()
    if(er=="group"){
        dfc<-dfc[!(is.na(dfc[,index])),]
        groups<-as.character(unique(dfc$Group))
        nG<-length(groups)
        df.names<-c("total",groups)
    }else{
        index <-4
        dfc<-dfc[!(is.na(dfc[,index])),]
        location<-as.character(unique(dfc$Time))
        nG<-length(location)
        df.names<-c("total",location)
    }
    if(what=="mean"){
        data<-data.frame(matrix(nrow=nT,ncol=nG + 1))
        names(data)<-df.names
        rownames(data)<-taxa
        for(t in unique(dfc$Taxa)){
            dfct<-dfc[dfc$Taxa==t,]
            means <- sapply(split(dfct, dfct[,index]), function(x){mean(x$Count)})  
            data[t,] <-c(mean(dfct$Count), means)
        }
        write.csv(file=out,data,quote=F,row.names=T)
    }else{
        data<-data.frame(matrix(nrow=nT+1,ncol=nG + 1))
        names(data)<-df.names
        rownames(data)<-c(taxa,"sum_sample")

        for(t in unique(dfc$Taxa)){
            dfct<-dfc[dfc$Taxa==t,]
            sum <- sapply(split(dfct, dfct[,index]), function(x){sum(x$Count)})  
            data[t,] <-c(sum(dfct$Count), sum)
        }        
        data["sum_sample",]<-c(sum(c$annot$total),sapply(split(c$annot$total, c$annot[,index+1]),sum))
        write.csv(file=out,data,quote=F,row.names=T)
    } 
}
