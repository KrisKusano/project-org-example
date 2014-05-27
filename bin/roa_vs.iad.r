# compare ROA to IAD flights
# note: need to set current working directory (swd) to bin/
#
# Future steps: convert graphics to ggplot2

require(grDevices)  # export eps files
require(digest)  # summarize input data
require(xtable)  # export to LaTeX
require(ggplot2)  # make pretty plots
require(gridExtra)  # muliple plots with grid.arrange
library(scales)  # change axes to percent
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
print("Data Summary:")
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

# export
tab_name <- "tab_nflights.tex"
s <- xtable(ftab,
            caption=("Number of Flights from ROA and IAD in February 2014 and September 2013"),
            align=c("l", "l", "r"))
label(s) <- "tab:nflights"
print(s,
      file=paste(plot_dir, tab_name, sep="/"),
      caption.placement="top",
      comment=FALSE,
      include.rownames=FALSE,
      booktabs=TRUE,
      table.placement="!htbp")
print(sprintf("Output table '%s'", tab_name))
# Cancelled Flights by Month -----------------------------------------------
# make table
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
# print(c_all_out)

# export
tab_name <- "tab_cancelled_by_month.tex"
s <- xtable(c_all_out,
            caption="Cancelled Flights by Month",
            align=c("l", "l","r", "r", "r"))
label(s) <- "tab:cancelled_by_month"
print(s,
      file=paste(plot_dir, tab_name, sep="/"),
      comment=FALSE,,
      include.rownames=FALSE,
      caption.placement="top",
      booktabs=TRUE,
      table.placement="!htbp")
print(sprintf("Output table '%s'", tab_name))
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
  plot_name <- 'cancelled_by_month.eps'
  setEPS()
  postscript(paste(plot_dir, plot_name, sep="/"),
             onefile=FALSE,
             paper="special",
             width=4.0,
             height=3.0,
             pointsize=9)
}
cmonth <- table(f$cancelled,
                f$airport,
                factor(f$month, labels=c("Feb 2014", "Sep 2013")))
cmonth <- sweep(cmonth, c(2,3), colSums(cmonth, dims=1), "/")  # conver to percent

yl = c(0, ceiling(max(cmonth[2,,])*100)/100 + 0.02)
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
  print(sprintf("Exported plot '%s'", plot_name))
}

# Delay Time by Month -----------------------------------------------------
if (export_plots)
{
  plot_name <- "delay_time_cdfs.eps"
  setEPS()
  postscript(paste(plot_dir, plot_name, sep="/"),
             onefile=FALSE,
             paper="special",
             width=4.0,
             height=6.0,
             pointsize=9)
}
idx_nc <-  f$cancelled == 0
idx_feb <- f$month == 2 & idx_nc
idx_sep <- f$month == 9 & idx_nc

xl <- c(-10, 150)
gg_ecdf <- function(xdata)
{
  ggplot(xdata, aes(x=dep_delay, colour=airport)) + 
    stat_ecdf() + 
    scale_y_continuous(name="Cumulative\nFrequency",
                       labels=percent) +
    scale_x_continuous(name="", limits=xl) +
    theme(text = element_text(size=9))
}

# Feb
p1 <- gg_ecdf(f[idx_feb,]) +
  theme(legend.position = c(1, 0),
        legend.justification=c(1,0)) +
  ggtitle("February 2014")

# Sept
p2 <- gg_ecdf(f[idx_sep,])  +
  theme(legend.position="none") + # no legend
  ggtitle("September")
  
# Both
p3 <- gg_ecdf(f[idx_nc,]) +
  theme(legend.position="none") + # no legend
  scale_x_continuous(name="Delay Time (min)", limits=xl) +
  ggtitle("All Months")
  
grid.arrange(p1, p2, p3, ncol=1)

if (export_plots) {
  dev.off()
  print(sprintf("Exported plot '%s'", plot_name))
}