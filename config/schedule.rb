# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
set :output, "log/cron_log.log"

# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever

every :reboot do
	command "cd /home/ubuntu/AaditLife/current && RAILS_ENV=staging ./bin/delayed_job start"
	command "cd /home/ubuntu/AaditLife/current && bundle exec pumactl -S /home/ubuntu/AaditLife/shared/tmp/pids/puma.state -F /home/ubuntu/AaditLife/shared/puma.rb restart"
end