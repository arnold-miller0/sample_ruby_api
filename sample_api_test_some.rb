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

$stdout.sync = true
# Execute for Veesion match, not match; Each Filter Group; All Filter Groups
# Check API TV Show: Web ver,    API Ver,      EvalType, isShows, Sort,  Genre, Rate,  Letter
checkWebApiShowInfo("23-3-3-1", "origin/23-3-3", "None", false, false, false, false, false)
checkWebApiShowInfo("23-3-3-1", "origin/23-3-3", "None", true , false, false, false, false)
#checkWebApiShowInfo("20.1.0",  "20.1.0",        "Filter",false, true , true , true , true )
#checkWebApiShowInfo("20.1.0",  "20.1.0",        "All",   false, "name", false, false, false)
#checkWebApiShowInfo("20.1.0",  "20.1.0",        "Random", false ,false, false, false, false)
#checkWebApiShowInfo("20.1.2.1", "20.1.0",       "Cluster", false ,"name", false, false, false)
sortkey=["score", "most_popular", "date", "rating", "tomatometer"]
sortYday = Date.today.yday()
puts "#{sortYday}: #{sortkey[sortYday % sortkey.length]}"
#checkWebApiShowInfo("20.1.2.1", "20.1.0", "All",sortkey[sortYday % sortkey.length], false , false, false, false)
#checkWebApiShowInfo("20.1.2.2", "20.1.1", "All", false ,"score", false, false, false)
#checkWebApiShowInfo("20.1.2.3", "20.1.2", "All", false , "most_popular", false, false, false)
#checkWebApiShowInfo("20.1.2.4", "20.1.3", "All", false , "date", false, false, false)
#checkWebApiShowInfo("20.1.2.5", "20.1.4", "All", false , "rating", false, false, false)
#checkWebApiShowInfo("20.1.2.6", "20.1.5", "All", false , "tomatometer", false, false, false)
#checkWebApiShowInfo("20.1.0", "20.1.0", "Strata",false , false, false, false, false)
#checkWebApiShowInfo("20.1.0", "20.1.0", "Filter", false , true , false, false, false)
#checkWebApiShowInfo("20.1.0", "20.1.0", "Filter", false ,false, true , false, false)
#checkWebApiShowInfo("20.1.0", "20.1.0", "Filter", false , false, false, true , false)
#checkWebApiShowInfo("20.1.4", "20.1.4", "Strata", false , "most_popular", false, false, false)
#checkWebApiShowInfo("20.1.4", "20.1.4", "Strata", true , false, false, false, false)
#checkWebApiShowInfo("20.1.0", "20.1.0", "Filter" ,false , false, false, false, true )
#checkWebApiShowInfo("20.1.0", "20.1.0", "Filter" ,true  , false, false, false, true )
