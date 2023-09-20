require 'digest'   # MD5 , RMD160, SHA1, SHA2
require 'json'     # JSON format parse and buld
require 'httparty' # HTTP methods
require 'csv'      # CSV format and files
require 'uri'      # URI for HTTP comamnds and args
require 'test/unit' # Unit test
extend Test::Unit::Assertions

require_relative 'sample_trap_assert'
require_relative 'sample_class_restrsp'
require_relative 'sample_class_webapiurl'

# Class API TV Shows Information
class TVShowsInfo

  # TV Show Filter Group Path with query parameter
  @@tvShowsFilPath= "franchises?kind=show"

  # TV Show Find Path with query parameter
  @@tvShowsGetPath= "franchises?kind=show"

  # Franchise (TV shows, Movies) Sort Filter Group
  #   With Getter methood
  @@sortFilters = []
  def getSortFilters ()
    return @@sortFilters
  end

  # Franchise (TV shows, Movies) Genre Filter Group
  #   With Getter methood
  @@genreFilters = []
  def getGenreFilters ()
    return @@genreFilters
  end

  # Franchise (TV shows, Movies)Rating Filter Group
  #   With Getter methood
  @@ratingFilters = []
  def getRatingFilters ()
    return @@ratingFilters
  end
  # Franchise (TV shows, Movies) Letter (Staring) Filter Group
  #   With Getter methood
  @@letterFilters = []
  def getLetterFilters ()
    return @@letterFilters
  end

  # Franchise (TV shows, Movies) Eval Error Object initialize
  @@TVShowErrors = {
    :totalCount => 0,   # Total Evaluted TV Show count
    :allNoErrCnt => 0, # No Error TV Shwo Count
    :dupErrorCount => 0, # Duplicate Found Error Count
    :repErrorCount => 0, # Repeat Found Error Count
    :noError => [],    # No Error TV Shows
    :noDesc => [],    # No Description TV Shows
    :noRating => [],  # No Rating TV Shows
    :noGenre => [],  # No Genre TV Shows
    :noNetwork => [],  # No Network TV Shows
    :noImage => []  # No Image TV Shows
  }

  # Method resetTVShowErrors
  #   Franchise (TV shows, Movies) Eval Error Object reset
  def resetTVShowErrors()
    @@TVShowErrors = {
      :totalCount => 0,   # Total Evaluted TV Show count
      :allNoErrCnt => 0, # No Error TV Shwo Count
      :dupErrorCount => 0, # Duplicate Found Error Count
      :repErrorCount => 0, # Repeat Found Error Count
      :noError => [],    # No Error TV Shows
      :noDesc => [],    # No Description TV Shows
      :noRating => [],  # No Rating TV Shows
      :noGenre => [],  # No Genre TV Shows
      :noNetwork => [],  # No Network TV Shows
      :noImage => []  # No Image TV Shows
    }
    end

  def initialize (isTvShows=true)
    if isTvShows
      @@tvShowsFilPath= "franchises?kind=show"
      @@tvShowsGetPath= "franchises?kind=show"
      @@franType="TV-Shows"
    else
      @@tvShowsFilPath= "franchises?kind=movie"
      @@tvShowsGetPath= "franchises?kind=movie"
      @@franType="Movies"
    end
    puts("create with #{isTvShows}") if false
  end

  def getFranType()
    return @@franType
  end

  # Method getTVShowsEvalTotalCount
  # Get Franchise (TV shows, Movies) Eval Error Object's Total Count
  def getTVShowsEvalTotalCount()
    return @@TVShowErrors[:totalCount]
  end

    # Method getTVShowsEvalAllNoErrCnt
    # Get Franchise (TV shows, Movies) Eval Error Object's NO Error Count
  def getTVShowsEvalAllNoErrCnt()
    return @@TVShowErrors[:allNoErrCnt]
  end

    # Method getTVShowsEvalDupErrCount
    # Get Franchise (TV shows, Movies) Eval Error Object's Duplicate Count
  def getTVShowsEvalDupErrCount()
    return @@TVShowErrors[:dupErrorCount]
  end

    # Method getTVShowsEvalRepErrCount
    # Get Franchise (TV shows, Movies) Eval Error Object's Repeat Count
  def getTVShowsEvalRepErrCount()
    return @@TVShowErrors[:repErrorCount]
  end

    # Method getTVShowsnoError
    # Get Franchise (TV shows, Movies) Eval Error Object's No Error TV shows
    def getTVShowsNoError()
      return @@TVShowErrors[:noError]
    end

    # Method getTVShowsNoDesc
    # Get Franchise (TV shows, Movies) Eval Error Object's No Description TV Shows
  def getTVShowsNoDesc()
    return @@TVShowErrors[:noDesc]
  end

    # Method getTVShowsNoRating
    # Get Franchise (TV shows, Movies) Eval Error Object's No Rating TV Shows
  def getTVShowsNoRating()
    return @@TVShowErrors[:noRating]
  end

    # Method getTVShowsNoGenre
    # Get Franchise (TV shows, Movies) Eval Error Object's No Genre TV Shows
  def getTVShowsNoGenre()
    return @@TVShowErrors[:noGenre]
  end

    # Method getTVShowsNoNetwork
    # Get Franchise (TV shows, Movies) Eval Error Object's No Network TV Shows
  def getTVShowsNoNetwork()
    return @@TVShowErrors[:noNetwork]
  end

    # Method getTVShowsNoNetwork
    # Get Franchise (TV shows, Movies) Eval Error Object's No Network TV Shows
  def getTVShowsNoImage()
    return @@TVShowErrors[:noImage]
  end

  # Method getSumErrCount
  # Sum the Error Counts
  def getSumErrCount()
    return (self.getTVShowsNoError().length +
           self.getTVShowsEvalDupErrCount() -
           self.getTVShowsEvalRepErrCount() +
           self.getTVShowsNoDesc().length +
           self.getTVShowsNoRating().length +
           self.getTVShowsNoGenre().length +
           self.getTVShowsNoNetwork().length +
           self.getTVShowsNoImage().length
         )
  end

    # Method getTVShowsEvalSummary
    # Output Franchise (TV shows, Movies) Eval Error Object's Summary
  def getTVShowsEvalSummary(
     preStrg       # pre string before display Information
   )
    totalCount  = self.getTVShowsEvalTotalCount()
    sumErrCount = self.getSumErrCount()
    allNoErrCnt  = self.getTVShowsEvalAllNoErrCnt()
    dupErrCount = self.getTVShowsEvalDupErrCount()
    unqTotCnt = totalCount - dupErrCount
    repErrCount = self.getTVShowsEvalRepErrCount()
    unqNoErrCnt  = self.getTVShowsNoError().length
    noDescCount = self.getTVShowsNoDesc().length
    noRateCount = self.getTVShowsNoRating().length
    noGeneCount = self.getTVShowsNoGenre().length
    noNetwCount = self.getTVShowsNoNetwork().length
    noImagCount = self.getTVShowsNoImage().length
    franType = self.getFranType()
    printf("%s %4d or %5.1f%s",preStrg + " Evaluate", totalCount,  totalCount*100.0/totalCount, "% Total #{franType}\n")
    printf("%s %4d or %5.1f%s",preStrg + " Evaluate", sumErrCount, sumErrCount*100.0/totalCount,"% Count #{franType}\n")
    printf("%s %4d or %5.1f%s",preStrg + "    Found", allNoErrCnt, allNoErrCnt*100.0/totalCount,"% All No Errors\n")
    printf("%s %4d or %5.1f%s",preStrg + "    Found", dupErrCount, dupErrCount*100.0/totalCount,"% Dupilcate Errors\n")
    printf("%s %4d or %5.1f%s",preStrg + "    Found", unqTotCnt,   allNoErrCnt*100.0/totalCount,"% All Unique #{franType}\n")
    printf("%s %4d or %5.1f%s",preStrg + "    Found", unqNoErrCnt, unqNoErrCnt*100.0/unqTotCnt, "% Unique No Errors\n")
    printf("%s %4d or %5.1f%s",preStrg + "    Found", repErrCount, repErrCount*100.0/unqTotCnt, "% Repeat Error Unique\n")
    printf("%s %4d or %5.1f%s",preStrg + "    Found", noDescCount, noDescCount*100.0/unqTotCnt, "% No Description Unique\n")
    printf("%s %4d or %5.1f%s",preStrg + "    Found", noRateCount, noRateCount*100.0/unqTotCnt, "% No Ratings Unique\n")
    printf("%s %4d or %5.1f%s",preStrg + "    Found", noGeneCount, noGeneCount*100.0/unqTotCnt, "% No Generes Unique\n")
    printf("%s %4d or %5.1f%s",preStrg + "    Found", noNetwCount, noNetwCount*100.0/unqTotCnt, "% No Networks Unique\n")
    printf("%s %4d or %5.1f%s",preStrg + "    Found", noImagCount, noImagCount*100.0/unqTotCnt, "% No Images Unique\n")
  end

