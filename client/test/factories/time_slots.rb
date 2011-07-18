Factory.define(:time_slot) do |f|
  f.association :organisation, :factory => :organisation
  f.association :activity, :factory => :activity
  f.starts_at_string "09:00"
  f.ends_at_string "17:00"  
  f.mon true
  f.tue true
  f.wed true
  f.thu true
  f.fri true
  f.sat true
  f.sun true    
end