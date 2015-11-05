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

ORIGINAL RESEARCH

An statistical analysis of adverse event reports

Daichi Narushima et al

Adverse Events Associated with Incretin-based Drugs in Spontaneous Reports: A Mixed Effects Logistic Regression Analysis of the Japanese spontaneous reporting system
=======

Authors' names:  
Daichi Narushima, Yohei Kawasaki, Shoji Takamatsu, Hiroshi Yamada

Author affiliations:  
Department of Drug Evaluation & Informatics, Graduate school of Pharmaceutical Sciences, University of Shizuoka, Shizuoka, Japan (DN, YK and HY);
Office of Safety II, Pharmaceuticals and Medical Devices Agency, Japan (ST)

Correspondence:  
Hiroshi Yamada, MD, PhD, FACP  
Department of Drug Evaluation & Informatics, Graduate School of Pharmaceutical Sciences, University of Shizuoka, 52-1 Yada, Suruga-ku, Shizuoka 422-8526, Japan  
Tel: +81 54 264 5762  
Fax: +81 54 264 5762  
Email: hyamada@u-shizuoka-ken.ac.jp

Keywords:  
Spontaneous retporting system, mixed effect, logistic regression, hypoglycemic drug, incretin-based drug

Abstract
--------

##### Background
Dipeptidyl peptidase 4 (DPP-4) inhibitors and glucagon-like peptide 1 (GLP-1) agonists are incretin-based hypoglycemic drugs which are widely used to treat type 2 diabetes.
The safety of these drugs is one of the most concerns in diabetes medication.
To assess adverse events associated with incretin-based drugs, Japanese spontaneous reports were analysed.

    - the rationale of study
    - the specific study hypothesis and/or study objectives

##### Methods
This study is designed as a disproportionality analysis based on logistic regression model of spontaneous ADE reports.
The report data was fetched from the Japanese Adverse Drug Event Report database (JADER), which is published by Pharmaceuticals and Medical Devices Agency (PMDA).
176,957 unique cases were analyzed, which were reported from 2010 to 2014 and had available records about age and sex.

In the first, Fisher's exact tests were performed by all combinations between generic names of drugs and MedDRA High Level Terms (HLTs) including adverse events.
drug-event combinations which two-sided p-value < 0.01 and odds ratio > 1

##### Results

using fixed effects model and adverse events associated with incretin-based drug were extracted.

This model includes use of incretin-based drug, concomitant suspected drug, history of the event, age, and sex as predictor variables, and occurrence of each HLTs as an outcome variable.
In the second screening, the cases treated with hypoglycemic drug were analyzed using the same model as that in the previous screening.
In the final analysis, the cases treated with hypoglycemic drug were analyzed using the random effects model which has reporting quarter as a random effect besides the fixed effects.
The result showed that GLP-1 agonists associated with risks of pancreatic neoplasms (odds ratio 25.0, 99 % credible interval 8.2 to 79.3) and pancreatitis (12.5, 5.9 to 26.9) and that DPP-4 inhibitors are associated with risks of pancreatic neoplasms (4.9, 1.76 to 15.4), pancreatitis (13.3, 7.2 to 27.9) and abnormal urinalysis (7.8, 1.5 to 69.1).

    - What was studied
    - main methods used
    - how many participants were enrolled
    - statistical tests
    - a measure of its precision
    - main limitation

##### Conclusions

    - general interpretation for any implications
    - important recommendation for future

    タイトル・抄録 [title and abstract]
    1. タイトルまたは抄録のなかで，試験デザインを一般に用いられる用語 で明示する。
    2. 抄録では，研究で行われたことと明らかにされたことについて，十分 な情報を含み，かつバランスのよい要約を記載する。 



Introduction
------------

Incretin is a group of intestinal hormones stimulating insulin secretion, and several hypoglycemic drugs based on this mechanisms have been developed during the last decade.
There are two types of incretin-based drugs, inhibitors of the incretin-degrading protease dipeptidyl peptidase 4 (DPP-4) and receptor agonists of the incretin hormone glucagon-like peptide 1 (GLP-1), which are gaining widespread use for type 2 diabetes.
DPP-4 inhibitors and GLP-1 agonists have the clinical advantages, e.g. effective lowering of fasting and postprandial glucose, avoidance of hypoglycemia, no risk of body weight gain, reduction in blood pressure. [1]

