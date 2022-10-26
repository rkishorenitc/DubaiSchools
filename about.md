------------------
This tool is developed to support parents in Dubai to select schools for their children based on different criteria. It provides a single-interface to all schools registered in the Emirate of Dubai, with information on location, fees, enrollments, curricula and user-ratings and feedback. The tool was developed using R and Shiny libraries and is hosted on ShinyApps.io free account. The maplet runs on leaflet package with Open Street Maps as the base layer, and the drive-time isochrones utilize the Open Street Routing Machine (OSRM).

#### Features

- Filter schools based on location, curriculum, Google rating and fees
- View the location of schools on a map (color-coded by its Google Rating), and as a list
- Clicking on each school will reveal further details, along with its Google ratings, number of reviews, and historic changes in Google ratings
- Isochrones show drive-time locations for each selected school in 10, 20 and 30 minutes interval
- List of schools includes annual enrollments and year of establishment

#### Data Sources

The tool utilizes the following datasets & resources:

| Data/Resource | Source |
| ------ | ------ |
| School List | Knowledge and Human Development Autority (KHDA) |
| School Fees | Dubai Pulse Portal by Dubai Digital Authority |
| DSIB Ratings | Dubai School Inspection Bureau (A unit under KHDA) |
| Enrollments | Knowledge and Human Development Autority (KHDA) |
| Ratings and Reviews | Google Places API, updated every 5 days |
| Drive Time Polygons | Open Street Routing Machine Libraries |
| Analytics | Google Analytics used to collect usage information |
| Hosting | Done on ShinyApps.IO free hosting platform |

#### Limitations

- KHDA updates are done only once a year, and hence that's the update frequency of school list.
- Google ratings are updated every 5 days to have the API consumption within free tier.
- First user loading every 5 days may see slow loading since the app updates all underlying data for this user. All subsequent users will have faster load times.
- OOSRM libraries take around 30-seconds to load the isochrones.
- ShinyApps.io free tier is limited to 25-hours monthly usage.

#### Bugs & Disclaimer

The developer assumes no responsibility for accuracy of information on the tool, or for any decisions made based on the tool. Any bugs to be reported to rkishore@vt.edu.