class Hash

  def method_missing(id)
      to_hash[id.id2name]
  end
  
  # takes an array of keys and returns an array of values
  # it would really be ideal to extend the definition of []
  def find_multiple_key_values(array)
    return [self[array]] unless array.is_a? Array
    array.collect { |k| self[k] }
  end

	def inspect
		a = keys.collect { |key| n = (key.respond_to?(:to_s)) ? key.to_s : nil; [key, n] }.sort { |l, r| l[1] <=> r[1] }
		"{" + a.collect { |(key, junk)| key.inspect + "=>" + self[key].inspect }.join(", ") + "}"
	end
  
end
