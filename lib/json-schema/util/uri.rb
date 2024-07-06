require 'addressable/uri'
require 'concurrent'

module JSON
  module Util
    module URI
      SUPPORTED_PROTOCOLS = %w(http https ftp tftp sftp ssh svn+ssh telnet nntp gopher wais ldap prospero)

      @cache_mutex = Mutex.new

      class << self
        def absolutize_ref(ref, base)
          parsed_ref = parse(ref.dup)
          # Like URI2.strip_fragment but with wired caching inside parse
          ref_uri = if parsed_ref.fragment.nil? || parsed_ref.fragment.empty?
                      parsed_ref
                    else
                      parsed_ref.merge(fragment: '')
                    end

          return ref_uri if ref_uri.absolute?
          return parse(base) if ref_uri.path.empty?

          uri = URI2.strip_fragment(base).join(ref_uri.path)
          URI2.normalize_uri(uri)
        end

        def parse(uri)
          if uri.is_a?(Addressable::URI)
            uri.dup
          else
            @parse_cache ||= {}
            parsed_uri = @parse_cache[uri]
            if parsed_uri
              parsed_uri.dup
            else
              @parse_cache[uri] = Addressable::URI.parse(uri)
            end
          end
        rescue Addressable::URI::InvalidURIError => e
          raise JSON::Schema::UriError, e.message
        end

        def clear_cache
          cache_mutex.synchronize do
            @parse_cache = {}
          end
        end

        private

        # @!attribute cache_mutex
        #   @return [Mutex]
        attr_reader :cache_mutex
      end
    end
  end
end
