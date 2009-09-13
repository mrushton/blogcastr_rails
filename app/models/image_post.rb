class ImagePost < Post 
  has_attached_file :image, :styles => { :default => "400x800>" }
end
