#include "mex.h"
#include "matrix.h"
#include <sys/stat.h>

#define OSX

const mwSize dims[] = {13};

void mexFunction(int nlhs, mxArray * plhs[],
		 int nrhs, const mxArray *prhs[]) {
    
    long long * output;
    struct stat s;
    int res;
    char * path;

    path = mxArrayToString(prhs[0]);
    res = stat(path, &s);
    if (res) {
	mexErrMsgIdAndTxt("MATLAB:stat:FileNotFound",
			  "'%s' was not found.", path);
    }
    else {
	plhs[0] = mxCreateNumericArray(1,dims,mxINT64_CLASS,mxREAL);
	output = (long long *)mxGetData(plhs[0]);
	output[0] = s.st_dev;
	output[1] = s.st_ino;
	output[2] = s.st_mode;
	output[3] = s.st_nlink;
	output[4] = s.st_uid;
	output[5] = s.st_gid;
	output[6] = s.st_rdev;
	output[7] = s.st_size;
#ifdef OSX
	output[8] = s.st_atimespec.tv_sec;
	output[9] = s.st_mtimespec.tv_sec;
	output[10] = s.st_ctimespec.tv_sec;
#else
	output[8] = s.st_atime;
	output[9] = s.st_mtime;
	output[10] = s.st_ctime;
#endif
	output[11] = s.st_blksize;
	output[12] = s.st_blocks;
    }
}
