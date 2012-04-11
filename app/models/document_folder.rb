class DocumentFolder < ActiveRecord::Base

  has_many :documents, :dependent => :destroy, :foreign_key => "folder_id"

  validates_presence_of :name
  
  default_scope :order => "name ASC"
  
  def to_s
    name
  end

end
