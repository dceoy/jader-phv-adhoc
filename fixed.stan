data {
  int<lower=0> N;
  int<lower=0> M;
  int<lower=0, upper=1> y[N];
  matrix[N, M] x;
}
parameters {
  real alpha;
  vector[M] beta;
}
model {
  alpha ~ normal(0, 100);
  for (k in 1:M)
    beta[k] ~ normal(0, 100);
  for (i in 1:N)
    y[i] ~ bernoulli_logit(alpha + dot_product(x[i], beta));
}
generated quantities {
  vector[N] log_lik;
  for(i in 1:N)
    log_lik[i] <- bernoulli_logit_log(y[i], alpha + dot_product(x[i], beta));
}
