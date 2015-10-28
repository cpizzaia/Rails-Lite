require 'uri'
require 'byebug'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    #
    # You haven't done routing yet; but assume route params will be
    # passed in as a hash to `Params.new` as below:
    def initialize(req, route_params = {})
      @req = req
      @params = {}
      @params.merge!(parse_www_encoded_form(req.query_string)) if req.query_string
      @params.merge!(parse_www_encoded_form(req.body)) if req.body
      @params.merge!(route_params)
    end

    def [](key)
       @params[key.to_s].nil? ? @params[key.to_sym] : @params[key.to_s]
    end

    # this will be useful if we want to `puts params` in the server log
    def to_s
      @params.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      params = {}

      key_values = URI.decode_www_form(www_encoded_form)
      key_values.each do |full_key, value|
        scope = params
        key_seq = parse_key(full_key)
        key_seq.each_with_index do |key, idx|
          if (idx + 1) == key_seq.count
            scope[key] = value
          else
            scope[key] ||= {}
            scope = scope[key]
          end
        end
      end

      params
    end

    # this should return an array
    # "user[address][street]" should return ['user', 'address', 'street']
    def parse_key(key)
      result = []
      last_found_position = 0
      for i in 0..key.length-1
        if key[i] == "["
          string = key[last_found_position..i-1]
          string = string[0..-2] if string[-1] == "]"
          result << string
          last_found_position = i+1
        elsif i == key.length-1
          string = key[last_found_position..i]
          if string[-1] == "]"
            result << string[0..-2]
          else
            result << string
          end
        end
      end
      result
    end
  end
end
