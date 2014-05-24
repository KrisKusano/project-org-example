#!/bin/bash
# remove all double quotes from all the csvs in the data file
# Kristofer D. Kusano - 5/24/14
echo "Removing quotes, saving as temp files ('filename.csv.tmp')"
for f in in ../*.csv; do
  echo "Removing double quotes from $f"
  /bin/sed 's/"//g' $f > "$f.tmp"
done