# Method setApiTVShowsFilters
#  Set TV Shows Filter Groups (Sort, Genre, Rating, Letter)
  def setApiTVShowsFilters (
    printInfo=false # debug print flag
  )
    webApiURL = WebApiURL.new
    restRsp = RestRsp.new
    # set API for TV Shows sort Filter list
    baseUri = webApiURL.getApiHttpName + @@tvShowsFilPath + "&itemStart=0&totalItems=0"
    uri_path = baseUri + webApiURL.getTestArg
    puts "API #{@@franType} sort filters #{uri_path}" if true
    @@sortFilters = []
    @@genreFilters = []
    @@ratingFilters= []
    @@letterFilters = []
    getRespCode = restRsp.getURL_core(uri_path, @@getTVShowHeaaders, printInfo)
    if (getRespCode == restRsp.rspGood())

      # Set API TV Show Sort Filter list
      #   ["sorts"] is array of {"name": "Value", "slug": value} pairs
      sortJsonList = restRsp.getRestRspJson()["sorts"]
      sortJsonList.each do |pair|
        @@sortFilters.push({:webDisplay => pair["name"], :apiSearch => pair["slug"]})
      end

      # set API for TV Shows Genre Filter list
      # ["filters"]["genres"] is array of search strings
      geneJsonList = restRsp.getRestRspJson()["filters"]["genres"]
      geneJsonList.each do |item|
        @@genreFilters.push({:webDisplay => item, :apiSearch => item})
      end

      # set API for TV Shows Rating Filter list
      # ["filters"]["ratings"] is array of {"name": "Value", "slug": value} pairs
      rateJsonList = restRsp.getRestRspJson()["filters"]["ratings"]
      rateJsonList.each do |pair|
        @@ratingFilters.push({:webDisplay =>pair["name"], :apiSearch => pair["slug"]})
      end

      # set API for TV Shows Start-Letter Filter list
      # "starting_letters" is list of key: count
      # where key is an upcase letter or '#'
      #     api search is the lower case letter or '123'
      lettJsonList = restRsp.getRestRspJson()["starting_letters"]
      lettJsonList.each do |key, value|
        if key == "#"
          @@letterFilters.push({:webDisplay => key, :apiSearch => "123", :count => value})
        else
          @@letterFilters.push({:webDisplay => key, :apiSearch => key.downcase, :count => value})
        end
      end
    end
  end

