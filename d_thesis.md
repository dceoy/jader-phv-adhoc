########### Adverse Events Associated with Incretin-based Drugs in Japanese Spontaneous Reports: A Mixed Effects Logistic Regression Model

Daichi Narushima^1^, Yohei Kawasaki^1^, Shoji Takamatsu^2^, Hiroshi
Yamada^1^

^1^ Department of Drug Evaluation & Informatics, Graduate school of
Pharmaceutical Sciences, University of Shizuoka, Shizuoka, Japan

^2^ Office of Safety II, Pharmaceuticals and Medical Devices Agency,
Japan

Corresponding author:\
Hiroshi Yamada, MD, PhD, FACP\
Department of Drug Evaluation & Informatics, Graduate School of
Pharmaceutical Sciences, University of Shizuoka, 52-1 Yada, Suruga-ku,
Shizuoka 422-8526, Japan\
Email: hyamada@u-shizuoka-ken.ac.jp

<span id="introduction" class="anchor"></span>

##################### Abstract

<span id="background" class="anchor"></span>Background

Spontaneous reporting systems (SRSs) are passive systems composed of
reports of suspected adverse drug events (ADEs), and are used for
pharmacovigilance (PhV), namely, drug safety surveillance. Exploration
of analytical methodologies to enhance SRS-based discovery will
contribute to more effective PhV. In this article, we proposed a
statistical modeling approach for SRS data to address heterogeneity by
time of reporting. Furthermore, we applied this approach to analyze ADEs
of incretin-based drugs such as DPP-4 inhibitors and GLP-1 receptor
agonists, which are widely used to treat type 2 diabetes.

<span id="methods" class="anchor"></span>Methods

SRS data were obtained from the Japanese Adverse Drug Event Report
(JADER) database. Reported adverse events were classified according to
the MedDRA High Level Terms (HLTs). A mixed effects logistic regression
model was used to analyze the occurrence of each HLT. The model treated
DPP-4 inhibitors, GLP-1 receptor agonists, hypoglycemic drugs,
concomitant suspected drugs, age, and sex as fixed effects, while the
quarterly period of reporting was treated as a random effect. Before
application of the model, Fisher's exact tests were performed for all
drug-HLT combinations. Mixed effects logistic regressions were performed
for the HLTs that were found to be associated with incretin-based drugs.
Statistical significance was determined by the odds ratio and a
two-sided p-value &lt;0.01 or a 99% confidence interval. Finally, the
models with and without the random effect were compared by Akaike's
information criteria (AIC) to assess the adequacy of the random effect.

<span id="results" class="anchor"></span>Results

The analysis included 187,181 cases reported from January 2010 to March
2015. It showed that 33 HLTs, including pancreatic, gastrointestinal,
and cholecystic events, were significantly associated with DPP-4
inhibitors or GLP-1 receptor agonists. In the AIC comparison, half of
the HLTs reported with incretin-based drugs favored the random effect,
whereas HLTs reported frequently tended to favor the mixed model.

<span id="conclusion" class="anchor"></span>Conclusion

The model with the random effect was appropriate for ADEs reported
frequently; however, the model can be improved. Further exploration is
required to increase the sophistication of the model.

##################### Introduction {#introduction-1}

<span id="material-and-methods" class="anchor"></span>The incretins are
a group of intestinal hormones that stimulate insulin secretion. During
the last decade, several hypoglycemic drugs based on incretin have
gained widespread use as treatments for patients with type 2 diabetes.
Incretin-based drugs are classified as inhibitors of incretin-degrading
protease dipeptidyl peptidase 4 (DPP-4) or as incretin hormone
glucagon-like peptide 1 (GLP-1) receptor agonists. DPP-4 inhibitors and
GLP-1 receptor agonists lower fasting and postprandial glucose, but do
not produce hypoglycemia and are not associated with body weight gain or
reduced in blood pressure. (Nauck 2013)

