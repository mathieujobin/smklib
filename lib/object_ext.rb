class Object

  def self.run_once(unique_string, &block)
    $run_once_guard ||= {}
    return if $run_once_guard[unique_string]
    raise "No block given" unless block_given?
    yield
    $run_once_guard[unique_string] = true
  end
  
  def to_class
    self.class.const_get self.to_s
  end
  
  def in?(array)
    array.include? self
  end

	# based on http://www.rubygarden.org/ruby?Make_A_Deep_Copy_Of_An_Object
	def deep_clone
		Marshal::load(Marshal.dump(self))
	end

	def ignore_exception(*exceptions, &block)
		begin
			yield
		rescue Exception => e
			skip = false
			exceptions.each { |ex| skip = true if e.kind_of? ex }
			raise e unless skip
		end
	end

end
