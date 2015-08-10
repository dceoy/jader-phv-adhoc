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


Adverse Events Associated with Incretin-based Drugs in Spontaneous Reports: A Logistic Regression Analysis of Japanese Adverse Drug Event Reports
=======

Authors:  
Daichi Narushima, Yohei Kawasaki, Shoji Takamatsu, Hiroshi Yamada

Author Affiliations:  
Department of Drug Evaluation & Informatics, Graduate school of Pharmaceutical Sciences, University of Shizuoka, Shizuoka, Japan (DN, YK and HY);
Office of Safety II, Pharmaceuticals and Medical Devices Agency, Japan (ST)

Corresponding Author:  
Hiroshi Yamada, MD, PhD, FACP, Department of Drug Evaluation & Informatics, Graduate School of Pharmaceutical Sciences, University of Shizuoka, 52-1 Yada, Suruga-ku, Shizuoka 422-8526, Japan (hyamada@u-shizuoka-ken.ac.jp).


Abstract
--------

##### Background
Dipeptidyl peptidase 4 (DPP-4) inhibitors and glucagon-like peptide 1 (GLP-1) agonists are incretin-based hypoglycemic drugs which are widely used to treat type 2 diabetes.
The safety of these drugs is one of the most concerns in diabetes medication.
To assess adverse events (AEs) associated with incretin-based drugs, we analyzed Japanese spontaneous reports.

    - the rationale of study
    - the specific study hypothesis and/or study objectives

##### Methods and Findings
This study is designed as a disproportionality analysis based on logistic regression model of spontaneous AE reports.
The report data was fetched from Japanese Adverse Drug Event Report database (JADER), which is published by Pharmaceuticals and Medical Devices Agency (PMDA).
176,957 unique cases were analyzed, which were reported from 2010 to 2014 and had available records about age and sex.


In the first, Fisher's exact test were performed by all combinations between generic names of drugs and MedDRA High Level Terms (HLTs) including adverse events.
drug-event combinations which two-sided p-value < 0.01 and odds ratio > 1


using fixed effects model and AEs associated with incretin-based drug were extracted.

This model includes use of incretin-based drug, concomitant suspected drug, history of the event, age and sex as predictor variables, and occurrence of each AEs as an outcome variable.
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
There are two types of incretin-based drugs, dipeptidyl peptidase 4 (DPP-4) inhibitors and glucagon-like peptide 1 (GLP-1) agonists.

GLP-1 agonists demonstrate an efficacy comparable to insulin treatment and appear to do so with significant effects to promote weight loss with minimal hypoglycemia. <sup>1</sup>

In addition, there are significant data with dipeptidyl peptidase 4 (DPP-4) inhibitors showing efficacy comparable to sulfonylureas but with weight neutral effects and reduced risk for hypoglycemia.

    <-  advantages of incretin-based drugs

These drugs have many advantages, however
Adverse Event (AE)

    <-  feared AE


Spontaneous reporting systems (SRSs) play an essential roles in drug safety surveillance. These cumulate a large quantity of case reports.

Japanese Adverse Drug Event Report database (JADER)
Pharmaceuticals and Medical Devices Agency (PMDA)

The report data is fetched from Japanese Adverse Drug Event Report database (JADER), which is published by Pharmaceuticals and Medical Devices Agency (PMDA).

    はじめに[introduction]
    背景[background]/ 論拠[rationale] 2 研究の科学的な背景と論拠を説明する。
    目的[objective] 3 特定の仮説を含む目的を明記する。


Methods
-------

##### Study Design

This study comprises two phases of analyses for drug-event associations on spontaneous reports.
The first phase is a frequency analysis based on Fisher's exact test, the second phase is a multivariate analysis using a mixed effects logistic regression model.

##### Data Source

Japanese AE report data of JADER were fetched from the website of PMDA, and the dataset published in July 2015 was used, which contain 353,988 unique cases.
In these, cases which were reported from January 2010 to March 2015 and had available records about age and sex were analyzed.

AEs in JADER were coded as Preferred Terms (PTs) in the Japanese version of the Medical Dictionary for Regulatory Activities (MedDRA/J). [1]
For data analysis, we constructed a relational database (RDB) containing the JADER dataset and MedDRA/J version 18.0.
As an RDB management system, SQLite version 3.8.5 was used. [2]

Incretin-based drugs

##### Data Analysis

The PTs of AEs were classified in MedDRA High Level Terms (HLTs), all the combinations between drug generic names and HLTs were extracted.
Fisher's exact tests were performed by all the drug-HLT combinations.
Combinations in which a two-sided p-value was less than 0.01 and an odds ratio (OR) was greater than 1 were handled as significant associations.

About the HLTs significantly associated with incretin-based drugs (Table 1), mixed effects logistic regressions for occurrences of each HLT were performed.
A mixed effects model contains random effects at group levels besides traditional fixed effects. [3]

In this study, the following covariates were treated as fixed effects: use of DPP-4 inhibitors, use of GLP-1 agonists, use of any hypoglycemic drugs (an alternative indicator of hyperglycemia), sum of concomitant suspected drugs (determined by reference to the Fisher's exact tests), age (each 10-year) and sex.
Moreover, reporting date (quarterly period) was treated as a random effect.
This was supposed to be a random intercept normally distributed with mean 0 and a common variance.
The associations between incretin-based drugs and HLTs were assessed by ORs with 99% Wald-type confidence intervals.
Furthermore, adequacy of the random effect was assessed using Akaike information criteria (AIC) among HLTs reported along with incretin-based drug.

All data analyses were performed in the statistical computing environment of R version 3.2.1. [4]
For mixed effects logistic regression, glmmML package version 1.0 were used with method 'ghq' (Gauss-Hermite quadrature). [5]


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

176,957 unique cases were analyzed, which were reported from January 2010 to March 2015 had available records about age and sex.
In these cases, 4,952 unique drug generic name and 6,151 unique PTs were reported.
1,377 unique HLTs




**Table 1** results of logistic regressions

![](output/img/q_count.png)

**Figure 1** Report counts of hypoglycemic drugs

![](output/img/mixed_or.png)

**Figure 2** Odds ratios of HLTs associated with DPP-4 inhibitors or GLP-1 agonists

![](output/img/aic_diff.png)

**Figure 3** AIC improvements with a random effect



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


References
1.  MedDRA
2.  SQLite
3.  Larsen, K., et al. (2000). "Interpreting Parameters in the Logistic Regression Model with Random Effects." Biometrics 56(3): 909-914.
4.  R Core Team. R: A Language and Environment for Statistical Computing. Vienna, Austria2015.
5.  Broström G. glmmML: Generalized linear models with clustering. 2013.


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


