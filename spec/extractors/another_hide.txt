#require 'minitest/mock'
#require 'minitest/unit'
=begin
require 'date'

require "minitest/autorun"

#MiniTest::Unit.autorun

#class TestMailPurge < MiniTest::Unit::TestCase
class TestMailPurge < MiniTest::Test

  class MailPurge
    def initialize(imap)
      @imap = imap
    end
    
    def purge(date)
      formatted_date = date.strftime('%d-%b-%Y')
      
      @imap.authenticate('LOGIN', 'user', 'password')
      @imap.select('INBOX')

      message_ids = @imap.search(["BEFORE #{formatted_date}"])
      @imap.store(message_ids, "+FLAGS", [:Deleted])
    end

    def list(dir)
    end
  end


  
  def test_purging_mail
    date = Date.new(2010,1,1)
    formatted_date = '01-Jan-2010'
    ids = [4,5,6]
    
    mock = MiniTest::Mock.new
    
    # mock expects:
    #            method      return  arguments
    #-------------------------------------------------------------
    mock.expect(:authenticate,  nil, ['LOGIN', 'user', 'password'])
    mock.expect(:select,        nil, ['INBOX'])
    mock.expect(:search,        ids, [["BEFORE #{formatted_date}"]])
    mock.expect(:store,         nil, [ids, "+FLAGS", [:Deleted]])

    
    mp = MailPurge.new(mock)
    mp.purge(date)
    
    assert mock.verify
  end
  
end
=end
