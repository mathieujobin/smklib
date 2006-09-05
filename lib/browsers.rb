module SMKLib
	module Browsers
		def is_mobile_browser?(ua)
			mobile_browsers = [
				'DoCoMo',
				'alcatel',
				'auditautomatic',
				'ericsson',
				'lg-g7000',
				'mitsu',
				'mot-.*',
				'nokian-gage',
				'opwv-sdk',
				'panasonic-[xg].*',
				'philips-.*',
				'r380',
				'r600',
				'sagem-3xxx',
				'sagem-9xx',
				'sagem-myx-.*',
				'samsung-sgh-[xevtasrn][0-9][0-9][0-9].*',
				'sec-sgh[cpqsavdex][0-9][0-9][0-9]',
				'sharp-tq-gx[0-9][0-9]',
				'sonyericsson',
				'alcatel',
				'ericssona2628s',
				'ericssonr320',
				'lg-[cfgltG0-9]*',
				'sie-[acfxvmniedsklt0-9]*',
				'sagem-m.*',
				'mot-[-abvcetdf0-9]*',
				'nokia[0-9]*',
				'panasonic',
				't66',
				'n21i',
				'n22i',
				'ts21i',
				'portalmmm',
				'ipcheck',
				'cnf2'
			]
			is_it = false
			modified_ua = ua.gsub(/[+ ]/, '_')
			mobile_browsers.each do |x|
				is_it = true if modified_ua.match(/^#{x}/)
			end
			return is_it
		end
	
		def user_agent
			ua = request.env_table['HTTP_USER_AGENT']
			if ua.nil?
				"31337_h4x0r"
			elsif ua.match(/Opera/)
				"Opera"
			elsif ua.match(/MSIE/)
				"MSIE"
			elsif ua.match(/Safari/)
				"Safari"
			elsif ua.match(/KHTML/)
				"KHTML"
			elsif is_mobile_browser?(ua)
				"Mobile"
			else # we are not making a difference for other browsers.
				"Mozilla" # standard
			end
		end
	end
end
