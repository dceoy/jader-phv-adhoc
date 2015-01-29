data {
    int<lower=0> N;
    int<lower=0> M;
    int<lower=0> L;
    int<lower=0, upper=1> y[N];
    matrix[N, M] x;
    int<lower=0> g[N];
}
parameters {
    real alpha;
    real rr[N];
    real rs[L];
    vector[M] beta;
    real sigma_r;
    real sigma_s;
}
model {
//  alpha ~ normal(0, 1.0e+2);
//  beta ~ normal(0, 1.0e+2);
//  sigma ~ uniform(0, 1.0e+4);
  rr ~ normal(0, sigma_r);
  rs ~ normal(0, sigma_s);
  for (i in 1:N)
    y[i] ~ bernoulli(inv_logit(alpha + dot_product(x[i], beta) + rr[i] + rs[g[i]]));
}
