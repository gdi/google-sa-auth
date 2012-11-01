class GoogleSAAuth
  class Client
    class << self
      def run(args)
        # Clean up our arguments.
        args = args.inject({}){|item,(k,v)| item[k.to_sym] = v; item}
        args = args.delete_if {|k,v| ![:uri, :data, :headers, :method].include?(k)}
        args[:data] ||= {}
        args[:headers] ||= {}

        # Parse the uri.
        protocol, host, path = parse_uri(args[:uri])

        # Set up a nice host info hash.
        host_info = {
          :host => host,
          :path => path,
          :protocol => protocol,
          :headers => args[:headers]
        }

        # Perform the request.
        if args[:method] == 'get'
          CurbFu.get(host_info, args[:data])
        elsif args[:method] == 'post'
          CurbFu.post(host_info, args[:data])
        elsif args[:method] == 'put'
          CurbFu.put(host_info, args[:data])
        elsif args[:method] == 'delete'
          CurbFu.delete(host_info, args[:data])
        else
          raise 'InvalidRequestType', "Unknown method: #{method}"
        end
      end

  private
      def parse_uri(uri)
        return [$1, $2, $3] if uri =~ /^(https?):\/\/([a-z0-9\.\-]+)(\/.*)$/i
        raise ArgumentError "Error parsing URI: #{uri}"
      end
    end
  end
end
