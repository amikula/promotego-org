String.class_eval do
  def sluggify
    downcase.gsub(/\W|_/, '-').gsub(/--+/, '-').sub(/^-+/, '').sub(/-+$/, '')
  end
end
