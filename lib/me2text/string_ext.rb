# -*- encoding: utf-8 -*-

require 'me2text'

module Me2Text
  module StringExtension
    def self.included(base)
      base.extend ClassMethods
      base.send(:include, InstanceMethods)
    end
  
    module InstanceMethods 
      def me2text(format = :html, options = {})
        Me2Text.me2text(self, format, options)
      end
    end
  
    module ClassMethods 
      def me2text(text, format = :html, options = {})
        Me2Text.me2text(text, format, options)
      end
    end
  end
end

class String
  include Me2Text::StringExtension
end