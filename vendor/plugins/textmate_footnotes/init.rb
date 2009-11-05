# Copyright:
#   (c) 2006 syncPEOPLE, LLC.
#   Visit us at http://syncpeople.com/
# License: MIT
# Author: Duane Johnson (duane.johnson@gmail.com)
# Description:
#   Creates clickable footnotes on each rendered page, as well as clickable
#   links in the backtrace should an error occur in your Rails app.  Links take
#   you to the right place inside TextMate.

# Enable only on Macs in development mode
begin
  if (ENV['RAILS_ENV'] == 'development') && (`uname`.chomp == "Darwin")
    #require 'textmate_footnotes'
    #require 'textmate_backtracer'
  end
rescue
  # Windows doesn't have 'uname'
end