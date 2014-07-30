# encoding: UTF-8
#require 'timezone'
#require 'rmagick'

# The methods added to this helper will be available to all templates in the application.
module SMKLib
module HtmlUtils
	# Return valid google analytics Javascript code
	def google_analytics(code)
		# code should look like this UA-97533-1
    if RAILS_ENV == "production" and not(code.to_s.empty?)
      return <<EOT
  <script src="https://www.google-analytics.com/urchin.js" type="text/javascript">
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
		when 'Photo'
			parent.photo
		when 'Floorplan'
			nil
		else
			raise "fuck you #{opclass.inspect}"
			ref_id = (opclass.is_a?(RealtorAttachment) ? -1 : nil) if ref_id.nil?
			opclass.find(:first, :conditions => ["properties_id = ? and htmlname = ?", ref_id, spname])
		end
	end

	def fileinput_field(parent, opclass, options={})
		raise "'wrong options #{options.inspect}'" unless options.is_a?(Hash)
		options = {:no_div => false, :value => nil, :lang => 'en'}.merge(options)
		controller = parent.class.to_s.downcase.pluralize
		spname = "#{controller.singularize}_#{opclass.to_s.downcase}"
		options[:value] = get_file_value(parent, opclass, spname) if options[:value].nil?
		id_name = "fileinput_field_#{spname}"
		if options[:value].kind_of?(opclass) and options[:value][:id].to_i > 0
			url_hash = {:controller => controller, :action => 'kill_picture', :id => parent, :pic_class => Inflector.underscore(opclass)}
			if options[:lang]=='en'
			 link_text = 'Delete picture'
			 confirm_text = 'Are you sure?'
			 msg_text = 'To replace the picture, you need to delete this one first.'
			else
			 link_text = '変更'
			 confirm_text = '本当ですか？'
			 msg_text = ''
			end
			link = link_to_remote(link_text, :update => id_name, :url => url_hash, :confirm => confirm_text)
			h = "<img src='#{options[:value].thumbnail_path}' /><br/>#{link}<br/>#{msg_text}"
		else
			t = "<br/><small>(jpeg, jpg, gif files of up to 3MB in size can be uploaded.)</small>" if options[:lang]=='en'
			h = "<input type='file' name='#{controller.singularize}[#{opclass.to_s.downcase}]' />#{t}"
		end
		if options[:no_div]
			h
		else
			"<div id='#{id_name}'>#{h}</div>"
		end
	end

	def form_filter(content, action = '')
		"<form id='my_f' style='display: inline; margin: 0px; padding: 0px;' action='#{action}' method='post'>" + content + '</form>'
	end

  begin
    do_nothing = true if Locale.is_a?(Class)
  rescue
    def _(str)
      str
    end
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
				src="https://pagead2.googlesyndication.com/pagead/show_ads.js">
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
				src="https://pagead2.googlesyndication.com/pagead/show_ads.js">
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
				src="https://pagead2.googlesyndication.com/pagead/show_ads.js">
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
			<script type="text/javascript" src="https://pagead2.googlesyndication.com/pagead/show_ads.js"></script>
