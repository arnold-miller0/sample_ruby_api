require 'digest'   # MD5 , RMD160, SHA1, SHA2
require 'json'     # JSON format parse and buld
require 'httparty' # HTTP methods
require 'csv'      # CSV format and files
require 'uri'      # URI for HTTP comamnds and args
require 'time'     # date time
require 'test/unit' # Unit test
require 'abanalyzer' # Stat AB analyzer
extend Test::Unit::Assertions

require_relative 'sample_trap_assert'
require_relative 'sample_class_restrsp'
require_relative 'sample_class_webapiurl'
require_relative 'sample_class_tvshowinfo'
require_relative 'sample_check_webapiinfo'
require_relative 'sample_check_aptvshowinfo'

# API TV Show check file

#  Method checkApiTVShowFiltersList
#  Aftr Set API TV Show Filter groups
#     Sort
#     Genre
#     Rating
#     letter (Starting Letter)
#  Check that each Filter group has value count of filters
def checkApiTVShowFiltersList (
  isTvShows,      # true TV Shows; false Movies
  printInfo=false # debug print flag
)
  tvShowsInfo = TVShowsInfo.new isTvShows
  tvShowsMovies = tvShowsInfo.getFranType()
  puts "Expect: API #{tvShowsMovies} Filters groups:"
  tvShowsInfo.setApiTVShowsFilters(printInfo)

  puts "Expect: API #{tvShowsMovies} Sort Group"
trap_NumEQ(tvShowsInfo.getSortFilters.size, 6, "API #{tvShowsMovies} Sort count(=6)",true)

  puts "Expect: API #{tvShowsMovies} Genre Group"
  trap_NumGT(tvShowsInfo.getGenreFilters.size, 3, "API #{tvShowsMovies} Genre count(>3)",true)

  puts "Expect: API #{tvShowsMovies} Rating Group"
  trap_NumGT(tvShowsInfo.getRatingFilters.size, 4, "API #{tvShowsMovies} Rating count(>4)",true)

  puts "Expect: API #{tvShowsMovies} Letter Group"
  trap_NumEQ(tvShowsInfo.getLetterFilters.size, 27, "API #{tvShowsMovies} Letter count(=27)",true)

end

# Method checkApiTVShowsFilter
# For specific Filter Group (Sort, Genre, Rating, Letter)
#   Find default TV Shows for each filter's search in Specific Filter Group
#     via tvShowsInfo.getApiTVShowsFilter()
#     Report Filter found result counts
#   Then Evbluate each found TV show for Errors with Counts
#     via tvShowsInfo.evalShowObj()
#     No Description
#     No Rating
#     No Genre
#     No Network
def checkApiTVShowsFilter (
  isTvShows,       # true TV Shows; false Movies
  filterType,      # type of Filter
  filterPairs,     # Array of Filter pairs (:apiSearch, :webDisplay)
  resResultFP,     # output result file
  printInfo=false  # debug print flag
  )
  tvShowsInfo = TVShowsInfo.new isTvShows
  tvShowsMovies = tvShowsInfo.getFranType()
  resResultFP << ["", "Filter", "Display", "Search", "Total", "Count"]
  genCount = 0
  filterPairs.each do |gen|
    genSearch = gen[:apiSearch]
    genDisplay = gen[:webDisplay]
    case filterType
    when "Sort"
      tvShowTotal, tvGenCount, tvShowsList = tvShowsInfo.getApiTVShowsFilter("sort", genSearch, genDisplay, printInfo)
      resResultFP << ["", "sort", genDisplay, genSearch, tvShowTotal, tvGenCount]
    when "Genre"
      tvShowTotal, tvGenCount, tvShowsList = tvShowsInfo.getApiTVShowsFilter("genres",genSearch, genDisplay, printInfo)
      resResultFP << ["", "genres", genDisplay, genSearch, tvShowTotal, tvGenCount]
    when "Rating"
      tvShowTotal, tvGenCount, tvShowsList = tvShowsInfo.getApiTVShowsFilter("ratings",genSearch, genDisplay, printInfo)
      resResultFP << ["", "ratings", genDisplay, genSearch, tvShowTotal, tvGenCount]
    when "Letter"
      tvShowTotal, tvGenCount, tvShowsList = tvShowsInfo.getApiTVShowsFilter("starting_letter",genSearch, genDisplay, printInfo)
      resResultFP << ["", "letter", genDisplay, genSearch, tvShowTotal, tvGenCount]
    else
      puts "Invalid FilterType #{filterType}; exit function"
      resResultFP << []
      return
    end
    genCount += tvGenCount
    showCount=0
    tvShowsList.each do |show|
      tvShowsInfo.evalShowObj(filterType + ": #{genDisplay} #{showCount}", show, printInfo)
      showCount += 1
    end
  end
  resResultFP << []
  puts filterType + ": Search found #{genCount} #{tvShowsMovies}"
  tvShowsInfo.getTVShowsEvalSummary(filterType + ":")
  puts ""
