#require 'timezone'
#require 'rmagick'

# The methods added to this helper will be available to all templates in the application.
module HtmlUtils

	def datetime_select(object, method, options = {})
		id = "#{object}_#{method}"
		# <form action="#" method="get" style="visibility: hidden">
		# <input type="hidden" name="date" id="f_date_d" />
		# </form>
		code = <<EOC

<span style="background-color: #ff8; cursor: default;"
         onmouseover="this.style.backgroundColor='#ff0';"
         onmouseout="this.style.backgroundColor='#ff8';"
         id="show_d">Click to open date &amp; time selector</span>

<script type="text/javascript">
    Calendar.setup({
        inputField     :    "#{id}",     // id of the input field
        ifFormat       :    "%Y-%m-%d %H:%M",     // format of the input field (even if hidden, this format will be honored)
        displayArea    :    "show_d",       // ID of the span where the date is to be shown
        daFormat       :    "%A, %B %d, %Y [%H:%M]",// format of the displayed date
				showsTime      :    true,
				timeFormat     :    "24",
        align          :    "Tl",           // alignment (defaults to "Bl")
        singleClick    :    true
    });
</script>
EOC
		#js = 'return showCalendar("#{id}", "%Y-%m-%d [%W] %H:%M", "24", true);'
		#"#{text_field(object, method, :size => 30)}<input type='reset' value='...' onclick='#{js}'>"
		hidden_field(object, method) + code
	end

	def get_img_size(filename)
		#im = Magick::Image.read(real_filename(filename)).first
		#return [im.columns, im.rows]
		[22,22]
		[64,64]
	end

	def img_tag(options = {})
		if false and ENV['HTTP_USER_AGENT'] =~ /MSIE.*Windows/
			if options["src"] =~ /\.png/
				options["style"] = "filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='#{options["src"]}');" # , enabled='enabled', sizingMethod='scale');"
				options["width"], options["height"] = get_img_size(options["src"]) unless options["width"] && options["height"]
				options["src"] = "/images/spacer.gif"
			end
		end
		#if block_given?
		#	method_missing(:img, options, yield)
		#else
		#	method_missing(:img, options)
		#end
		o = options.collect {|f,v| "#{f}='#{v}'" }.join(' ')
		"<img #{o} />"
	end

#			<div class="div_title">Advertising / Publicit&eacute;</div>
#			help keep www.justbudget.com alive, click a link!<br/>
#			aider moi a garder www.justbudget.com en vie, cliquer sur un liens sponsoriser!<br/>
	def google_ads(orientation)
		# justbudget.com
		if orientation == "horizontal"
		'
		<div class="ads_on_the_bottom">
			<script type="text/javascript"><!--
			google_ad_client = "pub-4887039760095281";
			google_ad_width = 728;
			google_ad_height = 90;
			google_ad_format = "728x90_as";
			google_ad_channel ="";
			google_color_border = "578A24";
			google_color_bg = "CCFF99";
			google_color_link = "00008B";
			google_color_url = "00008B";
			google_color_text = "000000";
			//--></script>
			<script type="text/javascript"
				src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
			</script>
		</div>
		'
		elsif orientation == "vertical"
		'
		<div class="ads_on_the_side">
			<div class="div_title">Advertising</div>
			<script type="text/javascript"><!--
			google_ad_client = "pub-4887039760095281";
			google_ad_width = 120;
			google_ad_height = 600;
			google_ad_format = "120x600_as";
			google_ad_channel ="";
			google_color_border = "E0FFE3";
			google_color_bg = "E0FFE3";
			google_color_link = "0000CC";
			google_color_url = "008000";
			google_color_text = "000000";
			//--></script>
			<script type="text/javascript"
				src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
			</script>
		</div>
		'
		else
		'
		<p>
		</p>
		'
		end
	end

	def display_error
		s = ""
		s += flash.inspect + ' -- ' + @flash.inspect + ' -- ' + @session.inspect

		#@flash['notice'] = "hahaha"
		#@flash['alert'] = "hahaha"
		if @flash['notice']
			s += '<div class="flash notice_content">'
			s += img_tag(:src => "/images/button_ok.png")
			s += '<span>'
			s += @flash['notice']
			s += '</span>'
			s += '</div>'
		end
		if @flash['alert']
			s += '<div class="flash error_content">'
			s += img_tag(:src => "/images/button_cancel.png")
			s += '<span>'
			s += @flash['alert']
			s += '</span>'
			s += '</div>'
		end
		return s + '<div>&nbsp;</div>' unless s.empty?
	end

	def mailto(text, email)
		"<a href='mailto:#{email}'>#{text}</a>"
	end

	def display_footer
		"any questions ? suggestions ? comments ? please email #{mailto('me', 'somekool@somekool.net')}" if (@session['user']).is_a?(User)
	end

	def separator
		'<div class="separator"><hr/></div>'
	end

	def select_timezone(object, method)
		select object, method, Timezone.find_all
	end

	def my_select_day(date, select_name, options = {})
		day_options = []
		1.upto(31) do |day|
				#raise "he #{date.kind_of?(Fixnum)} ... #{date.class} -- #{date}"
				day_options << ((date.kind_of?(Fixnum) ? date : date.day) == day ?
				"<option selected=\"selected\">#{day}</option>\n" :
				"<option>#{day}</option>\n"
			)
		end
		select_html(select_name, day_options, options[:prefix], options[:include_blank], options[:discard_type])
	end

	def text_and_select_field(label, object, method, select_data, current_value, options = {})
		text_id = "#{object}_#{method}"
		select_id = "select_#{object}_#{method}_box"
		widget_width = "width: 190px;"
		if select_data.empty?
			show_textfield = true
			text_field_html_options = {'style' => widget_width}
			select_css_style = "display:none;margin:0px;padding:0px;#{widget_width}"
		else
			show_textfield = false
			text_field_html_options = {'style' => "display:none;#{widget_width}"}
			select_css_style = "display:inline;margin:0px;padding:0px;#{widget_width}"
		end
		select_js_code = "AddToCategoryClick('#{text_id}', this);" + options[:select_extra_js].to_s
		img_js_code = "showOrHide('#{select_id}');showOrHide('#{text_id}');"  + options[:img_extra_js].to_s
		xml = Builder::XmlMarkup.new(:indent=>2)
		xml.p do
			xml.label(:for => text_id) { xml << label.capitalize }
			xml.br
			if options[:text_field_type] == "tag"
				xml << text_field_tag(text_id, options[:text_field_value], text_field_html_options)
			else
				xml << text_field(object, method, text_field_html_options)
			end
			xml.span(:id => select_id + '_div') do
				xml.select(:id => select_id, :name => select_id, :style => select_css_style, :onchange => select_js_code) do
					xml.option(:value => '') { xml << "Choose one" } # a #{label}" }
					xml << options_for_select(select_data, current_value)
				end
			end
			options[:default_img_src] ||= "/images/icon-pull-down-arrows.gif"
			options[:default_img_alt] ||= "... or click here to add a new one."
			xml.img(:src => options[:default_img_src], :alt => options[:default_img_alt], :border => 0, :align => "absmiddle", :onclick => img_js_code)
			xml.span do
				xml << options[:extra]
			end if options[:extra]
		end
	end

end
