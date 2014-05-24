RITA Bureau of Transportation Statistics Flight Dataset
=======================================================
Kristofer D. Kusano - 5/23/14

Source
------
[RITA BTS](http://www.transtats.bts.gov/DL_SelectFields.asp?Table_ID=236)

Data Description
----------------
The data can be downloaded from the above link. Data can be downloaded
one month at a time. The downloads all have the same name. I unzipped
them and renamed them as "Geography_Year_Month.csv" where Geography,
Year, and Month all correspond to drop downs from the website.

Some variables are coded and have "lookup tables" that describe
the codes were downloaded from the website and are in the ./formats
folder

Data Processing
-----------------
A script to read in all the \*.csv files is in the ./processed folder

Data Elements
-------------
* **_Time Period_**
  * **Year**.
  * **Month**.
  * **DayofMonth**. Numerical (1-12) month
  * **DayOfWeek**. 1=Monday, 7=Sunday, 9=Unknown
  * **FlightDate**. yyyymmdd
* **_Airline_**
  * **Carrier**. IATA assigned code for airlines (see ./formats/L_CARRIER_HISTORY.csv Folder)
* **_Origin_**
  * **Origin**. Origin airport (3-letter code, e.g. ROA, see ./formats/L_CARRIER_HISTORY.csv)
* **_Destination_**
  * **Dest**. Destination Airport (see ./formats/L_CARRIER_HISTORY.csv) 
* **_Departure Performance_**
  * **CRSDepTime**. CRS Departure time (local time: hhmm)
  * **DepDelay**. Difference in minutes between scheduled and actual
    departure time. Early departures show negative numbers.
  * **DepartureDelayGroups**. Delay intervals, every 15 min (-15 to >180
    min, see ./formats/L_DEPARRBLK.csv)
* **_Arrival Performance_**
  * **CRSArrTime**. local time hhmm
* **_Canceled_**
  * **Cancelled**. 1=Yes
  * **CancellationCode**. Specifies reason for cancellation
* **_Flight Summaries_**
  * **CRSElapsedTime**. in minutes
* **_Causes of Delay_**
  * **CarrierDelay**. in min
  * **WeatherDelay**. in min
  * **NASDelay**. National Air System delay (in min)
  * **SecurityDelay**. in min
  * **LateAircraftDelay**. in min

