
##
#  script to compare the output of the assessment using the new Fprop and the 2017 assessment


rm(list=ls()); graphics.off(); start.time <- proc.time()[3]
options(stringsAsFactors=FALSE)


# choose the assessments to be compared

assess1 <- "0_basecase"
assess2 <- "2_newM"
assess3 <- "2c_newM_scaled_profile"
assess4 <- "2e_oldM_scaled"


# local path
path <- "D:/git/wg_HAWG/NSAS/benchmark/"
try(setwd(path),silent=TRUE)

### ======================================================================================================
### Define parameters and paths for use in the assessment code
### ======================================================================================================
output.dir          <-  file.path(".","results/")                #figures directory
output.base         <-  file.path(output.dir,"NSH Assessment")  #Output base filename, including directory. Other output filenames are built by appending onto this one


### ============================================================================
### imports
### ============================================================================
library(FLSAM); library(FLEDA)  ; library(ggplot2); #library(FLBRP)


data_series <- "catch unique"


load(file.path(".","results",assess1,"NSH.RData")  )
fit1.stck  <-NSH
fit1.flsam <-NSH.sam

load(file.path(".","results",assess2,"NSH.RData")  )
fit2.stck  <-NSH
fit2.flsam <-NSH.sam

load(file.path(".","results",assess3,"NSH.RData")  )
fit3.stck  <-NSH
fit3.flsam <-NSH.sam

load(file.path(".","results",assess4,"NSH.RData")  )
fit4.stck  <-NSH
fit4.flsam <-NSH.sam



#plot(residuals_catch)

#logLik(fit1.flsam)
#logLik(fit2)

#1-pchisq(2*(logLik(fit2)-logLik(fit1)),6)

#AIC(fit1)
#AIC(fit2)

#pdf(file.path(output.dir,paste(name(NSH.sam),".pdf",sep="")))
#png(file.path(output.dir,paste(name(NSH.sam),"figures - %02d.png")),units = "px", height=800,width=672, bg = "white")
windows()
#compare stock trajectories
st.names <- c(assess1,assess2,assess3,assess4)
stc <- FLStocks(fit1.stck,fit2.stck, fit3.stck, fit4.stck)
names(stc) <- st.names
flsam <- FLSAMs(fit3.flsam, fit4.flsam)
names(flsam) <- c("HAWG 2016 profiling","SMS 2017 profiling")

plot(flsam)
savePlot(file.path(".","results",assess4,"comparison of stock trajectories.png"),type="png")


#  compare the M vectors
library(ggplotFL)
M<-FLQuants(fit1.stck@m,fit2.stck@m, fit3.stck@m, fit4.stck@m)
st.names <- c("HAWG2017","SMS2017","HAWG2017 profiled","SMS2017 profiled")
#st.names <- c("0_basecase","2_newM","2_newM","2_newM")
names(M) <- st.names
#names(M) <- c("HAWG_2016","SMS_2017","SMS_2017_profiling","SMS_2017_profiling")#st.names#c("HAWG 2016", "SMS 2017", "SMS 2017 profiling", "SMS 2017 profiling")#st.names
ggplot(M , aes (x =year ,y =data  , colour = qname)) + geom_line() + facet_wrap(~age) + ylab("M") + xlab("year") + theme(legend.position="bottom") + scale_colour_discrete(name = "")

savePlot(file.path(".","results",assess4,"comparison of M.png"),type="png")

# compare old and new M
M<-FLQuants(fit1.stck@m,fit2.stck@m)
st.names <- c("HAWG2017","SMS2017")
names(M) <- st.names
ggplot(M , aes (x =year ,y =data  , colour = qname)) + geom_line() + facet_wrap(~age) + ylab("M") + xlab("year") + theme(legend.position="bottom") + scale_colour_discrete(name = "")

savePlot(file.path(".","results",assess4,"comparison of M_1.png"),type="png")

# plot last M
windows()
M <- as.data.frame(FLQuants(fit2.stck@m))

for(idx in 1:dim(M)[1]){M$age[idx] <- toString(M$age[idx])}

g <- ggplot(M, aes (x =year ,y =data)) + geom_line(aes(color = age)) + geom_text(aes(label=age,color = age)) + ylab("Time series of M") + xlab("year") + theme_bw()
g
savePlot(file.path(".","results",assess4,"M at age_SMS2017.png"),type="png")

windows()
M <- as.data.frame(FLQuants(fit3.stck@m))

for(idx in 1:dim(M)[1]){M$age[idx] <- toString(M$age[idx])}

g <- ggplot(M, aes (x =year ,y =data)) + geom_line(aes(color = age)) + geom_text(aes(label=age,color = age)) + ylab("Time series of M") + xlab("year") + theme_bw()
g
savePlot(file.path(".","results",assess4,"M at age_SMS2017_profile.png"),type="png")


# look at parameter values

  # catchability values
catch1 <- catchabilities(fit1.flsam)
catch2 <- catchabilities(fit2.flsam)
catch1$assess <- assess1
catch2$assess <- assess2

