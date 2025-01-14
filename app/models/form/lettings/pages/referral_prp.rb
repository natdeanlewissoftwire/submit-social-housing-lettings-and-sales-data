class Form::Lettings::Pages::ReferralPrp < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_prp"
    @depends_on = [{ "managing_organisation_provider_type" => "PRP", "needstype" => 1, "renewal" => 0 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralPrp.new(nil, nil, self)]
  end
end
