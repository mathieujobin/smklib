
class ActiveRecord::Base
	def self.has_movable(association_id, options = {}, &extension)
		define_method('last_order_index') do
			max = -6500
			self.send(association_id.to_s).each { |p| max = p.order_index.to_i if p.order_index.to_i > max.to_i }
			max < -1 ? -1 : max
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

	end

	def self.is_movable_within_a(association_id, options = {}, &extension)
		before_create { |model| model.order_index = model.send(association_id.to_s).last_order_index + 1 }
	end
end
