require 'net/http'
require 'uri'
require 'json'
require 'mysql2'

module NewrelicSphinx
  class Metric
    attr_reader :key, :name, :units, :mode, :last_value
    attr_accessor :value

    def initialize(key, name, units, mode = :plain)
      @key, @name, @units, @mode = key, name, units, mode
      @value = 0
      @last_value = 0
    end

    def memorize
      @last_value = value
    end

    def plain?
      mode == :plain
    end

    def incremental?
      mode == :incremental
    end
  end

  class Agent
    def initialize(configuration = {})
      # If you use localhost, MySQL insists on a socket connection, but Sphinx
      # requires a TCP connection. Using 127.0.0.1 fixes that.
      address = configuration[:host] || '127.0.0.1'
      address = '127.0.0.1' if address == 'localhost'

      options = {
        :host      => address,
        :port      => configuration[:port] || 9306,
        :username  => "root",
        :reconnect => true
      }

      @verbose = !! configuration[:verbose]
      @client = Mysql2::Client.new(options)
      @license_key = configuration[:license_key]
      @host = configuration[:hostname] || `hostname`
      @endpoint = configuration[:endpoint] || "https://platform-api.newrelic.com/platform/v1/metrics"
      @frequenzy = configuration[:frequenzy] || 20
      @component_name = 'Sphinx Stats'
      @component_guid = 'com.github.troelskn.Sphinx'
      @version = '0.0.1'
      @metrics = []
      @metrics << Metric.new("avg_query_wall", "avg/Avg Query Wall Time", "milisecond", :plain)
      @metrics << Metric.new("queries", "general/Queries", "Queries/second", :incremental)
      @metrics << Metric.new("connections", "general/Connections", "connections/second", :incremental)
      @metrics << Metric.new("maxed_out", "error/Maxed out connections", "connections/second", :incremental)
      @metrics << Metric.new("command_search", "commands/Command search", "command/second", :incremental)
      @metrics << Metric.new("command_excerpt", "commands/Command excerpt", "command/second", :incremental)
      @metrics << Metric.new("command_update", "commands/Command update", "command/second", :incremental)
      @metrics << Metric.new("command_keywords", "commands/Command keywords", "command/second", :incremental)
      @metrics << Metric.new("command_persist", "commands/Command persist", "command/second", :incremental)
      @metrics << Metric.new("command_flushattrs", "commands/Command flushattrs", "command/second", :incremental)
    end

    def run
      update_metrics
      @last = Time.now
      while true
        execute
        sleep 1
      end
    end

    def execute
      puts "*** execute" if @verbose
      send_stats(build_metrics) if since_last > @frequenzy
    end

    def since_last
      Time.now - @last
    end

    def send_stats(metrics)
      puts "*** send_stats" if @verbose
      data = {
        'agent' => {
          'host' => @host,
          'version' => @version,
        },
        'components' => [
          {
            'name' => @component_name,
            'guid' => @component_guid,
            'duration' => since_last.round,
            'metrics' => metrics
          }
        ]
      }
      uri = URI.parse(@endpoint)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = JSON.pretty_generate(data)
      request["Content-Type"] = "application/json"
      request["Accept"] = "application/json"
      request["X-License-Key"] = @license_key
      http = Net::HTTP.new(uri.hostname, uri.port)
      if uri.scheme == 'https'
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      http.set_debug_output $stderr if @verbose
      response = http.start do |http|
        http.request(request)
      end
      update_state if response.kind_of? Net::HTTPSuccess
    end

    def update_state
      @last = Time.now
      @metrics.each do |m|
        m.memorize if m.incremental?
      end
    end

    def update_metrics
      data_source = {}
      @client.query("show status").each do |row|
        key = row.values[0]
        value = row.values[1]
        if value == "OFF"
          data_source[key] = nil
        elsif value =~ /^\d+$/
          data_source[key] = value.to_i
        else
          data_source[key] = value.to_f
        end
      end
      @metrics.each do |m|
        m.value = data_source[m.key]
      end
    end

    def build_metrics
      update_metrics
      struct = {}
      @metrics.each do |m|
        raise "Missing metric #{m.name}" if m.value.nil?
        if m.incremental?
          struct["Component/#{m.name}[#{m.units}]"] = m.value - m.last_value
        else
          struct["Component/#{m.name}[#{m.units}]"] = m.value
        end
      end
      struct
    end

  end
end