Incretin-based drugs have many benefits, by contrast, there are safety concerns about adverse outcomes.
Pancreatic disorders are ones of the most controversial issues in the concerns.
In one study analyzing the US Food and Drug Administration (FDA) Adverse Event Reporting System (FAERS), use of the DPP-4 inhibitor sitagliptin or the GLP-1 agonist exenatide increased the odds ratio (OR) for pancreatitis more than 6-fold and for pancreatic cancer more than 2-fold  as compared with other medications. [2]
However, in most other clinical studies, data have suggested no evidence for the risks of pancreatitis or pancreatic cancer. [1, 3]
The FDA and the European Medicines Agency (EMA) explored multiple streams of data and agreed that assertions concerning a causal association between incretin-based drugs and pancreatitis or pancreatic cancer were inconsistent with the current data. [4]

Spontaneous reporting systems (SRSs) such as FAERS are passive systems composed of reports of suspected adverse drug events (ADEs) collected from healthcare professionals, consumers, and pharmaceutical companies. [5]
Although they cover large populations, their data have some bias in reporting.
In the case of incretin-based drugs in the FAERS, reporting of pancreatitis was largely influenced by the relevant FDA alerts, which is so-called notoriety bias and could cause overestimation of risks. [6]

The objective of this article is to evaluate associations between incretin-based drugs and adverse events reported in spontaneous reports by statistical approach.
We performed comprehensive analyses based on multivariate mixed effects logistic regression.
The analyzed data were from the Japanese SRS that is termed JADER (Japanese Adverse Drug Event Report database) and maintained by the Pharmaceuticals and Medical Devices Agency (PMDA).
Most of case reports in the JADER are medically confirmed, while those in the FAERS are from consumers or lawyers. [7]
In the analyses, in addition to logistic regressions, disproportionality analyses (DPA) were used adjunctively.
As methods applied to SRSs, while DPA are traditional approaches, multivariate logistic regressions are more appropriate to handle confounding. [5]
Mixed effects logistic regression is one of generalized linear mixed models (GLMMs) and contains variables for fixed and random effects.
By introducing random variable in a logistic regression model, ramifications of different sources of heterogeneity and associations between outcomes are described. [8]
As an application of GLMMs to SRSs, the approach based on mixed effects Poisson regression models was proposed in one study. [9]
This method yields rate multipliers for each drug in a class of drugs that describe the deviation of the rate for a specific adverse event from that for the drug class as a whole.
On the other hand, the present approach is based on the logistic regression model with the random intercept, where time of reporting is treated as a random effect so as to address heterogeneity between reporting periods.
To the best of our knowledge, this is the first application of logistic regression models with random effects for time on data analysis of SRSs.


Material and Methods
--------------------

##### Study Design

This study was designed as two phases of analyses for drug-event associations on spontaneous reports.
The first phase is DPA based on Fisher's exact test, the second phase is multivariate analyses based on a mixed effects logistic regression model.

##### Data Source

The JADER dataset was fetched from the website of the PMDA, which was published in July 2015 and contained 353,988 unique cases.
The cases analyzed were reported from January 2010 to March 2015 and had available records about age and sex.

Adverse events in the JADER were coded as Preferred Terms (PTs) in the Japanese version of the Medical Dictionary for Regulatory Activities (MedDRA/J). [10]
Before data analyses, a relational database was constructed from the JADER dataset and MedDRA/J version 18.0.
For the database management system, SQLite version 3.8.5 was used. [11]

As incretin-based drugs, all of the approved DPP-4 inhibitors and GLP-1 agonists in Japan were followed.
The DPP-4 inhibitors were: sitagliptin phosphate hydrate, vildagliptin, alogliptin benzoate, alogliptin benzoate / pioglitazone hydrochloride (combination drug), linagliptin, teneligliptin hydrobromide hydrate, anagliptin, and saxagliptin hydrate.
The GLP-1 agonists were: exenatide, liraglutide, and lixisenatide.

##### Data Analysis

The PTs of adverse events were classified in MedDRA High Level Terms (HLTs), and all the combinations between drug generic names and HLTs were extracted.
Fisher's exact tests were performed by all the combinations between drugs and HLTs reported along with incretin-based drugs.
Combinations where a two-sided p-value < 0.01 and an OR > 1 were handled as significant associations.

About the HLTs significantly associated with incretin-based drugs, mixed effects logistic regressions for occurrences of each HLT were performed.
A model for mixed effects logistic regression, i.e. logistic regression with random effects, is described as the following:

\[\frac{P\left( Y_{i} = 1 \middle| x_{i},z_{i} \right)}{P\left( Y_{i} = 0 \middle| x_{i},z_{i} \right)} = exp\left( x_{i}^{T}\beta + z_{i}^{T}u \right)\]

Y_{_i_} is a variable for a binary outcome of case _i_, which is 0 or 1.
\beta is a fixed parameter vector, and x_{_i_} is a covariate vector for fixed effects.
_u_ is a vector of random variables from probability distributions, and z_{_i_} is a covariate vector for random effects.
_u_ can be thought as unmeasured covariates, as a way to model heterogeneity, or as a way to model correlated data. [8]

