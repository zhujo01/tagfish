require 'tagfish/docker_registry_vboth_client'

module Tagfish
  class DockerRegistryV1Client < DockerRegistryVbothClient
    
    def api_version
      'v1'
    end
    
    def search(keyword)
      if not keyword
        abort("You need to specify a keyword to search a Registry V1")
      end
      repos_raw = APICall.new(search_uri(keyword)).get_json(http_auth)
      repos = repos_raw["results"].map {|result| result["name"]}
    end
    
    def tag_names
      tag_map.tag_names
    end

    def tag_map
      tags_list = tags_api(tags)
      Tagfish::Tags.new(tags_list)
    end
    
    private

    def tags
      APICall.new(tags_uri).get_json(http_auth)
    end
        
    def tags_api(api_response_data)
      case api_response_data
        when Hash
        api_response_data
      when Array
        api_response_data.reduce({}) do |images, tag|
          images.merge({tag["name"] => tag["layer"]})
        end
      else
        raise "unexpected type #{api_response_data.class}"
      end
    end
    
    def ping_uri
      "#{base_uri}/v1/_ping"
    end
    
    def search_uri(keyword)
      "#{base_uri}/v1/search?q=#{keyword}"  
    end
    
    def tags_uri
      "#{base_uri}/v1/repositories/#{docker_uri.repository}/tags"
    end
  end
end