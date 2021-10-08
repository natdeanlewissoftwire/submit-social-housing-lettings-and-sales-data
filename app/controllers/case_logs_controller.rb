class CaseLogsController < ApplicationController
  def index
    @submitted_case_logs = CaseLog.where(status: 1)
    @in_progress_case_logs = CaseLog.where(status: 0)
  end

  def create
    @case_log = CaseLog.create!
    redirect_to @case_log
  end

  # We don't have a dedicated non-editable show view
  def show
    edit
  end

  def edit
    @form = Form.new(2021, 2022)
    @case_log = CaseLog.find(params[:id])
    render :edit
  end

  def submit_form
    form = Form.new(2021, 2022)
    @case_log = CaseLog.find(params[:id])
    previous_page = params[:case_log][:previous_page]
    questions_for_page = form.questions_for_page(previous_page).keys
    answers_for_page = page_params(questions_for_page).select { |k, _v| questions_for_page.include?(k) }
    @case_log.custom_validator_options = { previous_page: previous_page, validation: form.questions_for_page(previous_page)[previous_page]["regex_validation"] }
    if @case_log.update(answers_for_page)
      redirect_path = form.next_page_redirect_path(previous_page)
      redirect_to(send(redirect_path, @case_log))
    else
      page_info = form.all_pages[previous_page]
      render "form/page", locals: { form: form, page_key: previous_page, page_info: page_info }, status: :unprocessable_entity
    end
  end

  def check_answers
    @case_log = CaseLog.find(params[:case_log_id])
    current_url = request.env["PATH_INFO"]
    subsection = current_url.split("/")[-2]
    render "form/check_answers", locals: { case_log: @case_log, subsection: subsection }
  end

  form = Form.new(2021, 2022)
  form.all_pages.map do |page_key, page_info|
    define_method(page_key) do |errors = {}|
      @case_log = CaseLog.find(params[:case_log_id])
      render "form/page", locals: { form: form, page_key: page_key, page_info: page_info }
    end
  end

private

  def page_params(questions_for_page)
    params.require(:case_log).permit(questions_for_page)
  end
end
