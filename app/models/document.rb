class Document < ActiveRecord::Base

  # include Media
  # include TramlinesStaticImage

  AUDIO_FILE_EXTENSIONS = %w{mp3}

  belongs_to :folder, :class_name => "DocumentFolder"
  belongs_to :member

  validates_presence_of :file
  validates_size_of :file, :maximum => 10.megabytes, :allow_blank => true
  
  before_save :extract_text_from_pdf!
  
  search_attributes %w{name file_name pdf_text}, :autocomplete => %w{name file_name}

  named_scope :audio, :conditions => "file_ext IN (#{AUDIO_FILE_EXTENSIONS.map {|ext| "'#{ext}'"}.join(',')})"
  named_scope :most_recent, :order => 'created_at DESC'
  named_scope :non_audio, :conditions => "file_ext NOT IN (#{AUDIO_FILE_EXTENSIONS.map {|ext| "'#{ext}'"}.join(',')})"
  named_scope :ordered_by_name, :order => "name ASC"
  named_scope :without_folder, :conditions => "documents.folder_id IS NULL OR documents.folder_id = ''"

  attachment_accessor :file
  attr_boolean_accessor :process_pdf

  class << self
    
    def default_image(image_attr = 'image')
      Dragonfly::App[:images].fetch(default_image_location(image_attr))
    end
    
    def default_image_location(image_attr = 'image')
      "defaults/doc_item"
    end
    
  end

  def default_image(image_attr='image')
    Dragonfly::App[:images].fetch("defaults/doc_#{file_ext_description}")
  end

  # used in image_for
  def file_ext_description
    case
    when file_ext.in?(%w{pdf})
      "pdf"      
    when file_ext.in?(%w{swf fla swd})
      "flash"
    when file_ext =~ /^pp[ts]/
      "ppt"
    when file_ext.in?(%w{xls csv xlt xlsx})
      "excel"
    when file_ext.in?(%w{doc docx rtf txt wps})
      "word"
    when file_ext.in?(%w{zip gzip rar})
      "zip"
    when file_ext.in?(%w{jpg jpeg gif png})
      'image'
    else
      "item"
    end
  end

  # def image_uid
  #   "defaults/doc_#{file_ext_description}"
  # end

  def name
    read_attribute(:name).blank? ? file_name : read_attribute(:name)
  end
  alias_method :to_s, :name

  def path_to_file
    "#{RAILS_ROOT}/public#{url_for_file}"
  end

  def to_s
    name
  end

  def url_for_file
    file.url :format => file_ext
  end
  
  private
  def pdf_changed?
    (file_ext == "pdf" && (process_pdf? || new_record? || changed.include?("file_uid")))
  end
  
  def extract_text_from_pdf!
    return true unless pdf_changed?
    text_path = "#{file.file.path}-text#{rand(1000)}.txt"
    if system("pdftotext -enc UTF-8 #{file.file.path} #{text_path} 2>&1") && File.exists?(text_path)
      self.pdf_text = File.new(text_path).read(1000000)
    end
  end

end
