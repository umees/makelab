function addrule(target,deps,fdeps,rule,mfname)
% function addrule(target,deps,fdeps,rule,mfname)
%
% Adds a rule to a makefile. Make sure the makefile is global.
%
% in:
%	target; name of target being added - if the target exists
%		it gets clobbered.
%	deps; cell array of other targets this depends on
%	fdeps; cell array of filenames this depends on
%	rule; string that will build the target when evaluated
%	mfname; optional, default 'makefile'; makefile to use
%
% out: nothing
%
	if nargin < 5; mfname = 'makefile'; end
	if nargin < 4; help(mfilename); error(mfilename); return; end
	eval(['global ', mfname, ';'])
	t.deps = deps;
	t.fdeps = fdeps;
	t.rule = rule;
	t.timestamp = 0;
	eval([mfname, '.', target, ' = t;']);
