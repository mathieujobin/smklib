################################################
#
# Usage:
#
# 	somekool_scaffold :agents, :ignore_columns => [:last_edit_at], :foreign_keys => [{:key => :sub_of_agent_id, :model => Agent, :title => _('Sub of')}], :css_class => :table_list_view

# 	def set_agent_sub_of_agent_id
# 	a = Agent.find(params[:id])
# 		a[:sub_of_agent_id] = params[:value]
# 		a.save
# 		render :text => (a[:sub_of_agent_id].nil? ? _('NULL') : Agent.find(a[:sub_of_agent_id]).to_s)
# 	end

#
#
#
#
################################################

module ActionView
	module Helpers
		module JavaScriptMacrosHelper
			def in_place_collection_dropdown(field_id, options = {})
				function =  "new Ajax.InPlaceCollectionEditor("
				function << "'#{field_id}', "
				function << "'#{url_for(options[:url])}'"

				js_options = {}
				js_options['cancelText'] = %('#{options[:cancel_text]}') if options[:cancel_text]
				js_options['okText'] = %('#{options[:save_text]}') if options[:save_text]
				js_options['loadingText'] = %('#{options[:loading_text]}') if options[:loading_text]
				#js_options['rows'] = options[:rows] if options[:rows]
				#js_options['cols'] = options[:cols] if options[:cols]
				#js_options['size'] = options[:size] if options[:size]
				js_options['collection'] = options[:collection] if options[:collection]
				js_options['value'] = options[:value] if options[:value]
				js_options['externalControl'] = "'#{options[:external_control]}'" if options[:external_control]
				js_options['loadTextURL'] = "'#{url_for(options[:load_text_url])}'" if options[:load_text_url]
				js_options['ajaxOptions'] = options[:options] if options[:options]
				js_options['evalScripts'] = options[:script] if options[:script]
				js_options['callback']   = "function(form) { return #{options[:with]} }" if options[:with]
				function << (', ' + options_for_javascript(js_options)) unless js_options.empty?

				function << ')'

				javascript_tag(function)
			end


			def in_place_editor_dropdown(object, method, tag_options = {}, in_place_editor_options = {})
				tag = ::ActionView::Helpers::InstanceTag.new(object, method, self)
raise tag.inspect if tag_options[:crash]
				front_val = tag_options.delete(:front_val)
				tag_options = {:tag => "span", :id => "#{object}_#{method}_#{tag.object.id}_in_place_editor", :class => "in_place_editor_field"}.merge!(tag_options)
				in_place_editor_options[:url] = in_place_editor_options[:url] || url_for({ :action => "set_#{object}_#{method}", :id => tag.object.id })
				(front_val.to_s.empty? ? tag.to_content_tag(tag_options.delete(:tag), tag_options) : tag.content_tag(tag_options.delete(:tag), front_val, tag_options)) +
				in_place_collection_dropdown(tag_options[:id], in_place_editor_options)
			end
		end
	end
end

class ActionController::Base
	# Get a metaclass for this class
	#def self.metaclass; class << self; self; end; end

	def self.somekool_scaffold(model, options = {})
#raise Object.const_get(model.to_s.singularize.capitalize).inspect
		instance_eval do
			# required for in_place_editor_field
			include ActionView::Helpers::TagHelper
			include ActionView::Helpers::JavaScriptHelper
			include ActionView::Helpers::JavaScriptMacrosHelper

			# get model object
			object_model = Object.const_get(model.to_s.singularize.capitalize)
			model_sym = model.to_s.singularize.downcase.to_sym

			# call in_plate_edit_for all columns
			columns = object_model.content_columns.collect do |c|
				if options[:ignore_columns].include? c.name.to_sym
					nil
				else
					in_place_edit_for model_sym, c.name.to_sym
					c
				end
			end.compact
			options[:foreign_keys].each do |fk|
				in_place_edit_for model_sym, fk[:key].to_sym
			end

			# simple action index
			define_method(:index) do
				redirect_to :action => 'list'
			end

			# main action
			define_method(:list) do
				xml = Builder::XmlMarkup.new(:indent=>2)
				xml.table(:cellpadding => 0, :cellspacing => 0, :border => 0, :class => "somekool_scaffold list #{model} #{options[:css_class]}") do
					xml.tr do
						columns.each do |c|
							xml.th { xml << c.human_name.to_s.nbsp}
						end
						options[:foreign_keys].each do |fk|
							fk[:collection] = ([[nil, _('NULL')]] + fk[:model].find_all.collect { |item| [item.id, item.to_s] }).inspect.gsub(/nil/, 'null')
							xml.th fk[:title]
						end if options[:foreign_keys]
					end
					object_model.find_all.each_with_index do |row, row_index|
						instance_variable_set("@#{model_sym}", row)
						xml.tr(:class => row_index % 2 == 0 ? 'even' : 'odd') do
							columns.each do |c|
								xml.td do
									#xml << row.send(c.name)
									instance_variable_get("@#{model_sym}")[c.name.to_sym] = " " if instance_variable_get("@#{model_sym}")[c.name.to_sym].to_s.empty?
									xml << in_place_editor_field(model_sym, c.name)
								end
							end
							options[:foreign_keys].each do |fk|
								begin
									front_val = fk[:model].find(row[fk[:key]]).to_s
								rescue
									front_val = _('NULL')
								end
								xml.td do
									xml << in_place_editor_dropdown(model_sym, fk[:key], {:front_val => front_val}, {:value => row[fk[:key]], :collection => fk[:collection]})
								end
								#xml.td fk[:model].find(:first, :conditions => ["#{fk[:key]} = ?", row[fk[:key]]]).inspect ## same
							end if options[:foreign_keys]
						end
					end
				end
				render :text => xml.target!, :layout => 'main'
			end
			#define_method(:new) do
			#end
			#define_method(:create) do
			#end
			#define_method(:edit) do
			#end
			#define_method(:update) do
			#end
			#define_method(:destroy) do
			#end
		end
	end
end