end

def getRandomStart(
  rInts,   # number of random integers
  maxInt,   # Max Integerfile
  printInfo=false # debug print flag
)
  rArray = []
  # puts " Get #{rInts} Random Start value with Max #{maxInt}"
  prng = Random.new
  dup = 0
  rInts.times {
    r = prng.rand(maxInt)
    if rArray.include?(r)
      dup += 1
      puts "  Already #{r} in start array" if printInfo
    else
      rArray.push(r)
    end
  }
  puts " Wanted: #{rInts}; Max: #{maxInt}; Unique: #{rArray.length}; Duplicate: #{dup};"
  return rArray.sort
end

# Method checkApiTVShowEval
def checkApiTVShowEval(
  evalType,       # Evaluation Type
  isTvShows,      # true TV Shows; false Movies
  sortKey,        # sort key value
  preStrg,        # Pre output String
  resResultFP,    # output result file
  printInfo=false # debug print flag
)
  tvShowsInfo = TVShowsInfo.new isTvShows
  tvShowsMovies = tvShowsInfo.getFranType()
  genCount = 0

  case sortKey
  when 'name'
  sortVal = 'Title'
  when 'score'
    sortVal = 'Relevance'
  when 'most_popular'
    sortVal = 'Most Popular'
  when 'date'
    sortVal = 'Date Added'
  when 'rating'
    sortVal = 'Critics Rating'
  when 'tomatometer'
    sortVal = 'Tomatometer'
  else
    puts "sortKey: #{sortKey} reset to name"
    resResultFP << ["sortKey", sortKey, "name" ]
    sortKey = 'name'
    sortVal = 'Title'
  end

  preTVString = preStrg + " " + evalType + " " + sortKey
  case evalType
  when 'All'
    # get total Count
    tvShowTotal, tvGenCount, tvShowsList = tvShowsInfo.getApiTVShowEval(0, 0, sortKey, nil, false, printInfo)
    groupSize = 100
    loops = (tvShowTotal/groupSize)+1
    resResultFP << ["EvalType", "sortVal", "start", "Max", "Total", "Count"]
    loops.times { |start|
      itemStart = start*groupSize
      tvShowTotal, tvGenCount, tvShowsList = tvShowsInfo.getApiTVShowEval(itemStart, groupSize, sortKey, nil, true, printInfo)
      resResultFP << ["Eval All", sortVal, itemStart, groupSize, tvShowTotal, tvGenCount]
      genCount += tvGenCount
      showCount=0
      tvShowsList.each do |show|
        tvShowsInfo.evalShowObj(preTVString + ": start #{itemStart} #{showCount}", show, printInfo)
        showCount += 1
      end
    }
  when 'Random'
    # get total Count
    tvShowTotal, tvGenCount, tvShowsList = tvShowsInfo.getApiTVShowEval(0, 0, sortKey, nil, false, printInfo)
    groupSize = 1
    intRads = tvShowTotal/(10*groupSize)
    maxRad  = (tvShowTotal/groupSize)+1
    # get random Start values
    startArray = getRandomStart(intRads, maxRad)
    resResultFP << ["EvalType", "sortVal", "EvalMax", "EvalAmt",       "Size",     "#{tvShowsMovies}"]
    resResultFP << [evalType,    sortVal,    intRads, startArray.length, groupSize, tvShowTotal]
    # For each start Array get is only TV Show via sort name
    startArray.each { |start|
      itemStart = start*groupSize
      tvShowTotal, tvGenCount, tvShowsList = tvShowsInfo.getApiTVShowEval(itemStart, groupSize, sortKey, nil, false, printInfo)
      genCount += tvGenCount
      showCount=0
      tvShowsList.each do |show|
        tvShowsInfo.evalShowObj(preTVString + ": start #{itemStart} #{showCount}", show, printInfo)
        showCount += 1
      end
    }
  when 'Cluster'
    # get total Count
    tvShowTotal, tvGenCount, tvShowsList = tvShowsInfo.getApiTVShowEval(0, 0, sortKey, nil, false, printInfo)
    # get cluster Start values
    groupSize = 10
    intRads = tvShowTotal/(10*groupSize)
    maxRad  = (tvShowTotal/groupSize)+1
    startArray = getRandomStart(intRads, maxRad)
    resResultFP << ["EvalType", "sortVal", "EvalMax", "EvalAmt",        "Size",     "#{tvShowsMovies}"]
    resResultFP << [evalType,    sortVal,   intRads,  startArray.length, groupSize, tvShowTotal]
    # For each start Array get its Cluster TV Show via sort name
    startArray.each { |start|
      itemStart = start*groupSize
      tvShowTotal, tvGenCount, tvShowsList = tvShowsInfo.getApiTVShowEval(itemStart, groupSize, sortKey, nil, false, printInfo)
      genCount += tvGenCount
      showCount = 0
      tvShowsList.each do |show|
        tvShowsInfo.evalShowObj(preTVString + ": start #{itemStart} #{showCount}", show, printInfo)
        showCount += 1
      end
    }
  when 'Strata'
    # get total Count
    puts("Strata API #{tvShowsInfo.getFranType()} via #{sortKey}")
    tvShowTotal, tvGenCount, tvShowsList = tvShowsInfo.getApiTVShowEval(0, 0, sortKey, nil, false, printInfo)
    # get Strata via Starting letterFilters
    checkApiTVShowFiltersList(isTvShows, printInfo)
    groupSize = 1
    stratArray = []
    straCount = 0
    straTotal = 0
    tvShowsInfo.getLetterFilters.each do |letter|
      # proRate random items for each Letter strata via its count with at least 1
      lSearch = letter[:apiSearch]
      lDisplay = letter[:webDisplay]
      letTotal, letGenCount, letShowsList = tvShowsInfo.getApiTVShowEval(0, 0, sortKey, lSearch, false, printInfo)
      maxRad = letTotal/groupSize
      maxRad = 1 if maxRad == 0
      intRads = (maxRad/(10.0*groupSize)).round(0)
      intRads = 1 if intRads == 0
      straTotal += intRads
      puts(" lSearch: #{lSearch}, lDisplay: #{lDisplay}, maxRad: #{maxRad}, intRads: #{intRads}") if printInfo
      startArray = getRandomStart(intRads, maxRad)
      straCount += startArray.length
      stratArray.push({:lSearch => lSearch, :lDisplay => lDisplay,
                        :maxRad => maxRad, :intRads => intRads,
                        :sArray => startArray})
    end

    resResultFP << ["EvalType", "sortVal", "EvalMax", "EvalAmt", "Size", "#{tvShowsMovies}"]
    resResultFP << [evalType,    sortVal,  straTotal,  straCount, groupSize, tvShowTotal]
    # loop through each strata letter getting and evaluating random TV Shows
    stratArray.each do |strata|
      lSearch = strata[:lSearch]
      lDisplay = strata[:lDisplay]
      intRads = strata[:intRads]
      maxRad = strata[:maxRad]
      startArray = strata[:sArray]
      resResultFP << ["", "Letter #{lDisplay}", intRads,  startArray.length, groupSize, maxRad]
      startArray.each do |start|
        itemStart = start*groupSize
        tvShowTotal, tvGenCount, tvShowsList = tvShowsInfo.getApiTVShowEval(itemStart, groupSize, sortKey, lSearch, false, printInfo)
        genCount += tvGenCount
        showCount=0
        tvShowsList.each do |show|
          tvShowsInfo.evalShowObj(preTVString + ": start #{itemStart} #{showCount}", show, printInfo)
          showCount += 1
        end
      end
    end
  else
    puts "Not found evalType #{evalType}"
  end
  resResultFP << []
  puts evalType + " Search found #{genCount} #{tvShowsMovies}"
  tvShowsInfo.getTVShowsEvalSummary(evalType + ":")
