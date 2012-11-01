class GoogleSAAuth
  class Scope
    attr_accessor :scope_urls, :api_info
    def initialize(name)
      get_api_info(name.to_s)
    end

    def url
      full_access
    end

    def full_access
      # Get the shortest scope, which theoretically will be full permissions.
      self.scope_urls.sort_by {|url| url.length}.first
    end

    def read_only
      # Simply wrapper for .readonly permissions.
      by_extension('readonly')
    end

    def by_extension(extension)
      # If extension is nil, then we can just return full access.
      return full_access if extension.nil?

      # Try to find a scope by extension, e.g. ".readonly"
      self.scope_urls.each do |url|
        return url if url =~ /\.#{extension}$/i
      end
      nil
    end

  private
    def known_apis
      # Get the list of known APIs using the Google's API Discovery
      response =  GoogleSAAuth::Client.run(
        :uri => 'https://www.googleapis.com/discovery/v1/apis',
        :method => 'get'
      )

      # Make sure we got a 200 response.
      raise RuntimeError unless response.status == 200

      # Parse the json and store the known apis.
      result = JSON.parse(response.body)
      apis = {}
      result['items'].each {|item| apis[item['name']] = item}
      apis
    end

    def get_api_info(scope_name)
      return if self.scope_urls

      # Make sure google listed this API.
      api_info = known_apis[scope_name]
      return nil unless api_info && api_info['discoveryRestUrl']

      # Get the OAuth 2.0 scope url.
      response = GoogleSAAuth::Client.run(
        :uri => api_info['discoveryRestUrl'],
        :method => 'get'
      )

      # Make sure we got a 200 response.
      raise RuntimeError unless response.status == 200

      # Parse the result and try to determine scope URLs.
      result = JSON.parse(response.body)
      self.scope_urls = result['auth']['oauth2']['scopes'].keys rescue nil
      self.api_info = result
    end
  end
end
