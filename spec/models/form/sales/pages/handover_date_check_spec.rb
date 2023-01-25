require "rails_helper"

RSpec.describe Form::Sales::Pages::HandoverDateCheck, type: :model do
  subject(:page) { described_class.new(page_id, page_definition, subsection) }

  let(:page_id) { "" }
  let(:page_definition) { nil }
  let(:subsection) { instance_double(Form::Subsection) }

  it "has correct subsection" do
    expect(page.subsection).to eq(subsection)
  end

  it "has correct questions" do
    expect(page.questions.map(&:id)).to eq(%w[hodate_check])
  end

  it "has the correct id" do
    expect(page.id).to eq("")
  end

  it "has the correct header" do
    expect(page.header).to be_nil
  end

  it "has correct depends_on" do
    expect(page.depends_on).to eq([
      {
        "hodate_3_years_or_more_saledate?" => true,
      },
    ])
  end
end