DPP-4 inhibitors and GLP-1 receptor agonists have been associated with
adverse outcomes, including pancreatic disorders, although some of these
findings are controversial. (Butler et al. 2013; Devaraj & Maitra 2014;
Nauck 2013) An analysis of the US Food and Drug Administration (FDA)
Adverse Event Reporting System (FAERS) revealed that use of DPP-4
inhibitor sitagliptin or GLP-1 receptor agonist exenatide increased the
odds ratio (OR) for pancreatitis more than 6-fold, while increasing the
OR for pancreatic cancer more than 2-fold, in comparison with other
medications; (Elashoff et al. 2011) however, most other clinical studies
have demonstrated no evidence suggesting such risks. (Li et al. 2014;
Nauck 2013) The FDA and European Medicines Agency (EMA) explored
multiple streams of data and agreed that assertions concerning a causal
association between incretin-based drugs and pancreatitis or pancreatic
cancer were inconsistent with the current data. (Egan et al. 2014)

Spontaneous reporting systems (SRSs) such as the FAERS are passive
systems composed of reports of suspected adverse drug events (ADEs)
collected from healthcare professionals, consumers, and pharmaceutical
companies. (Harpaz et al. 2012) SRSs play an essential role in
pharmacovigilance (PhV), which is also referred to as drug safety
surveillance. Although SRSs cover large populations, their data have
some biases in reporting. In the case of incretin-based drugs in the
FAERS, reporting of pancreatitis was largely influenced by the relevant
FDA alerts in an example of notoriety bias, which could cause
overestimation of risk. (Raschi et al. 2013) SRS data have numerous
limitations; nevertheless, PhV has relied predominantly on SRSs.
(Gibbons et al. 2010; Harpaz et al. 2012) Therefore, exploration of
novel analytical methodologies to enhance SRS-based discovery will
highlight the value of SRSs and contribute to more effective PhV.

The objectives of this article are to propose a statistical modeling
approach for SRS data and to apply this approach to analyze ADEs
associated with incretin-based drugs from an SRS. We designed a mixed
effects logistic regression model and performed comprehensive analyses
using this model. The analyzed data were obtained from the Japanese
Adverse Drug Event Report (JADER) database maintained by the
Pharmaceuticals and Medical Devices Agency (PMDA). \[10\] Most case
reports in the FAERS are from consumers or lawyers, whereas those in the
JADER are medically confirmed. (Nomura et al. 2015) The analyses were
based mainly on multivariate mixed effects logistic regression, in which
conventional disproportionality analyses (DPA) were used adjunctively.
Multivariate logistic regressions are more appropriate than DPAs for
handling confounding variables. (Harpaz et al. 2012) Mixed effects
logistic regression models are a type of generalized linear mixed model
(GLMM) and contain variables for fixed and random effects. The use of
GLMMs in medical literature has recently increased to take into account
data correlations when modeling binary or count data. (Casals et al.
2014) An approach based on mixed effects Poisson regression models was
proposed as an application of GLMMs to SRS data that yields rate
multipliers for each drug in a class of drugs. (Gibbons et al. 2008) The
rate multipliers describe the deviation of the rate for a specific
adverse event from that for the drug class as a whole. In contrast, the
present approach is based on a logistic regression model with a random
intercept. The random variable in a logistic regression model describes
the ramifications of different sources of heterogeneity and associations
between outcomes. (Larsen et al. 2000) The model introduced here treats
time as a random effect to address heterogeneity between periods of
reporting. To the best of our knowledge, this is the first application
of a logistic regression model with random effects to SRS data.

##################### Material and Methods {#material-and-methods-1}

<span id="study-design" class="anchor"></span>Data Source

<span id="data-analysis" class="anchor"></span>The JADER dataset, which
was published in July 2015 and contained 353,988 unique cases, was
obtained from the website of the PMDA. The analyzed cases were reported
from January 2010 to March 2015 and had available records regarding age
and sex.

Adverse events in the JADER were coded as Preferred Terms (PTs) in the
Japanese version of the Medical Dictionary for Regulatory Activities
(MedDRA/J). \[15\] Before data analyses, a relational database was
constructed from the JADER dataset and MedDRA/J version 18.0. SQLite
version 3.8.5 was used as the database management system. \[16\]

