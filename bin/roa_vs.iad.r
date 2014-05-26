# compare ROA to IAD flights
# note: need to set current working directory (swd) to bin/
#
require(grDevices)
require(digest)
require(xtable)
# Load in Data ----------
export_plots = TRUE
plot_dir = "../results/2014-05-23";
dpath <- "../data/2014-05-23/"
fnames <- list.files(path=dpath,
                     pattern=".csv$")
flights <- NULL
for (f in fnames)
{
  dat <- read.table(paste(dpath, f, sep="/"),
                    header=TRUE,
                    sep = ",");
  flights <- rbind(flights, dat)
}

colnames(flights) <- tolower(colnames(flights))
flights$x <- NULL  # remove empty extra column

# subset
idx_roa = flights$origin == "ROA" | flights$dest == "ROA"
idx_iad = flights$origin == "IAD" | flights$dest == "IAD"
flights$airport <- "ROA"
flights[idx_iad, "airport"] <- "IAD"

f <- flights[idx_roa | idx_iad,]

# Make Summary of Dataset -------------------------------------------------
sum_file <- "../results/2014-05-23/dataset_summary"
flights_sha1 <- digest(flights, algo="sha1")
sum_txt <- c(
  "Files:",
  fnames,
  " ",
  "Number of Observations:",
  nrow(flights),
  " ",
  "SHA-1 Sum of 'flights' data frame in R",
  flights_sha1)

fid <- file(sum_file)
writeLines(sum_txt, fid)
close(fid)
# Sumarize flighs out of ROA and IAD --------------

nroa <- sum(idx_roa)
niad <- sum(idx_iad)
print(sprintf("Flights from ROA: %.0f", nroa))
print(sprintf("Flights from IAD: %.0f", niad))
print(sprintf("Flights from Either: %.0f", sum(idx_roa & idx_roa)))
print(sprintf("Flights total: %.0f", sum(idx_roa | idx_iad)))

# Total Flights -----------------------------------------------------------
ftab <- table(f$airport)
ftab <- data.frame(N = c(ftab[1], ftab[2], sum(ftab)))
rownames(ftab)[3] <- "Total"
ftab$Airport <- rownames(ftab)
ftab$N <- format(ftab$N, big.mark=",", scientific=F)
ftab <- ftab[,c(2,1)]

s <- xtable(ftab,
            caption=("Number of Flights from ROA and IAD in February 2014 and September 2013"),
            align=c("l", "l", "r"))
label(s) <- "tab:nflights"
print(s,
      file=paste(plot_dir, "tab_nflights.tex", sep="/"),
      caption.placement="top",
      comment=FALSE,
      include.rownames=FALSE,
      booktabs=TRUE,
      table.placement="!htbp")
# Cancelled Flights by Month -----------------------------------------------
c_all <- table(f$month, f$cancelled)  # cancelled by month
c_all_out <- rbind(c_all, colSums(c_all))  # add total
c_all_pct <- sweep(c_all, 1, rowSums(c_all), "/") # add percent
c_all_pct <- paste0(round(c_all_pct*100, 1), "%")  # convert to percent
c_all_pct <- matrix(c_all_pct, nrow=2, ncol=2)
c_all_pct <- rbind(c_all_pct, paste0(round(colSums(c_all)/sum(c_all)*100, 1), "%")) # add blanks to bottom

c_all_out <- format(c_all_out, big.mark=",", scientific=FALSE)
c_all_out <- cbind(c_all_out, c_all_pct)  # combine

c_all_out <- c_all_out[,c(1,2,4)] # keep only cancelled
c_all_out <- cbind(c("February 2014", "September 2013", "Total"), c_all_out)
colnames(c_all_out) <- c("Month", "Flights", "Cancelled", "% Cancelled")
print(c_all_out)

s <- xtable(c_all_out,
            caption="Cancelled Flights by Month",
            align=c("l", "l","r", "r", "r"))
label(s) <- "tab:cancelled_by_month"
print(s,
      file=paste(plot_dir, "tab_cancelled_by_month.tex", sep="/"),
      comment=FALSE,,
      include.rownames=FALSE,
      caption.placement="top",
      booktabs=TRUE,
      table.placement="!htbp")
# Canceled Flights --------------------------------------------------------
# if (export_plots)
# {
#   setEPS()
#   postscript(paste(plot_dir, "cancelled_by_airport.eps", sep="/"),
#              onefile=FALSE,
#              paper="special",
#              width=4.0,
#              height=3.0)
# }
cancelled <- table(f$cancelled, f$airport)
cancelled <- sweep(cancelled, 2, colSums(cancelled), '/')   # convert to percent

yl <- c(0, ceiling(max(cancelled[2,])*100)/100)
yt <- seq(yl[1], yl[2], 0.01)

bh <- barplot(cancelled[2,],
              yaxt="n",
              col="blue",
              ylim=c(yl[1], yl[2]))

axis(2, 
     at=yt,
     lab=paste0(yt*100, "%"), las=TRUE)
text(bh, cancelled[2,], labels=paste0(round(cancelled[2,]*100, 1), "%"), cex=1, pos=3)

# if (export_plots)
# {
#   dev.off()
# }

# Canceled flights by month -----------------------------------------------
if (export_plots)
{
  setEPS()
  postscript(paste(plot_dir, 'cancelled_by_month.eps', sep="/"),
             onefile=FALSE,
             paper="special",
             width=4.0,
             height=3.0)
}
cmonth <- table(f$cancelled,
                f$airport,
                factor(f$month, labels=c("Feb 2014", "Sep 2013")))
cmonth <- sweep(cmonth, c(2,3), colSums(cmonth, dims=1), "/")  # conver to percent

yl = c(0, ceiling(max(cmonth[2,,])*100)/100 + 0.01)
yt = seq(yl[1], yl[2], 0.05)
bh <- barplot(cmonth[2,,], 
              beside=TRUE, 
              col=c("Blue", "Red"), 
              ylim=yl,
              yaxt="n",
              legend=c("IAD", "ROA"))
axis(2,
     at=yt,
     lab=paste0(yt*100, "%"))
text(bh, cmonth[2,,], 
     labels=paste0(round(cmonth[2,,]*100,1), "%"), 
     pos=3)
if (export_plots)
{
  dev.off()
}