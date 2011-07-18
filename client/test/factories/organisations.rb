Factory.define(:organisation) do |f|
  f.association :member, :factory => :member
  f.name "An Organisation"
end