class Form::Lettings::Pages::Scheme < ::Form::Page
  def initialize(_id, hsh, subsection)
    super("scheme", hsh, subsection)
    @header = ""
    @description = ""
    @depends_on = [{
      "needstype" => 2,
    }]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::SchemeId.new(nil, nil, self),
    ]
  end
end