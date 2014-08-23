require 'table_print'
require_relative 'lib/setup'
require_relative 'lib/stats'
require_relative 'models/player'
require_relative 'models/batting_stat'

desc 'stats'
task :stats do
  options = [
    {
      data_file: "data/Master-small.csv",
      schema: {
        table_name: 'players',
        columns: ['player_id', 'birth_year', 'first_name', 'last_name'] }
    },
    {
      data_file: "data/Batting-07-12.csv",
      schema: {
        table_name: 'batting_stats',
        columns: ['player_id', 'year', 'league', 'team_id', 'g', {'at_bats' => :integer}, {'r' => :integer}, {'hits' => :integer}, {'doubles' => :integer}, {'triples' => :integer}, {'home_runs' => :integer}, {'runs_batted_in' => :integer}, {'sb' => :integer}, {'cs' => :integer}], primary_key: nil }
    }
  ]

  setup = Setup.new(options)
  setup.db_tables
  setup.load_data

  puts "BATTING AVERAGE"
  puts "\n"
  tp Stats.batting_average, :player_id, {player_name: lambda {|u| u.player.name}}, :improved_delta

  puts "\n\n\n"
  puts "SLUGGING PERCENTAGE FOR OAK 2007"
  puts "\n"
  tp Stats.slugging_percentage, :player_id, {player_name: lambda {|u| u.player.name }}, {slugging_percentage: lambda {|u| '%3.1f%%' % u.slugging_percentage }}

  puts "\n\n\n"
  puts "TRIPLE CROWN WINERS"
  puts "\n"
  ['2011', '2012'].each do |year|
    ['AL', 'NL'].each do |league|
      puts "\n\n #{league} LEAGUE #{year} \n"
      tp Stats.triple_crown_winner(year, league), :player_id, {player_name: lambda {|u| u.try(:player).try(:name) }}, :highest_batting_avg, :max_home_runs, :max_rbi
    end
  end




end
