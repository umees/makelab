#!/bin/sh

matlab -nojvm <<EOF > /dev/null 2> /dev/null
f = fopen('/tmp/matlabroot','w');
fprintf(f,'%s',matlabroot);
fclose(f);
EOF

MATLAB_ROOT=`cat /tmp/matlabroot`
MEX_PATH=$MATLAB_ROOT/bin/mex

$MEX_PATH stat.c -o stat_mex
$MEX_PATH gettimeofday.c -o gettimeofday_mex