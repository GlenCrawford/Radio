module SpecHelpers
  def uploaded_image(file_path = nil, content_type = "image/jpeg")
    file_path ||= Rails.root.join "spec", "assets", "With smiles like that they must be stoned - TruShu.jpg"
    uploaded_file file_path, content_type
  end

  def uploaded_file(file_path, content_type)
    Rack::Test::UploadedFile.new file_path, content_type
  end
end
