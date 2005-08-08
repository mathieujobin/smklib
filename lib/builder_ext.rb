class Builder::XmlMarkup

	class AbortTransaction < RuntimeError; end

	def transaction!(&block)
		old_target = @target
		@target = ''
		begin
			yield
			@target = old_target + @target
		rescue AbortTransaction => e
			@target = old_target
		end
	end

	def ignore_abort!(val = true)
		@ignore_abort = val
	end

	def abort!
		raise AbortTransaction, "abort" unless @ignore_abort
	end

end
