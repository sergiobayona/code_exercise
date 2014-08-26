class BattingStat < ActiveRecord::Base
  belongs_to :player, primary_key: :player_id

  scope :batting_criteria, ->(years, batting_above) {
    select("*, SUM(at_bats) AS at_bats_aggregate, SUM(hits) AS hits_aggregate")
    .where(year: years)
    .where(self.arel_table[:at_bats].gt(batting_above))
    .group(:year, :player_id)
  }


  def slugging_percentage
    at_bats.to_i > 0 ? (100.0 * (hits + 2*doubles + 3*triples + 4*home_runs) / at_bats) : 0.0
  end
end
