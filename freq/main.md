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

Adverse Events Associated with Incretin-based Drugs in the Japanese Spontaneous Reports: A Mixed Effects Logistic Regression Modeling
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

Spontaneous reporting systems (SRSs) are passive systems composed of reports of suspected adverse drug events (ADEs) and are exploited for pharmacovigilance (PhV), namely, drug safety surveillance.
Exploration of analytical methodologies to enhance SRS-based discovery will contribute to more effective PhV.
In this article, we proposed a statistical modeling approach for SRS data to address heterogeneity by time of reporting.
Furthermore, we applied this to analyze ADEs of incretin-based drugs, which are widely used to treat type 2 diabetes and contain DPP-4 inhibitors and GLP-1 receptor agonists.

##### Methods

The SRS data were obtained from the Japanese SRS, termed "JADER".
Adverse events reported were classified in the MedDRA High Level Terms (HLTs).
The statistical model was designed as mixed effects logistic regression model for occurrence each HLT.
The model treated DPP-4 inhibitors, GLP-1 receptor agonists, hypoglycemic drugs, concomitant suspected drugs, age, and sex as fix effects, quarterly period of reporting as a random effect.
Before application of the model, Fisher's exact tests were performed by all the drug-HLT combinations.
About the HLTs associated with incretin-based drugs in these tests, the mixed effects logistic regressions were performed.
Statistical significance was determined by odds ratio and two-sided p-value < 0.01, or 99 % confidence interval.
Finally, the models with or without the random effect were compared by Akaike's information criteria (AIC) to assess the adequacy of the random effect.

##### Results

In the JADER data, 187,181 cases reported from January 2010 to March 2015 were analyzed.
As the result, 33 HLTs were significantly associated with DPP-4 inhibitors or GLP-1 receptor agonists, which were pancreatic, gastrointestinal, or cholecystic events.
In the AIC comparison, half of the HLTs reported with incretin-based drugs favored the random effect, where HLTs reported frequently tended to favor the mixed model.

##### Conclusion

The model with the random effect showed appropriateness for ADEs reported frequently.
However, this has room for improvement.
To sophisticate the modeling, further exploration will be required.


Introduction
------------

Incretin is a group of intestinal hormones stimulating insulin secretion.
During the last decade, several hypoglycemic drugs based on incretin have been developed and have gained widespread use for type 2 diabetes.
Incretin-based drugs are classified in two types, which are inhibitors of the incretin-degrading protease dipeptidyl peptidase 4 (DPP-4) and receptor agonists of the incretin hormone glucagon-like peptide 1 (GLP-1).
DPP-4 inhibitors and GLP-1 receptor agonists have the clinical advantages, e.g., effective lowering of fasting and postprandial glucose, avoidance of hypoglycemia, no risk of body weight gain, reduction in blood pressure. [1]

By contrast, they have safety concerns about adverse outcomes.
Pancreatic disorders are ones of the most controversial issues in the concerns. [1, 2, 3]
In a certain study analyzing the US Food and Drug Administration (FDA) Adverse Event Reporting System (FAERS), use of the DPP-4 inhibitor sitagliptin or the GLP-1 receptor agonist exenatide increased the odds ratio (OR) for pancreatitis more than 6-fold and for pancreatic cancer more than 2-fold as compared to other medications. [4]
However, most other clinical studies have demonstrated no evidence suggesting such risks. [1, 5]
The FDA and the European Medicines Agency (EMA) explored multiple streams of data and agreed that assertions concerning a causal association between incretin-based drugs and pancreatitis or pancreatic cancer were inconsistent with the current data. [6]

Spontaneous reporting systems (SRSs) such as the FAERS are passive systems composed of reports of suspected adverse drug events (ADEs) collected from healthcare professionals, consumers, and pharmaceutical companies. [7]
They play essential roles in pharmacovigilance (PhV) which is also referred to as drug safety surveillance.
SRSs cover large populations, whereas their data have some biases in reporting.
In the case of incretin-based drugs in the FAERS, reporting of pancreatitis was largely influenced by the relevant FDA alerts, which is so-called notoriety bias and could cause overestimation of risk. [8]
SRS data have numerous limitations, nevertheless, PhV has relied predominantly on SRSs. [7, 9]
Therefore, exploration of novel analytical methodologies to enhance SRS-based discovery will highlight the value of SRSs and contribute to more effective PhV.

