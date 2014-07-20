require_dependency 'smklib/object_ext'

module DebugSupport

	def self.append_features(base)
		super
		base.before_filter :initialize_timing, :check_local_request
	end

	def initialize_timing
		@time = Time.now
	end

	def local_request?
		#session['local_request'] == 1
		consider_all_requests_local or session['local_request'] == 1
	end

	def check_local_request
		val = params['local_request'].to_i
		default = consider_all_requests_local ? 1 : 0
		session['local_request'] ||= default
		session['local_request'] = val if val.in? [1, 0] unless params['local_request'].nil?
	end 

end

