require 'chef/data_bag'
require_relative './s3'

class Chef
  ##
  # Extend Chef::DataBag to fetch from S3
  ##
  class DataBag
    class << self
      alias_method :__load__, :load
      def load(name)
        return __load__(name) unless Chef::Config[:s3_data_bags]

        load_from_s3(name)
      end

      def load_from_s3(name)
        data_bag_prefix = File.join(Chef::Config[:data_bag_path], name)
        Chef::Log.debug("Listing items in databag #{name} from s3://#{ Chef::S3.bucket }/#{ data_bag_prefix }")

        ## Match the ChefServer API response, which is a hash of {ID => ResourcePath}
        Chef::S3.list(data_bag_prefix).each_with_object({}) do |item, contents|
          contents[::File.basename(item, '.json')] = ::File.join(data_bag_prefix, item)
        end

        ## An invalid prefix does not throw any error; just returns an empty set.
      rescue Aws::S3::Errors::NoSuchBucket
        raise Chef::Exceptions::InvalidDataBagPath, "S3 bucket '#{Chef::S3.bucket}' is invalid"
      end
    end
  end
end
