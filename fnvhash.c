#include "mex.h"
#include "matrix.h"

#define FNV_BASIS 14695981039346656037ULL
#define FNV_PRIME 1099511628211ULL

const mwSize dims[] = {1};

void mexFunction(int nlhs, mxArray * plhs[],
		 int nrhs, const mxArray *prhs[]) {
    
    unsigned long long * output;
    unsigned long long h;
    int sz, szr, szi;
    unsigned char * pr = (unsigned char*) mxGetPr(prhs[0]);
    unsigned char * pi = (unsigned char*) mxGetPi(prhs[0]);
    double * dp = mxGetPr(prhs[1]);
    szr = dp[0]; szi = 0;
    if (mxIsComplex(prhs[0])) szi = szr;

    plhs[0] = mxCreateNumericArray(1,dims,mxINT64_CLASS,mxREAL);
    output = (unsigned long long *)mxGetData(plhs[0]);
    
    int i;
    h = FNV_BASIS;
    for (i = 0; i < szr; i++, pr++) {
      h ^= (unsigned long long)(*pr);
      h *= FNV_PRIME;
    }
    for (i = 0; i < szi; i++, pi++) {
      h ^= (unsigned long long)(*pi);
      h *= FNV_PRIME;
    }

    *output = h;
}
