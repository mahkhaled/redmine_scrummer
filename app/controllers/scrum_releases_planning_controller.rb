class ScrumReleasesPlanningController < IssuesController
  unloadable
  # layout 'base'
  
  include ScrumUserstoriesController::SharedScrumConstrollers
  
  before_filter :find_scrum_project, :only => [:index, :destroy_release]
  prepend_before_filter :find_project, :only => [:create, :destroy_release, :edit_release, :show_release, :update_release, :set_issue_release]
  # By Mohamed Magdy
  # Filter before entering the index action to highlight the scrummer
  # menu tab
  before_filter :current_page_setter
  before_filter :build_new_issue_from_params, :only => :index
  
  # GET /releases
  # GET /releases.xml
  def index
    @query = IssueQuery.find_by_scrummer_caption("Release-Planning")
    # initialize_sort
    
    @release  = Release.new
    @releases = @project.releases
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @releases }
    end
  end

  # GET /releases/1
  # GET /releases/1.xml
  def show_release
    @release = Release.find(params[:id])

    respond_to do |format|
      format.html # show_release.html.erb
      format.xml  { render :xml => @release }
    end
  end

  # GET /releases/1/edit
  def edit_release
    @release = Release.find(params[:id])
  end

  # POST /releases
  # POST /releases.xml
  def create
    @query = IssueQuery.find_by_scrummer_caption("Release-Planning")
    # initialize_sort
    @release = Release.new(params[:release])
    @release.project_id = @project.id
  end

  # PUT /releases/1
  # PUT /releases/1.xml
  def update_release
    @release = Release.find(params[:id])

    respond_to do |format|
      if @release.update_attributes(params[:release])
        format.html { redirect_to(:action => 'index', :project_id => @project, :notice => 'Release was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit_release" }
        format.xml  { render :xml => @release.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def set_issue_release
    @issue = Issue.find params[:issue_id]
    @issue.init_journal(User.current)
    release_id = params[:release_id] != 'backlog' ? params[:release_id] : nil
    @issue.release_id = release_id
    @issue.save
    
    render :update do |page|
      page.visual_effect :highlight, "header-#{release_id}", :duration => 3
    end
    
  end

  # DELETE /releases/1
  # DELETE /releases/1.xml
  def destroy_release
    @release = @project.releases.find(params[:id])
    @release.destroy

    respond_to do |format|
      format.html { redirect_to scrum_release_planing_path(:project_id => @project.identifier) }
      format.js
    end
  end
  
  protected
  # By Mohamed Magdy
  # This methods sets the curret_page attribute to be used in the view 
  # and mark the current page in the scrummer menu
  def current_page_setter
    @current_page = :release_planning
  end
end