# Method setShowObj
#   Set intneral TV Show  Object via API reponsse TV Show Json Object
  def setShowObj(
    count,          # count of show in list of shows
    showJson,       #  JSON response show object
    printInfo=false # debug print flag
  )
    showObj = {
      :index => count,
      :desc => showJson["description"],  # description
      :name => showJson["name"],         # name
      :search => showJson["slug"],       # unique Search Id
      :kind => showJson["kind"],         # kind
      :rating => showJson["rating"],     # Raiing List
      :genreList => showJson["genres"],  # Genre List
      :networkList => [],                # Network List
      :imageUrl => showJson["images"]["poster_url"] # Image Url
    }

    # description must be a string  (default empty)
    if (showObj[:desc].nil? || !showObj[:desc].is_a?(String))
      showObj[:desc] = ""
    end

    # Rating list must be list  (default empty)
    if (showObj[:rating].nil? || !showObj[:rating].is_a?(Array))
      showObj[:rating] = []
    end

    # Genre list must be list  (default empty)
    if (showObj[:genreList].nil? || !showObj[:genreList].is_a?(Array))
      showObj[:genreList] = []
    end

    # Network list must be list (default empty)
    if (!showJson["networks"].nil?)
      showJson["networks"].each do |network|
        showObj[:networkList].push(network["name"])
      end
    end

    # imageUrl must be a string  (default empty)
    if (showObj[:imageUrl].nil? || !showObj[:imageUrl].is_a?(String))
      showObj[:imageUrl] = ""
    end

    return showObj
  end

  # Method evalShowObj
  #   Evalute ShowObj for error and count
  #   when find error uses Method addShowErrorList to only add Unique TV Show to List
  def evalShowObj(
     preStrg,       # pre string before display Information
     showObj,       # Internal ShowObj to display
    printInfo=false # debug print flag
  )

    @@TVShowErrors[:totalCount] += 1
    noError = true

    # No Description Error, add when not already in No Desc List
    if (showObj[:desc].empty?)
       noError = addShowErrorList(
         noError, "No Desc", showObj, @@TVShowErrors[:noDesc], preStrg, true, printInfo)
    end
    # No Rating Error, add when not already in No Rate List
    if (showObj[:rating].empty?)
      noError = addShowErrorList(
        noError, "No Rate", showObj, @@TVShowErrors[:noRating], preStrg, true, printInfo)
    end

    # No Genre Error, add when not already in No Genre List
    if (showObj[:genreList].empty?)
        noError = addShowErrorList(
          noError, "No Gene", showObj, @@TVShowErrors[:noGenre], preStrg, true, printInfo)
    end

    # No Network Error, add when not already in No Network List
    if (showObj[:networkList].empty?)
        noError = addShowErrorList(
          noError, "No Netw", showObj, @@TVShowErrors[:noNetwork], preStrg, true, printInfo)
    end

    # No Image Error, add when not already in No Image List
    if (showObj[:imageUrl].empty?)
        noError = addShowErrorList(
          noError, "No Imag", showObj, @@TVShowErrors[:noImage], preStrg, true, printInfo)
    end

    if (noError)
      @@TVShowErrors[:allNoErrCnt] += 1
      noError = addShowErrorList(
        true, "No Erro", showObj, @@TVShowErrors[:noError], preStrg, false, printInfo)
      printShowObj(preStrg + " All No Err: ", showObj) if printInfo
    end

  end

  # Method printShowSummary
  # ouputs TV Show Summaty information
  # Like file: mersive_check_aptvshowinfo; Method: outputErrorList
  #   Outputs TV Show's Franchise Search, Type, Kind, Name
    def printShowSummary(
      preStrg,       # pre string before display Information
      showObj,       # Internal ShowObj to display
      tag=true       # True print tags; otherwise not tags
    )
    strg = "#{preStrg}; "
    if tag
      strg += "search: #{showObj[:search]}; kind: #{showObj[:kind]}; name: #{showObj[:name]}"
    else
        strg += "#{showObj[:search]}; #{showObj[:kind]}; #{showObj[:name]}"
    end
      puts strg
    end

