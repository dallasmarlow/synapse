require "synapse/service_watcher/base"
require "marathon"

module Synapse
  class MarathonWatcher < BaseWatcher
    def start
      @marathon = Marathon::Client.new(@discovery['marathon_url'])
      @check_interval = @discovery['check_interval'] || 15.0
      @watcher = Thread.new do
        watch
      end
    end

    private
    def validate_discovery_opts
      ['marathon_url', 'marathon_application'].each do |key|
        unless @discovery[key] and not @discovery[key].empty?
          raise ArgumentError, "option #{key} is required"
        end
      end
    end

    def watch
      until @should_exit
        begin
          start = Time.now
          task_addresses = list_task_addresses
          set_backends(task_addresses) unless task_addresses.empty?
          sleep_until_next_check(start)
        rescue Exception => e
          log.warn "synapse: error in marathon watcher thread: #{e.inspect}"
          log.warn e.backtrace
        end
      end

      log.info "synapse: marathon watcher exited"
    end

    def sleep_until_next_check(start_time)
      sleep_time = @check_interval - (Time.now - start_time)
      if sleep_time > 0.0
        sleep(sleep_time)
      end
    end

    def list_task_addresses
      marathon_response = @marathon.list_tasks(@discovery['marathon_application'])
      unless marathon_response.success?
        raise "marathon api request failed: #{marathon_response.error}"
      end

      marathon_response.parsed_response['tasks'].map do |task|
        if task['ports'] and not task['ports'].empty?
          {'name' => task['id'], 'host' => task['host'], 'port' => task['ports'].first}
        else
          log.warn "synapse marathon watcher excluding task #{task['id']} from backends due to missing ports"
        end
      end.flatten
    rescue => e
      log.warn "synapse marathon watcher: error while polling for tasks: #{e.inspect}"
      []
    end
  end
end
