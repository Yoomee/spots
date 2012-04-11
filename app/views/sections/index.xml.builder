xml.instruct!
xml.urlset :xmlns => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @sections.not_hidden.each do |section|
    xml << render("section", :section => section)
  end
end