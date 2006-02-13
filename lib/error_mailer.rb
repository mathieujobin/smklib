module ErrorMailerSupport

	#attr_accessor :error_mailer_to

	#def self.append_features(base)
	#	super
	#	base.before_filter :initialize_error_mailer
	#end

	def error_mailer_recipients
		'somekool@somekool.net'
	end

	def error_mailer_from
    'Error Mailer <error@somekool.net>'
	end

	def log_error(exception)
		super(exception)

		begin
			ErrorMailer.deliver_snapshot(error_mailer_recipients, error_mailer_from, exception, clean_backtrace(exception),
				@session.instance_variable_get("@data"), @params, @request.env) unless local_request?
		rescue => e
			logger.error(e)
		end
	end

	def rescue_action_in_public(exception) #:doc:
		case exception.class
			when RoutingError, UnknownAction then
				render_text(IO.read(File.join(RAILS_ROOT, 'smklib', 'public', '404.html')), "404 Not Found")
			where Mysql::Error
				render_text(IO.read(File.join(RAILS_ROOT, 'smklib', 'public', '500-mysql.html')), "500 Internal Server Error")
			else
				render_text(IO.read(File.join(RAILS_ROOT, 'smklib', 'public', '500.html')), "500 Internal Server Error")
		end
	end
end

class ErrorMailer < ActionMailer::Base

	def snapshot(rcpt, from, exception, trace, session, param, env, sent_on = Time.now)
		@recipients         = rcpt
		@from               = from
		if exception.class.to_s == "ActionController::UnknownAction"
	    @subject            = "[NotFound] #{exception.class.to_s} in #{env['REQUEST_URI']}" 
		else
	    @subject            = "[Error] #{exception.class.to_s} in #{env['REQUEST_URI']}" 
		end
		@sent_on            = sent_on
		@body["exception"]  = exception
		@body["trace"]      = trace
		@body["session"]    = session
		@body["param"]      = param
		@body["env"]        = env
		content_type "text/html"
		template_root = "#{RAILS_ROOT}/smklib/app/views/"
	end

end
