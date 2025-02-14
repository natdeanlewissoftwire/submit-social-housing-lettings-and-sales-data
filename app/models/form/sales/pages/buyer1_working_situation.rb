class Form::Sales::Pages::Buyer1WorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_working_situation"
    @depends_on = [
      {
        "privacynotice" => 1,
      },
      {
        "noint" => 1,
      },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1WorkingSituation.new(nil, nil, self),
    ]
  end
end
