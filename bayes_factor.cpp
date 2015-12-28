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
NumericVector bayes_factor(NumericVector v, int n = 10000) {
  return NumericVector::create(
    _["a"] = v[0],
    _["b"] = v[1],
    _["c"] = v[2],
    _["d"] = v[3],
    _["bf"] = bf(v, n)
  );
}
