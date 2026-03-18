require 'chef/config'

class Chef
  ##
  # Add S3 parameters to Chef::Config
  ##
  class Config
    default :aws_access_key_id, nil
    default :aws_secret_access_key, nil

    default :s3_bucket, nil
    default :s3_cache, nil
    default :s3_region, 'us-east-1'

    default :s3_environments, false
    default :s3_data_bags, false
  end
end
