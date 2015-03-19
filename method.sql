-- 1. Extraction of Drug-Event Combinations from 2009q4 to 2013q2 (Jan 2010 - Sep 2013)

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
  INNER JOIN
    reac r ON d.case_id == r.case_id
  INNER JOIN
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
        age LIKE "%0歳%" AND
        sex IN ("男性", "女性") AND
        (quarter == '2009・第四' OR quarter LIKE '201%')
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
    canagliflozin   カナグリフロジン

-- イプラグリフロジン　Ｌ−プロリン
-- ダパグリフロジンプロピレングリコール水和物
-- トホグリフロジン水和物
-- ルセオグリフロジン水和物
-- カナグリフロジン水和物
*/
