require 'base64'

module Devise
  module Encryptors
    # = BCrypt
    # Uses the BCrypt hash algorithm to encrypt passwords.
    class Base64 < Base
      # Gererates a default password digest based on stretches, salt, pepper and the
      # incoming password. We don't strech it ourselves since BCrypt does so internally.
      def self.digest(password, stretches, salt, pepper)
        ::Base64.encode64(password)
      end

    end
  end
end
