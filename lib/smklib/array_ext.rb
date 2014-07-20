class Array

	def multi_slice(*slice_size)
		return self if slice_size.empty?
		tmp_out = []
		index = 0
		n = 0
		while(index < size)
			ss = slice_size[n] || slice_size.first
			tmp_out << slice(index, ss)
			index += ss
			n += 1
		end
		tmp_out
	end

  # takes an array of hashes and an array of ordered hash keys
  # creates a nested array based on the elements of the hashes
  # name the last elt in the key array 'count' if you want to pair the last two elements
  def create_nested_array(keys)
    h_count      = self[0].length   # count the number of elements in the hash - assumes all are the same length
    old_vals     = Hash.new        # keep a record of elements already recorded
    o            = Array.new       # create output variable 
    str,str_eval = nil             # create temp variable for holding code to execute
    has_count_column = keys.last == 'count'
    h_end        = (has_count_column) ? h_count - 2 : h_count - 1
    
    self.each do |a|
      current = o
      keys.each_with_index do |k,i|
				begin
					unless (i >= h_end and has_count_column)
					#if ((i != h_end) || (keys.last != 'count'))
						if a[k] != old_vals[k]
							current << [ a[k], [] ]
							keys[i+1..keys.length].each { |q| old_vals[q] = nil }
						end
						current = current.last.last # reference the value array
					else 
						current << [a[k], a['count']] if (i == h_end)
					end
					old_vals[k] = a[k]  # record element we just looked at
				rescue Exception => e
					raise "Error: #{e.inspect}, " +
					      "current = #{current.inspect}, " +
					      "a[k] = #{a[k].inspect} and a[k] != old_vals[k] = #{(a[k] != old_vals[k]).inspect}, " +
					      "a = #{a.inspect}, " +
					      "o = #{o.to_yaml}, " +
					      "self = #{self.to_yaml}, "
				end
      end
    end
    o
  end
  
  def randomize
    self.sort { |l,r| rand(2) - 1  }
  end
  
  def randomize!
    self.sort! { |l,r| rand(2) - 1  }
  end
  
	def to_double_array
		self.each_with_index { |x,i| self[i] = [x,x] }
		self
	end
end

def search_array_of_hash(data, value, key="value", text="label")
  return_text = ""
  data.each do |x|
    return_text = x.to_hash[text.to_sym] if x.to_hash[key.to_sym].to_s == value.to_s
  end
  return_text
end
