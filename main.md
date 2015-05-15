<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    tex2jax: {
      inlineMath: [['$','$'], ['\\(','\\)']],
      displayMath: [['$$','$$'], ['\[','\]']],
      processEscapes: true,
      skipTags: ['script', 'noscript', 'style', 'textarea', 'pre', 'h5'],
    }
  });
</script>
<script type="text/javascript" src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>


Adverse Events Associated with Incretin-based Drugs: A Logistic Regression Analysis of Japanese Adverse Drug Event Reports
=======

Authors:  
Daichi Narushima, ST, HY

Author Affiliations:  
Department of Drug Evaluation & Informatics, Graduate school of Pharmaceutical Sciences, University of Shizuoka, Shizuoka, Japan (DN and HY);
Office of Safety II, Pharmaceuticals and Medical Devices Agency, Japan (ST)

Corresponding Author:  
Hiroshi Yamada, MD, PhD, FACP, Department of Drug Evaluation & Informatics, Graduate School of Pharmaceutical Sciences, University of Shizuoka, 52-1 Yada, Suruga-ku, Shizuoka 422-8526, Japan (hyamada@u-shizuoka-ken.ac.jp).


Abstract
--------

##### Background
Glucagon-like peptide 1 (GLP-1) agonists and dipeptidyl peptidase 4 (DPP-4) inhibitors are incretin-based hypoglycemic drugs which are widely used to treat type 2 diabetes.
The safety of these drugs is one of the most concerns in diabetes medication.
To assess adverse drug events (ADEs) associated with incretin-based drugs, we analyzed Japanese spontaneous reports.

    - the rationale of study
    - the specific study hypothesis and/or study objectives

##### Methods and Findings
This study is designed as a disproportionality analysis based on logistic regression model of spontaneous ADE reports.
The report data was fetched from Japanese Adverse Drug Event Report database (JADER), which is published by Pharmaceuticals and Medical Devices Agency (PMDA).
165,779 unique cases were analyzed, which were reported from 2010 to 2014 and had available records about age and sex.
In the first screening, all the cases were analyzed using fixed effects model and ADEs associated with incretin-based drug were extracted.
This model includes use of incretin-based drug, concomitant suspected drug, history of the event, age and sex as predictor variables, and occurrence of each ADEs as an outcome variable.
In the second screening, the cases treated with hypoglycemic drug were analyzed using the same model as that in the previous screening.
In the final analysis, the cases treated with hypoglycemic drug were analyzed using the mixed effects model which has reporting quarter as a random effect besides the fixed effects.
The result showed that GLP-1 agonists associated with risks of pancreatic neoplasms (odds ratio 25.0, 99% credible interval 8.2 to 79.3) and pancreatitis (12.5, 5.9 to 26.9) and that DPP-4 inhibitors are associated with risks of pancreatic neoplasms (4.9, 1.76 to 15.4), pancreatitis (13.3, 7.2 to 27.9) and abnormal urinalysis (7.8, 1.5 to 69.1).

    - What was studied
    - main methods used
    - how many participants were enrolled
    - statistical tests
    - a measure of its precision (99%CI)
    - main limitation

##### Conclusions
Incretin-based drugs associate with various AEs on Japanese spontaneous reports.

These results are consistent with

    - general interpretation for any implications
    - important recommendation for future

    タイトル・抄録 [title and abstract]
    1. タイトルまたは抄録のなかで，試験デザインを一般に用いられる用語 で明示する。
    2. 抄録では，研究で行われたことと明らかにされたことについて，十分 な情報を含み，かつバランスのよい要約を記載する。 


Introduction
------------

Incretin is a group of hormones stimulating insulin secretion and several hypoglycemic drugs based on this mechanism have been developed during the last decade.
There are two types of incretin-based drugs, Glucagon-like peptide 1 (GLP-1) agonists and dipeptidyl peptidase 4 (DPP-4) inhibitors.

GLP-1 agonists demonstrate an efficacy comparable to insulin treatment and appear to do so with significant effects to promote weight loss with minimal hypoglycemia.

In addition, there are significant data with dipeptidyl peptidase 4 (DPP-4) inhibitors showing efficacy comparable to sulfonylureas but with weight neutral effects and reduced risk for hypoglycemia.

    <-  advantages of incretin-based drugs

These drugs have many advantages, however
Adverse Drug Event (ADE)

    <-  feared ADE

Spontaneous reporting systems (SRSs) play an essential roles in drug safety surveillance. These cumulate a large quantity of case reports.

Japanese Adverse Drug Event Report database (JADER)

The report data is fetched from Japanese Adverse Drug Event Report database (JADER), which is published by Pharmaceuticals and Medical Devices Agency (PMDA).

    はじめに[introduction]
    背景[background]/ 論拠[rationale] 2 研究の科学的な背景と論拠を説明する。
    目的[objective] 3 特定の仮説を含む目的を明記する。


