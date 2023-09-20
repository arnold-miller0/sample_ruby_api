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
require_relative 'sample_class_tvshowinfo'

# Web API Status check Methods

# Method checkWebApiVersion
#   Checks that Web Version, API Version, API health status
#   Matched expected values via webApiURL.getWebApiVersion()
#   Using Trapped Unit Test Asserts
  def checkWebApiVersion (
    webVersion,     #  Web expect status version
    apiVersion,     # API expectstatus version
    apiEStatus,     # API expect health status
    printInfo=false # debug print flag
  )
    webApiURL = WebApiURL.new
    puts "Expect: Web Version: #{webVersion}; API Version: #{apiVersion}; API Status: #{apiEStatus}"
    webGBranch, apiGBranch, apiHStatus = webApiURL.getWebApiVersion(printInfo)
    trap_Equals(webVersion, webGBranch, "Web Version")
    trap_Equals(apiVersion, apiGBranch, "API Version")
    trap_Equals(apiEStatus, apiHStatus, "API Status")
    return [webGBranch, apiGBranch, apiHStatus]
  end

  # Method checkApiThirdStatus
  #   Checks that API third Party Status
  #   Matched expected value via webApiURL.getApiThirdStatus()
  #   Using Trapped Unit Test Asserts
  def checkApiThirdStatus (
    expStatus,      # expect API Third Party Status
    printInfo=false # debug print flag
  )
    webApiURL = WebApiURL.new
    puts "Expect: API Third Party Status: #{expStatus}"
    notExpStatus = []
    thirdParties = true
    thirdPartyStatus = webApiURL.getApiThirdStatus(printInfo)
    if (!thirdPartyStatus.nil?)
      thirdPartyStatus.each { |tParty, tStatus|
        if (!trap_Equals(expStatus, tStatus, "#{tParty} Status",printInfo))
          notExpStatus.push([tParty, tStatus])
        end
      }
    else
      trap_Equals(expStatus, nil, "No Third Party Status")
      thirdParties = true
    end
    return [thirdParties, notExpStatus]
  end
