require 'smklib/builder_ext'

class SuperLookingList

	attr_accessor :model, :list, :columns, :speed, :table_width, :options
	
	def initialize(model, list, columns, speed, table_width, options = {})
		@model, @list, @columns, @speed, @table_width, @options = model, list, columns, speed, table_width, options
	end
	
	def format_column(item, column)
		c = column[:field]
		val = item[c]
		if column[:format]
			val = column[:format].call(item, c)
		else
			if item.respond_to? :format_for_display
				STDERR.puts "Warning: {model}::format_for_display is deprecated (#{item.to_s})"
				val = item.format_for_display(c)
			end
		end
		val = "n/a" if val.to_s.empty?
		return val.to_s
	end

	def render(xml = nil, &block)
		xml ||= Builder::XmlMarkup.new(:indent => 2)
		xml.div do
			xml.tight_table("border" => "1", "width" => table_width.to_s, "cellpadding" => "2", "class" => "SuperTableList #{@model.capitalize}") do
				xml.tr do
					columns.each { |c|
						xml.th {
							if options[:header_format]
								options[:header_format].call(xml, c)
							else
								xml << c[:label]
							end
						}
					}
				end
				idx = 0
				for item in list
					style = ((idx % 2 == 0) ? "even" : "odd") + " type_#{item.class}"
					xml.tr("id" => "#{model}_row_#{idx}", "onclick" => "proceed_on_click(this, #{speed})", "onmouseover" => "show_details(this);", "class" => style, "onmouseout" => "hide_last_shown(this);") do
						columns.each do |col|
							xml.td("class" => "field_#{col[:field]}") { xml << format_column(item, col) }
						end
					end
					xml.tr("class" => "current", "id" => "#{model}_row_#{idx}_details", "style" => "display: none;") do
						xml.td("colspan" => columns.size) do
							xml.div("style" => "overflow: auto;", "id" => "#{model}_row_#{idx}_block_details") do
								yield(xml, item)
							end
						end
					end
					idx += 1
				end
			end
		end
	end
end


