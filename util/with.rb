require 'sqlite3'
$SAFE = -1
db = SQLite3::Database.new 'data/crawling.db'
sql = <<-SQL
WITH ratio_table AS (
    SELECT
        date,
        ROUND( (adj * 1.0 / close) /
          POWER(10, CAST(FLOOR(LOG10(adj * 1.0 / close)) as int)), 3 - 1) * 
        POWER(10, CAST(FLOOR(LOG10(adj * 1.0 / close)) as int)) AS ratio
    FROM '4689'
),
change_points AS (
    SELECT
        date, ratio, LAG(ratio) OVER (ORDER BY date) AS prev_ratio
    FROM ratio_table
)
SELECT date, ratio
FROM change_points
WHERE prev_ratio IS NOT NULL
  AND ratio <> prev_ratio
ORDER BY date limit 200;
SQL
# binding.irb
ar = db.execute sql
pp ar
__END__
Thu, 14 Aug 2025 10:08:20 +0900
[["1999-03-26", 2.44e-06],
 ["1999-09-27", 4.88e-06],
 ["2000-03-28", 9.77e-06],
 ["2000-09-26", 1.95e-05],
 ["2002-03-26", 3.91e-05],
 ["2002-09-25", 7.81e-05],
 ["2003-03-26", 0.00015600000000000002],
 ["2003-09-25", 0.000313],
 ["2004-03-26", 0.000625],
 ["2004-09-27", 0.00125],
 ["2005-03-28", 0.0025],
 ["2005-09-27", 0.005],
 ["2006-03-28", 0.01],
 ["2013-09-26", 1.0]]

