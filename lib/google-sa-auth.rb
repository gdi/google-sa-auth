require 'google-jwt'
require 'curb-fu'
require 'google-sa-auth/scope'
require 'google-sa-auth/token'
require 'google-sa-auth/client'

class GoogleSAAuth
  attr_accessor :claim_set, :pkcs12, :token
  def initialize(args)
    # Symbolize keys.
    args = args.inject({}){|item,(k,v)| item[k.to_sym] = v; item}

    # Remove unknown keys and make sure we have all the required keys.
    args.delete_if {|k,v| ![:email_address, :scope, :key, :password, :audience].include?(k)}
    [:email_address, :scope, :key].each do |required|
      raise RuntimeError, "Missing required argument key #{required}" unless args[required]
    end

    # Setup default password and audience.
    args[:password] ||= 'notasecret'
    args[:audience] ||= 'https://accounts.google.com/o/oauth2/token'

    # Create the claim set.
    self.claim_set = {:iss => args[:email_address], :aud => args[:audience]}

    # Determine the scope.
    if args[:scope].class == String
      if args[:scope] =~ /^http/i
        self.claim_set[:scope] = args[:scope]
      else
        self.claim_set[:scope] = GoogleSAAuth::Scope.new(args[:scope]).url
      end
    elsif args[:scope].class == Array
      scopes = args[:scope].each.collect do |scope|
        if scope =~ /http/i
          scope
        else
          GoogleSAAuth::Scope.new(scope).url
        end
      end
      self.claim_set[:scope] = scopes.join(' ')
    elsif args[:scope].class == Hash
      # Specify extension, e.g. => {:fusiontables => 'readonly'}
      scopes = []
      args[:scope].each do |scope,extension|
        if scope =~ /^http/i
          url = scope
        else
          url = GoogleSAAuth::Scope.new(scope).by_extension(extension)
        end
        scopes.push(url) unless url.nil?
      end
      self.claim_set[:scope] = scopes.join(' ')
    end

    # Set other attributes.
    self.pkcs12 = {:key => args[:key], :password => args[:password]}

    # Get our authorization.
    auth_token
    self
  end

  def auth_token
    # Make sure this token isn't expired.
    self.token = nil if self.token.nil? || self.token.expired?
    self.token ||= GoogleSAAuth::Token.new(jwt)
    self.token
  end

  def token_string
    # Return only the string for the token.
    auth_token.token
  end

  def jwt
    # Make sure the jwt isn't already expired.
    @json_web_token = nil if @json_web_token.nil? || Time.now.to_i >= @json_web_token.claim_set[:exp]

    # (Re)create the JSON web token.
    @json_web_token ||= GoogleJWT.new(
      self.claim_set,
      self.pkcs12[:key],
      self.pkcs12[:password]
    )
    @json_web_token
  end
end