As incretin-based drugs, all DPP-4 inhibitors and GLP-1 receptor
agonists approved in Japan were assessed. The DPP-4 inhibitors were
sitagliptin phosphate hydrate, vildagliptin, alogliptin benzoate,
alogliptin benzoate/pioglitazone hydrochloride (combination drug),
linagliptin, teneligliptin hydrobromide hydrate, anagliptin, and
saxagliptin hydrate. The GLP-1 receptor agonists were exenatide,
liraglutide, and lixisenatide.

Data Analysis

The analysis of ADEs associated with incretin-based drugs was composed
of two phases. The first phase was a DPA based on Fisher's exact test.
The second phase was a multivariate analysis using a mixed effects
logistic regression model.

The PTs of ADEs were classified according to the MedDRA High Level Terms
(HLTs). All combinations of generic drug names and HLTs were extracted.
Fisher's exact tests were performed for all combinations of
incretin-based drugs and reported HLTs. Associations that yielded a
two-sided p-value &lt;0.01 and an OR &gt;1 were considered significant.

Mixed effects logistic regressions were performed for each HLT
significantly associated with incretin-based drugs. The mixed effects
logistic regression model was as follows:

$$\frac{P\left( Y_{i} = 1 \middle| x_{i},z_{i} \right)}{P\left( Y_{i} = 0 \middle| x_{i},z_{i} \right)} = exp\left( x_{i}^{T}\beta + z_{i}^{T}u \right)$$

Where *Y~i~* is a binary variable describing the outcome of case *i* (0
or 1), *β* is a fixed parameter vector, *x~i~* is a covariate vector for
fixed effects, *u* is a vector of random variables from probability
distributions, and *z~i~* is a covariate vector for random effects. *u*
represents unmeasured covariates as a way of modeling heterogeneity and
correlated data. (Larsen et al. 2000)

In the newly developed model, the binary outcome was whether or not each
HLT was reported. For fixed effects, the covariates were use of DPP-4
inhibitors, use of GLP-1 receptor agonists, use of any hypoglycemic
drugs (an alternative indicator for hyperglycemia), sum of concomitant
suspected drugs (determined by reference to the Fisher's exact tests),
age (in 10-year intervals), and sex. The random effect was the quarterly
period of reporting. The variables for the random effect were random
intercepts normally distributed with mean 0 and one common variance. The
associations between incretin-based drugs and HLTs were assessed by ORs
with 99% Wald-type confidence intervals (CIs).

<span id="results-1" class="anchor"></span>The newly developed mixed
model was compared with a fixed model that did not include the random
effect. The covariates for fixed effects in the fixed model were the
same covariates use in the mixed model. Logistic regressions based on
each model were performed for all reported HLTs associated with
incretin-based drugs. Subsequently, the adequacy of the model was
assessed by Akaike's information criteria (AIC). (Burnham & Anderson
2002)

All analyses were performed using the R version 3.2.1. (R Core Team
2015) The glmmML package version 1.0 was used with the "ghq"
(Gauss-Hermite quadrature) method for the mixed effects logistic
regressions. (Broström 2013)

##################### Results {#results-2}

################################################### Description of the analyzed case reports

<span id="the-mixed-effects-logistic-regressions"
class="anchor"></span>The JADER included 204,472 unique cases that were
reported from January 2010 to March 2015, of which 187,181 had available
records for age and sex and were analyzed. The records included 4,952
generic drug names and 6,151 PTs under 1,377 HLTs. DPP-4 inhibitors were
mentioned in 7,265 cases, whereas GLP-1 receptor agonists were mentioned
in 451 cases. Figure 1 shows the number of cases mentioning hypoglycemic
drugs that were reported during each quarterly period. Although the
number of cases for other hypoglycemic drugs increased gradually over
time, the number of cases for DPP-4 inhibitors increased markedly.

################################################### Mixed effects logistic regressions

