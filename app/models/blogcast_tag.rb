class BlogcastTag < ActiveRecord::Base
  belongs_to :blogcast
  belongs_to :tag
end