Methods
-------

##### Data Source

Japanese ADE report data, JADER was acquired from the website of Pharmaceuticals and Medical Devices Agency (PMDA).
We used data published in April 2015 which contain 338,224 cases.
In these cases, 165,779 unique cases were analyzed, which were reported from 2010 to 2014 and had available records about age and sex.
For classification of ADEs in JADER, the Japanese version of MedDRA, MedDRA/J was used.

We constructed a relational database based on JADER and MedDRA/J for analysis using SQLite3.

##### Data Analysis

This study is designed as a disproportionality analysis based on logistic regression model of spontaneous ADE reports.




In the first screening, all the cases were analyzed using fixed effects model and ADEs associated with incretin-based drug were extracted.
This model includes use of incretin-based drug, concomitant suspected drug, history of the event, age and sex as predictor variables, and occurrence of each ADEs as an outcome variable.


\[
  \ln(\frac{ p }{ 1 - p })  = \alpha + \beta_1 x_1 + \beta_2 x_2
\]

In the second screening, the cases treated with hypoglycemic drug were analyzed using the same model as that in the previous screening.

In the final analysis, the cases treated with hypoglycemic drug were analyzed using the mixed effects model which has reporting quarter as a random effect besides the fixed effects.

    <-  formula



We analyzed the data and created all figures in the R Environment for Statistical Computing (nn).

For the mixed effects model, We used Stan (nn), a Hamiltonian Monte Carlo sampler.
Results are based on 5,000 samples each from eight chains, after 5,000 adaptation steps in each.
Convergence was assessed by both trace plots and the R-hat Gelman and Rubin statistic.

We analyzed the data using both uninformative priors, as well as weakly informative variance priors, without any substantive change in inferences.


    Analysis. We used multilevel logistic regressions to analyze our binary outcome variable: whether or not participants selected the 1/1 payoff distribution in the CSG and PG or the 2/2 payoff in FAM1. We center participants’ age (PA) to create an age parameter CA, and we create a second age parameter by squaring CA:
    CA =.PA−dmean of PAT_=dSD of PAT
    CA2 =f.PA −dmean of PAT_=dSD of PATg2:

    We analyzed the data in the R Environment for Statistical Computing (46). We fit the models using Stan (47), a Hamiltonian Monte Carlo sampler. Results are based on 5,000 samples each from four chains, after 5,000 adaptation steps in each. Convergence was assessed by both trace plots and the R-hat Gelman and Rubin statistic. Model code was generated and DIC calculated using glmer2stan (48), a convenience package for Rstan. We analyzed the data using both uninformative (flat) priors, as well as weakly informative variance priors, without any substantive change in inferences.

    何のためのベイズか
    モデルとそのパラメータ
    事前分布の適切性

    方法[methods]
    研究デザイン[study design] 4 研究デザインの重要な要素を論文のはじめの[early]部分で示す。
    セッティング[setting] 5 セッティング，実施場所のほか，基準となる日付については，登録，曝露 [exposure]，追跡，データ収集の期間を含めて明記する。
    参加者[participant] 6
    (a)・コホート研究[cohort study]：適格基準[eligibility criteria]，参加者の 母集団[sources]，選定方法を明記する。追跡の方法についても記述 する。
    (a)・ケース・コントロール研究[case-control study]：適格基準，参加者 の母集団，ケース[case]の確定方法とコントロール[control]の選択 方法を示す。ケースとコントロールの選択における論拠を示す。
    (a)・横断研究[cross-sectional study]：適格基準，参加者の母集団，選択 方法を示す。
    (b)・コホート研究：マッチング研究[matched study]の場合，マッチング の基準，曝露群[exposed]と非曝露群[unexposed]の各人数を記載する。
    (b)・ケース・コントロール研究：マッチング研究[matched study]の場合， マッチングの基準，ケースあたりのコントロールの人数を記載する。
    変数[variable] 7 すべてのアウトカム，曝露，予測因子[predictor]，潜在的交絡因子 [potential confounder]，潜在的な効果修飾因子[effect modifier]を明確に定義 する。該当する場合は，診断方法を示す。 データ源[data source]/ 測定方法 8＊ 関連する各因子に対して，データ源，測定・評価方法の詳細を示す。二つ 以上の群がある場合は，測定方法の比較可能性[comparability]を明記する。
    バイアス[bias] 9 潜在的なバイアス源に対応するためにとられた措置があればすべて示す。
    研究サイズ[study size] 10 研究サイズ[訳者注：観察対象者数]がどのように算出されたかを説明する。
    量的変数 [quantitative variable] 11 (a)量的変数の分析方法を説明する。該当する場合は，どのグルーピング [grouping]がなぜ選ばれたかを記載する。
    統計・分析方法 [statistical method] 12
    (a)交絡因子の調整に用いた方法を含め，すべての統計学的方法を示す。
    (b)サブグループと相互作用[interaction]の検証に用いたすべての方法を示す。
    (c)欠損データ[missing data]をどのように扱ったかを説明する。
    (d)・コホート研究：該当する場合は，脱落例[loss to follow-up]をどのように扱ったかを説明する。 (d)・ケース・コントロール研究：該当する場合は，ケースとコントロー ルのマッチングをどのように行ったかを説明する。
    (d)・横断研究：該当する場合は，サンプリング方式[sampling strategy]を 考慮した分析法について記述する。
    (e)あらゆる感度分析[sensitivity analysis]の方法を示す。