The cases associated with incretin-based drugs included 1,430 PTs under
735 HLTs. The Fisher's exact tests showed that 106 of the 735 HLTs were
significantly associated with any incretin-based drug (two-sided p-value
&lt;0.01 and OR &gt;1). In the mixed effects logistic regressions, 33 of
the 106 HLTs identified by the Fisher's exact tests were significantly
associated with DPP-4 inhibitors or GLP-1 receptor agonists (99% CI).
Table 1 shows the number of cases reported for each HLT. Figure 2 shows
ORs with 99% CIs for the significant associations between HLTs and DPP-4
inhibitors or GLP-1 receptor agonists. "NEC" in the MedDRA terms is an
acronym for "Not Elsewhere Classified", which denotes groupings of
miscellaneous terms, whereas “excl” is an abbreviation of “excluding”.
The HLTs associated with DPP-4 inhibitors included "Pancreatic disorders
NEC" (OR 18.66; 99% CI 2.09–166.25) and "Acute and chronic pancreatitis"
(8.65; 5.76–12.98). The HLTs associated with GLP-1 receptor agonists
included "Thyroid neoplasms" (87.25; 6.64-1146.27) and "Cystic
pancreatic disorders" (61.32; 1.69-2224.49). The HLTs associated with
DPP-4 inhibitors and GLP-1 receptor agonists indicated pancreatic events
("Acute and chronic pancreatitis", "Pancreatic neoplasms", "Pancreatic
neoplasms malignant (excl islet cell and carcinoid)", and "Pancreatic
disorders NEC"), gastrointestinal events ("Benign neoplasms
gastrointestinal (excl oral cavity)" and "Gastrointestinal stenosis and
obstruction NEC"), and cholecystic events ("Cholecystitis and
cholelithiasis"). Although DPP-4 inhibitors and GLP-1 receptor agonists
were not associated with hypoglycemic events, GLP-1 receptor agonists
were associated with several HLTs related to diabetes, including
"Hyperglycaemic conditions NEC" and "Diabetic complications NEC".

################################################### Comparison between the models with and without the random effect

Figure 3 shows the comparison between the models with (mixed model) and
without (fixed model) the random effect . In 604 of the 735 HLTs
reported with incretin-based drugs, the AIC of the models were
calculated normally. Of the 604 HLTs, 302 favored the mixed model,
whereas the others favored the fixed model. The median number of
reported cases for the group of HLTs favoring the mixed model was 264,
whereas the median number of reported cases for the group of HLTs
favoring the fixed model was 83; thus, HLTs reported frequently tended
to favor the mixed model.

##################### Discussion

<span id="time-series-variation-of-spontaneous-rep"
class="anchor"></span>Time-series variation of spontaneous reports

SRSs accumulate a large amount of data regarding ADEs every year; thus,
the contents of SRSs are not constant. In the present study, the report
composition of hypoglycemic drug groups varied during the study period.
Reports associated with DPP-4 inhibitors showed a marked increase in
comparison with that of reports associated with other hypoglycemic
drugs, perhaps because of an increasing number of approved products and
an associated increase in drug use. The number of reports during a
particular period is affected by numerous factors. This variation in
reporting results in temporal heterogeneity, supporting the
appropriateness of the mixed model.

<span id="adverse-events-associated-with-incretin-"
class="anchor"></span>Adverse events associated with incretin-based
drugs

Some HLTs associated with incretin-based drugs in the present study have
been reported as issues of concern in previous studies. Some groups of
similar HLTs, e.g., "Thyroid neoplasms malignant" and "Thyroid neoplasms
malignant" were identified because some PTs are linked to multiple HLTs
in the MedDRA. In comparison with DPP-4 inhibitors, GLP-1 receptor
agonists showed relatively wide CIs for some of the HLTs because fewer
cases were reported, leading to unreliable results.

In the present study, pancreatic disorders, including pancreatitis and
pancreatic cancer, were associated with DPP-4 inhibitors and GLP-1
receptor agonists, which were consistent with results obtained via
analysis of FAERS data. (Butler et al. 2013; Elashoff et al. 2011) In
addition, thyroid cancer was associated with GLP-1 receptor agonists;
however, because of the small number of cases, this finding is
unreliable. Analyses of FAERS data also indicated that GLP-1 receptor
agonists increased ORs for thyroid cancer. (Butler et al. 2013; Elashoff
et al. 2011) Thyroid cancer and pancreatic disorders are among the most
controversial safety concerns regarding incretin-based drugs; however,
no evidence has been found for such risks in human clinical studies.
(Butler et al. 2013; Nauck 2013) The other HLTs associated with DPP-4
inhibitors and GLP-1 receptor agonists were "Benign neoplasms
gastrointestinal (excl oral cavity)", "Gastrointestinal stenosis and
obstruction NEC", and "Cholecystitis and cholelithiasis".
Gastrointestinal events such as nausea, vomiting, and diarrhea are
common ADEs of incretin-based drugs. (Nauck 2011) However, benign
gastrointestinal neoplasms, stenosis, and obstruction have not been
referred to in past studies. Cholecystic events have not in the same
way.

Hypoglycemia, an adverse event associated with some hypoglycemic drugs,
was not associated with incretin-based drugs. In contrast, hyperglycemia
and several other diabetic complications were associated with GLP-1
receptor agonists, perhaps because of cases of ineffective drug
treatment.

<span id="limitations" class="anchor"></span>Limitations

The limitations of SRS data mining include confounding by indication
(i.e., patients taking a particular drug may have a disease that is
itself associated with a higher incidence of the adverse event),
systematic under-reporting, questionable representativeness of patients,
effects of media publicity on numbers of reports, extreme duplication of
reports, and attribution of the event to a single drug when patients may
be exposed to multiple drugs. (Gibbons et al. 2010) In addition,
spontaneous reports do not reliably detect adverse drug reactions that
occur widely separated in time from the original use of the drug.
(Brewer & Colditz 1999)

The newly developed model reported here addresses the confounding
influences of temporal heterogeneity and concomitant drug use.
Nevertheless, risks identified via analysis of SRS data should be
considered as safety signals, rather than definitive statements of cause
and effect. For further interpretation of each ADE, additional reviews
of other data sources are recommended.

<span id="mixed-effects-logistic-regression-model"
class="anchor"></span>Mixed effects logistic regression model

In the AIC comparison between the mixed model and the fixed model, half
of the HLTs reported with incretin-based drugs favored each model. The
HLTs that favored the mixed model were reported more frequently than
those that favored the fixed model, indicating that the mixed model may
be more appropriate for frequently reported ADEs. The AIC formula has a
bias-correction term for the number of estimable parameters. (Burnham &
Anderson 2002) In the above comparison, the mixed model has only one
more parameter than does the fixed model; hence, the difference between
the penalties for the correction is small.

The adequacy of the random effect was demonstrated; however, the model
can be improved. Although we assumed a normal distribution for the
random effect, the appropriateness of this assumption is unclear.
Moreover, it is unclear whether a single probability distribution is
sufficient to assess the random effect on the widely spread time-scale
of spontaneous reports. Sampling of parameter distributions by Bayesian
hierarchical modeling is a potential solution to these problems.
Currently, diverse implementations of Bayesian methods, which support
practice of such modeling, are accessible. (Li et al. 2011; MacLehose &
Hamra 2014)

Time-of-reporting is an attribution common to all spontaneous reports.
Hence, modeling the random effect of time is applicable to any ADE in
any SRS; however, this approach has not been reported. Therefore, the
newly developed model reported here will improve future analyses of
spontaneous report data.

##################### Conclusion {#conclusion-1}

We proposed a logistic regression model for SRS data taking into account
the random effect of time and applied this model to analyze ADEs
reported with incretin-based drugs in the JADER . The newly developed
model was appropriate for ADEs reported frequently; however, further
exploration will improve the sophistication of the model.

<span id="discussion-1" class="anchor"></span>![](media/image1.png)

**Figure 1** Case counts of hypoglycemic drugs by each quarterly period.

The upper line plot denotes cases reported with hypoglycemic drugs. The
lower area plot denotes all cases.

  -------------------------------------------------------------------------------------------------------
  MedDRA HLT                                                       DPP-4\       GLP-1 receptor\   Total
                                                                   inhibitors   agonists          
  ---------------------------------------------------------------- ------------ ----------------- -------
  Thyroid neoplasms                                                1            3                 62

  Thyroid neoplasms malignant                                      0            2                 53

  Cystic pancreatic disorders                                      2            1                 16

  Pancreatic disorders NEC                                         11           3                 50

  Adrenal cortical hypofunctions                                   5            4                 184

  Gastrointestinal neoplasms benign NEC                            5            2                 22

  Chronic polyneuropathies                                         3            2                 44

  Pancreatic neoplasms                                             47           16                166

  Cholecystitis and cholelithiasis                                 39           12                441

  Bile duct infections and inflammations                           9            4                 176

  Pancreatic neoplasms malignant (excl islet cell and carcinoid)   42           13                142

  Injection site reactions                                         6            8                 742

  Non-mechanical ileus                                             16           7                 325

  Diabetic complications NEC                                       23           19                177

  Acute and chronic pancreatitis                                   234          29                1038

  Gastrointestinal atonic and hypomotility disorders NEC           20           9                 390

  Gastric neoplasms malignant                                      19           5                 279

  Benign neoplasms gastrointestinal (excl oral cavity)             16           3                 95

  Skin autoimmune disorders NEC                                    27           0                 186

  Rheumatoid arthropathies                                         17           1                 153

  Rheumatoid arthritis and associated conditions                   17           1                 154

  Hyperglycaemic conditions NEC                                    92           34                728

  Arthropathies NEC                                                24           0                 417

  Lower respiratory tract neoplasms                                26           4                 393

  Lower gastrointestinal neoplasms benign                          10           2                 51

  Diabetic complications neurological                              15           4                 71

  Gastrointestinal stenosis and obstruction NEC                    114          11                1216

  Urinalysis NEC                                                   36           1                 149

  Digestive enzymes                                                23           2                 249

  Metabolic acidoses (excl diabetic acidoses)                      98           14                611

  Skeletal and cardiac muscle analyses                             66           1                 896

  Non-site specific injuries NEC                                   76           4                 1179

  Coronary necrosis and vascular insufficiency                     141          12                1555
  -------------------------------------------------------------------------------------------------------

**Table 1** Case counts of adverse events associated with DPP-4
inhibitors or GLP-1 receptor agonists.

![](media/image2.png)

**Figure 2** Odds ratios of the adverse events associated with DPP-4
inhibitors or GLP-1 receptor agonists.

The forest plot denotes odds ratios (ORs) with 99% confidence intervals
(CIs) for each event. Significant ORs with CIs are plotted.

![](media/image3.png)

**Figure 3** AIC improvements with a random effect.

The vertical axis of the lower scatter plot denotes AIC differences
calculated by subtracting that of the fixed model from that of the mixed
model. When the AIC difference is less than 0, the mixed model is
favored. The horizontal axis denotes total case counts for each MedDRA
HLT. The upper plot is the histogram of the lower plot.

##################### References

MedDRA. *Available at*
[*http://www.meddra.org/*](http://www.meddra.org/).

Pharmaceuticals and Medical Devices Agency. *Available at*
[*https://www.pmda.go.jp/*](https://www.pmda.go.jp/).

SQLite Home Page. *Available at*
[*https://www.sqlite.org/*](https://www.sqlite.org/).

Brewer T, and Colditz GA. 1999. Postmarketing surveillance and adverse
drug reactions: current perspectives and future needs. *Jama*
281:824-829. 10.1001/jama.281.9.824

Broström G. 2013. glmmML: Generalized linear models with clustering.

Burnham KP, and Anderson DR. 2002. *Model selection and multimodel
inference: a practical information-theoretic approach*: Springer Science
& Business Media.

Butler PC, Elashoff M, Elashoff R, and Gale EA. 2013. A critical
analysis of the clinical use of incretin-based therapies: Are the GLP-1
therapies safe? *Diabetes Care* 36:2118-2125. 10.2337/dc12-2713

Casals M, Girabent-Farres M, and Carrasco JL. 2014. Methodological
quality and reporting of generalized linear mixed models in clinical
medicine (2000-2012): a systematic review. *PLoS One* 9:e112653.
10.1371/journal.pone.0112653

Devaraj S, and Maitra A. 2014. Pancreatic safety of newer incretin-based
therapies: are the "-tides" finally turning? *Diabetes* 63:2219-2221.
10.2337/db14-0545

Egan AG, Blind E, Dunder K, de Graeff PA, Hummer BT, Bourcier T, and
Rosebraugh C. 2014. Pancreatic safety of incretin-based drugs--FDA and
EMA assessment. *N Engl J Med* 370:794-797. 10.1056/NEJMp1314078

Elashoff M, Matveyenko AV, Gier B, Elashoff R, and Butler PC. 2011.
Pancreatitis, pancreatic, and thyroid cancer with glucagon-like
peptide-1-based therapies. *Gastroenterology* 141:150-156.
10.1053/j.gastro.2011.02.018

Gibbons RD, Amatya AK, Brown CH, Hur K, Marcus SM, Bhaumik DK, and Mann
JJ. 2010. Post-approval drug safety surveillance. *Annu Rev Public
Health* 31:419-437. 10.1146/annurev.publhealth.012809.103649

Gibbons RD, Segawa E, Karabatsos G, Amatya AK, Bhaumik DK, Brown CH,
Kapur K, Marcus SM, Hur K, and Mann JJ. 2008. Mixed-effects Poisson
regression analysis of adverse event reports: the relationship between
antidepressants and suicide. *Stat Med* 27:1814-1833. 10.1002/sim.3241

Harpaz R, DuMouchel W, Shah NH, Madigan D, Ryan P, and Friedman C. 2012.
Novel data-mining methodologies for adverse drug event discovery and
analysis. *Clin Pharmacol Ther* 91:1010-1021. 10.1038/clpt.2012.50

Larsen K, Petersen JH, Budtz-Jorgensen E, and Endahl L. 2000.
Interpreting parameters in the logistic regression model with random
effects. *Biometrics* 56:909-914. 10.1111/j.0006-341X.2000.00909.x

Li B, Lingsma HF, Steyerberg EW, and Lesaffre E. 2011. Logistic random
effects regression models: a comparison of statistical packages for
binary and ordinal outcomes. *BMC Med Res Methodol* 11:77.
10.1186/1471-2288-11-77

Li L, Shen J, Bala MM, Busse JW, Ebrahim S, Vandvik PO, Rios LP, Malaga
G, Wong E, Sohani Z, Guyatt GH, and Sun X. 2014. Incretin treatment and
risk of pancreatitis in patients with type 2 diabetes mellitus:
systematic review and meta-analysis of randomised and non-randomised
studies. *BMJ* 348:g2366. 10.1136/bmj.g2366

MacLehose RF, and Hamra GB. 2014. Applications of Bayesian Methods to
Epidemiologic Research. *Current Epidemiology Reports* 1:103-109.
10.1007/s40471-014-0019-z

Nauck MA. 2011. Incretin-based therapies for type 2 diabetes mellitus:
properties, functions, and clinical implications. *Am J Med* 124:S3-18.
10.1016/j.amjmed.2010.11.002

Nauck MA. 2013. A critical analysis of the clinical use of
incretin-based therapies: The benefits by far outweigh the potential
risks. *Diabetes Care* 36:2126-2132. 10.2337/dc12-2504

Nomura K, Takahashi K, Hinomura Y, Kawaguchi G, Matsushita Y, Marui H,
Anzai T, Hashiguchi M, and Mochizuki M. 2015. Effect of database profile
variation on drug safety assessment: an analysis of spontaneous adverse
event reports of Japanese cases. *Drug Des Devel Ther* 9:3031-3041.
10.2147/DDDT.S81998

R Core Team. 2015. R: A Language and Environment for Statistical
Computing. Vienna, Austria.

Raschi E, Piccinni C, Poluzzi E, Marchesini G, and De Ponti F. 2013. The
association of pancreatitis with antidiabetic drug use: gaining insight
through the FDA pharmacovigilance database. *Acta Diabetol* 50:569-577.
10.1007/s00592-011-0340-7
