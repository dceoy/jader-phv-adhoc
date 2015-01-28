data {
    int<lower=0> N;
    int<lower=0> M;
    matrix[N, M] x;
    int<lower=0, upper=1> y[N];
}
parameters {
    real alpha;
    vector[M] beta;
}
//transformed parameters {
//    real<lower=0> tau;
//    tau <- pow(sigma, -2);
//    for (j in 1:J)
//      tau[j] <- pow(sigma[j], -2);
//}
model {
  for (i in 1:N)
    y[i] ~ bernoulli(inv_logit(alpha + dot_product(x[i], beta)));
//   y[i] ~ dbern(p[i]);
//   rr[i] ~ dnorm(0, tau[1]);
//   logit(p[i]) <- b0 + b1 * x1[i] + b2 * x2[i] + b3 * x3[i] + b4 * x4[i] + b5 * x5[i] + rr[i] + rs[si[i]];
// sigma ~ dunif(0, 1.0E+4);
// tau <- pow(sigma, -2);
// b0 ~ dnorm(0, 1.0E-4); // intercept
// b1 ~ dnorm(0, 1.0E-4); // dpp4_inihibitor
// b2 ~ dnorm(0, 1.0E-4); // glp1_agonist
// b3 ~ dnorm(0, 1.0E-4); // concomit
// b4 ~ dnorm(0, 1.0E-4); // age
// b5 ~ dnorm(0, 1.0E-4); // sex
// for (j in 1:N.suspected) {
//   rs[j] ~ dnorm(0, tau[2]);
// }
// for (m in 1:2) {
//   sigma[m] ~ dunif(0, 1.0E+4);
//   tau[m] <- pow(sigma[m], -2);
// }
}

