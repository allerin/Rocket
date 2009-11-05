class PriceZone < ActiveRecord::Base
  allow_read(:all){ |r| true }
	allow_write(:all){ |r| r == :admin }
end
