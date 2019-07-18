RSpec.describe "`railsdock install` command", type: :cli do
  it "executes `railsdock help install` command successfully" do
    output = `railsdock help install`
    expected_output = <<-OUT
Usage:
  railsdock install

Options:
  -h, [--help], [--no-help]  # Display usage information

Command description...
    OUT

    expect(output).to eq(expected_output)
  end
end
