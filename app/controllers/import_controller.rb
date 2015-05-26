class ImportController < ControllerWithAuthentication
  def new
    @import = Import.new
  end

  def show
    @import = Import.load(session)

    if @import
      @import.apply_changes 
    else
      redirect_to new_import_path
    end
  end

  def create
    @import = Import.new(params[:import])

    respond_to do |format|
      if @import.save(session)
        format.html { redirect_to import_index_path }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @import = Import.load(session)
  end

  def commit
    @import = Import.load(session)

    if @import 
      @import.apply_changes
      @import.update_actions(params[:import][:actions])

      @import.import_in_db!

      respond_to do |format|
        format.html 
      end
    else
      redirect_to new_import_path
    end
  end
end
