Factory.define(:old_permalink) do |f|
  f.association :model, :factory => :section
  f.name "an-old-permalink"
end
