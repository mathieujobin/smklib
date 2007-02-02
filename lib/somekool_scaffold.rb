################################################
#
# Usage:
#
# 	somekool_scaffold :agents, :ignore_columns => [:last_edit_at], :foreign_keys => [{:key => :sub_of_agent_id, :model => Agent, :title => _('Sub of')}], :css_class => :table_list_view
#
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
			model_sym = model.to_s.singularize
			object_model = Object.const_get(model_sym.capitalize)
			model_sym = model_sym.downcase.to_sym

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

				define_method("set_#{model_sym}_#{fk[:key]}".to_sym) do
					a = object_model.find(params[:id])
					a[fk[:key].to_sym] = params[:value]
					a.save
					render :text => (a[fk[:key].to_sym].nil? ? _('NULL') : "#{a[fk[:key].to_sym]} - #{fk[:model].find(a[fk[:key].to_sym]).to_s}".nbsp)
				end
			end

			# simple action index
			define_method(:index) do
				redirect_to :action => 'list'
			end

			# main action
			define_method(:list) do
				xml = Builder::XmlMarkup.new(:indent=>2)
				xml.a(:class => "#{model_sym}_add_link", :href => "/#{model_sym.to_s.pluralize}/add") do
					xml.img(:title => 'add_button', :alt => 'add_button', :border => 0, :src => '/smklib/images/add.png')
					xml << _('Add new %s') % model_sym.to_s
				end
				xml.table(:cellpadding => 0, :cellspacing => 0, :border => 0, :class => "somekool_scaffold list #{model} #{options[:css_class]}") do
					xml.tr do
						xml.th _('ID') unless options[:no_id]
						columns.each do |c|
							xml.th { xml << c.human_name.to_s.nbsp}
						end
						options[:foreign_keys].each do |fk|
							fk[:collection] = ([[nil, _('NULL')]] + fk[:model].find_all.collect { |item| [item.id, item.to_s] }).inspect.gsub(/nil/, 'null')
							xml.th fk[:title]
						end if options[:foreign_keys]
						xml.th { xml << _('Delete') } unless options[:no_delete]
					end
					object_model.find_all.each_with_index do |row, row_index|
						instance_variable_set("@#{model_sym}", row)
						xml.tr(:class => row_index % 2 == 0 ? 'even' : 'odd') do
							xml.td do
								xml << instance_variable_get("@#{model_sym}")[:id].to_s
							end unless options[:no_id]
							columns.each do |c|
								xml.td do
									#xml << row.send(c.name)
									instance_variable_get("@#{model_sym}")[c.name.to_sym] = " " if instance_variable_get("@#{model_sym}")[c.name.to_sym].to_s.empty?
									xml << in_place_editor_field(model_sym, c.name)
								end
							end
							options[:foreign_keys].each do |fk|
								begin
									front_val = "#{row[fk[:key]]} - #{fk[:model].find(row[fk[:key]]).to_s}".nbsp
								rescue
									front_val = _('NULL')
								end
								xml.td do
									xml << in_place_editor_dropdown(model_sym, fk[:key], {:front_val => front_val}, {:value => row[fk[:key]], :collection => fk[:collection]})
								end
								#xml.td fk[:model].find(:first, :conditions => ["#{fk[:key]} = ?", row[fk[:key]]]).inspect ## same
							end if options[:foreign_keys]
							xml.td do
								xml.a(:class => "#{model_sym}_delete_link", :href => "/#{model_sym.to_s.pluralize}/destroy/#{row.id}") do
									xml.img(:title => 'delete_button', :alt => 'delete_button', :border => 0, :src => '/smklib/images/trashcan_empty.png')
								end
							end unless options[:no_delete]
						end
					end
				end
				render :text => xml.target!, :layout => 'main'
			end
			define_method(:add) do
				xml = Builder::XmlMarkup.new(:indent=>2)
				xml.form(:action => "/#{model_sym.to_s.pluralize}/create") do
					xml.table(:cellpadding => 0, :cellspacing => 0, :border => 0, :class => "somekool_scaffold add #{model} #{options[:css_class]}") do
						columns.each do |c|
							xml.tr do
								xml.th { xml << c.human_name.to_s.nbsp}
								xml.td { xml.input(:type => 'text', :name => "#{model_sym}[#{c.name}]") }
							end
						end
						options[:foreign_keys].each do |fk|
							fk[:collection] = ([[nil, _('NULL')]] + fk[:model].find_all.collect { |item| [item.id, item.to_s] })
							xml.tr do
								xml.th fk[:title]
								xml.td do
									xml.select(:name => "#{model_sym}[#{fk[:key]}]") do
										fk[:collection].each do |opt|
											xml.option(:value => opt[0]) { xml << opt[1] }
										end
									end
								end
							end
						end if options[:foreign_keys]
						xml.tr do
							xml.td(:colspan => 2) { xml.input(:type => 'submit', :value => _('Add'))}
						end
					end
				end
				render :text => xml.target!, :layout => 'main'
			end
			define_method(:create) do
				object_model.create(params[model_sym])
				flash[:notice] = _('New %s created') % model_sym.to_s
				redirect_to_path "/#{model_sym.to_s.pluralize}/list"
			end
			#define_method(:edit) do
			#end
			#define_method(:update) do
			#end
			define_method(:destroy) do
				object_model.find(params[:id]).destroy
				flash[:notice] = _('%s %s has been destroyed') % [model_sym.to_s, params[:id].to_s]
				redirect_to_path "/#{model_sym.to_s.pluralize}/list"
			end
		end
	end
end

