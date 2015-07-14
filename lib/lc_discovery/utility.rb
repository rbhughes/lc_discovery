require 'digest/sha1'

module Utility

  module_function

  # Because backslashes are...irritating
  def fwd_slasher(s)
    s.strip.gsub('\\', '/') rescue nil
  end

  # Make a sort of guid, which in some cases is a natural key
  def lc_id(s)
    Digest::SHA1.hexdigest(fwd_slasher(s.downcase))
  end


  def camelized_class(str)
    str.to_s.split('_').map {|w| w.capitalize}.join.constantize
  end

  # The string identifying a remote worker's semaphore
  #def qid(args)
  #  "#{args['queue']}_#{args['worker']}_#{args['jid']}".gsub(/\s/,'').downcase
  #end
  

end

