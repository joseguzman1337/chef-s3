require 'chef/data_bag_item'
require 'json'
require_relative './s3'

class Chef
  ##
  # Extend Chef::DataBagItem to fetch from S3
  ##
  class DataBagItem
    class << self
      alias_method :__load__, :load
      def load(data_bag, name)
        return __load__(data_bag, name) unless Chef::Config[:s3_data_bags]

        load_from_s3(data_bag, name)
      end

      def load_from_s3(data_bag, name)
        data_bag_key = File.join(Chef::Config[:data_bag_path], data_bag, "#{name}.json")
        Chef::Log.debug("Fetching item #{name} in databag #{data_bag} from s3://#{ Chef::S3.bucket }/#{ data_bag_key }")

        from_hash(Chef::JSONCompat.from_json(Chef::S3.fetch(data_bag_key).content))

      rescue Aws::S3::Errors::NoSuchKey
        raise Chef::Exceptions::InvalidDataBagItemID, "DataBag '#{data_bag}/#{name}' could not be loaded from S3"
      rescue Aws::S3::Errors::NoSuchBucket
        raise Chef::Exceptions::InvalidDataBagPath, "S3 bucket '#{Chef::S3.bucket}' is invalid"
      end
    end
  end
end
