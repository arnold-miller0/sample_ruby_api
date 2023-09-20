require 'digest'   # MD5 , RMD160, SHA1, SHA2
require 'json'     # JSON format parse and buld
require 'httparty' # HTTP methods
require 'csv'      # CSV format and files
require 'uri'      # URI for HTTP comamnds and args
require 'test/unit' # Unit test
extend Test::Unit::Assertions

require_relative 'sample_trap_assert'
require_relative 'sample_class_restrsp'

# Class RestRsp
#   Web API Version, Status
class WebApiURL

  # Weh Host Name;
  @@webHostName = "www.dishanywhere.com"

  #API Normal http URL; in Web Response
  @@apiHttpName = ""

  # API Health Check http URL; in Web Response
  @@apiHttpHeath = ""

  # Method getApiHttpName
  #   Getter for API Http Name
  def getApiHttpName()
    return @@apiHttpName
  end

  # API Test Query Paramter with Getter Methods
  #  Identify API request as Test Request instead of production Request
  @@testArg = "&test=api"
  def getTestArg()
    return @@testArg
  end

# Method getWebApiVersion
#   Gets the Web Version, API Verion, API Health Status values
  def getWebApiVersion(
    printInfo=false # debug print flag
  )
    # varirables to get Web and API GIT Branch values
    webBranch = "0.0.0"
    apiBranch = "0.0.0"
    apiStatus = "none"

    restRsp = RestRsp.new
    path = "health/config_check"

    # set (Web GIT Branch) URL path with args
    baseUri = "https://" + @@webHostName + "/" + path + "?"
    uri_path = baseUri + @@testArg
    puts "Web Branch #{uri_path}" if printInfo
    getRespCode = restRsp.getURL_core(uri_path, nil, printInfo)
    if (getRespCode == restRsp.rspGood())
      jsonBody = restRsp.getRestRspJson()
      webBranch = jsonBody["git"]["branch"]

      # response has
      # API Normal http URL with end /
      # API Health Check http URL without end /
      @@apiHttpName = jsonBody["config"]["session"]["radish_url"]
      @@apiHttpHeath = jsonBody["config"]["session"]["health_check_url"]

      # set (API Git Branch) URL path with args
      baseUri = @@apiHttpName + path + "?"
      uri_path = baseUri + @@testArg
      puts "API branch #{uri_path}" if printInfo
      getRespCode = restRsp.getURL_core(uri_path, nil, printInfo)
      if (getRespCode == restRsp.rspGood())
        apiBranch = restRsp.getRestRspJson()["git"]["branch"]
      end

      # set (API Health Check) URL path with args
      baseUri = @@apiHttpHeath + "?"
      uri_path = baseUri + @@testArg
      puts "API Status #{uri_path}" if printInfo
      getRespCode = restRsp.getURL_core(uri_path, nil, printInfo)
      if (getRespCode == restRsp.rspGood())
        apiStatus = restRsp.getRestRspJson()["status"]
      end
    end
    # Return the Web Version, API Verion, API Health Status values
    return [webBranch, apiBranch, apiStatus]

  end

# Method getApiThirdStatus
#   Get API each third Party Status
  def getApiThirdStatus(
    printInfo=false # debug print flag
  )
    restRsp = RestRsp.new
    # set API third party status URL path with args
    baseUri = @@apiHttpName + "?"
    uri_path = baseUri + @@testArg
    puts "API third party status #{uri_path}" if printInfo
    getRespCode = restRsp.getURL_core(uri_path, nil, printInfo)
    if (getRespCode == restRsp.rspGood())
      # Returns Response Json Body
      return restRsp.getRestRspJson()
    else
      return nil
    end
  end

end
