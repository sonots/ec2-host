class EC2
  class Host
    # If want sophisticated utility, better to use ActiveSupport
    module StringUtil
      def self.camelize(string)
        string = string.sub(/^[a-z\d]*/) { $&.capitalize }
        string.gsub!(/(?:_|(\/))([a-z\d]*)/i) { $2.capitalize }
        string.gsub!(/\//, '::')
        string
      end

      def self.underscore(camel_cased_word)
        return camel_cased_word unless camel_cased_word =~ /[A-Z-]|::/
        word = camel_cased_word.to_s.gsub(/::/, '/')
        word.gsub!(/([A-Z\d]+)([A-Z][a-z])/,'\1_\2')
        word.gsub!(/([a-z\d])([A-Z])/,'\1_\2')
        word.tr!("-", "_")
        word.downcase!
        word
      end

      def self.pluralize(string)
        "#{string.chomp('s')}s"
      end

      def self.singularize(string)
        string.chomp('s')
      end
    end
  end
end