end

# Method checkApiTVShowsSort
#  Find and Evaluate TV Shows using Sort Filter Group
#  via method Search found
#  Pass Report file to real Find, Evalute Method
def checkApiTVShowsSort (
  resResultFP,     # output result file
  isTvShows,       # true TV Shows; false Movies
  printInfo=false  # debug print flag
)
  tvShowsInfo = TVShowsInfo.new isTvShows
  checkApiTVShowsFilter(isTvShows, "Sort",tvShowsInfo.getSortFilters(), resResultFP,printInfo)
end

# Method checkApiTVShowsGenre
#  Find and Evaluate TV Shows using Genre Filter Group
#  via method checkApiTVShowsFilter
#  Pass Report file to real Find, Evalute Method
def checkApiTVShowsGenre (
  resResultFP,     # output result file
  isTvShows,       # true TV Shows; false Movies
  printInfo=false  # debug print flag
)
  tvShowsInfo = TVShowsInfo.new isTvShows
  checkApiTVShowsFilter(isTvShows, "Genre",tvShowsInfo.getGenreFilters(), resResultFP, printInfo)
end

# Method checkApiTVShowsRating
#  Find and Evaluate TV Shows using Rating Filter Group
#  via method checkApiTVShowsFilter
#  Pass Report file to real Find, Evalute Method
def checkApiTVShowsRating (
  resResultFP,     # output result file
  isTvShows,       # true TV Shows; false Movies
  printInfo=false  # debug print flag
)
  tvShowsInfo = TVShowsInfo.new isTvShows
  checkApiTVShowsFilter(isTvShows, "Rating",tvShowsInfo.getRatingFilters(), resResultFP, printInfo)
