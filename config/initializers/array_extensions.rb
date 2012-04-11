class Array

  def columns(n, &block)
    rem = size % n
    base_size = size / n
    if rem.zero?
      each_slice(base_size, &block)
    else
      n.times do |col|
        slice_size = column_item_count(n, col)
        yield slice(prior_items(n, col), slice_size)
      end
    end
  end
  
  def cut(item)
    if idx = index(item)
      out = self[idx,length] + self[0, idx]
    else
      self
    end
  end
  
  def each_pair
    (size - 1).times do |i|
      yield self[i], self[i + 1]
    end
  end

  def each_slice(num)
    return if num.zero?
    number_of_slices(num).times do |i|
      yield slice(i * num, num)
    end
  end
  
  def each_with_col_name(num_cols=3)
    each_with_index do |item, index|
      col_name = case (index % num_cols)
        when 0 then "left"
        when (num_cols - 1) then "right"
        else "middle"
      end
      yield item, col_name
    end
  end
  
  def each_with_col_name_and_index(num_cols = 3)
    each_with_index do |item, index|
      col_name = case (index % num_cols)
        when 0 then "left"
        when (num_cols - 1) then "right"
        else "middle"
      end
      yield item, col_name, index
    end
  end
  
  def move(from, to)
    insert(to, delete_at(from))
  end

  def move_by_name(name, to)
    return self if index(name).nil?
    move(index(name), to)
  end
  
  def move_to_front(name)
    move_by_name(name, 0)
  end
  
  def pick_n_at_random(n)
    ret = []
    members_to_pick_from = dup
    n.times do
      picked_item = members_to_pick_from.delete_at(Kernel::rand(members_to_pick_from.size))
      ret << picked_item
    end
    ret
  end

  def pick_one_at_random
    self[Kernel::rand(size)]
  end

  def random_element
    self[Kernel.rand(length)]
  end
  
  def random_elements(n)
    ret = []
    members_to_pick_from = dup
    n.times do
      picked_item = members_to_pick_from.delete_at(Kernel::rand(members_to_pick_from.size))
      ret << picked_item
    end
    ret
  end
  
  def randomize
    returning result = [] do
      pool = dup
      pool.size.times do
        result << pool.remove_one_at_random!
      end
    end
  end
  
  def remove_one_at_random!
    delete pick_one_at_random
  end
  
  def to_hash
    inject({}) { |h, nvp| h[nvp[0]] = nvp[1]; h }
  end
  
  private
  def column_item_count(no_of_columns, column_no)
    return 0 if column_no == -1
    rem = size % no_of_columns
    base_size = size / no_of_columns
    out = rem > column_no ? base_size + 1 : base_size
    out
  end

  def prior_items(no_of_columns, column_no)
    return 0 if column_no == -1
    column_item_count(no_of_columns, column_no - 1) + prior_items(no_of_columns, column_no - 1)
  end

  def number_of_slices(per_slice)
    (size % per_slice).zero? ? size / per_slice : (size / per_slice) + 1
  end
  
end
