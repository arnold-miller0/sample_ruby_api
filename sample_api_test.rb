require 'digest'   # MD5 , RMD160, SHA1, SHA2
require 'json'     # JSON format parse and buld
require 'httparty' # HTTP methods
require 'csv'      # CSV format and files
require 'uri'      # URI for HTTP comamnds and args
require 'test/unit' # Unit test
require 'date'      # Date functions
extend Test::Unit::Assertions

require_relative 'sample_trap_assert'
require_relative 'sample_class_restrsp'
require_relative 'sample_class_webapiurl'
require_relative 'sample_class_tvshowinfo'
require_relative 'sample_check_webapiinfo'
require_relative 'sample_check_aptvshowinfo'

=begin
Small automation project:
Dish Anywhere Web site https://www.dishanywhere.com/ via GET ReSTful APIs
•	Check/Report: Web GIT Version vs inputted values
  o	Web config check  https://www.dishanywhere.com/health/config_check?
    Note: This API response has the Base API URL path and the API Health Check URL
•	Checked and Report: API GIT Version vs inputted values
  o	API config check  https://radish.dishanywhere.com/health/config_check?
•	Checked and Report: API Health is ‘ok’
  o	API Health check https://radish.dishanywhere.com/healthcheck?
•	Checked and Report: API Third Party Status is ‘green’
  o	API third party status https://radish.dishanywhere.com/?
•	Via Web Site’s ‘On Demand’ ‘TV Shows’ https://www.dishanywhere.com/on_demand/all
  o	Using API Base URL  https://radish.dishanywhere.com/franchises?kind=show
    o	Find ‘Sort By’ filter API search and Web Display values
      Note: Response “sorts” Array of {“name”: Web Display, “slug”: API search} pairs
      Via API query parameter “sort=”
    o	Find ‘Genre’ filter API search and Web Display values
      Note: Response “filters” “genres” is list of API search values
      Via API query parameter “genres=”
    o	Find ‘Rating’ filter API search and Web Display values
      Note:  Response “filters” “ratings” is Array of of {“name”: Web Display, “slug”: API search} pairs
      Via API query parameter “ratings=”
    o	Find ‘Starting Letter’ query API search and Web Display values
      Note:  Response “starting_letters” Is Array of {Key: Value) pair
      Where Key is a starting letter and Value is count of show that start with this letter
          When Key is "#" has seqrch value "123"; Otherwise search is lowetr case Key
      Via API query parameter “starting_letter=”
•	For each Filter Group (Sort By, Genre, Rating, Starting Letter)
  •	Find default list of TV Shows for each filter’s API search value
    o	Report: Filter Group, specific Filter searched, count of response TV Shows, count of total TV that match filter
  •	Evaluated each found TV show for following errors
    o	No Description: response "description" is empty string or null or not string
    o	No Rating: response “rating” is empty array or null or not array
    o	No Genre: response “genres” is empty array or null or not array
    o	No Network: response “networks” has no network names
  •	Tracked Evaluated TV Shows via
    o	count of Evaluated TV shows (totalCount)
    o	count of TV shows with no errors (noCount)
    o	count of Each Error’s for unique per TV show (noDescCount, noGeneCount, noRateCount, NoLettCount)
    o	Each Error’s unique TV Show list
      Note: Response TV Shows: “slug” is unique search string
    o	Count of Duplicate TV shows for each Error (dupCount)
    o	Count of Repeat TV shows that have multiple Errors (repCounr)
      Note: When TV show in 3 errors, repeat count increase by 2
    o	Math: totalCount == noCount + dupCount – repCount + noDescCount + noGeneCount + noRateCount + NoLettCount
  •	After Evaluated all these found TV Shows; Report
    o	count of Evaluated TV shows (totalCount)
    o	count of TV shows with no errors (noCount)
    o	Count of Duplicate TV shows for each Error (dupCount)
    o	Count of Repeat TV shows that have multiple Errors (repCounr)
    o	For  Each Error type (No Description, No Ratting, No Genre, No Netowork)
    o	Count of the Error Type
    o	Summary of each TV Shows with Error in found Order
      	Error Type
      	TV Show: Web Franchise search string
      	TV Show: Type, Kind, Name
•	Report is via csv file with date-time name (Year-Mon-Day-Hour-Min-Second)
Done
=end
#$stdout.sync = true
# Execute for Version match, not match; Each Filter Group; All Filter Groups
# Check API TV Show: Web ver, API Ver,   EvalType, isShows, Sort,  Genre, Rate,  Letter
checkWebApiShowInfo("23-3-3-1", "origin/23-3-3", "None"  , false , false, false, false, false)

sortkey=["name", "score", "most_popular", "date", "rating", "tomatometer"]
sortYday = Date.today.yday()
sortItem = sortkey[sortYday % sortkey.length]

# Movie Franchises
# Check API TV Show: Web ver, API Ver,   EvalType, isShows, Sort,  Genre, Rate,  Letter
checkWebApiShowInfo("23-3-3-1", "origin/23-3-3", "Filter",  false , true , true , true , true )
checkWebApiShowInfo("23-3-3-1", "origin/23-3-2", "All",     false , sortItem, false, false, false)
checkWebApiShowInfo("23-3-3-1", "origin/23-3-1", "Random",  false , sortItem, false, false, false)
checkWebApiShowInfo("23-3-3", "origin/23-3-3", "Cluster", false , sortItem, false, false, false)
checkWebApiShowInfo("23-3-3", "origin/23-3-2", "Strata",  false , sortItem, false, false, false)

#TV-Show Franchises
# Check API TV Show: Web ver, API Ver,   EvalType, isShows, Sort,  Genre, Rate,  Letter
checkWebApiShowInfo("23-3-3", "origin/23-3-1", "Filter",  true , true , true , true , true )
checkWebApiShowInfo("23-3-2", "origin/23-3-3", "All",     true , sortItem, false, false, false)
checkWebApiShowInfo("23-3-2", "origin/23-3-2", "Random",  true , sortItem, false, false, false)
checkWebApiShowInfo("23-3-2", "origin/23-3-1", "Cluster", true , sortItem, false, false, false)
checkWebApiShowInfo("23-3-4", "origin/23-3-4", "Strata",  true , sortItem, false, false, false)

=begin
Agile Testing & Test Automation Summit in Denver is on December 19, 2019.
Please let us know if you would be interested in a 30 mins sessions.

Archana Akhaury;
I am interested in Speaking at the the Agile Testing & Test Automation Summit in Denver is on December 19, 2019.
I have submitted on the following 30 min session on https://1point21gws.com/testingsummit/denver/
Name: Arnold Miller
Email: arnold.miller0@gmail.com
Topic:  Train ML/AI via Statistical Sampling
Abstract:
Statistical Sampling method are useful to train Ml/AI application
Methods include Simple Random, Stratified, Cluster
Real Example comparing these methods to help you what is best for your application

-- Arnold Miller
https://stattrek.com/survey-research/sampling-methods.aspx
=end
