makelab
--------------

### What is this?

makelab is a utility (I guess the MATLAB&copy; Way would be to call it a
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

### How do I use it?

makelab comes with 3 functions---addrule, make, and touch, used in that
order.

*	addrule adds information about how to build a specific target.
	It takes the name of the target, its dependencies on other targets,
	its dependencies on other files, and a rule, that's just a string
	eventually passed to eval() that specifies how to actually build the
	target.

*	make takes the name of a target and builds it. It's the name of the show.

*	touch marks a target as needing a re-build.  Given that MATLAB variables
	don't carry around modification times, if a target ultimately
	has no file dependencies,
	changing something that would require the target to be rebuilt should
	be followed by a touch to mark it.  Changing files *will* work 
	correctly as in Unix make.

Each function's built-in documentation comes with more details.

#### An example:

	global makefile;
	addrule('toolboxes',{},{},...
		'd = pwd; cd (''~/toolboxes''); setup; cd(d);')
	addrule('params',{'toolboxes'},{'params.m'},'params')
	addrule('extraparams',{},{},'foo = bar * 5;')
	addrule('test1',{'params'},{'test1.m'},'test1')
	addrule('test2',{'params','extraparams'},{'test2.m'},'test2(foo)')
	addrule('plot1',{'test1'},{},'plot(results1)') % test1.m makes results1
	addrule('comparison',{'test1','test2'},{},...
		'plot(results1 - results2)');

	make comparison;
	bar = 7;
	touch extraparams;
	make comparison;
	% remakes extraparams, test2, and comparison,
    % but NOT test1, params, or toolboxes.

TODO: document this more.  Hopefully this with the actual function docs is
somewhat self-explanatory.
