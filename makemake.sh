#!/bin/sh

if [ ! -f arch.h ]; then
    echo "*******************************************";
    echo "to build this, add a file called 'arch.h';"
    echo "if on OSX, make it's contents simply:";
    echo "#define OSX";
    echo "otherwise, on Linux, leave it blank.";
    echo "*******************************************";
    exit;
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
$MEX_PATH fnvhash.c -o fnvhash_mex
