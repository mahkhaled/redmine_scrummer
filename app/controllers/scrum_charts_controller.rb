class ScrumChartsController < IssuesController
  unloadable
  
  include ScrumUserstoriesController::SharedScrumConstrollers

  prepend_before_filter :find_scrum_project, :only => [:index, :update_chart]
  before_filter :get_sprint, :only => [:index]
  before_filter :get_release, :only => [:index]
  
  # By Mohamed Magdy
  # Filter before entering the index action to highlight the scrummer
  # menu tab
  before_filter :current_page_setter, :only => [:index]
  
  def index    
    @sprints  = @project.versions
    @releases = @project.releases
    
    @release = @releases.find(params[:release_id]) if params[:release_id]
    @sprint = @sprints.find(params[:sprint_id]) if params[:sprint_id]
    
    @axes = {:accepted_pts => [], :total_pts => [], :actual_hrs => [], :actual_and_remaining_hrs => [], :remaining_hrs => []}
    
    gather_sprint_data
    gather_release_data
  end
  
  def update_chart
    @axes = {}
    if params[:chart] == 'sprint'
      get_sprint
      gather_sprint_data
      
      render :update do |page|
        page.replace_html 'sprint_container', ''
        page << "var sprint_chart = set_data('sprint_container', #{@axes[:actual_hrs].inspect}, #{@axes[:actual_and_remaining_hrs].inspect}, 'Sprint Burn Chart', 'Time (hrs)', 'Actual', 'Actual + Remaining', 'hrs');"
        page << "add_series('Remaining', #{@axes[:remaining_hrs].inspect}, sprint_chart)"
      end
    else
      get_release
      gather_release_data
      
      render :update do |page|
        page.replace_html 'release_container', ''
        page << "set_data('release_container', #{@axes[:accepted_pts].inspect}, #{@axes[:total_pts].inspect}, 'Release Burnup Chart', 'Points (pts)', 'Accepted Points', 'Total Points', 'pts');"
      end
    end
  end

  protected 

  def get_sprint
    @sprint = if params[:id]
      Version.find(params[:id])
    else
      @project.versions.find(:first, :order => 'effective_date DESC')
    end
  end
  
  def get_release
    @release = if params[:id]
      Release.find params[:id]
    else
      @project.releases.first
    end
  end
  
  def gather_sprint_data
    @sprint ||= @sprints.last
    @start_date = @sprint.start_date_custom_value
    @end_date   = @sprint.effective_date
    @issues     = @project.issues.trackable.find :all, :conditions => ['fixed_version_id = ?', @sprint.id]
    
    curves = [:actual_hrs, :actual_and_remaining_hrs, :remaining_hrs]
    curves.each do |curve|
      @axes[curve] = []
    end
    
    gather_information(@axes, curves) do |issue, date|
      # history will selects the issues in date descending order
      # steps: sort descendingly and get the first history.
      # if an issue has no history in this day, then the history will be the nearest history of this issue
      # before the given date 
      sprint_hrs = issue.history.find(:first, :conditions => ['date >= ? and date <= ?', @start_date, date])
      [sprint_hrs.try(:actual).to_f, sprint_hrs.try(:actual).to_f + sprint_hrs.try(:remaining).to_f, sprint_hrs.try(:remaining).to_f]
    end
  end

  def gather_release_data
    return if @release.nil?
    @start_date = @release.start_date
    @end_date   = @release.release_date
    @issues     = @release.issues.find :all, :conditions => ['tracker_id = ?', Tracker.scrum_user_story_tracker.id]
    
    curves = [:accepted_pts, :total_pts]
    
    curves.each do |curve|
        @axes[curve] = []
    end
      
    gather_information(@axes, curves) do |issue, date|
      # point histories will selects the issues in date descending order
      # steps: sort descendingly and get the first point history.
      # if an issue has no point history in this day, then the history will be the nearest point history of this issue
      # before the given date 
      accepted_id =  IssueStatus.find_by_scrummer_caption(:accepted).id
      release_points = issue.points_histories.find(:first, :conditions => ['date <= ?', date])
      [release_points.try(:issue).try(:status_id).to_i == accepted_id ? release_points.points : 0.0, release_points.try(:points).to_f]
    end
  end
  
  def gather_information(axes, curves, &block)
    start_date = @start_date
    end_date   = @end_date
    issues     = @issues
    # if the sprint or the release has no specified start or end date
    return unless start_date && end_date
    
    # loops over the days of the sprint or the release
    (start_date..end_date).each do |date|
      points = Array.new(curves.count, 0)
      
      # looping over all the issues every day to calculate it points (release) or the hours (sprint)
      issues.each do |issue|
        issue_points = block.call(issue, date)
        
        issue_points.each_with_index do |issue_point, i|
          points[i] += issue_point
        end
      end
      
      curves.each_with_index do |curve, i|
        axes[curve] << [(date.to_time + Time.now.utc_offset).to_i * 1000 , points[i]]
      end
    end
  end
  
  # By Mohamed Magdy
  # This methods sets the curret_page attribute to be used in the view 
  # and mark the current page in the scrummer menu
  def current_page_setter
    @current_page = :charts
  end
  
end