end

# Method checkApiTVShowsLetter
#  Find and Evaluate TV Shows using Letter Filter Group
#  via method checkApiTVShowsFilter
#  Pass Report file to real Find, Evalute Method
def checkApiTVShowsLetter (
  resResultFP,     # output result file
  isTvShows,       # true TV Shows; false Movies
  printInfo=false  # debug print flag
)
  tvShowsInfo = TVShowsInfo.new isTvShows
  checkApiTVShowsFilter(isTvShows, "Letter",tvShowsInfo.getLetterFilters(), resResultFP, printInfo)
end

# Method chkExistsResultFile
#  Create Report output file
def chkExistsResultFile (fullResPath)
  if not (File.exist? fullResPath)
    puts "create result file: #{fullResPath} as not exist"
    File.new(fullResPath, File::CREAT|File::TRUNC|File::RDWR )
  end
end

# Method outputErrorList
#   writes to Report File specific Found Error Type TV shows
#   This is simiar to Class: TVShowsInfo;  Method: printShowSummary
#   Writes for each TV Shows its Franchise Search, Type, Kind, Name
def outputErrorList(
  resResultFP,   # result output file
  preStrg,       # Pre output String
  errorType,     # Error Type
  errorList,     # error List
  totalCount     #  total error count
)
  #resResultFP << [preStrg, errorType, errorList.length, (errorList.length*100.0/totalCount).round(1)]
  if (errorList.length > 0)
    resResultFP << [preStrg, errorType, "franchise", "Kind", "Name"]
    errorList.each do |show|
      resResultFP << ["", errorType, show[:search], show[:kind], show[:name] ]
    end
    resResultFP << []
  end
end

# Method checkWebAPIStatus
def checkWebAPIStatus (
  webVersion,     # Web expect status version
  apiVersion,     # API expect status version
  resResultFP,    # output result file
  printInfo=false # debug print flag
)
  # Check and Report on Web Version; API Version; API Health
  resResultFP << ["Compare", "Expect", "Actual", "Match"]
  actWebVer, actApiVer, actApiStatus = checkWebApiVersion(webVersion, apiVersion, "ok", true)
  resResultFP << ["Web Version", webVersion, actWebVer, webVersion == actWebVer]
  resResultFP << ["API Version", apiVersion, actApiVer, apiVersion == actApiVer]
  resResultFP << ["API Status", "ok", actApiStatus, "ok" == actApiStatus]
  resResultFP << [""]

  # Check and Report on API Third Party Status
  exp3rdStatus = "green"
  haveThird, noExpThird = checkApiThirdStatus(exp3rdStatus, printInfo)
  pre3rdStrg = "API 3rd Party"
  if haveThird
    if noExpThird.empty?
      resResultFP << [pre3rdStrg, "All Status", exp3rdStatus]
    else
      resResultFP << [pre3rdStrg, "Not Status", exp3rdStatus]
      noExpThird.each do |third|
        resResultFP << ["", third[0], third[1]]
      end
    end
  else
    resResultFP << [pre3rdStrg, "No Status", "Exists"]
  end
  resResultFP << [""]
end

