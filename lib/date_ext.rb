require 'gettext/rails'

class Date
	if Object.respond_to?('_')
		raise "ye"
		MONTHNAMES = [nil, _("January"), _("February"), _("March"), _("April"), _("May"), _("June"), _("July"), _("August"), _("September"), _("October"), _("November"), _("December")]
		DAYNAMES = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
		ABBR_MONTHNAMES = [nil, _("Jan"), _("Feb"), _("Mar"), _("Apr"), _("May"), _("Jun"), _("Jul"), _("Aug"), _("Sep"), _("Oct"), _("Nov"), _("Dec")]
		ABBR_DAYNAMES = %w(Sun Mon Tue Wed Thu Fri Sat)
	elsif Locale.get.to_s == 'en'
		MONTHNAMES = [nil] + %w(January February March April May June July August September October November December)
		DAYNAMES = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
		ABBR_MONTHNAMES = [nil] + %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
		ABBR_DAYNAMES = %w(Sun Mon Tue Wed Thu Fri Sat)
	elsif Locale.get.to_s == 'ja'
		MONTHNAMES = [nil] + %w(一月 二月 三月 四月 五月 六月 七月 八月 九月 十月 十一月 十二月)
		DAYNAMES = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
		ABBR_MONTHNAMES = [nil] + %w(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
		ABBR_DAYNAMES = %w(Sun Mon Tue Wed Thu Fri Sat)
	else
		raise 'unsupported language'
	end
end
