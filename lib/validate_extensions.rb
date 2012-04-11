# -----------------------------------------------------------------------
#
# Copyright (c) andymayer.net Ltd, 2007-2008. All rights reserved.
 
# This software was created by andymayer.net and remains the copyright
# of andymayer.net and may not be reproduced or resold unless by prior
# agreement with andymayer.net.
#
# You may not modify, copy, duplicate or reproduce this software, or
# transfer or convey this software or any right in this software to anyone
# else without the prior written consent of andymayer.net; provided that
# you may make copies of the software for backup or archival purposes
# 
# andymayer.net grants you the right to use this software solely
# within the specification and scope of this project subject to the
# terms and limitations for its use as set out in the proposal.
# 
# You are not be permitted to sub-license or rent or loan or create
# derivative works based on the whole or any part of this code
# without prior written agreement with andymayer.net.
# 
# -----------------------------------------------------------------------
module ValidateExtensions

  DATE_FORMAT = /\d\d?\/\d\d?\/\d{4}/
  TIME_FORMAT = /\d\d?\/\d\d?\/\d{4} \d\d?:\d\d?/
  EMAIL_FORMAT = /^[^\s@]+@[^\s@]*\.[a-z]{2,}$/
  URL_FORMAT = /((((file|gopher|news|nntp|telnet|http|ftp|https|ftps|sftp):\/\/)|(www\.)?)+(([a-zA-Z0-9\._-]+\.[a-zA-Z]{2,6})|([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}))(\/[a-zA-Z0-9\&amp;%_\.\/-~-]*)?(?!['"]))|^\s*$/
  POSTCODE_FORMAT = /^([A-PR-UWYZ0-9][A-HK-Y0-9][AEHMNPRTVXY0-9]?[ABEHMNPRVWXY0-9]? {1,2}[0-9][ABD-HJLN-UW-Z]{2}|GIR 0AA)$/i

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    def validates_format_is_date_of field, options = {}
      options = {:with => DATE_FORMAT}.merge options
      validates_format_of field, options
    end
    alias_method :validates_date_format_of, :validates_format_is_date_of
    
    def validates_format_is_time_of field, options = {}
      options = {:with => TIME_FORMAT}.merge options
      validates_format_of field, options
    end
    alias_method :validates_time_format_of, :validates_format_is_time_of

    def validates_format_is_email_address_of field, options = {}
      options = {:with => EMAIL_FORMAT}.merge options
      validates_format_of field, options
    end
    alias_method :validates_email_format_of, :validates_format_is_email_address_of
    
    def validates_format_is_postcode_of field, options = {}
      options = {:with => POSTCODE_FORMAT}.merge options
      options.reverse_merge!(:message => "is not a valid postcode")
      validates_format_of field, options
    end
    alias_method :validates_postcode_format_of, :validates_format_is_postcode_of
    
    def validates_format_is_url_of field, options = {}
      options = {:with => URL_FORMAT}.merge options
      validates_format_of field, options
    end
    alias_method :validates_url_format_of, :validates_format_is_url_of

    def validates_order_of *attr_names
      options = attr_names.extract_options!
      validate do |record|
        record.validate_order_of(attr_names, options)
      end
    end

  end

  def is_email_address? string
    EMAIL_FORMAT.match string
  end

  def is_url? string
    URL_FORMAT.match string
  end

  def validate_order_of attr_names, options = {}
    options.reverse_merge!(:message => "#{attr_names[0].to_s.capitalize} must be before #{attr_names[1]}.")
    attr_names.each_pair do |attr_name1, attr_name2|
      if !send(attr_name1).blank? && !send(attr_name2).blank? && (send(attr_name1) >= send(attr_name2))
        errors.add_to_base options[:message]
        return false
      end
    end
  end

  def validate_format_is_email_address_of attr_names, message = nil, options = {}
    options.reverse_merge!(:separator => ',')
    message = "must be a list of valid email addresses (separated by '#{options[:separator]}')" if message.nil?
    attr_names.each do |attr_name|
      address_array = (send(attr_name) || "").split options[:separator]
      errors.add(attr_name, message) unless address_array.all? {|address| is_email_address? address.strip}
    end
  end

end
