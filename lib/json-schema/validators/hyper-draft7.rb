module JSON
  class Schema
    class HyperDraft6 < Draft7
      def initialize
        super
        @uri = JSON::Util::URI.parse('http://json-schema.org/draft-07/hyper-schema#')
      end

      JSON::Validator.register_validator(new)
    end
  end
end
