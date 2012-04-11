Factory.define(:enquiry_field) do |ef|
  ef.association :enquiry, :factory => :enquiry
  ef.name "email"
  ef.value "rob@yoomee.com"
end