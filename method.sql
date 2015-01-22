-- 1. Extraction of Drug-Event Combinations from 2009q4 to 2013q2 (Jan 2010 - Sep 2013)

/*
SELECT DISTINCT case_id FROM demo WHERE quarter == '2009・第四' OR quarter LIKE '201%' AND quarter != '2013・第四';
-- 147065
*/

CREATE TABLE ade10 (
  drug VARCHAR(120),
  pt_kanji VARCHAR(120),
  pt_code SMALLINT,
  hlt_code SMALLINT,
  case_id VARCHAR(10),
  drug_start_date VARCHAR(20),
  drug_end_date VARCHAR(20),
  event_onset_date VARCHAR(20)
);

INSERT INTO ade10 (drug, pt_kanji, pt_code, hlt_code, case_id, drug_start_date, drug_end_date, event_onset_date)
  SELECT DISTINCT
    name AS drug,
    pt_kanji,
    p.pt_code,
    hp.hlt_code,
    d.case_id,
    start_date AS drug_start_date,
    end_date AS drug_end_date,
    onset_date AS event_onset_date
  FROM
    drug d
  LEFT OUTER JOIN
    reac r ON d.case_id == r.case_id
  LEFT OUTER JOIN
    pt_j p ON p.pt_kanji == r.event
  INNER JOIN
    hlt_pt hp ON hp.pt_code == p.pt_code
  WHERE
    d.case_id IN (
      SELECT DISTINCT
        case_id
      FROM
        demo
      WHERE
        quarter == '2009・第四' OR quarter LIKE '201%'
    );


-- 2. Antidiabetes Drugs Classification

CREATE TABLE d_class (
  drug VARCHAR(120),
  class VARCHAR(120)
);

INSERT INTO d_class (drug, class)
  SELECT DISTINCT drug, 'insulin' FROM ade10 WHERE
    drug LIKE '%インスリン%';
/*
Insulin

-- イソフェンインスリン
-- インスリン
-- インスリン　アスパルト（遺伝子組換え）
-- インスリン　グラルギン（遺伝子組換え）
-- インスリン　グルリジン（遺伝子組換え）
-- インスリン　デグルデク（遺伝子組換え）
-- インスリン　デテミル（遺伝子組換え）
-- インスリン　リスプロ（遺伝子組換え）
-- ヒトインスリン
-- ヒトインスリン（遺伝子組換え）
-- ヒューマンモノコンポーネントインスリン
-- プロタミンインスリン亜鉛
-- 半合成ヒトインスリン
*/

INSERT INTO d_class (drug, class)
  SELECT DISTINCT drug, 'sulfonylurea' FROM ade10 WHERE
    drug LIKE '%トルブタミド%' OR
    drug LIKE '%グリクロピラミド%' OR
    drug LIKE '%アセトヘキサミド%' OR
    drug LIKE '%クロルプロパミド%' OR
    drug LIKE '%グリクラジド%' OR
    drug LIKE '%グリベンクラミド%' OR
    drug LIKE '%グリメピリド%';
/*
Sulfonylurea
    1st Generation
        tolbutamide                         トルブタミド
        glyclopyramide                      グリクロピラミド
        acetohexamide                       アセトヘキサミド
        chlorpropamide                      クロルプロパミド
    2nd Generation
        gliclazide                          グリクラジド
        glibenclamide                       グリベンクラミド
    3rd Generation
        glimepiride                         グリメピリド

-- アセトヘキサミド
-- クロルプロパミド
-- グリクラジド
-- グリクロピラミド
-- グリベンクラミド
-- グリメピリド
-- トルブタミド
-- ピオグリタゾン塩酸塩・グリメピリド配合剤
*/

INSERT INTO d_class (drug, class)
  SELECT DISTINCT drug, 'meglitinide' FROM ade10 WHERE
    drug LIKE '%ナテグリニド%' OR
    drug LIKE '%ミチグリニド%' OR
    drug LIKE '%レパグリニド%';
/*
Rapid Acting Insulin Secretagogue
    nateglinide                             ナテグリニド
    mitiglinide calcium hydrate             ミチグリニドカルシウム水和物
    repaglinide                             レパグリニド

-- ナテグリニド
-- ミチグリニドカルシウム水和物
-- ミチグリニドカルシウム水和物・ボグリボース配合剤
-- レパグリニド
*/

INSERT INTO d_class (drug, class)
  SELECT DISTINCT drug, 'biguanide' FROM ade10 WHERE
    drug LIKE '%メトホルミン%' OR
    drug LIKE '%ブホルミン%';
