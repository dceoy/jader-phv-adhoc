data {
    int<lower=0> N;
    int<lower=0> M;
    int<lower=0> L;
    int<lower=0> K;
    int<lower=0, upper=1> y[N];
    matrix[N, M] x;
    int<lower=0> d[N];
    int<lower=0> t[N];
}
parameters {
    real alpha;
    vector[M] beta;
    real sigma_s;
    real sigma_q;
    real rs[L];
    real rq[K];
}
model {
  alpha ~ normal(0, 100);
  beta ~ normal(0, 100);
  sigma_s ~ uniform(0, 10000);
  sigma_q ~ uniform(0, 10000);
  rs ~ normal(0, sigma_s);
  for (j in 1:K)
    if (j < 3)
      rq[j] ~ normal(0, sigma_q);
    else
      rq[j] ~ normal(2 * rq[j - 1] - rq[j - 2], sigma_q);
  for (i in 1:N)
    y[i] ~ bernoulli_logit(alpha + dot_product(x[i], beta) + rs[d[i]] + rq[t[i]]);
}
