module TramlinesEnquiries

  def self.included(klass)
    Notifier.send(:include, TramlinesEnquiries::NotifierExtensions)
  end

end