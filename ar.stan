data {
  int<lower=0> N;
  int<lower=0> M;
  int<lower=0> L;
  int<lower=0, upper=1> y[N];
  matrix[N, M] x;
  int<lower=0> t[N];
}
parameters {
  real alpha;
  vector[M] beta;
  real sigma;
  real r[L];
}
model {
  alpha ~ normal(0, 100);
  for (k in 1:M)
    beta[k] ~ normal(0, 100);
  sigma ~ uniform(0, 10000);
  r[1] ~ normal(0, sigma);
  for (j in 2:L)
    r[j] ~ normal(r[j - 1], sigma);
  for (i in 1:N)
    y[i] ~ bernoulli_logit(alpha + dot_product(x[i], beta) + r[t[i]]);
}
