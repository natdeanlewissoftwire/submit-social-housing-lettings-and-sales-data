class Form::Page
  attr_accessor :id, :header, :header_partial, :description, :questions, :depends_on, :title_text,
                :informative_text, :subsection, :hide_subsection_label, :next_unresolved_page_id

  def initialize(id, hsh, subsection)
    @id = id
    @subsection = subsection
    if hsh
      @header = hsh["header"]
      @header_partial = hsh["header_partial"]
      @description = hsh["description"]
      @questions = hsh["questions"].map { |q_id, q| Form::Question.new(q_id, q, self) }
      @depends_on = hsh["depends_on"]
      @title_text = hsh["title_text"]
      @informative_text = hsh["informative_text"]
      @hide_subsection_label = hsh["hide_subsection_label"]
      @next_unresolved_page_id = hsh["next_unresolved_page_id"]
    end
  end

  delegate :form, to: :subsection

  def routed_to?(log, _current_user)
    return true unless depends_on || subsection.depends_on

    subsection.enabled?(log) && form.depends_on_met(depends_on, log)
  end

  def non_conditional_questions
    @non_conditional_questions ||= questions.reject do |q|
      conditional_question_ids.include?(q.id)
    end
  end

  def interruption_screen?
    questions.all? { |question| question.type == "interruption_screen" }
  end

private

  def conditional_question_ids
    @conditional_question_ids ||= questions.flat_map { |q|
      next if q.conditional_for.blank?

      # TODO: remove this condition once all conditional questions no longer need JS
      q.conditional_for.keys if q.type == "radio"
    }.compact
  end
end
