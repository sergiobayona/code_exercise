class BattingStat < ActiveRecord::Base
  belongs_to :player, primary_key: :player_id

  delegate :name, to: :player, prefix: true, allow_nil: true

  scope :batting_criteria, ->(years, batting_above) {
    select("*, SUM(at_bats) AS at_bats_aggregate, SUM(hits) AS hits_aggregate, SUM(home_runs) AS home_runs_aggregate, SUM(runs_batted_in) AS rbi_aggregate")
    .where(year: years)
    .where(self.arel_table[:at_bats].gt(batting_above))
    .group(:year, :player_id)
  }


  def slugging_percentage
    at_bats.to_i > 0 ? (100.0 * (hits + 2*doubles + 3*triples + 4*home_runs) / at_bats) : 0.0
  end

  def self.best_batting_average(years=[], batting_above='200')
    raise ArgumentError unless years.is_a?(Array) && batting_above.to_i > 0
    results = batting_criteria(years, batting_above)
    grouped_results = results.to_a.group_by{|a| a.player_id }
    delta_results = calculate_delta(grouped_results)
    delta_results.max_by {|a| a[:delta]}
  end

  def self.triple_crown_winner(years=[], league='AL', batting_above='400')
    raise ArgumentError unless years.is_a?(Array) && batting_above.to_i > 0
    results = batting_criteria(years, batting_above).where(league: league)
    r = results.to_a.reject! {|i| i.at_bats.nil? || i.hits.nil? || i.home_runs.nil? || i.runs_batted_in.nil? }
    top_result(r)
  end

  private

  def self.calculate_delta(grouped_results)
    delta_results = []
    grouped_results.each do |key, values|
      next unless values.many?
      delta = values.inject(0) {|memo, a| (a.hits_aggregate.to_f/a.at_bats_aggregate.to_f) - memo }
      delta_results << {player: values.first.player, delta: delta }
    end
    delta_results
  end

  def self.top_result(r)
    return [] if r.nil?
    r = r.sort_by{|e| [(e.hits_aggregate.to_f/e.at_bats_aggregate.to_f), e.hits_aggregate, e.home_runs_aggregate, e.rbi_aggregate]}.reverse
    r.first
  end
end