/*
Biguanide
    metformin hydrochloride                 メトホルミン塩酸塩
    buformine hydrochloride                 ブホルミン塩酸塩

-- ピオグリタゾン塩酸塩・メトホルミン塩酸塩配合剤
-- ブホルミン塩酸塩
-- メトホルミン
-- メトホルミン塩酸塩
*/

INSERT INTO d_class (drug, class)
  SELECT DISTINCT drug, 'alpha_glucosidase_inhibitor' FROM ade10 WHERE
    drug LIKE '%ボグリボース%' OR
    drug LIKE '%アカルボース%' OR
    drug LIKE '%ミグリトール%';
/*
Alpha-Glucosidase Inhibitor
    voglibose                               ボグリボース
    acarbose                                アカルボース
    miglitol                                ミグリトール

-- アカルボース
-- ボグリボース
-- ミグリトール
-- ミチグリニドカルシウム水和物・ボグリボース配合剤
*/

INSERT INTO d_class (drug, class)
  SELECT DISTINCT drug, 'thiazolidinedione' FROM ade10 WHERE
    drug LIKE '%ピオグリタゾン%';
/*
Thiazolidinedione
    pioglitazone hydrochloride              ピオグリタゾン塩酸塩

-- アログリプチン安息香酸塩・ピオグリタゾン塩酸塩配合剤
-- ピオグリタゾン塩酸塩
-- ピオグリタゾン塩酸塩・グリメピリド配合剤
-- ピオグリタゾン塩酸塩・メトホルミン塩酸塩配合剤
-- 塩酸ピオグリタゾン
*/

INSERT INTO d_class (drug, class)
  SELECT DISTINCT drug, 'dpp4_inhibitor' FROM ade10 WHERE
    drug LIKE '%シタグリプチン%' OR
    drug LIKE '%ビルダグリプチン%' OR
    drug LIKE '%アログリプチン%' OR
    drug LIKE '%リナグリプチン%' OR
    drug LIKE '%テネリグリプチン%' OR
    drug LIKE '%アナグリプチン%' OR
    drug LIKE '%サキサグリプチン%';
/*
DPP-4 Inhibitors
    sitaglitin phosphate hydrate        シタグリプチンリン酸塩水和物
    vildagliptin                        ビルダグリプチン
    alogliptin benzoate                 アログリプチン安息香酸塩
    linagliptin                         リナグリプチン
    teneligliptin hydrobromide hydrate  テネリグリプチン臭化水素酸塩水和物
    anagliptin                          アナグリプチン
    saxagliptin                         サキサグリプチン

-- アナグリプチン
-- アログリプチン安息香酸塩
-- アログリプチン安息香酸塩・ピオグリタゾン塩酸塩配合剤
-- サキサグリプチン水和物
-- シタグリプチンリン酸塩水和物
-- テネリグリプチン臭化水素酸塩水和物
-- ビルダグリプチン
-- リナグリプチン
*/

INSERT INTO d_class (drug, class)
  SELECT DISTINCT drug, 'glp1_agonist' FROM ade10 WHERE
    drug LIKE '%リラグルチド%' OR
    drug LIKE '%エキセナチド%' OR
    drug LIKE '%リキシセナチド%';
/*
GLP-1 Analogs
    liraglutide                         リラグルチド
    exenatide                           エキセナチド
    lixisenatide                        リキシセナチド

-- エキセナチド
-- リキシセナチド
-- リラグルチド（遺伝子組換え）
-- 持続性エキセナチド注射剤
*/

INSERT INTO d_class (drug, class)
  SELECT DISTINCT drug, 'sglt2_inhibitor' FROM ade10 WHERE
    drug LIKE '%イプラグリフロジン%' OR
    drug LIKE '%ダパグリフロジン%' OR
    drug LIKE '%ルセオグリフロジン%' OR
    drug LIKE '%トホグリフロジン%' OR
    drug LIKE '%カナグリフロジン%' OR
    drug LIKE '%エンパグリフロジン%';
/*
SGLT-2 Inhibitors
    ipragliflozin   イプラグリフロジン
    dapagliflozin   ダパグリフロジン
    tofogliflozin   トホグリフロジン
    luseogliflozin  ルセオグリフロジン

-- イプラグリフロジン　L-プロリン
-- イプラグリフロジン　Ｌ−プロリン
-- ダパグリフロジンプロピレングリコール水和物
-- トホグリフロジン水和物
-- ルセオグリフロジン水和物
*/


/*
http://chart.apis.google.com/chart?cht=v&chd=t:52,100,44,31,13,5,3&chs=300x200&chdl=Incretin%20Based%20Drug|Oral%20Hypoglycemic%20Drug|insulin&chtt=Venn%20Diagram&chco=D3BADB,BAEAF8,FAC5DF
*/


