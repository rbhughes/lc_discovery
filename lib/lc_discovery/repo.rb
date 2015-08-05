#require_relative 'models/meta'
require 'yaml'


module Repo

  # meta madness:
  # Repo.fetch('meta') ~~> @meta = new (memoized) Elasticsearch MetaRepository
  def self.fetch(type)
    sym = "@#{type.downcase}".to_sym
    begin

      if self.instance_variables.include?(sym)
        self.instance_variable_get(sym)
      else
        repo = "#{type.capitalize}Repository".constantize.new(
          url: elasticsearch_url,
          log: true
        )
        repo.index = 'lc-dev'
        repo.client.transport.logger.formatter = proc { |s, d, p, m| "\e[2m# #{m}\n\e[0m" }

        instance_variable_set(sym, repo)
        self.instance_variable_get(sym)
      end

    rescue Exception => e
      raise e
    end
  end


  private

  def self.elasticsearch_url
    @elasticsearch_url ||=
      begin
        cfg = YAML.load_file('config.yml')['elasticsearch']
        ENV['ELASTICSEARCH_URL'] || "#{cfg['host']}:#{cfg['port']}"
      end
  end
end