EOC
		else
		'
		<p>
		</p>
		'
		end
	end

	def google_conversion_tracker_english
		if session['signup']
			session['signup'] = false
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
		<script language="JavaScript" src="https://www.googleadservices.com/pagead/conversion.js">
		</script>
		<noscript>
			<img height=1 width=1 border=0 src="https://www.googleadservices.com/pagead/conversion/1068909979/?value=1.0&label=Signup&script=0">
		</noscript>
		'
		end
	end

	def display_errors
		return '' if flash.class == String # flash got broken by render_component.
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
		f_n = [flash[:notice], flash['notice'], flash[:message], flash['message']].compact.sort.uniq.join(' ')
		unless f_n.empty?
			s += '<div class="flash notice_content">'
			s += img_tag(:src => image_path("button_ok.png"))
			s += '<span>'
			s += f_n
			#s += '<br/>' + google_conversion_tracker_english if @flash['signup']
			s += '</span>'
			s += '</div>'
			s += '<div>&nbsp;</div>' # unless s.empty?
		end
		f_a = [flash[:warning], flash['warning'], flash[:alert], flash['alert']].compact.sort.uniq.join(' ')
		unless f_a.empty?
			s += '<div class="flash error_content">'
			s += img_tag(:src => image_path("button_cancel.png"))
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
		options = {
			:select_extra_js => '',
			:img_extra_js => '',
			:select_js => "AddToCategoryClick('#{text_id}', this);",
			:img_js => "showOrHide('#{select_id}');showOrHide('#{text_id}');",
			:field_only => false,
			:text_field_type => 'magic', # can be 'tag'
			:text_field_value => '', # used if text_field_type == 'tag'
			:button_value => '...',
			:default_img_alt => '', # obsolete, button was and image
			:extra => nil, # some custom stuff I will add at the end.
		}.merge(options)
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
		field_only_or_not(text_id, label.to_s.capitalize, options[:field_only]) do |xml|
			if options[:text_field_type] == "tag"
				xml << text_field_tag(text_id, options[:text_field_value], text_field_html_options)
			else
				xml << text_field(object, method, text_field_html_options)
			end
			xml.span(:id => select_id + '_div') do
				xml.select(:id => select_id, :name => select_id, :style => select_css_style, :onchange => "#{options[:select_js]}#{options[:select_extra_js]}") do
					xml.option(:value => '') { xml << _("Choose one") } # a #{label}" }
					xml << options_for_select(select_data, current_value)
				end
			end
			xml.input(:type => 'button', :value => options[:button_value], :alt => options[:default_img_alt], :border => 0, :align => "absmiddle", :onclick => "#{options[:img_js]}#{options[:img_extra_js]}")
			xml.span do
				xml << options[:extra]
			end unless options[:extra].to_s.empty?
			xml.target!
		end
	end

	def normal_field(xml, object, method, label, type='text_field')
		xml.p do
			xml.label(:for => "#{object}_#{method}") do
				xml << label
			end
			xml.br
			case type
			when 'text_field'
				xml << text_field(object, method)
			when 'text_area'
				xml << text_area(object, method)
			when 'in_place_field'
				xml << in_place_editor_field(object, method)
			when 'in_place_editor'
				xml << in_place_editor(object, method)
			when 'in_place_select_field'
				xml << in_place_select_field(object, method)
			when 'other'
				yield(xml)
			end
		end
	end

	def many_to_many_field(xml, object, method, parent_method, label, all_values, options={})
		xml ||= Builder::XmlMarkup.new(:indent=>2)
		#@controller = (@controller or options[:controller])
		options = {:item_name => 'name', :m2m_selected => 'm2m_selected'}.merge(options)
		@object = instance_variable_get("@#{object}")
		@values = @object.send(method)
		parent_id = "#{object}_id".to_sym
		child_id = "#{method.to_s.singularize}_id".to_sym
		raise @values.inspect unless @values.is_a?(Array)
		normal_field(xml, object, method, label, 'other') do |xml|
			xml.div(:class => options[:m2m_selected]) do
				@values.each do |item|
					xml.div do
						xml << item.send(options[:item_name])
						xml << '&nbsp;'
						xml << link_to(_('Remove'), url_for(:controller => 'businesses', :action => "remove_#{method.to_s.singularize}_from_#{object}", parent_id => @object[:id], child_id => item[:id]))
					end
				end
			end
			s = "select_#{object}_#{method}_box"
			#url = url_for({ :action => "add_#{method.to_s.singularize}_to_#{object}" })
			#url += "/'+$('#{s}').options[$('#{s}').selectedIndex].value+'/to_#{object}/#{@object[:id]}"
			#url = url_for({ :action => "add_#{method.singularize}_to_#{object}", parent_id => @object[:id].to_i, child_id => "'+$('#{s}').options[$('#{s}').selectedIndex].value+'", :escape => false })
			url = url_for({ :action => "add_#{method.singularize}_to_#{object}", parent_id => @object[:id].to_i, child_id => "__js__", parent_method => "__js2__" })
			if all_values.empty?
				xml << "<input type='text' id='#{object}_#{parent_method}' />"
				xml << text_field(object, method)
				url.gsub!("__js__", "'+$('#{object}_#{method}').value+'")
				url.gsub!("__js2__", "'+$('#{object}_#{parent_method}').value+'")
				xml << "<input type='button' align='absmiddle' alt='' border='0' value='Add' onclick=\"window.location='#{url}';return false;\" />"
			else
				url.gsub!("__js__", "'+$('#{s}').options[$('#{s}').selectedIndex].value+'")
				xml << text_and_select_field(nil, object, method, all_values, nil, :button_value => _('Add'), :field_only => true, :text_field_type => 'tag', :img_js => "window.location='#{url}';return false;")
			end
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
end

module ActionController
	module Macros
		module ManyToMany #:nodoc:
			def self.append_features(base) #:nodoc:
				super
				base.extend(ClassMethods)
			end

			# Example:
			#
			#   # Controller
			#   class BusinessesController < ApplicationController
			#     many_to_many_for :business, :subcategories, :label => _('Subcategory'), :m2m_field_options => {:item_name => 'name_with_category'}
			#   end
			#
			#   # View
			#   xml.div(:id => 'm2m_business_subcategories') do
			#     many_to_many_field(xml, 'business', 'subcategories', _('Subcategory'), @subcategories, :item_name => 'name_with_category')
			#   end
			#
			module ClassMethods
				def many_to_many_for(object, attribute, options = {})
					#include SMKLib::HtmlUtils
					options = {:max_size => 10, :label => attribute.to_s.capitalize}.merge(options)
					parent_model, child_model = object.to_s.camelize.constantize, attribute.to_s.singularize.camelize.constantize
					@controller = self

					define_method("add_#{attribute.to_s.singularize}_to_#{object}") do
						instance_variable_set("@#{object}", parent_model.find(params[:business_id]))
						collection = instance_variable_get("@#{object}").send(attribute.to_s)
						if collection.size >= options[:max_size]
							flash[:alert] = _("Can't add. This %s already has %d %s.") % [object, options[:max_size], attribute]
						else
							if params[:subcategory_id].to_i > 0
								collection << child_model.find(params[:subcategory_id]) rescue flash[:alert] = _('%s already linked to this %s.') % [attribute.to_s.capitalize.singularize, object]
							else
								c = Category.find_or_create_by_name(params[:categories])
								collection << child_model.find_or_create_by_name_and_category_id(params[:subcategory_id], c[:id])
							end
						end
						redirect_to :action => 'edit', :id => instance_variable_get("@#{object}")[:id]
						# many_to_many_field(nil, object, attribute, options[:label], child_model.find_all, options[:m2m_field_options].merge(:controller => self))
					end

					define_method("remove_#{attribute.to_s.singularize}_from_#{object}") do
						instance_variable_set("@#{object}", parent_model.find(params[:business_id]))
						instance_variable_get("@#{object}").send(attribute).delete(child_model.find(params[:subcategory_id]))
						redirect_to :action => 'edit', :id => instance_variable_get("@#{object}")[:id]
						#raise many_to_many_field(nil, object, attribute, options[:label], child_model.find_all, options[:m2m_field_options].merge(:controller => self))
					end
				end
			end
		end
	end
end

ActionController::Base.class_eval do
	include ActionController::Macros::ManyToMany
end
