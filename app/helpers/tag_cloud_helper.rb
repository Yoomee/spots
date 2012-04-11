module TagCloudHelper

  # items needs to be set of records that includes a column called tag_count
  # e.g. 
  # named_scope :member_counts, :select => "jobs.*, COUNT(members.id) AS tag_count", :joins => "LEFT OUTER JOIN members ON (jobs.id = members.job_id)", :group => "jobs.id"
  # -render_tag_cloud(Job.member_counts) do |job|
  #   =link_to(job.title, job)
  def render_tag_cloud(items, options = {}, &block)
    options.reverse_merge!(:num_classes => 4)
    lowest, highest = items.minmax_by(&:tag_count).collect {|j| j.tag_count.to_i}
    spread = (highest.to_f - lowest.to_f)
    spread = 1.to_f if spread <= 0
    spread = spread / (options[:num_classes].to_f - 1.to_f)
    out = ""
    items.each do |item|
      class_num = (1 + (item.tag_count.to_f / spread)).to_i
      class_num = options[:num_classes] if class_num > options[:num_classes]
      content = block_given? ? capture(item, &block) : item.to_s
      out << content_tag(:li, content, :class => "tag_item tag_item_#{class_num}")
    end
    concat(content_tag(:ul, out, :class => "tag_cloud #{options[:class]}".strip))
  end
  
end