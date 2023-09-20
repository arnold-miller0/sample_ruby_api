require 'digest'   # MD5 , RMD160, SHA1, SHA2
require 'json'     # JSON format parse and buld
require 'httparty' # HTTP methods
require 'csv'      # CSV format and files
require 'uri'      # URI for HTTP comamnds and args
require 'test/unit' # Unit test
extend Test::Unit::Assertions

require_relative 'sample_trap_assert'

# Class RestRsp
#   API Restful Response class
class RestRsp

  # Good Response Code with Getter Method
  @@goodCode = 200
  def rspGood()
    return @@goodCode
  end

  # Method respInfoPrint
  #   Print Response Summary Information
  #     with detail print resposne body option
  def respInfoPrint (
    respInfo,
    bodyPrint = false
  )
    puts "respInfo code: #{respInfo[:getCode]}; bodyIsNull: #{respInfo[:bodyResp].nil?}; bodySize; #{respInfo[:bodySize]}"
    puts respInfo[:bodyResp] if bodyPrint
  end

  # Method initialize Instance
  #   set Respose Information Object
  def initialize ()
    self.resetRespInfo()
  end

  # Method resetRespInfo
  #   reset Respose Information Object
  def resetRespInfo()
    @getRespInfo = {
      :getCode => 0,    # response code
      :bodyResp => nil, # response body data
      :bodySize => 0,   # response body size
      :bodyJson => nil, # response body json format
      :matchInfo => "nothing_done"
    }
  end

  # Method getRestRspCode
  #   Getter Response Code
  def getRestRspCode ()
    return @getRespInfo[:getCode]
  end

  # Method getRestRspBody
  #   Getter Response Body in Raw Format
  def getRestRspBody ()
    return @getRespInfo[:bodyResp]
  end

  # Method getRestRspBody
  #   Getter Response Body size
  def getRestRspSize ()
    return @getRespInfo[:bodySize]
  end

  # Method getRestRspJson
  #   Getter Response Body is Json Format
  def getRestRspJson ()
    return @getRespInfo[:bodyJson]
  end

  # Method getRestRspMatch
  #   Getter Response Match Info
  def getRestRspMatch ()
    return @getRespInfo[:matchInfo]
  end

  # Method getURL_core
  #   Get API Rest Response with tra various response
  def getURL_core (
    uri_path,   # GET URL path
    headers,   # headers for GET request, nil no headers
    printInfo
  )
    self.resetRespInfo()
    # exec HTTP GET request and process response
    # Required Header for API fucntion and version
    if headers.nil?
      options = {:no_follow => true, :timeout => 30}
    else
      options = {:headers => headers, :no_follow => true, :timeout => 30 }
    end
    begin
      uri_resp=HTTParty.get(uri_path, options )
    rescue HTTParty::ResponseError
      puts "HTTParty.get response error: #{uri_path}"
      @getRespInfo[:matchInfo]="HTTP_error"
      return @getRespInfo[:getCode]
     rescue Net::ReadTimeout
      puts "HTTParty.get Read timeout: #{uri_path}"
      @getRespInfo[:matchInfo]="HTTP_error"
      return @getRespInfo[:getCode]
     rescue Net::OpenTimeout
      puts "HTTParty.get Open timeout: #{uri_path}"
      @getRespInfo[:matchInfo]="HTTP_error"
      return @getRespInfo[:getCode]
    rescue URI::InvalidURIError
      puts "HTTParty.get Invalid URI address: #{uri_path}"
      @getRespInfo[:matchInfo]="HTTP_error"
      return @getRespInfo[:getCode]
    else
      @getRespInfo[:getCode]=uri_resp.code
      if @getRespInfo[:getCode] == self.rspGood()
        @getRespInfo[:bodyResp] = uri_resp.body
        @getRespInfo[:bodySize] = uri_resp.body.length
        @getRespInfo[:bodyJson] = JSON.parse(uri_resp.body)
        self.respInfoPrint(@getRespInfo,false) if printInfo
        return @getRespInfo[:getCode]
      else
        puts "HTTParty.get response #{uri_resp.code} not 200: #{uri_path}"
        @getRespInfo[:matchInfo] = "not_OK_resp"
        return @getRespInfo[:getCode]
      end
    end
  end

end
