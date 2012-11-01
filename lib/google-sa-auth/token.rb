class GoogleSAAuth
  class Token
    attr_accessor :token, :response, :expires_at
    def initialize(jwt)
      # Get the token upon initialization and symbolize the keys.
      self.response = get_auth_token(jwt.jwt).inject({}){|item,(k,v)| item[k.to_sym] = v; item}
      self.token = self.response[:access_token]
      self.expires_at = jwt.claim_set[:exp]
    end

    def expired?
      Time.now.to_i >= self.expires_at
    end

  private
    def get_auth_token(jwt)
      # Post to the google oauth2 token URL.
      result = GoogleSAAuth::Client.run(
        :uri => 'https://accounts.google.com/o/oauth2/token',
        :headers => {
          'Content-Type' => 'application/x-www-form-urlencoded'
        },
        :data => "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=#{jwt}",
        :method => 'post'
      )

      # Throw an exception unless we got a 200 response.
      raise RuntimeError, "Error getting authentication token: #{result.body}" unless result.status == 200

      # Parse the results.
      JSON.parse(result.body.to_s)
    end
  end
end
