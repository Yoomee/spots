module MailHelper

  def render_mailing_progress(previous_status = nil)
    if uid = session[:mailing_worker_uid]
      status = Workling.return.get(uid) || previous_status
      session[:mailing_worker_uid] = nil if !status.nil? && status[:sent] == status[:total]
      render 'mailings/progress', :status => status, :uid => uid
#      render 'mailings/progress', :status => status
    end
  end
end