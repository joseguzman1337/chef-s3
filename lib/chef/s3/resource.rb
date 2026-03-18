require 'fileutils'
require_relative '../s3'

class Chef
  module S3
    ##
    # Handle validation and caching of a resource stored in S3
    ##
    class Resource
      class << self
        def cache
          Chef::Config[:s3_cache] || ::File.join(Chef::Config[:file_cache_path], 's3')
        end
      end

      attr_reader :key

      def initialize(key)
        @key = key

        Chef::Log.debug("Using S3 resource #{key} (#{etag})")
        fetch
      end

      def cached?
        ::File.exist?(_content_path) && ::File.exist?(_etag_path)
      end

      def content
        @content ||= IO.read(_content_path) rescue nil
      end

      def etag
        IO.read(_etag_path) rescue nil
      end

      private

      def fetch
        response = S3.client.get_object(
          :bucket => S3.bucket,
          :key => key,
          :if_none_match => etag
        )

        Chef::Log.debug("Fetched object #{key} (#{etag}) from S3")
        FileUtils.mkdir_p(::File.join(self.class.cache, key))

        @content = response.body.read
        IO.write(_etag_path, response.etag)
        IO.write(_content_path, @content)

      rescue Aws::S3::Errors::NotModified
        ## Cached content is current
        Chef::Log.debug("Using cached S3 resource #{key} (#{etag})")
      end

      def _content_path
        ::File.join(self.class.cache, key, 'Content')
      end

      def _etag_path
        ::File.join(self.class.cache, key, 'ETag')
      end
    end
  end
end
