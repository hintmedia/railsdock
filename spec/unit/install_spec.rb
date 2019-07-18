require 'railsdock/commands/install'

RSpec.describe Railsdock::Commands::Install do
  it "executes `install` command successfully" do
    output = StringIO.new
    options = {}
    command = Railsdock::Commands::Install.new(options)

    command.execute(output: output)

    expect(output.string).to eq("OK\n")
  end
end
