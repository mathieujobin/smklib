#require 'timezone'
#require 'rmagick'

# The methods added to this helper will be available to all templates in the application.
module HtmlUtils

	def google_analytics(code)
		# code should look like this UA-97533-1
    if RAILS_ENV == "production" and not(code.to_s.empty?)
      return <<EOT
  <script src="http://www.google-analytics.com/urchin.js" type="text/javascript">
  </script>
  <script type="text/javascript">
    _uacct = "#{code}";
    urchinTracker();
  </script>
EOT
		else
			""
    end
	end

	def get_file_value(parent, opclass, spname, ref_id=nil)
		case opclass.to_s
		when 'CompanyLogo'
			parent.company_logo
		when 'RealtorPhoto'
			parent.realtor_photo
		when 'ProductPhoto'
		  parent.product_photo
		when 'Photo','Floorplan'
			nil
		else
			raise "fuck you #{opclass.inspect}"
			ref_id = (opclass.is_a?(RealtorAttachment) ? -1 : nil) if ref_id.nil?
			opclass.find(:first, :conditions => ["properties_id = ? and htmlname = ?", ref_id, spname])
		end
	end
	
	def fileinput_field(parent, opclass, spname, nodiv=false, value=nil, lang='en')
		value = get_file_value(parent, opclass, spname) if value.nil?
		id_name = "fileinput_field_#{spname}"
		if value.kind_of?(opclass) and value[:id].to_i > 0
			sclass = Inflector.underscore(opclass)
			case sclass
			when 'company_logo', 'realtor_photo'
				url_hash = {:controller => 'realtors', :action => 'kill_picture', :id => parent, :pic_class => sclass}
			when 'product_photo'
				url_hash = {:controller => 'products', :action => 'kill_picture', :id => parent, :pic_class => sclass}
			else
				raise "fuck you too #{opclass.inspect}"
			end
			if lang=='en'
			 link_text = 'Delete picture'
			 confirm_text = 'Are you sure?'
			 msg_text = 'To replace the picture, you need to delete this one first.'
			else
			 link_text = '変更'
			 confirm_text = '本当ですか？'
			 msg_text = ''
			end
			link = link_to_remote(link_text, :update => id_name, :url => url_hash, :confirm => confirm_text)
			h = "<img src='/#{opclass.to_s.downcase.pluralize}/#{value[:id]}_thumb.png' /><br/>#{link}<br/>#{msg_text}"
		else
			t = "<br/><small>(jpeg, jpg, gif files of up to 3MB in size can be uploaded.)</small>" if lang=='en'
			h = "<input type='file' name='#{spname}' />#{t}"
		end
		if nodiv
			h
		else
			"<div id='#{id_name}'>#{h}</div>"
		end
	end

	def form_filter(content, action = '')
		"<form id='my_f' style='display: inline; margin: 0px; padding: 0px;' action='#{action}' method='post'>" + content + '</form>'
	end

	def _(str)
		str
	end

	def datetime_select(object, method, start_date=Time.now.strftime("%Y, %m, %d, %H, %M"), options = {})
		raise "dont use me you bastard."
	#	datetime_select_popup(object, method, start_date, options)
	end

	def datetime_select_popup(object, method, start_date=Time.now.strftime("%Y, %m, %d, %H, %M"), options = {})
		id = "#{object}_#{method}"
		# <form action="#" method="get" style="visibility: hidden">
		# <input type="hidden" name="date" id="f_date_d" />
		# </form>
		code = <<EOC

<span style="background-color: #ff8; cursor: default;"
         onmouseover="this.style.backgroundColor='#ff0';"
         onmouseout="this.style.backgroundColor='#ff8';"
         id="span_#{id}">Click to open date &amp; time selector</span>

