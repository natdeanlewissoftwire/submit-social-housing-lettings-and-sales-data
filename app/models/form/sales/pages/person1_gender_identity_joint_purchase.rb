class Form::Sales::Pages::Person1GenderIdentityJointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_gender_identity_joint_purchase"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [{
      "jointpur" => 1,
      "details_known_3" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person1GenderIdentityJointPurchase.new(nil, nil, self),
    ]
  end
end