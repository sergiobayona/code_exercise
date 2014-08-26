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

  context "ensuring proper options argument" do
    it "raises an argument error if options is nil or an empty array" do
      expect { Setup.new(nil) }.to raise_error(ArgumentError, "array is empty!")
      expect { Setup.new([]) }.to raise_error(ArgumentError, "array is empty!")
    end

    it "raise an error if no data_file k/v pair is found" do
      expect { Setup.new([{}])}.to raise_error(ArgumentError, "missing data_file key/value")
    end

    it "raise an error if no proper schema is found" do
      expect { Setup.new([{data_file: "/"}]) }.to raise_error(ArgumentError, "missing schema key/value")
    end

    it "raises an error if the schema has not table name" do
      expect { Setup.new([{data_file: "/", schema: {}}])}.to raise_error(ArgumentError, "missing schema's table_name")
    end

    it "raises an error if the schema has no column_names" do
      expect { Setup.new([{data_file: "/", schema: {table_name: "."}}])}.to raise_error(ArgumentError, "missing schema's column_name's")
    end
  end

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
      expect(query("SELECT * FROM players")).to be_empty
    end
  end

  context "after loading data" do
    before do
      setup.create_db_tables
      setup.load_data
    end

    it "returns a result set" do
      expect(query("SELECT * FROM players")).to_not be_empty
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
