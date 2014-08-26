require_relative '../lib/setup'

describe Setup do
  let(:options) do
    [
      {
        data_file: "spec/support/test.csv",
        schema: {
          table_name: 'players',
        columns: ['string', 'year'] }
      }
    ]
  end

  let(:setup) { Setup.new(options) }

  before { db_connect }

  it { expect(setup.options.class).to eq Array }

  context "setting up db tables" do
    it "raises an exeception unless create_db_tables is invoked" do
      expect {query("SELECT * FROM players")}.to raise_error
    end

    it "does not raise an error" do
      setup.create_db_tables
      expect {query("SELECT * FROM players")}.to_not raise_error
    end
  end

  context "before loading data" do
    before { setup.create_db_tables }

    it "returns an empty array" do
      expect(query("SELECT * FROM players")).to eq []
    end
  end

  context "after loading data" do
    before do
      setup.create_db_tables
      setup.load_data
    end

    it "returns a result set" do
      expect(query("SELECT * FROM players")).to eq [{"string" => "bla", "year" => "2010", 0 => "bla", 1 => "2010"}]
    end
  end

  private

  def query(sql)
    ActiveRecord::Base.connection.execute(sql)
  end

  def db_connect
    ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
  end

end
