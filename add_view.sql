CREATE VIEW ade AS
  SELECT DISTINCT
    dr.name AS drug,
    pj.pt_kanji AS pt_kanji,
    pj.pt_code AS pt_code,
    p.pt_soc_code AS soc_code,
    dr.case_id AS case_id,
    CASE
      WHEN quarter LIKE "%・第一" THEN REPLACE(quarter, "・第一", "")
      WHEN quarter LIKE "%・第二" THEN REPLACE(quarter, "・第二", "")
      WHEN quarter LIKE "%・第三" THEN REPLACE(quarter, "・第三", "")
      WHEN quarter LIKE "%・第四" THEN REPLACE(quarter, "・第四", "")
    END AS year,
    CASE
      WHEN age == "10歳未満" THEN 0
      WHEN age LIKE "%歳代" THEN REPLACE(age, "歳代", "")
    END AS age,
    CASE
      WHEN sex == "女性" THEN 0
      WHEN sex == "男性" THEN 1
    END AS sex
  FROM
    drug dr
  INNER JOIN
    reac re ON re.case_id == dr.case_id
  INNER JOIN
    demo de ON de.case_id == dr.case_id
  INNER JOIN
    pt_j pj ON pj.pt_kanji == re.event
  LEFT OUTER JOIN
    pt p ON p.pt_code == pj.pt_code
  WHERE
    age LIKE "%0歳%" AND
    sex IN ("男性", "女性") AND
    (quarter LIKE '2010%' OR
     quarter LIKE '2011%' OR
     quarter LIKE '2012%' OR
     quarter LIKE '2013%' OR
     quarter LIKE '2014%');
