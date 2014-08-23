class Player < ActiveRecord::Base
  self.primary_key = 'player_id'
  has_many :batting_stats, foreign_key: :player_id

  def name
    "#{first_name} #{last_name}"
  end
end
