Mocha::ObjectMethods.module_eval do

  def stubs_pagination
    stubs(:paginate).returns self
    stubs(:total_pages).returns 5
    stubs(:total_entries).returns 100
    stubs(:current_page).returns 1
    stubs(:previous_page).returns nil
    stubs(:next_page).returns 2
  end

  def stubs_path(path)
     path = path.split('.') if path.is_a? String
     raise "Invalid Argument" if path.empty?
     part = path.shift
     mock = Mocha::Mockery.instance.named_mock(part)
     exp = self.stubs(part)
     if path.length > 0
       exp.returns(mock)
       return mock.stubs_path(path)
     else
       return exp
     end
   end
   
   def expects_path(path)
     path = path.split('.') if path.is_a? String
     raise "Invalid Argument" if path.empty?
     part = path.shift
     mock = Mocha::Mockery.instance.named_mock(part)
     exp = self.expects(part)
     if path.length > 0
       exp.returns(mock)
       return mock.expects_path(path)
     else
       return exp
     end
   end
     
     
end