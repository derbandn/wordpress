#
# Cookbook Name:: wordpress
# Library:: helpers
# Author:: Yvo van Doorn <yvo@getchef.com>
# Author:: Julian C. Dunn <jdunn@getchef.com>
#
# Copyright 2013, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Wordpress
  module Helpers
    def is_local_host?(host)
      if host == 'localhost' || host == '127.0.0.1' || host == '::1'
        true
      else
        require 'socket'
        require 'resolv'
        Socket.ip_address_list.map { |a| a.ip_address }.include? Resolv.getaddress host
      end
    end

    def self.make_db_query(user, pass, query)
      %< --user=#{user} --password="#{pass}" --execute="#{query}" --socket=/var/run/mysql-default/mysqld.sock>
    end
  end
end

require "mixlib/log/formatter"
 
module Mixlib
module Log
class Formatter < Logger::Formatter
# Prints a log message as '[time] severity: message' if Chef::Log::Formatter.show_time == true.
# Otherwise, doesn't print the time.
def call(severity, time, progname, msg)
if @@show_time
reset = "\033[0m"
color = case severity
when "FATAL"
"\033[1;41m" # Bright Red
when "ERROR"
"\033[31m" # Red
when "WARN"
"\033[33m" # Yellow
when "DEBUG"
"\033[2;37m" # Faint Gray
else
reset # Normal
end
sprintf("[%s] #{color}%s#{reset}: %s\n", time.iso8601(), severity, msg2str(msg))
else
sprintf("%s: %s\n", severity, msg2str(msg))
end
end
end
end
end
