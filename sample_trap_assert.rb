require 'digest'   # MD5 , RMD160, SHA1, SHA2
require 'json'     # JSON format parse and buld
require 'httparty' # HTTP methods
require 'csv'      # CSV format and files
require 'uri'      # URI for HTTP comamnds and args
require 'test/unit' # Unit test
extend Test::Unit::Assertions

# Traped Unit Test Asserts for continue Execution after get Asserts

# Method trap_Equals
#   Common Trap Assert that checks Expected == Actual
  def trap_Equals (
    expect,
    acutal,
    infoMsg,
    printPass = false
  )
    begin
      assert_equal(expect, acutal, "not same")
    rescue Test::Unit::AssertionFailedError => ex
      puts "Failed: #{infoMsg} #{ex.user_message}; Expect: #{ex.expected}; Actual: #{ex.actual};"
      return false
    else
      puts "Passed: #{infoMsg} are same; Expect: #{expect}; Actual: #{acutal};" if printPass
      return true
    end
  end

  # Method trap_NumAssert
  #   Support Trap Assert for Number Comparisons
  #   Value is the Comparisons Boolean
  def trap_NumAssert (
    value,
    userMsg,
    infoMsg,
    printPass = false
  )
    begin
      assert(value, userMsg)
    rescue Test::Unit::AssertionFailedError => ex
      puts "Failed: not #{infoMsg} #{ex.user_message}"
      return false
    else
      puts "Passed: are #{infoMsg} " + userMsg if printPass
      return true
    end
  end

  # Method trap_NumGT
  #   Common Trap Assert Numbers checks Expected > Actual
  def trap_NumGT (
    expect,
    acutal,
    infoMsg,
    printPass = false
  )
    userMsg = "#{expect} > #{acutal}"
    value = (expect > acutal)
    return trap_NumAssert(value, userMsg, infoMsg, printPass)
  end

  # Method trap_NumGT
  #   Common Trap Assert Numbers checks Expected == Actual
  def trap_NumEQ (
    expect,
    acutal,
    infoMsg,
    printPass = false
  )
    userMsg = "#{expect} == #{acutal}"
    value = (expect == acutal)
    return trap_NumAssert(value, userMsg, infoMsg, printPass)
  end
