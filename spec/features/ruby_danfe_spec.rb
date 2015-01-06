require "spec_helper"

describe "RubyDanfe generated pdf files" do
  let(:base_dir) { "./spec/fixtures/"}
  let(:output_pdf) { "#{base_dir}output.pdf" }

  before(:each) do
    File.delete(output_pdf) if File.exist?(output_pdf)
  end

  after(:all) do
    pdf = "./spec/fixtures/output.pdf"
    File.delete(pdf) if File.exist?(pdf)
  end

  it "renders a NF-e with invalid float" do
    expect(File.exist?(output_pdf)).to be false

    RubyDanfe.generate(output_pdf, "#{base_dir}nfe_with_invalid_float.xml")

    expect("#{base_dir}nfe_with_invalid_float.xml.fixture.pdf").to be_same_file_as(output_pdf)
  end

  it "renders a basic NF-e with namespace" do
    expect(File.exist?(output_pdf)).to be false

    RubyDanfe.generate(output_pdf, "#{base_dir}nfe_with_ns.xml")

    expect("#{base_dir}nfe_with_ns.xml.fixture.pdf").to be_same_file_as(output_pdf)
  end

  it "renders another basic NF-e without namespace" do
    expect(File.exist?(output_pdf)).to be false

    RubyDanfe.generate(output_pdf, "#{base_dir}nfe_without_ns.xml")

    expect("#{base_dir}nfe_without_ns.xml.fixture.pdf").to be_same_file_as(output_pdf)
  end

  it "renders a NF-e having FCI in its items" do
    expect(File.exist?(output_pdf)).to be false

    RubyDanfe.generate(output_pdf, "#{base_dir}nfe_with_fci.xml")

    expect("#{base_dir}nfe_with_fci.xml.fixture.pdf").to be_same_file_as(output_pdf)
  end

  it "renders a NF-e of Simples Nacional using CSOSN" do
    expect(File.exist?(output_pdf)).to be false

    RubyDanfe.generate(output_pdf, "#{base_dir}nfe_simples_nacional.xml")

    expect("#{base_dir}nfe_simples_nacional.xml.fixture.pdf").to be_same_file_as(output_pdf)
  end

  it "renders a basic CT-e" do
    expect(File.exist?(output_pdf)).to be false

    RubyDanfe.generate(output_pdf, "#{base_dir}cte.xml", :dacte)

    expect("#{base_dir}cte.xml.fixture.pdf").to be_same_file_as(output_pdf)
  end
end