Results
-------

165,779 unique cases were analyzed, which were reported from 2010 to 2014 and had available records about age and sex.

    classification of target drugs -> Table. 1
    analysis flow -> Figure. 1
    characteristics of Japanese SRS -> Table. 2

**Figure. 2** Report counts of incretin-based drugs

![Fig. 2](output/img/case_count.svg)

    Preffered Term under High Level Term -> Table. 3

**Figure. 3** Forest plot of the first screening

![Fig. 3](output/img/sc_forest.svg)

**Figure. 4** Forest plot of the second screening

![Fig. 4](output/img/dm_forest.svg)

**Figure. 5** Violin plot of the final analysis

![Fig. 5](output/img/violin.svg)



    結果[result]
    参加者[participant] 13＊
    (a)研究の各段階における人数を示す(例：潜在的な適格[eligible]者数， 適格性が調査された数，適格と確認された数，研究に組入れられた数， フォローアップを完了した数，分析された数)。
    (b)各段階での非参加者の理由を示す。
    (c)フローチャートによる記載を考慮する。
    記述的データ [descriptive data] 14＊
    (a)参加者の特徴(例：人口統計学的，臨床的，社会学的特徴)と曝露や 潜在的交絡因子の情報を示す。 (b)それぞれの変数について，データが欠損した参加者数を記載する。
    (c)コホート研究：追跡期間を平均および合計で要約する。
    アウトカムデータ [Outcome data] 15＊
    ・コホート研究：アウトカム事象の発生数や集約尺度[summary measure] の数値を経時的に示す。
    ・ケース・コントロール研究：各曝露カテゴリーの数，または曝露の集約 尺度を示す。
    ・横断研究：アウトカム事象の発生数または集約尺度を示す。
    おもな結果[main result] 16
    (a)調整前[unadjusted]の推定値と，該当する場合は交絡因子での調整後の 推定値，そしてそれらの精度(例：95％信頼区間)を記述する。どの 交絡因子が，なぜ調整されたかを明確にする。
    (b)連続変数[continuous variable]がカテゴリー化されているときは，カテ ゴリー境界[category boundary]を報告する。
    (c)意味のある[relevant]場合は，相対リスク[relative risk]を，意味をもつ 期間の絶対リスク[absolute risk]に換算することを考慮する。
    他の解析[other analysis] 17 その他に行われたすべての分析(例：サブグループと相互作用の解析や感 度分析)の結果を報告する。


Discussion
----------

##### Limitation

    考察[discussion]
    鍵となる結果[key result] 18 研究目的に関しての鍵となる結果を要約する。
    限界[limitation] 19 潜在的なバイアスや精度の問題を考慮して，研究の限界を議論する。潜在 的バイアスの方向性と大きさを議論する。
    解釈[interpretation] 20 目的，限界，解析の多重性[multiplicity]，同様の研究で得られた結果やその他の関連するエビデンスを考慮し，慎重で総合的な結果の解釈を記載する。
    一般化可能性 [generalisability] 21 研究結果の一般化可能性(外的妥当性[external validity])を議論する。

    研究の財源[funding] 22 研究の資金源，本研究における資金提供者[funder]の役割を示す。該当する場合には，現在の研究の元となる研究[original study]についても同様に示す。


Acknowledgement
---------------


Reference
---------

    R Development Core Team (2013) R: A Language and Environment for Statistical Computing (R Foundation for Statistical Computing, Vienna, Austria).
    Stan Development Team (2013) Stan: A C++ Library for Probability and Sampling, Version 1.3. Available at http://mc-stan.org/.

    Wickham H (2009) ggplot2: Elegant Graphics for Data Analysis (Springer, New York).
    Stan Development Team (2012) Stan: A C++ Library for Probability and Sampling, Version 1.0. Available at http://mc-stan.org/.


Competing Interests
-------------------

Abbreviations
-------------

Figures
-------

Figure Legends
--------------

Tables
------


