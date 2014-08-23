class Stats
  def self.batting_average
    BattingStat.find_by_sql(
      %Q[
        SELECT *, MAX(batting_avg_2010 - batting_avg_2009) AS improved_delta
        FROM(
          SELECT batting_stats.player_id, CAST(batting_stats.hits AS REAL)/batting_stats.at_bats AS batting_avg_2010
          FROM batting_stats WHERE year = '2010' AND at_bats > 200
        ) AS a
        LEFT JOIN
          (SELECT batting_stats.player_id, CAST(batting_stats.hits AS REAL)/batting_stats.at_bats AS batting_avg_2009
            FROM batting_stats WHERE year = '2009' AND at_bats > 200
          ) AS b ON a.player_id = b.player_id
      ])
  end

  def self.slugging_percentage(team_id='OAK', year='2007')
    BattingStat.where(team_id: team_id, year: year)
  end

  def self.triple_crown_winner(year, league)
    BattingStat.find_by_sql(
      %Q[
        SELECT a.*, MAX(a.batting_avg) AS highest_batting_avg, b.max_home_runs AS max_home_runs, c.max_runs_batting_in AS max_rbi FROM
        (SELECT CAST(hits AS REAL)/at_bats AS batting_avg, player_id FROM batting_stats
          WHERE year = '#{year}' AND league = '#{league}' AND at_bats > 400)
         AS a
        INNER JOIN (
          SELECT player_id, MAX(CAST(home_runs AS REAL)) AS max_home_runs FROM batting_stats
          WHERE batting_stats.year = '#{year}' AND batting_stats.league = '#{league}' AND at_bats > 400
          ) AS b ON a.player_id = b.player_id
        INNER JOIN (
          SELECT player_id, MAX(CAST(runs_batted_in AS REAL)) AS max_runs_batting_in FROM batting_stats
          WHERE batting_stats.year = '#{year}' AND batting_stats.league = '#{league}' AND at_bats > 400
          ) AS c ON b.player_id = c.player_id
      ]
      )
  end
end
