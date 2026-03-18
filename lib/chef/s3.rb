## Patch Chef resources
require_relative './data_bag'
require_relative './data_bag_item'
require_relative './environment'

require 'aws-sdk'
require 'chef/config'

class Chef
  ##
  # Allow chef-client to fetch core objects from S3
  ##
  module S3
    class << self
      def client
        @client ||= Aws::S3::Client.new({
          :region => Chef::Config[:s3_region]
        }.tap do |config|
          config[:access_key_id] = Chef::Config[:aws_access_key_id] if Chef::Config[:aws_access_key_id]
          config[:secret_access_key] = Chef::Config[:aws_secret_access_key] if Chef::Config[:aws_secret_access_key]
        end)
      end

      def bucket
        Chef::Config[:s3_bucket]
      end

      def resources
        @resources ||= {}
      end

      def fetch(key)
        resources[key] ||= S3::Resource.new(key)
      end

      ## Assumes a simple key-path, e.g. /path/to/data_bags/:data_bag/:item.json
      def list(prefix)
        response = client.list_objects(
          :bucket => bucket,
          :prefix => prefix)

        contents = response.contents[1..-1] ## Drop the first item. This is the prefix folder
        return [] if contents.nil?

        contents.map { |o| ::File.basename(o.key) }
      end
    end
  end
end

require_relative './s3/version'
require_relative './s3/resource'