In the present analyses, the binary outcome was whether each HLT was reported or not, and the covariates were the followings.
For fixed effects: use of DPP-4 inhibitors, use of GLP-1 agonists, use of any hypoglycemic drugs (an alternative indicator for hyperglycemia), sum of concomitant suspected drugs (determined by reference to the Fisher's exact tests), age (each 10-year), and sex.
For a random effect: reporting date (quarterly period).
The variables for the random effect was supposed to be random intercepts normally distributed with mean 0 and one common variance.
The associations between incretin-based drugs and HLTs were assessed by ORs with 99 % Wald-type confidence intervals (CIs).

Furthermore, this mixed model was compared with the fixed model without the random effect.
The covariates for fix effects in the fixed model were common with those in the mixed model.
Logistic regressions based on each model were performed by all the HLTs reported along with incretin-based drugs, so that the adequacy of the random effect was assessed by Akaike information criteria (AIC).

All the data analyses were performed in the statistical computing environment of R version 3.2.1. [12]
For the mixed effects logistic regressions, glmmML package version 1.0 were used with a method "ghq" (Gauss-Hermite quadrature). [13]


Results
-------

##### Description of the analyzed case reports

204,472 unique cases were reported from January 2010 to March 2015, and 187,181 of these had available records about age and sex, which were analyzed.
In the data, 4,952 drug generic name and 6,151 PTs under 1,377 HLTs were reported.
DPP-4 inhibitors were in 7,265 cases and GLP-1 agonists were in 451 cases.
Figure 1 denotes the counts of the cases with hypoglycemic drugs by each quarterly period.
Although cases with other hypoglycemic drugs were prone to increase, cases with DPP-4 inhibitors were increasing markedly.

##### The mixed effects logistic regressions

1,430 PTs under 735 HLTs were reported in the cases with incretin-based drugs.
In the Fisher's exact tests, 106 of the 735 HLTs were significantly associated with any incretin-based drug by two-sided p-value < 0.01 and OR > 1.
In the mixed effects logistic regressions, 33 of the 106 HLTs were significantly associated with DPP-4 inhibitors or GLP-1 agonists by 99 % CI (Table 1).
Figure 2 denotes ORs with 99 % CIs for the significant combinations between HLTs and DPP-4 inhibitors or GLP-1 agonists.
The following HLTs were remarkably associated.
With DPP-4 inhibitors: Pancreatic disorders NEC (OR 18.65; 99 % CI 2.09-166.25), Acute and chronic pancreatitis (8.65; 5.76-12.98), etc.
With GLP-1 agonists: Thyroid neoplasms (87.25; 6.64-1146.27), Cystic pancreatic disorders (61.32; 1.69-2224.49), etc.
"NEC" in MedDRA terms is the abbreviation of "Not Elsewhere Classified" to denote groupings of miscellaneous terms.

##### AIC comparison between the models with or without the random effect

Figure 3 describes the comparison between the model with the random effect (mixed model) and the model without the random effect (fixed model).
In 604 of the 735 HLTs reported along with incretin-based drugs, AIC of the models were calculated normally.
Of the 604 HLTs, 302 favored the mixed model and the other favored the fixed model.
Each medians of the total case counts among these two groups were 264 and 83.
Thus, there was a tendency that frequently reported HLTs favored the mixed model.


Discussion
----------

SRSs accumulate large amount of data prefocused on ADEs every year, where the contents are not constant.
In the present study, the report composition by hypoglycemic drug groups had varied during the study period.
The reports with DPP-4 inhibitors showed a marked increase compared with that with the other hypoglycemic drugs.
This tendency could be caused by increase of approved products and drug use.
A report amount at one period are affected logically by various factors at the period.
This property results in heterogeneity by time, which may support the adequacy of the mixed model.

Many of HLTs associated with incretin-based drugs in the study are the concerns in other previous studies.
Pancreatitis ("Acute and chronic pancreatitis"), pancreatic neoplasms ("Pancreatic neoplasms" and "Pancreatic neoplasms malignant"), and other pancreatic disorders ("Cystic pancreatic disorders" and "Pancreatic disorders NEC") were associated with both of DPP-4 inhibitors and GLP-1 agonists, which are consistent with the result of the study analyzing the FAERS. [2]
However biases like the FAERS [6]
Thyroid neoplasms ("Thyroid neoplasms" and "Thyroid neoplasms malignant") were associated with GLP-1 agonists.



Neoplasms except pancreatic and thyroid ones ("Gastric neoplasms malignant", "Lower respiratory tract neoplasms", etc.)
Gastrointestinal adverse events ("Gastrointestinal stenosis and obstruction NEC", "Gastrointestinal atonic and hypomotility disorders NEC", etc.)
Diabetic complications ("Diabetic complications NEC", "Diabetic complications neurological", etc.)
Hyperglycemia ("Hyperglycaemic conditions NEC")



Cystic pancreatic disorders     嚢胞性膵障害
Pancreatic disorders NEC        膵障害ＮＥＣ
Acute and chronic pancreatitis  急性および慢性膵炎
Pancreatic neoplasms malignant (excl islet cell and carcinoid)  悪性膵新生物（膵島細胞腫瘍およびカルチノイドを除く）
Pancreatic neoplasms    膵新生物

Thyroid neoplasms malignant     悪性甲状腺新生物
Thyroid neoplasms       甲状腺新生物

Gastrointestinal neoplasms benign NEC   良性消化器新生物ＮＥＣ
Benign neoplasms gastrointestinal (excl oral cavity)    良性消化管新生物（口腔内新生物を除く）
Lower gastrointestinal neoplasms benign 良性下部消化管新生物
Gastric neoplasms malignant     悪性胃新生物
Lower respiratory tract neoplasms       下気道新生物

Gastrointestinal stenosis and obstruction NEC   消化管狭窄および閉塞ＮＥＣ
Non-mechanical ileus    非機械的イレウス
Gastrointestinal atonic and hypomotility disorders NEC  消化管アトニーおよび運動低下障害ＮＥＣ
Digestive enzymes       消化酵素

Metabolic acidoses (excl diabetic acidoses)     代謝性アシドーシス（糖尿病性アシドーシスを除く）
Hyperglycaemic conditions NEC   高血糖ＮＥＣ
Diabetic complications neurological     糖尿病性神経系合併症
Diabetic complications NEC      糖尿病性合併症ＮＥＣ
Chronic polyneuropathies        慢性多発ニューロパチー

Rheumatoid arthropathies        リウマチ性関節症
Rheumatoid arthritis and associated conditions  関節リウマチおよびその関連疾患
Arthropathies NEC       関節症ＮＥＣ

Adrenal cortical hypofunctions  副腎皮質機能低下
Skin autoimmune disorders NEC   皮膚の自己免疫障害ＮＥＣ
Skeletal and cardiac muscle analyses    骨格筋および心筋検査
Cholecystitis and cholelithiasis        胆嚢炎および胆石症
Bile duct infections and inflammations  胆管感染および炎症
Coronary necrosis and vascular insufficiency    冠血管壊死および血行不全
Urinalysis NEC  検尿ＮＥＣ
Non-site specific injuries NEC  部位不明の損傷ＮＥＣ
Injection site reactions        注射部位反応



With DPP-4 inhibitors: Pancreatic disorders NEC (OR 18.65; 99 % CI 2.09-166.25), Acute and chronic pancreatitis (8.65; 5.76-12.98), Skin autoimmune disorders NEC (6.87; 2.13-22.19), etc.
With GLP-1 agonists: Thyroid neoplasms (87.25; 6.64-1146.27), Cystic pancreatic disorders (61.32; 1.69-2224.49), Pancreatic disorders NEC (37.98; 5.56-259.52), etc.



    考察[discussion]
    鍵となる結果[key result] 18 研究目的に関しての鍵となる結果を要約する。
    限界[limitation] 19 潜在的なバイアスや精度の問題を考慮して，研究の限界を議論する。潜在 的バイアスの方向性と大きさを議論する。
    解釈[interpretation] 20 目的，限界，解析の多重性[multiplicity]，同様の研究で得られた結果やその他の関連するエビデンスを考慮し，慎重で総合的な結果の解釈を記載する。
    一般化可能性 [generalisability] 21 研究結果の一般化可能性(外的妥当性[external validity])を議論する。

    研究の財源[funding] 22 研究の資金源，本研究における資金提供者[funder]の役割を示す。該当する場合には，現在の研究の元となる研究[original study]についても同様に示す。


Conclusion
----------


Acknowledgements
----------------


Author contribution
-------------------


Disclosure
----------

The author reports no conflicts of interest in this work.

Reference
---------


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


**Table 1** Results of logistic regressions.


**Notes:**

**Abbreviations:** ADE, adverse event; SRS, spontaneous reporting system; OR, odds ratio.

**Figure 1** Report counts of hypoglycemic drugs.

![](output/img/q_count.png)

**Figure 2** Odds ratios of HLTs associated with DPP-4 inhibitors or GLP-1 agonists.

![](output/img/mixed_or.png)

**Figure 3** AIC improvements with a random effect.

![](output/img/aic_diff.png)

