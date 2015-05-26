class AttachmentsController < ControllerWithAuthentication
  filter_resource_access :member => [:download]
  
  def download
  	puts "attachment encoding: #{@attachment.data.encoding}"
  	puts "attachment size: #{@attachment.data.size}"
    send_data(@attachment.data,
              :filename => @attachment.name,
              :type => @attachment.content_type,
              :disposition => "attachment")
  end
  
end
