require 'digest/sha1'

module Utility

  module_function

  def lc_id(s)
    Digest::SHA1.hexdigest s.downcase
  end

  def camelized_class(str)
    str.to_s.split('_').map {|w| w.capitalize}.join.constantize
  end

  # The string identifying a remote worker's semaphore
  #def qid(args)
  #  "#{args['queue']}_#{args['worker']}_#{args['jid']}".gsub(/\s/,'').downcase
  #end
  

end

