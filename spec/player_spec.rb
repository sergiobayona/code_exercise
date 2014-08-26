require_relative '../lib/setup'
require_relative '../models/batting_stat'
require_relative '../models/player'

describe Player do
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

  subject(:player) { Player.find('cabremi01') }

  it { expect(player.name).to be_present }

  it { expect(player.batting_stats.to_a).to be_present }

  it { expect(Player.primary_key).to eq "player_id" }
end
