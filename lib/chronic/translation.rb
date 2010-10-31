module Chronic
  Translations = {}
  class << self
    def register_normalization(language, &block)
      Translations[language] = block
    end

    # Tries to translate / normalize idioms
    #
    # Always adds :en as last language, since english is used internally
    # 
    def translate!(text, *languages)
      languages = Translations.keys unless languages.any?
      languages  = languages.flatten.map!(&:to_sym)
      languages.delete :en # remove :en translation from everywhere
      languages.push :en   # to push it as the last one
      languages.each do |lang|
        Translations[lang] && Translations[lang].call(text)
      end
      text
    end
  end
end

# include translations
require 'chronic/languages/english.rb'
require 'chronic/languages/russian.rb'

