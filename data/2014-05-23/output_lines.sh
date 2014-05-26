# awk command to extract rows with column 7 == "ROA" in a csv
awk -F "," '$7=="\"ROA\""' All_2013_September.csv
