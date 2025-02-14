class Form::Lettings::Pages::TenancyType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "tenancy_type"
    @depends_on = [{ "startertenancy" => 2 }]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::Tenancy.new(nil, nil, self),
      Form::Lettings::Questions::Tenancyother.new(nil, nil, self),
    ]
  end
end
