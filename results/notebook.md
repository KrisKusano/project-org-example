# Flight Times Project - Lab Notebook
Kristofer D. Kusano

## 5/23/14 - First Download
* Downloaded flight data into `data/2014-05-23` directory. README
  explains the data elements that I downloaded.
* Wrote a file in the `data/2014-05-23/processed` folder that
  reads in all the CSV files in the data directory and saves them
  to `*.mat` format.

## 5/24/14 - Compare flight delays at small and large airports
*Objective:* Are flight delays more common at small regional airports
(like ROA) than at large airports (like IAD)?

### Methods
* made file `bin/roa_vs_iad.m` to investigate.

1. Extract out all flights that originated at ROA and IAD
2. Compare the level of delay between them
  * Number of Canceled flights
  * Cancelation Reason
  * Cumulative Distribution of Delay Time

After one session of writting lots of utility functions for MATLAB, I
thought to myself: "Wouldn't this just be easier in R?" So I started to
write an R script to do the analysis (`roa_vs_iad.r`).
### Results
I wrote the results in a LaTeX document in the `doc/2014-05-23/paper.tex`.

### Other notes
* I discovered that some of the fields (e.g. `origin`, `crs_dep_time`)
  are enclosed in double quotes. Wrote a shell script to remove them
  (`results/2014-05-23/processed/rm_double_quotes.sh`). The double
  quotes was an issue when I was writting in MATLAB, but R in it's
  infinite wisdom does not care. I left the shell script in the git repo
  so I can look at it later.