The objectives of this article are to propose a statistical modeling approach for SRS data and to apply this to analyze ADEs of incretin-based drugs on an SRS.
We designed a mixed effects logistic regression model and performed comprehensive analyses using this.
The analyzed data were obtained from the Japanese SRS that is termed "JADER" (Japanese Adverse Drug Event Report database) and maintained by the Pharmaceuticals and Medical Devices Agency (PMDA). [10]
Most of case reports in the FAERS are from consumers or lawyers, whereas those in the JADER are medically confirmed. [11]
The ADE analyses were based mainly on multivariate mixed effects logistic regression, where conventional disproportionality analyses (DPA) were used adjunctively.
Multivariate logistic regressions are more appropriate to handle confounding than DPAs. [7]
Mixed effects logistic regression model is one of generalized linear mixed models (GLMMs) and contains variables for fixed and random effects.
The use of GLMMs in medical literature has recently increased to take into account the correlation of data when modeling binary or count data. [12]
As an application of GLMMs to SRS data, the approach based on mixed effects Poisson regression models was proposed in one study. [13]
This method yields rate multipliers for each drug in a class of drugs that describe the deviation of the rate for a specific adverse event from that for the drug class as a whole.
On the other hand, the present approach is based on the logistic regression model with the random intercept.
Introducing random variable in a logistic regression model describes the ramifications of different sources of heterogeneity and associations between outcomes. [14]
The model we designed treats time as a random effect to address heterogeneity between periods of reporting.
To the best of our knowledge, this is the first application of logistic regression models with random effects to SRS data.


Material and Methods
--------------------

##### Data Source

The JADER dataset was fetched from the website of the PMDA, which was published in July 2015 and contained 353,988 unique cases.
The cases analyzed were reported from January 2010 to March 2015 and had available records about age and sex.

Adverse events in the JADER were coded as Preferred Terms (PTs) in the Japanese version of the Medical Dictionary for Regulatory Activities (MedDRA/J). [15]
Before data analyses, a relational database was constructed from the JADER dataset and MedDRA/J version 18.0.
For the database management system, SQLite version 3.8.5 was used. [16]

As incretin-based drugs, all of the approved DPP-4 inhibitors and GLP-1 receptor agonists in Japan were followed.
The DPP-4 inhibitors were: sitagliptin phosphate hydrate, vildagliptin, alogliptin benzoate, alogliptin benzoate / pioglitazone hydrochloride (combination drug), linagliptin, teneligliptin hydrobromide hydrate, anagliptin, and saxagliptin hydrate.
The GLP-1 receptor agonists were: exenatide, liraglutide, and lixisenatide.

##### Data Analysis

The ADE analysis of incretin-based drugs was composed of two phases.
The first phase was DPA based on Fisher's exact test, the second phase was multivariate analyses using a mixed effects logistic regression model.

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

