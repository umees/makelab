#include "mex.h"
#include <sys/time.h>

void mexFunction(int nlhs, mxArray * plhs[],
		 int nrhs, const mxArray *prhs[]) {
  
    double * output;
    struct timeval tv;
    
    gettimeofday(&tv, NULL);
    //printf("%d %d %d\n",nlhs,tv.tv_sec,tv.tv_usec);
    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
    plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
    output = mxGetPr(plhs[0]);
    output[0] = tv.tv_sec;
    output[0] += ((double)(tv.tv_usec) * 1e-6);
    //output = mxGetPr(plhs[1]);
    //output[0] = tv.tv_usec;
}
