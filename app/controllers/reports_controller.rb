class ReportsController < ApplicationController
  
  admin_only :create, :new
  
  before_filter :get_report_class

  after_filter :set_waypoint, :only => :new
  
  def create
    @report = @report_class.new params[:report]
    case @report.view
      when 'html'
        render :layout => 'html_reports'
      when 'xls'
        return send_data(render_to_string(:action => 'create_xls', :layout => false), :filename => @report.title.gsub(/\s/, '_') + '.xls', :type => 'application/vnd.ms-excel')
      when 'csv'
        return send_data(render_csv(@report), :filename => @report.title.gsub(/\s/, '_') + '.csv')
      else
        # Do something different
    end
  end
  
  def new
    @report = @report_class.new(params[:report])
  end
  
  private
  def get_report_class
    @report_class = "#{params[:name].camelize}Report".constantize
  end
 
  def render_csv(report)
    rows = [@report.headings] + @report.rows.map(&:values)
    rows.map {|row| render_csv_row(row)}.join "\n"
  end
  
  def render_csv_row(row)
    row.map {|field| "\"#{(field.to_s || '').gsub(/"/, "\"\"").gsub(/\r/, '')}\""}.join(",")
  end
 
end
