unless IO.respond_to?(:copy_stream)
  require 'fileutils'
  
  class IO
    def self.copy_stream(src, dest)
      src_stream, dest_stream = nil, nil
      begin
        src_stream = if src.respond_to?(:to_str) 
                       File.open(src, "rb")
                     else
                       src
                     end
        dest_stream = if dest.respond_to?(:to_str)
                        File.open(dest, "wb")
                      else
                        dest
                      end
        FileUtils.copy_stream(src_stream, dest_stream)
      ensure
        src_stream.close if src_stream.equal?(src)
        dest_stream.close if dest_stream.equal?(dest)
      end
    end
  end
end
