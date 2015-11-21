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

Adverse Events Associated with Incretin-based Drugs in Spontaneous Reports: A Mixed Effects Logistic Regression Analysis of the Japanese spontaneous reports
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

This study is designed as a disproportionality analysis based on logistic regression model for spontaneous ADE reports.
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

Incretin is a group of intestinal hormones that stimulate insulin secretion.
Several hypoglycemic drugs based on this mechanism have been developed during the last decade.
There are two classes of incretin-based drugs, inhibitors of the incretin-degrading protease dipeptidyl peptidase 4 (DPP-4) and receptor agonists of the incretin hormone glucagon-like peptide 1 (GLP-1), which are gaining widespread use for type 2 diabetes.
DPP-4 inhibitors and GLP-1 agonists have the clinical advantages, e.g., effective lowering of fasting and postprandial glucose, avoidance of hypoglycemia, no risk of body weight gain, reduction in blood pressure. [1]

By contrast, they have safety concerns about adverse outcomes.
Pancreatic disorders are ones of the most controversial issues in the concerns. [1, 2, 3]
In a certain study analyzing the US Food and Drug Administration (FDA) Adverse Event Reporting System (FAERS), use of the DPP-4 inhibitor sitagliptin or the GLP-1 agonist exenatide increased the odds ratio (OR) for pancreatitis more than 6-fold and for pancreatic cancer more than 2-fold as compared to other medications. [4]
However, in most other clinical studies, data have suggested no evidence for the risks of pancreatitis or pancreatic cancer. [1, 5]
The FDA and the European Medicines Agency (EMA) explored multiple streams of data and agreed that assertions concerning a causal association between incretin-based drugs and pancreatitis or pancreatic cancer were inconsistent with the current data. [6]

Spontaneous reporting systems (SRSs) such as the FAERS are passive systems composed of reports of suspected adverse drug events (ADEs) collected from healthcare professionals, consumers, and pharmaceutical companies. [7]
They play essential roles in pharmacovigilance (PhV) which is also referred to as drug safety surveillance.
SRSs cover large populations, whereas their data have some biases in reporting.
In the case of incretin-based drugs in the FAERS, reporting of pancreatitis was largely influenced by the relevant FDA alerts, which is so-called notoriety bias and could cause overestimation of risk. [8]
SRS data have numerous limitations, nevertheless, PhV has relied predominantly on SRSs. [7, 9]
Therefore, exploration of novel analytical methodologies to enhance SRS-based discovery will highlight the value of SRSs and contribute to more effective PhV.

The objectives of this article are to propose a statistical modeling approach for SRS data and to apply this to analyze ADEs of incretin-based drugs on an SRS.
We designed a mixed effects logistic regression model and performed comprehensive analyses using this.
The analyzed data were obtained from the Japanese SRS that is termed JADER (Japanese Adverse Drug Event Report database) and maintained by the Pharmaceuticals and Medical Devices Agency (PMDA). [10]
Most of case reports in the FAERS are from consumers or lawyers, whereas those in the JADER are medically confirmed. [11]
The analyses were based mainly on multivariate mixed effects logistic regression, where conventional disproportionality analyses (DPA) were used adjunctively.
Multivariate logistic regressions are more appropriate to handle confounding than DPAs. [7]
Mixed effects logistic regression model is one of generalized linear mixed models (GLMMs) and contains variables for fixed and random effects.
The use of GLMMs in medical literature has recently increased to take into account the correlation of data when modeling binary or count data. [12]
As an application of GLMMs to SRS data, the approach based on mixed effects Poisson regression models was proposed in one study. [13]
This method yields rate multipliers for each drug in a class of drugs that describe the deviation of the rate for a specific adverse event from that for the drug class as a whole.
On the other hand, the present approach is based on the logistic regression model with the random intercept.
Introducing random variable in a logistic regression model describes the ramifications of different sources of heterogeneity and associations between outcomes. [14]
This treats time of reporting as a random effect to address heterogeneity between reporting periods.
To the best of our knowledge, this is the first application of logistic regression models with random effects to SRS data.


Material and Methods
--------------------

##### Study Design

This study was designed as two phases of analyses for drug-event associations on spontaneous reports.
The first phase is DPA based on Fisher's exact test, the second phase is multivariate analyses based on a mixed effects logistic regression model.

##### Data Source

The JADER dataset was fetched from the website of the PMDA, which was published in July 2015 and contained 353,988 unique cases.
The cases analyzed were reported from January 2010 to March 2015 and had available records about age and sex.

Adverse events in the JADER were coded as Preferred Terms (PTs) in the Japanese version of the Medical Dictionary for Regulatory Activities (MedDRA/J). [15]
Before data analyses, a relational database was constructed from the JADER dataset and MedDRA/J version 18.0.
For the database management system, SQLite version 3.8.5 was used. [16]

As incretin-based drugs, all of the approved DPP-4 inhibitors and GLP-1 agonists in Japan were followed.
The DPP-4 inhibitors were: sitagliptin phosphate hydrate, vildagliptin, alogliptin benzoate, alogliptin benzoate / pioglitazone hydrochloride (combination drug), linagliptin, teneligliptin hydrobromide hydrate, anagliptin, and saxagliptin hydrate.
The GLP-1 agonists were: exenatide, liraglutide, and lixisenatide.