/*
SELECT COUNT(DISTINCT case_id) FROM ade10;
-- 170528
SELECT COUNT(DISTINCT case_id) FROM ade10 WHERE drug IN (
  SELECT DISTINCT drug FROM d_class
);
-- 15315
SELECT class, COUNT(DISTINCT case_id) AS c FROM ade10 INNER JOIN d_class ON ade10.drug == d_class.drug GROUP BY class;
-- alpha_glucosidase_inhibitor     3626
-- biguanide       2587
-- dpp4_inhibitor  5524
-- glp1_agonist    392
-- insulin 4418
-- meglitinide     1046
-- sglt2_inhibitor 202
-- sulfonylurea    5649
-- thiazolidinedione       2202
*/


-- 3. Data Table

CREATE TABLE base_dt (
  case_id CHAR(10) UNIQUE,
  dpp4_inhibitor SMALLINT DEFAULT 0,
  glp1_agonist SMALLINT DEFAULT 0,
  sglt2_inhibitor SMALLINT DEFAULT 0,
  alpha_glucosidase_inhibitor SMALLINT DEFAULT 0,
  biguanide SMALLINT DEFAULT 0,
  meglitinide SMALLINT DEFAULT 0,
  sulfonylurea SMALLINT DEFAULT 0,
  thiazolidinedione SMALLINT DEFAULT 0,
  insulin SMALLINT DEFAULT 0,
  age SMALLINT DEFAULT 0,
  sex SMALLINT DEFAULT 0
);

INSERT INTO base_dt (case_id, age, sex)
  SELECT
    case_id,
    CASE
      WHEN age == '10歳未満' THEN 0
      WHEN age LIKE '%歳代' THEN REPLACE(age, '歳代', '')
    END AS age,
    CASE
      WHEN sex == '女性' THEN 0
      WHEN sex == '男性' THEN 1
    END AS sex
  FROM
    demo
  WHERE
    case_id IN (
      SELECT DISTINCT case_id FROM (
        SELECT case_id, drug, MIN(drug_start_date) AS f FROM ade10 WHERE drug_start_date != '' group by case_id, drug
      ) WHERE drug IN (
        SELECT DISTINCT drug FROM d_class
      ) AND (
        f LIKE '201_' OR
        f LIKE '201___' OR
        f LIKE '201_____'
      ) AND case_id IN (
        SELECT case_id FROM demo WHERE age LIKE '%0歳%' AND sex IN ('男性', '女性')
      )
    );

UPDATE base_dt set dpp4_inhibitor == 1 WHERE case_id IN (
  SELECT DISTINCT case_id FROM ade10 WHERE drug IN (
    SELECT drug FROM d_class WHERE class == 'dpp4_inhibitor'
  )
);
UPDATE base_dt set glp1_agonist == 1 WHERE case_id IN (
  SELECT DISTINCT case_id FROM ade10 WHERE drug IN (
    SELECT drug FROM d_class WHERE class == 'glp1_agonist'
  )
);
UPDATE base_dt set sglt2_inhibitor == 1 WHERE case_id IN (
  SELECT DISTINCT case_id FROM ade10 WHERE drug IN (
    SELECT drug FROM d_class WHERE class == 'sglt2_inhibitor'
  )
);
UPDATE base_dt set alpha_glucosidase_inhibitor == 1 WHERE case_id IN (
  SELECT DISTINCT case_id FROM ade10 WHERE drug IN (
    SELECT drug FROM d_class WHERE class == 'alpha_glucosidase_inhibitor'
  )
);
UPDATE base_dt set biguanide == 1 WHERE case_id IN (
  SELECT DISTINCT case_id FROM ade10 WHERE drug IN (
    SELECT drug FROM d_class WHERE class == 'biguanide'
  )
);
UPDATE base_dt set meglitinide == 1 WHERE case_id IN (
  SELECT DISTINCT case_id FROM ade10 WHERE drug IN (
    SELECT drug FROM d_class WHERE class == 'meglitinide'
  )
);
UPDATE base_dt set sulfonylurea == 1 WHERE case_id IN (
  SELECT DISTINCT case_id FROM ade10 WHERE drug IN (
    SELECT drug FROM d_class WHERE class == 'sulfonylurea'
  )
);
UPDATE base_dt set thiazolidinedione == 1 WHERE case_id IN (
  SELECT DISTINCT case_id FROM ade10 WHERE drug IN (
    SELECT drug FROM d_class WHERE class == 'thiazolidinedione'
  )
);
UPDATE base_dt set insulin == 1 WHERE case_id IN (
  SELECT DISTINCT case_id FROM ade10 WHERE drug IN (
    SELECT drug FROM d_class WHERE class == 'insulin'
  )
);