def outputCountInfo(
  type,
  count,
  total,
  resResultFP,  # output result file
  doCnf=false
)
  precent = (count*100.0/total).round(1)
  outInfo = ["",type, count, precent]
  if doCnf
    low95raw, high95raw = ABAnalyzer.confidence_interval(count,total, 0.95)
    outInfo.push((low95raw*100).round(1))
    outInfo.push((high95raw*100).round(1))
  end
  resResultFP << outInfo
end

def outputFranErrors(
  preStrg,     # Pre output String
  franInfo,    # TV show (franchise) Info Error Object
  resResultFP  # output result file
)
  # Get Total and Sum Counts from Evaluated all found TV Shows (Franchise)
  totalCount = franInfo.getTVShowsEvalTotalCount()
  sumErrCount = franInfo.getSumErrCount()
  trap_NumEQ(totalCount,sumErrCount,"Total Eval is Sum Eval",true)
  dupErrCount = franInfo.getTVShowsEvalDupErrCount()
  unqTotCnt = totalCount - dupErrCount

  # Write Results of Evaluated all found TV Shows
  resResultFP << [preStrg,"Information", "Count", "Precent", "95% Low", "95% High"]
  outputCountInfo("Total Eval", totalCount,  totalCount, resResultFP, false)
  outputCountInfo("Sum Eval",   sumErrCount, totalCount, resResultFP, false)
  outputCountInfo("All No Err", franInfo.getTVShowsEvalAllNoErrCnt(),  totalCount, resResultFP, true)
  outputCountInfo("Dupilcate",  dupErrCount, totalCount, resResultFP, true)
  outputCountInfo("All Unique", unqTotCnt,   totalCount, resResultFP, true)
  outputCountInfo("Unq No Err", franInfo.getTVShowsNoError().length,   unqTotCnt, resResultFP, true)
  outputCountInfo("Repeat Err", franInfo.getTVShowsEvalRepErrCount(),  unqTotCnt, resResultFP, true)
  outputCountInfo("No Descripion", franInfo.getTVShowsNoDesc().length, unqTotCnt, resResultFP, true)
  outputCountInfo("No Rating",  franInfo.getTVShowsNoRating().length,  unqTotCnt, resResultFP, true)
  outputCountInfo("No Genre",   franInfo.getTVShowsNoGenre().length,   unqTotCnt, resResultFP, true)
  outputCountInfo("No Network", franInfo.getTVShowsNoNetwork().length, unqTotCnt, resResultFP, true)
  outputCountInfo("No Image",   franInfo.getTVShowsNoImage().length,   unqTotCnt, resResultFP, true)
  resResultFP << []
  outputErrorList(resResultFP, preStrg, "No Descripion",franInfo.getTVShowsNoDesc(), unqTotCnt)
  outputErrorList(resResultFP, preStrg, "No Rating",franInfo.getTVShowsNoRating(), unqTotCnt)
  outputErrorList(resResultFP, preStrg, "No Genre",franInfo.getTVShowsNoGenre(), unqTotCnt)
  outputErrorList(resResultFP, preStrg, "No Network",franInfo.getTVShowsNoNetwork(), unqTotCnt)
  outputErrorList(resResultFP, preStrg, "No Image",franInfo.getTVShowsNoImage(), unqTotCnt)
end

