if defined? ::ArJdbc::MySQL
  puts "Monkeypatching quote_string in mysql jdbc adapter"
  module ArJdbc::MySQL

    def quote_string_with_encoding_preservation(string)
      original_enc = string.encoding
      result = quote_string_without_encoding_preservation(string)
      result = result.force_encoding(original_enc) if result.encoding != original_enc
      result
    end
    alias_method_chain :quote_string, :encoding_preservation

  end
end
