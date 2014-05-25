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

### Results

### Conclusions

### GitHub commit

### Other notes
* I discovered that some of the fields (e.g. `origin`, `crs_dep_time`)
  are enclosed in double quotes. Wrote a shell script to remove them.
