require 'csv'

namespace :backend do
  
  namespace :passwords do
   
    desc <<-DESC 
      Resets passwords (ALL=YES ro FILTER=filter CONFIRM=YES will really run it).
      
      You can use ALL=YES to reset ALL passwords or
      FILTER=':username => "ognen.bla"' to reset only certain passwords
      CONFIRM=YES makes the change for real
      DESC
    task :reset => :environment do
      all = (ENV['ALL'] == "YES")
      filter = ENV['FILTER']
      confirmation = (ENV['CONFIRM'] == "YES")
      
      if all
        puts "Will reset all passwords"
        users = Member.all
      elsif filter
        puts "Will use filter: #{filter}"
        users = eval "Member.where(#{filter})"
      else
        puts "Will do nothing! Use ALL=YES to trigger resseting all passwords"
        users = nil
      end
      
      if users
        if confirmation
          users.each do |user|
            puts "Resetting password for: #{user.name}"
            begin
              user.send_reset_password_instructions
            rescue Exception => e
              puts "WARN: could not reset passsword for #{user.name}: #{e}"
            end
          end
        else
          puts "[DRY RUN] Would reset these passwords (use CONFIRM=YES to actually perform this)"
          puts ""
          
          users.each do |user|
            puts user.name
          end
          
          puts ""
        end
      end
    end
    
    desc "Resets all usernames and passwords using a csv (as INPUT_FILE env var)."
    task :lowercase => :environment do
     I18n.locale = :en 
     file = ENV['INPUT_FILE']

     raise "input file must be provided: INPUT_FILE=file.csv" unless file

     entries = CSV.read(file, :encoding => "utf-8")
     
     Member.transaction do
       entries.reject { |u, pw| u.blank? }.each do |username, pw|
         username.strip!
         pw.strip!
       
         member = Member.where("LOWER(email) = ?", username).first

         if member
           puts "setting member user, email, password to #{username}, #{pw}"
           member.username = username
           member.email = username
           member.password = pw

           unless member.save
             puts "There were problems saving #{username}: #{member.errors.inspect}"
           end
         else
           puts "Member not found for username = #{username}"
         end
       end
     end
    end

    desc "renames membership types, use INPUT_FILE for the csv"
    task :rename_membership_nominations => :environment do
      file = ENV['INPUT_FILE']

      raise "input file must be provided: INPUT_FILE=file.csv" unless file
      
      entries = CSV.read(file, :encoding => "utf-8")
      
      Membership.transaction do
        entries.each do |orig, de, fr|
          orig.strip!; de.strip!; fr.strip!
          
          
          replacement = "#{de} / #{fr}"

          puts "Replacing #{de} with #{replacement}"
          DesignationType.where(:grouping => "membership_nomination", :name.matches => "#{de}%").update_all(:name => replacement)
          Membership.where(:nomination.matches => "#{de}%").update_all(:nomination => replacement)
        end  
      end
    end
    
    desc "renames designation types, use INPUT_FILE for the csv"
    task :rename_designation_types => :environment do
      file = ENV['INPUT_FILE']

      raise "input file must be provided: INPUT_FILE=file.csv" unless file
      
      entries = CSV.read(file, :encoding => "utf-8")
      
      Designation.transaction do
        entries.each do |en, de, fr|
          en.strip!; de.strip!; fr.strip!
          
          replacement = "#{de} / #{fr}"

          puts "Replacing #{en} with #{replacement}"
          DesignationType.where(:grouping => "designation", :name.matches => "#{en}%").update_all(:name => replacement)
          Designation.where(:kind.matches => "#{en}%").update_all(:kind => replacement)
        end 
      end
    end
    
    desc "rename titles"
    task :rename_titles => :environment do
      Member.transaction do
        Member.where(:title.matches => "Dr.%").update_all(:title => "Dr. med.")
        Member.where(:title.matches => "Prof.%").update_all(:title => "Prof. Dr. med.")
      end
    end
    
    desc "Add default role"
    task :add_default_role => :environment do
      I18n.locale = :en
      discussion_deny = Group.find_by_code("SGDV_DISCUSSION_denyAccess")
      
      Member.all.each do |member|
        puts "Applying discussion deny group to member #{member.name}"
        
        member.groups << discussion_deny
        member.groups << Group.sgdv_members
        
        unless member.save
          puts "Could not update member #{member.name}, errors = #{member.errors}"
        end
      end
      
    end
    
    desc "Makes all ladies, ladies"
    task :fix_sex_field => :environment do
      I18n.locale = :en
      
      file = ENV['INPUT_FILE']
      raise "input file must be provided: INPUT_FILE=file.csv" unless file
      
      entries = CSV.read(file, :encoding => "utf-8")
      
      entries.each do |sex, user|
        next if sex.nil? or user.nil?
        
        sex.strip!; user.strip!

        next if sex.blank? or user.blank?

        sex = case sex
          when "0" then :F
          when "1" then :M
        end 
        
        if sex == :F
          puts "updating #{user} as F"
          
          member = Member.find_by_email(user)
          
          unless member
            puts "Could not find username for #{user}"
            next
          end
          
          member.sex = sex
          
          unless member.save
            puts "Could not update #{username}, errors = #{member.errors}"
          end
        end
      end
    end
  end
end
      
