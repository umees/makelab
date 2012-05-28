#!/bin/sh

if [ ! -f arch.h ]; then
    echo "*** this will not build without a file called 'arch.h'"
    echo "if this is OSX, create one with just the line '#define OSX'"
    echo "otherwise just create an empty file."
    exit
fi

matlab -nojvm <<EOF > /dev/null 2> /dev/null
f = fopen('/tmp/matlabroot','w');
fprintf(f,'%s',matlabroot);
fclose(f);
EOF

MATLAB_ROOT=`cat /tmp/matlabroot`
MEX_PATH=$MATLAB_ROOT/bin/mex

$MEX_PATH stat.c -o stat_mex
$MEX_PATH gettimeofday.c -o gettimeofday_mex
