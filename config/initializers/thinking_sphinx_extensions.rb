class ThinkingSphinx::Search
  
  def indexes_with_index_prefixing
    if index_prefix = options.delete(:index_prefix)
      index_re = /^#{index_prefix}/
    elsif index_prefix = options.delete(:exclude_index_prefix)
      index_re = /^(?!#{index_prefix})/
    end
    if index_prefix
      context = ThinkingSphinx::Context.new
      context.prepare
      indexed_models = options[:classes] || context.indexed_models.map(&:constantize)
      matched_indexes = indexed_models.map(&:sphinx_index_names).flatten.select {|index| index =~ index_re}
      options[:index] = matched_indexes.flatten.join(',')
    end
    indexes_without_index_prefixing
  end
  alias_method_chain :indexes, :index_prefixing
  
end

ThinkingSphinx::Configuration.instance.model_directories << "#{RAILS_ROOT}/client/app/models"

