### ============================================================================
### Document Assessment
###
### 18/03/2018 Added Standard Graph database output
### ============================================================================

# library(FLCore)
# library(FLSAM)
# load("//community.ices.dk@SSL/DavWWWRoot/ExpertGroups/HAWG/2018 Meeting docs1/09. Personal Folders/Benoit/NSH_final.RData")

old.opt           <- options("width","scipen")
options("width"=75,"scipen"=1000)

sam.out.file      <- FLSAM.out(NSH,NSH.tun,NSH.sam,format="TABLE 2.6.3.%i North Sea Herring.")
write(sam.out.file,file=paste(output.base,"sam.out",sep="."))
options("width"=old.opt$width,"scipen"=old.opt$scipen)
#
##And finally, write the results out in the lowestoft VPA format for further analysis
writeFLStock(NSH,output.file=file.path(output.dir,"NSAS_47d3_"))

stockSummaryTable <- cbind(rec(NSH.sam)$year,
                           rec(NSH.sam)$value,      rec(NSH.sam)$lbnd,    rec(NSH.sam)$ubnd,
                           tsb(NSH.sam)$value,      tsb(NSH.sam)$lbnd,    tsb(NSH.sam)$ubnd,
                           ssb(NSH.sam)$value,      ssb(NSH.sam)$lbnd,    ssb(NSH.sam)$ubnd,
                           catch(NSH.sam)$value,    catch(NSH.sam)$lbnd,  catch(NSH.sam)$ubnd,
                           catch(NSH.sam)$value / ssb(NSH.sam)$value, catch(NSH.sam)$lbnd / ssb(NSH.sam)$lbnd, catch(NSH.sam)$ubnd / ssb(NSH.sam)$ubnd,
                           fbar(NSH.sam)$value,     fbar(NSH.sam)$lbnd,   fbar(NSH.sam)$ubnd,
                           c(quantMeans(harvest(NSH.sam)[ac(0:1),])),
                           c(sop(NSH),NA),
                           c(catch(NSH),NA))
colnames(stockSummaryTable) <-
  c("Year",paste(rep(c("Recruits Age 0 (Thousands)","Total biomass (tonnes)","Spawing biomass (tonnes)",
                       "Landings (tonnes)","Yield / SSB (ratio)","Mean F ages 2-6"),each=3),c("Mean","Low","High")),"Mean F ages 0-1","SoP (%)","WG Catch")
stockSummaryTable[nrow(stockSummaryTable),] <- NA
stockSummaryTable[nrow(stockSummaryTable),"Spawing biomass (tonnes) Mean"] <- 2271364
stockSummaryTable[nrow(stockSummaryTable),2:4] <- c(rec(NSH.sam)$value[nrow(rec(NSH.sam))],rec(NSH.sam)$lbnd[nrow(rec(NSH.sam))],rec(NSH.sam)$ubnd[nrow(rec(NSH.sam))])

# write.csv(stockSummaryTable,file=file.path(output.dir,paste(name(NSH),"stockSummaryTable.csv",sep="_")))
write.csv(stockSummaryTable,file=file.path("NSAS","stockSummaryTable.csv"))

options("width"=old.opt$width,"scipen"=old.opt$scipen)


# ----------------------------------------------------------------------------
# Add assessment output to SAG database
# ----------------------------------------------------------------------------

library(devtools)
devtools::install_github("ices-tools-prod/icesSAG")

library(icesSAG)
library(tidyverse)

# login to ICES SAG, generate a token and paste the token code below
cat("# Standard Graphs personal access token",
    "SG_PAT=f78abd38-aabb-4c2a-9ff2-e2e431f2ad66",
    sep = "\n",
    file = "~/.Renviron_SG")

# make use of the token
options(icesSAG.use_token = TRUE)

info     <- stockInfo(StockCode="her.27.3a47d", AssessmentYear = 2018, ContactPerson = "mpastoors@pelagicfish.eu")
fishdata <- stockFishdata(1947:2018)
FiY       <- ac(range(NSH)["minyear"]) 
DtY       <- ac(range(NSH)["maxyear"]) 
LaY       <- ac(range(NSH.sam)["maxyear"]) 
nyrs      <- range(NSH)["maxyear"]-range(NSH)["minyear"]+1


info$StockCategory             <- "1"
info$MSYBtrigger               <- 1400000
info$Blim                      <- 800000
info$Bpa                       <- 900000
info$Flim                      <- 0.34
info$Fpa                       <- 0.30 
info$FMSY                      <- 0.26
info$Fage                      <- "2-6"
info$RecruitmentAge            <- 0
info$CatchesCatchesUnits       <- "tonnes"
info$RecruitmentDescription    <- "wr"
info$RecruitmentUnits          <- "thousands"
info$FishingPressureDescription<- "F"
info$FishingPressureUnits      <- "Year-1"
info$StockSizeDescription      <- "SSB"
info$StockSizeUnits            <- "tonnes"
info$CustomSeriesName1         <- "model catch"
info$CustomSeriesName2         <- "model catch low"
info$CustomSeriesName3         <- "model catch high"
info$CustomSeriesUnits1        <- "tonnes"
info$CustomSeriesUnits2        <- "tonnes"
info$CustomSeriesUnits3        <- "tonnes"

# fishdata$Landings[1:nyrs]      <- an(NSH@landings) 
fishdata$Catches[1:nyrs]       <- an(NSH@landings) 
fishdata$Low_Recruitment       <- rec(NSH.sam)$lbnd
fishdata$Recruitment           <- rec(NSH.sam)$value
fishdata$High_Recruitment      <- rec(NSH.sam)$ubnd 
fishdata$TBiomass              <- tsb(NSH.sam)$value
fishdata$Low_TBiomass          <- tsb(NSH.sam)$lbnd
fishdata$High_TBiomass         <- tsb(NSH.sam)$ubnd
fishdata$StockSize             <- ssb(NSH.sam)$value
fishdata$Low_StockSize         <- ssb(NSH.sam)$lbnd
fishdata$High_StockSize        <- ssb(NSH.sam)$ubnd
fishdata$FishingPressure       <- fbar(NSH.sam)$value
fishdata$Low_FishingPressure   <- fbar(NSH.sam)$lbnd
fishdata$High_FishingPressure  <- fbar(NSH.sam)$ubnd

fishdata$CustomSeries1         <- catch(NSH.sam)$value
fishdata$CustomSeries2         <- catch(NSH.sam)$lbnd
fishdata$CustomSeries3         <- catch(NSH.sam)$ubnd

# summary(fishdata)
# glimpse(fishdata)

# upload to SAG
key <- icesSAG::uploadStock(info, fishdata)

glimpse(info)
