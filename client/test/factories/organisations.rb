Factory.define(:organisation) do |f|
  f.association :member, :factory => :member
  f.association :location, :factory => :location  
  f.name "An Organisation"
  f.group_type Organisation::GROUP_TYPES.first
end