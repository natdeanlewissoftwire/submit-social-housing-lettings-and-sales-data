class Form::Sales::Pages::Person3Age < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_3_age"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "hholdcount" => 3 },
      { "hholdcount" => 4 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person3AgeKnown.new(nil, nil, self),
      Form::Sales::Questions::Person3Age.new(nil, nil, self),
    ]
  end
end