# Method printShowObj
#   output TV Show detail information
  def printShowObj(
    preStrg,       # pre string before display Information
    showObj        # Internal ShowObj to display
  )
    strg = "#{preStrg}; index: #{showObj[:index]}" +
      "; kind: #{showObj[:kind]}" +
      "; name: #{showObj[:name]}" +
      "; desc.length: #{showObj[:desc].length}" +
      "; search: #{showObj[:search]}"+
      "; rating: #{showObj[:rating]}" +
      "; gList: #{showObj[:genreList]}" +
      "; nList: #{showObj[:networkList]}" +
      "; imageUrl.length: #{showObj[:imageUrl].length}";
    puts strg
  end

  @@getTVShowHeaaders = {:accept=> "application/vnd.echostar.franchises+json;version=1"}
  # Method getApiTVShowsFilter
  # Get TV Shows via specific Filter's Search Key
  # returns; Count of all TV show via fiter, Found TV Show Count, Found TV Show List
  def getApiTVShowsFilter (
    searchParam,    # search URL parameter
    searchKey,      # search Key value
    displayKey,     # display Key value
    printInfo=false # debug print flag
  )
    webApiURL = WebApiURL.new
    restRsp = RestRsp.new
    # set API for get TV Shows via search param value
    baseUri = webApiURL.getApiHttpName + @@tvShowsGetPath + "&" + searchParam + "=" + searchKey
    case searchParam
    when "sort"  # get first 100 items like web site
      itemParamValue = "&itemStart=0&totalItems=100"
    when "genres"  # get first 50 items
      itemParamValue = "&itemStart=0&totalItems=50"
    when "ratings" # get first 50 items
      itemParamValue = "&itemStart=0&totalItems=50"
    when "starting_letter" # get first 25 items
        itemParamValue = "&itemStart=0&totalItems=25"
    else  # get first default (12) items
        itemParamValue = ""
    end
    uri_path = baseUri + itemParamValue + webApiURL.getTestArg
    puts "API TV Shows via #{displayKey} #{uri_path}" if printInfo
    tvShowsList = []
    tvShowsTotal = 0
    tvShowsCount = 0
    getRespCode = restRsp.getURL_core(uri_path, @@getTVShowHeaaders, printInfo)
    if (getRespCode == restRsp.rspGood())
      tvShowsJson = restRsp.getRestRspJson()
      tvShowsTotal = tvShowsJson["count"]
            tvShowsCount = tvShowsJson["franchises"].length
      puts "  Shows #{searchParam} via #{displayKey}; Total: #{tvShowsTotal}; Count #{tvShowsCount};"
      count = 0
      tvShowsJson["franchises"].each do |show|
        # puts "    count #{count} show"
        showObj = self.setShowObj(count,show)
        tvShowsList.push(showObj)
        count += 1
      end
    end
    # Count of all TV show via fiter, Found TV Show Count, Found TV Show List
    return [tvShowsTotal, tvShowsCount, tvShowsList]
  end

  # Method getApiTVShowEval
  # Get TV Shows via
  # returns; Count of all TV show via fiter, Found TV Show Count, Found TV Show List
  def getApiTVShowEval (
    itemStart,    # start offset for TV Shows
    totalItems,   # max TV shows to return
    sortKey,      # sort key value
    letterKey=nil, # Optional starting-letter key
    printResp=false, # debug print get resp summary
    printInfo=false # debug print flag
  )
    webApiURL = WebApiURL.new
    restRsp = RestRsp.new
    # set API for get TV Shows via search param value
    baseUri = webApiURL.getApiHttpName + @@tvShowsGetPath +
      "&itemStart=#{itemStart}&totalItems=#{totalItems}" +
      "&sort=#{sortKey}"
      if (letterKey.is_a?(String))
        baseUri += "&starting_letter=#{letterKey}"
        putLetter = "letter #{letterKey};"
      else
        putLetter = ""
      end
    uri_path = baseUri + webApiURL.getTestArg
    puts "API #{@@franType} via start: #{itemStart}; max: #{totalItems}; sort #{sortKey}; " + putLetter + " #{uri_path}" if printInfo
    tvShowsList = []
    tvShowsTotal = 0
    tvShowsCount = 0
    getRespCode = restRsp.getURL_core(uri_path, @@getTVShowHeaaders, printInfo)
    if (getRespCode == restRsp.rspGood())
      tvShowsJson = restRsp.getRestRspJson()
      tvShowsTotal = tvShowsJson["count"]
      tvShowsCount = tvShowsJson["franchises"].length
      puts "  Shows start: #{itemStart}; max: #{totalItems}; sort #{sortKey}; " + putLetter +
           " Total: #{tvShowsTotal}; Count #{tvShowsCount};" if printResp
      count = 0
      tvShowsJson["franchises"].each do |show|
        # puts "    count #{count} show"
        showObj = self.setShowObj(count,show)
        tvShowsList.push(showObj)
        count += 1
      end
    end
    # Count of all TV show via fiter, Found TV Show Count, Found TV Show List
    return [tvShowsTotal, tvShowsCount, tvShowsList]
  end

  # start Private Methods
  private

  # Method addShowErrorList (Private)
  #  Add TV Show Object to Error Show List when not already in that List
  def addShowErrorList(
    noError,        #  Not found error yet
    errorType,      #  Type of Error
    showObj,        #  Show Object that has error
    errorShowList,  #  Error List to store Show Object
    preStrg,        # pre string before display Information
    printAdd=false, # print when add to list
    printInfo=false # debug print flag
  )
    # Is  this First error for TV Show
    if (noError)
      noError = false
    else
        # not first error, so increase Repeat count
        @@TVShowErrors[:repErrorCount] += 1
    end

    # Search for alreay in Error Show List
    matchShow = errorShowList.select do |show|
      show[:search] == showObj[:search]
    end
    # when not in list add to List
    if (matchShow.empty?)
      errorShowList.push(showObj)
      self.printShowSummary("  #{preStrg} Added to #{errorType} List",showObj, false) if printAdd
      printShowObj(preStrg + " #{errorType}: ", showObj) if printInfo
    else
      # Already in list, increase Duplicate count
      @@TVShowErrors[:dupErrorCount] += 1
      self.printShowSummary("  #{preStrg} Exist in #{errorType} List",showObj, false)
    end
    return noError
  end

  # end Class
end
