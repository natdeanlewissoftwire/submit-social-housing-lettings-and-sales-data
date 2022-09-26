class Form::Sales::Subsections::Setup < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "setup"
    @label = "Set up this sales log"
    @section = section
  end

  def pages
    @pages ||= [
      Form::Common::Pages::Organisation.new(nil, nil, self),
      Form::Common::Pages::CreatedBy.new(nil, nil, self),
      Form::Sales::Pages::SaleDate.new(nil, nil, self),
      Form::Sales::Pages::PurchaserCode.new(nil, nil, self),
      Form::Sales::Pages::OwnershipScheme.new(nil, nil, self),
      Form::Sales::Pages::SharedOwnershipType.new(nil, nil, self),
      Form::Sales::Pages::DiscountedOwnershipType.new(nil, nil, self),
      Form::Sales::Pages::OutrightOwnershipType.new(nil, nil, self),
      Form::Sales::Pages::JointPurchase.new(nil, nil, self),
      Form::Sales::Pages::NumberJointBuyers.new(nil, nil, self),
      Form::Sales::Pages::Age1.new(nil, nil, self),
    ]
  end
end