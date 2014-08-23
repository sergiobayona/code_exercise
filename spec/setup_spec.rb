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

  before { ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:' }

  it { expect(setup.options.class).to eq Array }

  context "setting up db tables" do
    it "raises an exeception unless db_tables is invoked" do
      expect {ActiveRecord::Base.connection.execute("SELECT * FROM players")}.to raise_error
    end

    it "does not raise an error" do
      setup.db_tables
      expect {ActiveRecord::Base.connection.execute("SELECT * FROM players")}.to_not raise_error
    end
  end

  context "loading data" do
    before { setup.db_tables }

    it "returns an empty array unless load_data is invoked" do
      expect(ActiveRecord::Base.connection.execute("SELECT * FROM players")).to eq []
    end

    it "loads the data into the table" do
      setup.load_data
      expect(ActiveRecord::Base.connection.execute("SELECT * FROM players")).to eq [{"string" => "bla", "year" => "2010", 0 => "bla", 1 => "2010"}]
    end
  end

end
