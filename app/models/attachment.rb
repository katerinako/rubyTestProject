class Attachment < ActiveRecord::Base
  KINDS = {
    :cv => 'cv',
    :document => 'document'
  }

  file_accessor :uploaded_file
  validates :uploaded_file, :presence => true
  validates_size_of :uploaded_file, :within => 0..(20.megabytes)

  def name
    uploaded_file.name
  end

  def description
    "Attachment: #{uploaded_file.name}"
  end
  
end
