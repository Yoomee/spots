Factory.define(:wall_post) do |w|
  w.association :wall, :factory => :wall
  w.association :member, :factory => :member
  w.text "Wall post text"
end