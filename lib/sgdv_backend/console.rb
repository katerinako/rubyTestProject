module SgdvBackend

  module Console

    def sample_import
      import = Import.new
      import.data_file_path = Rails.root.join("db/bulk-import-sample.xlsx")
      import
    end

    def sample_update_action(resolve = true)
      if resolve
        sample_import.actions[1]
      else
        sample_import.unresolved_actions[1]
      end
    end

    def expose_default_proc(obj)
      case obj
      when Array
        obj.each {|o| expose_default_proc(o)}
      when Hash
        puts "HAS DEFAULT PROC: #{obj}" if obj.default_proc 
        obj.each {|k, v| expose_default_proc(v)}
      end
    end
  end
  
end