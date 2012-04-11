Factory.define(:wall) do |w|
  w.association :attachable, :factory => :member
end