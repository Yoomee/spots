Factory.define(:enquiry) do |e|
  e.form_name "Sample"
  e.association :member, :factory => :member
  e.after_build do |enquiry|
    enquiry.stubs(:valid?).returns true
  end
end
