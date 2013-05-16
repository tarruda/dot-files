require 'rubygems'
require 'wirble'
require 'irb/ext/save-history'
Wirble.init
Wirble.colorize
#History configuration
IRB.conf[:SAVE_HISTORY] = 100
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-save-history"
