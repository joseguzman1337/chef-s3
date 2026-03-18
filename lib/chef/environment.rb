require 'chef/environment'
require_relative './s3'

class Chef
  ##
  # Extend Chef::Environment to fetch from S3
  ##
  class Environment
    class << self
      alias_method :__load__, :load
      def load(name)
        return __load__(name) unless Chef::Config[:s3_environments]

        load_from_s3(name)
      end

      def load_from_s3(name)
        env_key = File.join(Chef::Config[:environment_path], "#{name}.json")
        Chef::Log.info("Fetching environment #{ name } from s3://#{ Chef::S3.bucket }/#{ env_key }")

        # from_json returns object.class => json_class in the JSON.
        Chef::JSONCompat.from_json(Chef::S3.fetch(env_key).content)

      rescue Aws::S3::Errors::NoSuchKey
        raise Chef::Exceptions::EnvironmentNotFound, "Environment '#{name}' could not be loaded from s3://#{Chef::S3.bucket}"
      rescue Aws::S3::Errors::NoSuchBucket
        raise Chef::Exceptions::InvalidEnvironmentPath, "S3 bucket '#{Chef::S3.bucket}' is invalid"
      end
    end
  end
end
