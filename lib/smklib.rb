module SMKLib
	if defined?(::Rails)
		require 'smklib/railtie'
		class Engine < ::Rails::Engine; end
	end
end
