
class ActiveRecord::Base
	def self.has_movable(association_id, options = {}, &extension)
		define_method('last_order_index') do
			max = -6500
			self.send(association_id.to_s).each { |p| max = p.order_index.to_i if p.order_index.to_i > max.to_i }
			max
		end

		define_method('update_order_indexes') do |moved_page_id, above_page_id|
			moved_page = self.send(association_id.to_s).find(moved_page_id)
			above_page = self.send(association_id.to_s).find(above_page_id)
			next_next_order_index = above_page.order_index.to_i + 2
			self.send(association_id.to_s).find(:all, :conditions => ['order_index > ?', above_page.order_index]).each { |p|
				p.order_index = next_next_order_index
				p.save
				next_next_order_index +=1
			}
			moved_page.order_index = above_page.order_index.to_i + 1
			moved_page.save
		end

		before_create { |model| model.order_index = model.site.last_order_index + 1 }
		#define_method('before_create') do
		#	raise 'in movable children.s'
		#end

		#alias :before_create_orig :before_create
		#define_method('before_create') do
		#	self.order_index = self.site.last_order_index + 1
		#	before_create_orig
		#end
	end
end
