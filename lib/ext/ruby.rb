String.class_eval do
  def sluggify
    downcase.gsub(/[^A-Za-z0-9]/, '-').gsub(/--+/, '-').sub(/^-+/, '').sub(/-+$/, '')
  end
end