##### Data Analysis

The PTs of adverse events were classified in the MedDRA High Level Terms (HLTs), and all the combinations between drug generic names and HLTs were extracted.
Fisher's exact tests were performed by all the combinations between drugs and HLTs reported along with incretin-based drugs.
Combinations where a two-sided p-value < 0.01 and an OR > 1 were handled as significant associations.

About the HLTs significantly associated with incretin-based drugs, mixed effects logistic regressions for occurrences of each HLT were performed.
A model for mixed effects logistic regression, i.e., logistic regression with random effects, is described as the following:

\[\frac{P\left( Y_{i} = 1 \middle| x_{i},z_{i} \right)}{P\left( Y_{i} = 0 \middle| x_{i},z_{i} \right)} = exp\left( x_{i}^{T}\beta + z_{i}^{T}u \right)\]

Y_{_i_} is a variable for a binary outcome of case _i_, which is 0 or 1.
\beta is a fixed parameter vector, and x_{_i_} is a covariate vector for fixed effects.
_u_ is a vector of random variables from probability distributions, and z_{_i_} is a covariate vector for random effects.
_u_ can be thought as unmeasured covariates, as a way to model heterogeneity, or as a way to model correlated data. [14]

In the model we designed, the binary outcome was whether each HLT was reported or not, and the covariates were the followings.
For fixed effects: use of DPP-4 inhibitors, use of GLP-1 agonists, use of any hypoglycemic drugs (an alternative indicator for hyperglycemia), sum of concomitant suspected drugs (determined by reference to the Fisher's exact tests), age (each 10-year), and sex.
For a random effect: reporting date (quarterly period).
The variables for the random effect were supposed to be random intercepts normally distributed with mean 0 and one common variance.
The associations between incretin-based drugs and HLTs were assessed by ORs with 99 % Wald-type confidence intervals (CIs).

Furthermore, this mixed model was compared with the fixed model without the random effect.
The covariates for fix effects in the fixed model were common with those in the mixed model.
Logistic regressions based on each model were performed by all the HLTs reported along with incretin-based drugs.
Subsequently, the adequacy of the model was assessed by Akaike's information criteria (AIC). [17]

All the data analyses were performed in the statistical computing environment of R version 3.2.1. [18]
For the mixed effects logistic regressions, glmmML package version 1.0 were used with a method "ghq" (Gauss-Hermite quadrature). [19]


Results
-------

##### Description of the analyzed case reports

204,472 unique cases were reported from January 2010 to March 2015, and 187,181 of these had available records about age and sex, which were analyzed.
In the data, 4,952 drug generic name and 6,151 PTs under 1,377 HLTs were reported.
DPP-4 inhibitors were in 7,265 cases and GLP-1 agonists were in 451 cases.
Figure 1 denotes the counts of the cases with hypoglycemic drugs by each quarterly period.
Although cases with other hypoglycemic drugs were prone to increase, cases with DPP-4 inhibitors were increasing markedly.

##### Mixed effects logistic regressions

1,430 PTs under 735 HLTs were reported in the cases with incretin-based drugs.
In the Fisher's exact tests, 106 of the 735 HLTs were significantly associated with any incretin-based drug by two-sided p-value < 0.01 and OR > 1.
In the mixed effects logistic regressions, 33 of the 106 HLTs were significantly associated with DPP-4 inhibitors or GLP-1 agonists by 99 % CI (Table 1).
Figure 2 denotes ORs with 99 % CIs for the significant combinations between HLTs and DPP-4 inhibitors or GLP-1 agonists.
"NEC" in the MedDRA terms is the abbreviation of "Not Elsewhere Classified" to denote groupings of miscellaneous terms, and “excl” represents excluding.
DPP-4 inhibitors were associated with "Pancreatic disorders NEC" (OR 18.66; 99 % CI 2.09-166.25), "Acute and chronic pancreatitis" (8.65; 5.76-12.98), etc.
GLP-1 agonists were associated with "Thyroid neoplasms" (87.25; 6.64-1146.27), "Cystic pancreatic disorders" (61.32; 1.69-2224.49), etc.
The HLTs associated with both of the drug classes indicated pancreatic events ("Acute and chronic pancreatitis", "Pancreatic neoplasms", "Pancreatic neoplasms malignant (excl islet cell and carcinoid)", and "Pancreatic disorders NEC"), gastrointestinal events ("Benign neoplasms gastrointestinal (excl oral cavity)" and "Gastrointestinal stenosis and obstruction NEC"), or cholecystic events ("Cholecystitis and cholelithiasis").
Although both the classes were not associated with hypoglycemic events, GLP-1 agonists were associated with several HLTs related to diabetes ("Hyperglycaemic conditions NEC", "Diabetic complications NEC", etc.).

##### Comparison between the models with or without the random effect

Figure 3 describes the comparison between the model with the random effect (mixed model) and that without the random effect (fixed model).
In 604 of the 735 HLTs reported along with incretin-based drugs, AIC of the models were calculated normally.
Of the 604 HLTs, 302 favored the mixed model and the other favored the fixed model.
Each medians of the total case counts among these two groups were 264 and 83.
Thus, HLTs reported frequently tended to favor the mixed model.


Discussion
----------

##### Time-series variation of spontaneous reports

SRSs accumulate large amount of data prefocused on ADEs every year.
Their contents are not constant.
In the present study, the report composition of hypoglycemic drug groups had varied during the study period.
The reports with DPP-4 inhibitors showed a marked increase compared with that with the other hypoglycemic drugs.
This momentum could be driven by increase of approved products and drug use.
A report amount at one period are affected by numerous factors in the period.
This property results in the heterogeneity by time, which may support the adequacy of the mixed model.

##### Adverse events associated with incretin-based drugs

Some of HLTs associated with incretin-based drugs in the study are the concerns in other previous studies.
Some groups of similar HLTs, e.g., "Thyroid neoplasms malignant" and "Thyroid neoplasms malignant" were shown because some PTs are linked to multiple HLTs in the MedDRA.
GLP-1 agonists showed relatively wide CIs for the overall HLTs because the reports with them were fewer than that with DPP-4 inhibitors.

Pancreatic disorders, including pancreatitis and pancreatic cancer, were associated with both of DPP-4 inhibitors and GLP-1 agonists.
These results were consistent with those of analyzing the FAERS data. [2, 4]
Thyroid cancer was associated with GLP-1 agonists.
In the FAERS data, GLP-1 agonists increased the odds ratios for thyroid cancer. [2, 4]
Thyroid cancer is one of the most controversial issues in the safety concerns of incretin-based drugs as well as pancreatic disorders, however, there is no evidence for such risk of human. [1, 2]
Other than the above-noted events, the HLTs associated with the both classes were "Benign neoplasms gastrointestinal (excl oral cavity)", "Gastrointestinal stenosis and obstruction NEC", and "Cholecystitis and cholelithiasis".
Gastrointestinal events such as nausea, vomiting, or diarrhea are common ADEs. [20]
Nevertheless, gastrointestinal benign neoplasms, stenosis and obstruction have not been reported in literatures.
In the same way, cholecystitis and cholelithiasis has also not.
Cholelithiasis is related to diabetes or obesity, which develops complications, including cholecystitis and pancreatitis. [21]
Therefore, these events do not seem to be unconnected with diabetes.

Hypoglycemia, which is An on-target adverse event of hypoglycemic drugs, was not associated with incretin-based drugs.
In contrast, hyperglycemia and several other diabetic complications were associated with GLP-1 agonists.
This could be due to ineffective cases of drugs.

##### Limitations

SRS data have various limitations in data mining.
These include confounding by indication (i.e., patients taking a particular drug may have a disease that is itself associated with a higher incidence of the adverse event), systematic under-reporting, questionable representativeness of patients, effects of media publicity on numbers of reports, extreme duplication of reports, and attribution of the event to a single drug when patients may be exposed to multiple drugs. [9]
In addition, spontaneous reports do not reliably detect adverse drug reactions that occur widely separated in time from the original use of the drug. [22]

The model we designed addresses confounding by reported concomitant drugs heterogeneity by time.
Nevertheless, addressing the most parts of limitations is impossible.
Risks emerging in SRS data should be considered not as valid ones, but as safety signals.
For further interpretation of each ADE, additional reviews of other data sources are recommended.

##### Mixed effects logistic regression model

In AIC comparison between the mixed model and the fixed model, half of the HLTs reported with incretin-based drugs favored the former.
The HLTs that favor the mixed model were reported more frequently than the other.
This indicates that the mixed model may be appropriate in sufficiently frequent ADEs.
The formula of AIC has the bias-correction term from the number of estimable parameters. [17]
In the above comparison, the mixed model has only one more parameter than the fixed model, hence, the difference between the penalties for the correction is small.

The adequacy of the random effect was described, however, the modeling has room for improvement.
We assumed normal distribution for the random effect, of which appropriateness is unclear.
Moreover, it should be considered whether one probability distribution is enough for the random effect on widely spread time-scale of spontaneous reports.
For solutions to these problems, sampling of parameter distributions by Bayesian hierarchical modeling will be a potential avenue.
Today, diverse implementations of Bayesian methods are accessible, which support practice of such modeling. [23, 24]

Time of reporting is the attribution common to all spontaneous reports.
Hence, modeling the random effect of time is applicable to any ADE on SRSs.
This is an approach that has not been discussed, which open new possibilities for data analysis of spontaneous reports.


Conclusion
----------

In the present study, we proposed the mixed effects logistic regression model for SRS data.
Furthermore, we applied this model to ADEs of incretin-based drugs on the Japanese SRS.
As a result, several ADEs including pancreatic disorders was associated with incretin-based drugs.



Acknowledgements
----------------


Author contribution
-------------------


Disclosure
----------

The author reports no conflicts of interest in this work.

    研究の財源[funding] 22 研究の資金源，本研究における資金提供者[funder]の役割を示す。該当する場合には，現在の研究の元となる研究[original study]についても同様に示す。

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

