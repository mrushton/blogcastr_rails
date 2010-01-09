module ActionView
  module Helpers
    module JavaScriptHelper
      #MVR - change button_to_function to use button elements and not input elements
      def button_to_function(name, *args, &block)
        html_options = args.extract_options!.symbolize_keys

        function = block_given? ? update_page(&block) : args[0] || ''
        onclick = "#{"#{html_options[:onclick]}; " if html_options[:onclick]}#{function};"

        content_tag(:button, name, html_options.merge(:type => 'button', :onclick => onclick))
      end
    end
  end
end
