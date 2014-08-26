require_relative '../lib/setup'
require_relative '../models/batting_stat'
require_relative '../models/player'

describe BattingStat do
  before(:all) do
    options = [
      {
        data_file: "spec/support/players.csv",
        schema: {
          table_name: 'players',
        columns: ['player_id', 'birth_year', 'first_name', 'last_name'] }
      },
      {
        data_file: "spec/support/batting_stats.csv",
        schema: {
          table_name: 'batting_stats',
        columns: ['player_id', 'year', 'league', 'team_id', 'g', {'at_bats' => :integer}, {'r' => :integer}, {'hits' => :integer}, {'doubles' => :integer}, {'triples' => :integer}, {'home_runs' => :integer}, {'runs_batted_in' => :integer}, {'sb' => :integer}, {'cs' => :integer}], primary_key: nil }
      }
    ]
    setup = Setup.new(options)
    setup.create_db_tables
    setup.load_data
  end

  subject(:stat) { BattingStat.first }

  it { expect(stat.player_name).to be_present }

  it { expect(stat.player).to be_instance_of(Player) }

  it { expect(stat.slugging_percentage).to be_a(Float) }

  describe "best batting average" do
    let(:bba) { BattingStat.best_batting_average }

    it { expect(bba).to include(:delta) }
    it { expect(bba).to include(:player) }
    it { expect(bba[:delta]).to be_a Float }
    it { expect(bba[:player]).to be_a Player }
  end

  describe "triple crown winner" do
    let(:tcw) { BattingStat.triple_crown_winner }

    it { expect(tcw).to eq [] }
  end


end
