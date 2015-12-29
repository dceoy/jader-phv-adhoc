// [[Rcpp::plugins("cpp11")]]
#include <Rcpp.h>
using namespace Rcpp;

double bf(NumericVector v, int n) {
  int h = sum(rbeta(n, 1 + v[0], 1 + v[1]) > rbeta(n, 1 + v[2], 1 + v[3]));

  if (h == n) {
    return R_PosInf;
  } else {
    return (double)h / (n - h);
  }
}

// [[Rcpp::export]]
NumericVector bayes_factor(NumericVector ct, int iter = 1000000) {
  return NumericVector::create(
    _["a"] = ct[0],
    _["b"] = ct[1],
    _["c"] = ct[2],
    _["d"] = ct[3],
    _["bf"] = bf(ct, iter)
  );
}
