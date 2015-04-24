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
    real q[L];
}
model {
  alpha ~ normal(0, 100);
  beta ~ normal(0, 100);
  sigma ~ uniform(0, 10000);
  for (j in 1:L)
    q[j] ~ normal(0, sigma);
  for (i in 1:N)
    y[i] ~ bernoulli_logit(alpha + dot_product(x[i], beta) + q[t[i]]);
}
