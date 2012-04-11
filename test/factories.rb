include Mocha::API

Factory.define(:child_section, :class => Section) do |s|
  s.name 'A child section'
  s.association :parent, :factory => :root_section
end

Factory.define(:document) do |d|
  d.file_uid 'document.pdf'
  d.association :folder, :factory => :document_folder
  d.association :member, :factory => :member
  d.name 'Document'
  d.after_build do |document|
    document.stubs(:save_attachments).returns true
    document.file.stubs(:size).returns 100.kilobytes
  end
end

Factory.define(:document_folder) do |d|
  d.name 'Document Folder'
end

Factory.define(:link) do |p|
  p.association :member, :factory => :member
  p.url "http://www.yoomee.com"
end

Factory.define(:login_hash) do |f|
  f.association :member, :factory => :member
end

Factory.define(:mail) do |m|
  m.from "sender <sender@test.com>"
  m.html_body "<p>The html body</p>"
  m.association :recipient, :factory => :member
  m.subject 'An email'
end

Factory.define(:member) do |f|
  f.sequence(:email) {|n| "test#{n}@test.com"}
  f.forename 'John'
  f.password 'pa55w0rd'
  f.surname 'Smith'
  f.sequence(:username) {|n| "johnsmith#{n}"}
end

Factory.define(:admin_member, :parent => :member) do |m|
  m.is_admin true
end

Factory.define :membership do |f|
  f.association :member
end

Factory.define(:news_feed_item) do |n|
  n.association :attachable, :factory => :member
end

Factory.define(:page) do |p|
  p.created_at 1.day.ago
  p.updated_at 1.day.ago
  p.association :section
  p.text Lorem::Base.new('paragraphs', 5).output
  p.title 'A page'
end

Factory.define(:expired_page, :parent => :page) do |p|
  p.expires_on 1.day.ago
end

Factory.define(:page_with_photo, :parent => :page) do |p|
  p.association :photo
end

Factory.define(:page_without_photo, :parent => :page) do |p|
end

Factory.define(:photo) do |p|
  p.image_uid 'test_image'
  p.association :member, :factory => :member
  p.association :photo_album
  p.after_build do |photo|
    image_mock = mock
    photo.stubs(:image).returns image_mock
    image_mock.stubs(:size).returns 100.kilobytes
    image_mock.stubs(:process).returns image_mock
    image_mock.stubs(:mime_type).returns 'image/png'
    image_mock.stubs(:url).returns '/url/to/image.png'
    photo.stubs(:resize_down).returns true
    photo.stubs(:save_attachments).returns true
  end
end

Factory.define(:photo_album) do |a|
  a.name "Photo Album"
end

Factory.define(:root_section, :class => Section) do |s|
  s.name 'A root section'
  s.parent nil
end

Factory.define(:section) do |s|
  s.created_at Time.now
  s.name 'A section'
end

Factory.define(:sent_mail, :parent => :mail) do |m|
  m.status 'sent'
end

Factory.define(:status) do |v|
  v.association :member, :factory => :member
  v.text "This is a status"
end

Factory.define(:tag, :class => Tag) do |f|
end

Factory.define(:video) do |v|
  v.association :member, :factory => :member
  v.url "http://www.vimeo.com/123"
  v.after_build do |v|
    v.stubs(:created_at).returns Time.now
    v.stubs(:reformatted_html).returns "<theEmbedHTML></theEmbedHTML>"
  end
end

Factory.define(:unpublished_page, :parent => :page) do |p|
  p.publish_on 1.day.from_now
end

Factory.define(:yoomee_member, :parent => :member) do |m|
  m.email "si@yoomee.com"
end

