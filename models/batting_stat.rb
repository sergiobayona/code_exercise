class BattingStat < ActiveRecord::Base
  belongs_to :player, primary_key: :player_id


  def slugging_percentage
    at_bats.to_i > 0 ? (100.0 * (hits + 2*doubles + 3*triples + 4*home_runs) / at_bats) : 0.0
  end
end
