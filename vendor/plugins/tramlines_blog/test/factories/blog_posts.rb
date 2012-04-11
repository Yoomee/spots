Factory.define(:blog_post) do |p|
  p.association :blog, :factory => :blog
  p.created_at Time.now
  p.association :member, :factory => :member
  p.text "This is a blog post"
  p.title "Blog Post"
  p.updated_at Time.now
end
