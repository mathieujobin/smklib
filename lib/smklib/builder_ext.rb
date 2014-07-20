require 'RMagick'
require 'smklib/array_ext'

class Builder::XmlMarkup

	# Builder Transaction ...

	class AbortTransaction < RuntimeError; end

	def transaction!(&block)
		old_target = @target
		@target = ''
		begin
			yield
			@target = old_target + @target
		rescue AbortTransaction => e
			@target = old_target
		end
	end

	def ignore_abort!(val = true)
		@ignore_abort = val
	end

	def abort!
		raise AbortTransaction, "abort" unless @ignore_abort
	end

	# Build Extensions ...

  class << self
    attr_accessor :environment
  end
  
  def get_ua
    env = ENV
    env = Builder::XmlMarkup.environment if Builder::XmlMarkup.environment
    env['HTTP_USER_AGENT']
  end
  
  def tight_table(options = {})
    table({ "cellspacing" => 0, "cellpadding" => 0, "border" => 0 }.merge(options)) { yield }
  end
 
  #cells is an array of objects that respond to to_s
  def table_row(cells, tr_options = {}, td_options = {})
    tr(tr_options) { cells.each_with_index { |i,k| td(td_options[k] || {}) { self << i.to_s } } }
  end
  
  def sortable_column_header(label, link, options = {})
    #th({"x" => "y"}.merge(options)) do
    th(options) do
      if !label.empty?
        a("href" => link) { self << "&nbsp;#{label}&nbsp;" }
      else
        self << "&nbsp;"
      end
    end
  end

  def real_filename(filename)
		if defined?(RAILS_ROOT)
			RAILS_ROOT + "/public/" + filename
		else
			filename
		end
  end

  def get_img_size(filename)
    im = Magick::Image.read(real_filename(filename)).first
    return [im.columns, im.rows]
  end

	def img(options = {})
		if get_ua =~ /MSIE 6.*Windows/
			if options[:src] =~ /\.png$/
				options[:style] = "filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='#{options[:src]}', sizingMethod='scale');" + options[:style].to_s
				options[:width], options[:height] = get_img_size(options[:src]) unless options[:width] && options[:height]
				options[:src] = '/images/spacer.gif'
			end
		end
    if block_given?
      method_missing(:img, options, yield)
    else
      method_missing(:img, options)
    end
  end
  
  def nbsp(count=1)
    self << (1..count).collect{ "&nbsp;" }.join
  end

	def ob2(ob, *extra, &block)
		# yes this is kind of ugly but makes this a soft dependancy on OdlumBox2
		ob = Class.const_get('OdlumBox2').new(ob) if ob.kind_of? Hash
		div(*extra) do
			ob.render(self) { |xml|
				yield
			}
		end
	end

end