In the model we designed, the binary outcome was whether each HLT was reported or not, and the covariates were the following.
For fixed effects: use of DPP-4 inhibitors, use of GLP-1 receptor agonists, use of any hypoglycemic drugs (an alternative indicator for hyperglycemia), sum of concomitant suspected drugs (determined by reference to the Fisher's exact tests), age (each 10-year), and sex.
For a random effect: quarterly period of reporting.
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
DPP-4 inhibitors were in 7,265 cases and GLP-1 receptor agonists were in 451 cases.
Figure 1 denotes the counts of the cases with hypoglycemic drugs by each quarterly period.
Although cases with other hypoglycemic drugs were prone to increase, cases with DPP-4 inhibitors were increasing markedly.

##### Mixed effects logistic regressions

1,430 PTs under 735 HLTs were reported in the cases with incretin-based drugs.
In the Fisher's exact tests, 106 of the 735 HLTs were significantly associated with any incretin-based drug by two-sided p-value < 0.01 and OR > 1.
In the mixed effects logistic regressions, 33 of the 106 HLTs were significantly associated with DPP-4 inhibitors or GLP-1 receptor agonists by 99 % CI.
Table 1 denotes the counts of the cases reported with each of those HLTs.
Figure 2 denotes ORs with 99 % CIs for the significant combinations between HLTs and DPP-4 inhibitors or GLP-1 receptor agonists.
"NEC" in the MedDRA terms is the abbreviation of "Not Elsewhere Classified" to denote groupings of miscellaneous terms, and “excl” represents excluding.
DPP-4 inhibitors were associated with "Pancreatic disorders NEC" (OR 18.66; 99 % CI 2.09-166.25), "Acute and chronic pancreatitis" (8.65; 5.76-12.98), etc.
GLP-1 receptor agonists were associated with "Thyroid neoplasms" (87.25; 6.64-1146.27), "Cystic pancreatic disorders" (61.32; 1.69-2224.49), etc.
The HLTs associated with both of the drug classes indicated pancreatic events ("Acute and chronic pancreatitis", "Pancreatic neoplasms", "Pancreatic neoplasms malignant (excl islet cell and carcinoid)", and "Pancreatic disorders NEC"), gastrointestinal events ("Benign neoplasms gastrointestinal (excl oral cavity)" and "Gastrointestinal stenosis and obstruction NEC"), or cholecystic events ("Cholecystitis and cholelithiasis").
Although both the classes were not associated with hypoglycemic events, GLP-1 receptor agonists were associated with several HLTs related to diabetes ("Hyperglycaemic conditions NEC", "Diabetic complications NEC", etc.).

##### Comparison between the models with or without the random effect

Figure 3 describes the comparison between the model with the random effect (mixed model) and that without the random effect (fixed model).
In 604 of the 735 HLTs reported along with incretin-based drugs, AIC of the models were calculated normally.
Of the 604 HLTs, 302 favored the mixed model and the other favored the fixed model.
The medians of the total case counts among these two groups were 264 and 83, respectively.
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
Some groups of similar HLTs, e.g., "Thyroid neoplasms" and "Thyroid neoplasms malignant" were shown because some PTs are linked to multiple HLTs in the MedDRA.
GLP-1 receptor agonists showed relatively wide CIs for some of the HLTs because the cases reported with them were fewer than that with DPP-4 inhibitors.
Such results will be unreliable.

Pancreatic disorders, including pancreatitis and pancreatic cancer, were associated with both of DPP-4 inhibitors and GLP-1 receptor agonists.
These results were consistent with those of analyzing the FAERS data. [2, 4]
Thyroid cancer was associated with GLP-1 receptor agonists.
However, because of the few cases, this result will be not reliable.
In the FAERS data, GLP-1 receptor agonists increased the odds ratios for thyroid cancer. [2, 4]
Thyroid cancer is one of the most controversial issues in the safety concerns of incretin-based drugs as well as pancreatic disorders, however, no evidence has been found for such risk of human. [1, 2]
Other than the above-noted events, the HLTs associated with the both classes were "Benign neoplasms gastrointestinal (excl oral cavity)", "Gastrointestinal stenosis and obstruction NEC", and "Cholecystitis and cholelithiasis".
Gastrointestinal events such as nausea, vomiting, or diarrhea are common ADEs. [20]
Nevertheless, gastrointestinal benign neoplasms, stenosis and obstruction have not been reported in literatures.
In the same way, cholecystitis and cholelithiasis has also not.
Cholelithiasis is related to diabetes or obesity, which develops complications, including cholecystitis and pancreatitis. [21]
Therefore, these events do not seem to be unconnected with diabetes.

Hypoglycemia, which is An on-target adverse event of hypoglycemic drugs, was not associated with incretin-based drugs.
In contrast, hyperglycemia and several other diabetic complications were associated with GLP-1 receptor agonists.
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

In the AIC comparison between the mixed model and the fixed model, half of the HLTs reported with incretin-based drugs favored the former.
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

We proposed the logistic regression model with the random effect of time for SRS data and applied this to analyze ADEs of incretin-based drugs on the Japanese SRS.
As a result, the model showed appropriateness for ADEs reported frequently.
However, this is an exploratory model and has room for improvement.
To sophisticate the modeling, further exploration will be required.


Acknowledgements
----------------


Disclosure
----------

The authors report no conflicts of interest.


Author contribution
-------------------

Reference
---------

Competing Interests
-------------------

Abbreviations
-------------

ADE, adverse drug event; SRS, spontaneous reporting system; OR, odds ratio.


![](output/img/q_count.png)

**Figure 1** Case counts of hypoglycemic drugs by each quarterly period.

The upper line plot denotes cases reported with hypoglycemic drugs.
The lower area plot denotes all the cases.


**Table 1** Case counts of the adverse events associated with DPP-4 inhibitors or GLP-1 receptor agonists.


![](output/img/mixed_or.png)

**Figure 2** Odds ratios of the adverse events associated with DPP-4 inhibitors or GLP-1 receptor agonists.

The forest plot denotes odds ratios (ORs) with 99 % confidence intervals (CIs) by the events.
Significant ORs with CIs are plotted.


![](output/img/aic_diff.png)

**Figure 3** AIC improvements with the random effect.

The vertical axis of the lower scatter plot denotes AIC differences calculated by subtracting that of the fixed model from that of the mixed model.
When this value is less than 0, the mixed model is favored.
The horizontal axis denotes total case counts by the MedDRA HLTs.
The upper plot is the histogram of the lower.