# Method checkWebApiShowInfo
# Main Method that Checks and Reports on
#   Web Git version
#   API Git Version
#   API Health status
#   API Third Party status
#   API TV Show Find using Filter Groups
#   Found API TV Show evalute for error
def checkWebApiShowInfo(
  webVersion,         # Web expect status version
  apiVersion,         # API expect status version
  evalType='Filter',  # Show Info Type (default 'None')
                      # 'None' no evaluation
                      # 'Filter' via each Filter Group (Sort, Rating, Genre, Letters)
                      # 'All'    via All TV Shows (sort name)
                      # 'Random' via Simple Random (sort name)
                      # 'Cluster' via Cluster Random (sort name)
                      # 'Strata' via Starified Random (sort name)
  isTvShows=true,     # true TV Shows; false Movies
  filterSort=false,   # check Show via Sort Filters
  filterGenre=false,  # check Show via Genre Filters
  filterRating=false, # check Show via Rating Filters
  filterLetter=false, # check Show  via LEtter Filters
  printInfo=false     # debug print flag
)

  # Set Start Time resutltDirectory
  startTimeUTC = Time.now.utc
  sCurrentDate = startTimeUTC.strftime("%Y_%m_%d_%H_%M_%S") # for ressult report file
  resutltDirectory = "./results"

  # set Franchice Type (TV Shows or Movies)
  tvShowsInfo = TVShowsInfo.new isTvShows
  tvShowsMovies = tvShowsInfo.getFranType()

  # Open Result Output File
  fullResultPath = File.absolute_path("result_api#{tvShowsMovies}_#{sCurrentDate}.csv", resutltDirectory)
  chkExistsResultFile fullResultPath
  puts "open result file #{fullResultPath}"
  resResultFP = CSV.open(fullResultPath,"w")

  # Write start time UTC to Report file
  resResultFP << ["API TV Show Results", "Time UTC: ", sCurrentDate]
  resResultFP << [""]
  checkWebAPIStatus(webVersion,apiVersion,resResultFP)

  # Find and Evaluate TV Shows using any Filter Group
  preTVshowStrg = "API #{tvShowsMovies}"
  tvShowsInfo.resetTVShowErrors
  evalError = false
  case evalType.upcase()[0]
  when 'A'
    # filterSort is the All sort value
    puts "Evalute #{tvShowsMovies} All via sort #{filterSort}"
    evalError = true
    checkApiTVShowEval("All", isTvShows, filterSort, preTVshowStrg, resResultFP, printInfo)
  when 'R'
    # filterSort is the Random sort value
    puts "Evalute #{tvShowsMovies} Random via sort #{filterSort}"
    evalError = true
    checkApiTVShowEval("Random", isTvShows, filterSort, preTVshowStrg, resResultFP, printInfo)
  when 'C'
    # filterSort is the Cluster sort value
    puts "Evalute #{tvShowsMovies} Cluster via sort #{filterSort}"
    evalError = true
    checkApiTVShowEval("Cluster", isTvShows, filterSort, preTVshowStrg, resResultFP, printInfo)
  when 'S'
    # filterSort is the Strata sort value
    # filterSort = "name"
    puts "Evalute #{tvShowsMovies} Strata via sort #{filterSort}"
    evalError = true
    checkApiTVShowEval("Strata", isTvShows, filterSort, preTVshowStrg, resResultFP, printInfo)
  when 'F'
    puts "Evaluate #{tvShowsMovies} per Filter Groups"
    if (filterSort || filterGenre || filterRating || filterLetter)
      evalError = true
      resResultFP << [preTVshowStrg, "Error Report"]
      checkApiTVShowFiltersList(isTvShows, printInfo)
      # Find and Evaluate using Sort Filter Group
      if filterSort
        resResultFP << [preTVshowStrg, "Error Report","via Sorts"]
        checkApiTVShowsSort(resResultFP, isTvShows, printInfo)
      end
      # Find and Evaluate using Genre Filter Group
      if filterGenre
        resResultFP << [preTVshowStrg, "Error Report","via Genre"]
        checkApiTVShowsGenre(resResultFP, isTvShows, printInfo)
      end
      # Find and Evaluate using Rating Filter Group
      if filterRating
        resResultFP << [preTVshowStrg, "Error Report","via Rating"]
        checkApiTVShowsRating(resResultFP, isTvShows, printInfo)
      end
      # Find and Evaluate using letter Filter Group
      if filterLetter
        resResultFP << [preTVshowStrg, "Error Report","via Letter"]
        checkApiTVShowsLetter(resResultFP, isTvShows, printInfo)
      end
    else
      puts "No Filter Groups"
      evalError = false
    end
  else
    puts "No Evaluate #{tvShowsMovies}"
    evalError = false
  end
  puts ""
  if evalError
    # output TV Show Error Objects (Franchise)
    outputFranErrors(preTVshowStrg, tvShowsInfo, resResultFP)
  end

  # Write end time UTC to Report file
  endTimeUTC = Time.now.utc
  eCurrentDate = endTimeUTC.strftime("%Y_%m_%d_%H_%M_%S")
  resResultFP << [""]
  durTime = endTimeUTC - startTimeUTC
  durSec = durTime.round(0) % 60
  durMin = durTime.round(0) / 60
  resResultFP << ["API #{tvShowsMovies} Done", "Time UTC: ", eCurrentDate]
  resResultFP << ["API #{tvShowsMovies} Took", evalType, "Minutes:", durMin ] if (durMin > 0)
  resResultFP << ["API #{tvShowsMovies} Took", evalType, "Seconds:", durSec ]
  resResultFP.close

end
