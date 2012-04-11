Factory.define(:permalink) do |p|
  p.association :model, :factory => :section
  p.name "a-permalink"
end
