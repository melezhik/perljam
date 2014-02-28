class SourcesController < ApplicationController
    def create

        @project = Project.find params[:project_id]
        @source = @project.sources.create( params[:source].permit( :url, :scm_type ) )
        @source.save!

        begin
            @project.sources.find(@project[:distribution_source_id])
        rescue ActiveRecord::RecordNotFound => ex
            @project.update({:distribution_source_id => @source[:id]})
        end

        @project.history.create!( { :commiter => request.remote_host, :action => "add #{@source._indexed_url}" }) 

        if @project.save
            flash[:notice] = "source ID:#{@source[:id]} has been successfully created"
        else
            flash[:alert] = "error has been occured when creating source: #{@project.errors.full_messages.join ' '}"
        end
        redirect_to edit_project_path @project

    end

    def destroy

        @project = Project.find(params[:project_id])
        @source = @project.sources.find(params[:id])
        indexed_url =  @source._indexed_url
        url = @source.url
        @source.destroy
        @project.history.create!( { :commiter => request.remote_host, :action => "remove #{indexed_url}" }) 
        flash[:notice] = "source ID:#{params[:id]}; Url: #{url} has been successfully deleted"
        redirect_to edit_project_path @project
    end

    def edit
        @project = Project.find(params[:project_id])
        @source = @project.sources.find(params[:id])
    end

    def update 

        @project = Project.find(params[:project_id])
        @source = @project.sources.find(params[:id])

        @project.history.create!( { :commiter => request.remote_host, :action => "update project" }) 
        
        if @source.update(source_params)
            flash[:notice] = "source ID: #{@source.id} has been successfully reordered"
            redirect_to [ :edit, @project, @source ]
        else
            flash[:alert] = "error has been occured when reorder source ID: #{@source.id}"
            render 'edit'
        end
    end


    def app

        @project = Project.find(params[:project_id])
        @source = @project.sources.find(params[:id])
        
        if @project.update({ :distribution_source_id => @source.id })
            flash[:notice] = "source ID: #{@source.id} has been successfully marked as an application source for project ID: #{@project.id}"
            @project.history.create!( { :commiter => request.remote_host, :action => "mark source ID: #{@source.id}; indexed_url: #{@source._indexed_url} as an application source for project ID: #{@project.id}" })
            redirect_to [:edit, @project]
        else
            flash[:alert] = "error has been occured when trying to mark source ID: #{@source.id} as an application source for project ID: #{@project.id}"
            redirect_to edit_project_path @project
        end
    end

    def on
        @project = Project.find(params[:project_id])
        @source = @project.sources.find(params[:id])
        if @source.update({:state => true })
            flash[:notice] = "source ID:#{params[:id]}; Url: #{@source.url} has been sucessfully enabled"
            redirect_to [:edit, @project]
        else
            flash[:alert] = "error has been occured when enabling source ID:#{params[:id]}; Url: #{@source.url}"
            render :edit            
        end
    end

    def off
        @project = Project.find(params[:project_id])
        @source = @project.sources.find(params[:id])

        #if @source.update({:state => false})
        #    flash[:notice] = "source ID:#{params[:id]}; Url: #{@source.url}  has been sucessfully disabled"
        #    redirect_to [:edit, @project]
        #else
        #    flash[:alert] = "error has been occured when disabling source ID:#{params[:id]}; Url: #{@source.url}"
        #    render :edit            
        #end

        redirect_to [:edit, @project]
        flash[:alert] = "`off source' feature is temporary disabled"
    end

private

  def source_params
      params.require( :source ).permit( :sn )
  end

end
