require 'aws-sdk'
require 'dupondius/aws/cloudformation'
require 'dupondius/aws/ec2'
require 'ostruct'

module Dupondius
extend self

  @config = OpenStruct.new

  def configure
    block_given? ? yield(@config) : @config
  end
  alias :config :configure

  class Version

    def self.refspec
      @_refspec ||= `git rev-parse HEAD 2>/dev/null`.strip
    end

    def self.version
      if @_version
        @_version
      else
        versions ||= `git log --decorate --format=format:%d #{refspec} 2>/dev/null | awk '/v[0-9]+\\.[0-9]+\\.[0-9]+/' | head -n 1`
        @_version = versions[1..-2].split(', ').collect { |it| it.match(/v\d+\.\d+\.\d+/) }.select { |it| it }.first[0] if versions.size > 1
        @_version ||= ''
      end
    end

    def self.build_date
      @_build_date ||= `git log -n 1 #{refspec} --format=%ad 2>/dev/null`.strip
    end

  end

end
