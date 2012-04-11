Factory.define(:blog) do |p|
  p.description "This is a blog"
  p.association :member, :factory => :member
  p.name "Blog"
end
