makelab
--------------

### What is this?

makelab is a utility (the MATLAB&copy; Way would be to call it a
toolbox) that operates much like Unix's make, but within the MATLAB,
and as an added bonus, GNU Octave, shell.
If you have a numerical computation to do that takes a lot of time and
has a lot of interlocking dependencies, all you have to do is tell these
to makelab, and it will calculate any target you want.  As an added bonus,
if the dependencies are modular enough, changing the parameters or some
component of your computation and re-making will only require recomputing
the parts it needs to.  Like Unix make does.

One could similarly use make, combined with marshalling data in to and out
of MATLAB, to acheive the same effect, but it would be much less elegant.

### Installation

Run ./makemake.sh, this should build the .mex files needed. Then add the makelab
directory to your path somehow.

### How do I use it?

1.  use `addrule` or `rule` to add information about how to build targets, including the files, variables, and other targets it depends on.
2.  use `make` to make your targets.
3.  do things, edit files, etc.
4.  use `make` again to remake your targets.
5.  *(Optional:)* use `touch` if you think something should be remade but it isn't happening.

Each function's built-in documentation comes with more details.

#### An example:

     % The basic syntax for a target X that depends on targets Y and Z,
     % files file1.m and data.mat, and variable q, and is built by running the command 'makeX' is:
     % rule X @Y @Z #file1.m #data.mat &q : makeX ;
     % '!' is a shortcut for a rule X depending on X.m, and building the target by running X.
     rule toolboxes ! ;
     rule params @toolboxes #parameters.m : parameters ;
     rule extraparams &bar : foo = bar * 5 ;
     rule test1 @params ! ;
     rule test2 @params @extraparams #test2.m : test2(foo) ;
     rule comparison @test1 @test2 : plot(results1 - results2) ;

     % makes toolboxes, params, extraparams, test1, test2, and comparison:
     make comparison;
     bar = 7;
     % only makes extraparams, test2, and comparison:
     make comparison;

