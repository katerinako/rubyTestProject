require 'action_view'
  
module ActionView
  module Template::Handlers
    
    module XLSXHelper

      def xlsx_document(opts={})
        download = opts.delete(:force_download)
        filename = opts.delete(:filename)

        begin
          tempfile = Tempfile.new(['wx', '.xlsx'])
          workbook = RubyXL::Workbook.new([], tempfile.path)

          yield workbook if block_given?

          workbook.write
          
          disposition(download, filename) if (download || filename)

          str = File.binread(tempfile.path)
          str
        ensure
          tempfile.unlink if tempfile
        end
      end

      def disposition(download, filename)
        download = true if (filename && download == nil)
        disposition = download ? "attachment;" : "inline;"
        disposition += " filename=\"#{filename}\"" if filename
        headers["Content-Disposition"] = disposition
      end

    end


    class XLSXTemplateHandler < Template::Handler
      include Compilable
      
      self.default_format = Mime::XLSX

      def compile(template)
        require 'rubyXL'
        require 'tempfile'
       
        <<-TEMPLATE 
          #{template.source.strip}
        TEMPLATE
      end
    end
  end
end

ActionView::Base.send(:include, ActionView::Template::Handlers::XLSXHelper)