<script type="text/javascript">
    Calendar.setup({
        inputField     :    "#{id}",     // id of the input field
        ifFormat       :    "%Y-%m-%d %H:%M",     // format of the input field (even if hidden, this format will be honored)
        displayArea    :    "span_#{id}",       // ID of the span where the date is to be shown
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

	def datetime_select_flat(object, method, options = {})
		id = "#{object}_#{method}"
		code = <<EOC
				<div style="float: right; margin-left: 1em; margin-bottom: 1em;" id="calendar-container"></div>
				
				<script type="text/javascript">
					Calendar.setup(
						{
							inputField     :    "#{id}",     // id of the input field
							ifFormat       :    "%Y-%m-%d %H:%M",     // format of the input field (even if hidden, this format will be honored)
							showsTime      :    true,
							timeFormat     :    "24",
							align          :    "Tl",           // alignment (defaults to "Bl")
							flat         : "calendar-container", // ID of the parent element
							flatCallback : dateChanged           // our callback function
						}
					);
				</script>
EOC
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
	def google_ads(orientation, channel="")
		if channel == "public"
			channel = "0967175666"
		elsif channel == "private"
			channel = "2002318862"
		end
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
			google_color_border = "FFFFFF";
			google_color_bg = "FFFFFF";
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
		elsif orientation == "justbudget"
		return <<EOC
			<script type="text/javascript"><!--
			google_ad_client = "pub-4887039760095281";
			google_alternate_color = "FFFFFF";
			google_ad_width = 120;
			google_ad_height = 240;
			google_ad_format = "120x240_as";
			google_ad_type = "text_image";
			google_ad_channel ="#{channel}";
			google_color_border = "000000";
			google_color_bg = "F0F0F0";
			google_color_link = "0000FF";
			google_color_url = "008000";
			google_color_text = "000000";
			//--></script>
			<script type="text/javascript"
				src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
			</script>
EOC
		elsif orientation == "srosa"
		return <<EOC
			<script type="text/javascript"><!--
			google_ad_client = "pub-4887039760095281";
			google_ad_width = 120;
			google_ad_height = 240;
			google_ad_format = "120x240_as";
			google_ad_channel ="";
			google_color_border = "FFFFFF";
			google_color_bg = "FFFFFF";
			google_color_link = "086582";
			google_color_url = "086582";
			google_color_text = "333333";
			//--></script> 
			<script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js"></script> 
EOC
		else
		'
		<p>
		</p>
		'
		end
	end

	def google_conversion_tracker_english
		if @session['signup']
			@session['signup'] = false
		'
		<br/>
		<!-- Google Code for Signup Conversion Page -->
		<script language="JavaScript" type="text/javascript">
		<!--
			var google_conversion_id = 1068909979;
			var google_conversion_language = "en_US";
			var google_conversion_format = "2";
			var google_conversion_color = "0066CC";
			if (1.0) {
				var google_conversion_value = 1.0;
			}
			var google_conversion_label = "Signup";
		//-->
		</script>
		<script language="JavaScript" src="http://www.googleadservices.com/pagead/conversion.js">
		</script>
		<noscript>
			<img height=1 width=1 border=0 src="http://www.googleadservices.com/pagead/conversion/1068909979/?value=1.0&label=Signup&script=0">
		</noscript>
		'
		end
	end

	def display_errors
		s = ""
		css = "
      <style>
        .flash { text-align: left; padding: 5px 25px; border: 4px solid blue; margin: 0px auto 20px; display: table; }
        .flash img { margin-right: 15px; }
        .flash.error_content { border-color: red; }
        .flash.notice_content { border-color: green; }
      </style>
    "
		# s += '<pre>--' + flash.to_yaml + '<br/> -- ' + @flash.to_yaml + '<br/> -- </pre>' if local_request?
		f_n = "#{flash[:notice]}#{flash['notice']}"
		unless f_n.empty?
			s += '<div class="flash notice_content">'
			s += img_tag(:src => "/smklib/images/button_ok.png")
			s += '<span>'
			s += f_n
			#s += '<br/>' + google_conversion_tracker_english if @flash['signup']
			s += '</span>'
			s += '</div>'
			s += '<div>&nbsp;</div>' # unless s.empty?
		end
		f_a = "#{flash[:warning]}#{flash['warning']}#{flash[:alert]}#{flash['alert']}"
		unless f_a.empty?
			s += '<div class="flash error_content">'
			s += img_tag(:src => "/smklib/images/button_cancel.png")
			s += '<span>'
			s += f_a
			s += '</span>'
			s += '</div>'
			s += '<div>&nbsp;</div>' # unless s.empty?
		end
		s = css + s unless s.empty?
		return s
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
		select object, method, Timezone.find_all.collect {|p| [ p.first, p.last ] }, { :include_blank => true }
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
		def field_only_or_not(label_for, label_text, field_only) # , &block)
			xml = Builder::XmlMarkup.new(:indent=>2)
			if field_only
				yield(xml)
			else
				xml.p do
					xml.label(:for => label_for) { xml << label_text }
					xml.br
					yield(xml)
				end
			end
		end
		#raise options[:field_only].inspect
		field_only_or_not(text_id, label.capitalize, options[:field_only]) do |xml|
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
			xml.input(:type => 'button', :value => '...', :alt => options[:default_img_alt], :border => 0, :align => "absmiddle", :onclick => img_js_code)
			xml.span do
				xml << options[:extra]
			end if options[:extra]
		end
	end

=begin
@columns = [
	{:label => 'Status', :field => 'status', :format => nil},
	{:label => 'Entered', :field => 'created_time', :format => Proc.new{|d| d.strftime("%Y.%d.%m") } },
	{:label => 'Modified', :field => 'modified_time', :format => Proc.new{|d| d.strftime("%Y.%d.%m") } },
	{:label => 'Name', :field => 'fullname', :format => nil},
	{:label => 'House', :field => 'house', :format => nil},
	{:label => 'Category', :field => 'category', :format => nil},
]
=end

	def sortable_list(xml, table_id, columns, data)
		xml = Builder::XmlMarkupr.new(:indent=>2, :margin=>4) if xml.nil?
		xml.table(:id => table_id, :cellpadding => 0, :cellspacing => 0) do
			xml.tr(:class => 'header') do
				columns.each { |c|
					xml.th do
						xml.a(:href => url_for(:action => 'list', :sort => c[:field], :order => ((@params[:sort] == c[:field] and @params[:order] == 'asc') ? 'desc' : 'asc'))) do
							xml << c[:label]
						end
					end
				}
				xml.th(:colspan => 3) { xml << "" }
			end
			for inquiry in data
				xml.tr do # xml.tr(:class => "row #{inquiry['status']}") do
					columns.each { |c|
						f = c[:field]
						if c[:format].nil?
							xml.td inquiry[f]
						else
							xml.td c[:format].call(inquiry[f])
						end
					}
					xml.td { xml << link_to(img_tag('src' => '/images/viewmag.png'), :action => 'show', :id => inquiry) } if false
					xml.td { xml << link_to(img_tag('src' => '/images/edit.png'), :action => 'edit', :id => inquiry) }
					xml.td { xml << link_to(img_tag('src' => '/images/trashcan_empty.png'), {:action => 'destroy', :id => inquiry}, :post => true, :confirm => "Are you sure?") }
				end
# 				xml.tr(:class => "row #{inquiry['status']} desc") do
# 					xml.td(:colspan => columns.size + 3) do
# 						xml.p do
# 							unless inquiry['phone'].empty?
# 								xml << 'Phone: ' + inquiry['phone']
# 								xml.br
# 							end
# 							unless inquiry['email'].empty?
# 								xml << 'Email: ' + inquiry['email']
# 								xml.br
# 							end
# 							xml << 'Description: ' + inquiry['description'] unless inquiry['description'].empty?
# 						end
# 					end
# 				end
			end
		end
	end
end
