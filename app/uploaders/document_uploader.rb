# encoding: utf-8

class DocumentUploader < CarrierWave::Uploader::Base

  storage :file
  # storage :grid_fs

  # Override the directory where uploaded files will be stored
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def extension_white_list
     %w(pdf ps eps jpg doc zip pps txt xls)
   end
end
