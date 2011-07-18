Factory.define(:time_slot_booking) do |f|
  f.association :member, :factory => :member
  f.association :time_slot, :factory => :time_slot
  f.starts_at Time.parse("12:00", 1.day.from_now)
end