catchab<-rbind(catch1,catch2)
catchab$age[is.na(catchab$age)] <- "all"
catchab$label <- paste(catchab$fleet,catchab$age,sep="_")

g <- ggplot(data = catchab , aes(label , value , fill = assess))
g   <-  g  +  geom_bar(aes(fill = assess   ), position = "dodge", stat="identity")
g   <-  g  +  ggtitle("survey catchability")  + xlab("")  + theme(axis.text.x = element_text(angle = 90, hjust = 1))
g   <-  g  +  geom_errorbar(aes(ymin=lbnd, ymax=ubnd),width=1, position=position_dodge(.9))
g   <-  g  +  facet_grid(fleet~.,scales = "free") + scale_colour_discrete(name = "ASSESSMENT")
g

savePlot(file.path(".","results",assess2,"comparison of catchabilities.png"),type="png")

  # observation variance values
obs1 <- obs.var(fit1.flsam)
obs2 <- obs.var(fit2.flsam)
obs1$assess <- assess1
obs2$assess <- assess2
obs<-rbind(obs1,obs2)
obs$age[is.na(obs$age)] <- "all"
obs$label <- paste(obs$fleet,obs$age,sep="_")

g <- ggplot(data = obs , aes(label , value , fill = assess))
g   <-  g  +  geom_bar(aes(fill = assess   ), position = "dodge", stat="identity")
g   <-  g  +  ggtitle("observation variances")  + xlab("") + theme(axis.text.x = element_text(angle = 90, hjust = 1))
g   <-  g  +  geom_errorbar(aes(ymin=lbnd, ymax=ubnd),width=1, position=position_dodge(.9))
g   <-  g  +  facet_grid(fleet~.,scales = "free") + scale_colour_discrete(name = "ASSESSMENT")
g

savePlot(file.path(".","results",assess2,"comparison of obs.vars.png"),type="png")

  # process variances 
mvars <- c("logSdLogFsta","logSdLogN") 
 
pvar1<- params(fit1.flsam)[is.element(params(fit1.flsam )$name,mvars),]
pvar2<- params(fit2.flsam)[is.element(params(fit2.flsam )$name,mvars),]
pvar1$assess <- assess1
pvar1$dummy <- 1:dim(pvar1)[1]
pvar2$assess <- assess2
pvar2$dummy <- 1:dim(pvar2)[1]
pvar  <-  rbind(pvar1,pvar2)
pvar$lbnd <- with(pvar , value - 2 * std.dev) 
pvar$ubnd <- with(pvar , value + 2 * std.dev)
pvar$value <- exp(pvar$value)
pvar$lbnd <- exp(pvar$lbnd)
pvar$ubnd <- exp(pvar$ubnd)
pvar$label<- paste(pvar$name,pvar$dummy,sep="_") 
pvar$name <- gsub("log","",pvar$name)


g <- ggplot(data = pvar , aes(label , value , fill = assess))
g   <-  g  +  geom_bar(aes(fill = assess   ), position = "dodge", stat="identity")
g   <-  g  +  ggtitle("process variances")  + xlab("")   + theme(axis.text.x = element_text(angle = 90, hjust = 1))
g   <-  g  +  geom_errorbar(aes(ymin=lbnd, ymax=ubnd),width=1, position=position_dodge(.9))
g   <-  g  +  facet_grid(name~.,scales = "free")  + scale_colour_discrete(name = "ASSESSMENT")
g

savePlot(file.path(".","results",assess2,"comparison of process.vars.png"),type="png")


# uncertainty
CV.yrs <- ssb(fit1.flsam)$year
CV.dat <- data.frame(year = CV.yrs,SSB=ssb(fit1.flsam)$CV,
                Fbar=fbar(fit1.flsam)$CV,Rec=rec(fit1.flsam)$CV)
CV.dat1<-tidyr::gather (CV.dat , key = "var" , value = "value", 2:4)               
CV.dat1$assess <- assess1

CV.yrs <- ssb(fit1.flsam)$year
CV.dat <- data.frame(year = CV.yrs,SSB=ssb(fit2.flsam)$CV,
                Fbar=fbar(fit2.flsam)$CV,Rec=rec(fit2.flsam)$CV)
CV.dat2<-tidyr::gather (CV.dat , key = "var" , value = "value", 2:4)               
CV.dat2$assess <- assess2

CV.dat <- rbind(CV.dat1,CV.dat2)


g <- ggplot(data = CV.dat , aes(x = year , y  = value , colour = assess))
g   <-  g  +  geom_line(aes(colour = assess   ))
g   <-  g  +  ggtitle("assessment uncertainty")  + xlab("") + theme(axis.text.x = element_text(angle = 90, hjust = 1))
g   <-  g  +  facet_grid(var~.,scales = "free")   + scale_colour_discrete(name = "ASSESSMENT")
g


savePlot(file.path(".","results",assess2,"comparison of model uncertainty.png"),type="png")