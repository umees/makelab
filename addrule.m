function s = addrule(target,deps,fdeps,rule,force,mfname)
% function addrule(target,deps,fdeps,rule,force,mfname)
%
% Adds a rule to a makefile. Make sure the makefile is global.
%
% in:
%	target; name of target being added - if the target exists
%		it gets clobbered (unless force == 0)
%	deps; cell array of other targets this depends on
%	fdeps; cell array of filenames this depends on
%	rule; string that will build the target when evaluated
%	force; optional, default 1;
%		clobber the original rule if it exists, otherwise
%		do nothing.
%	mfname; optional, default 'makefile'; makefile to use
%
% out: 0 if the rule was added and didn't exist
%      1 if the rule replaced a previous rule
%      2 if nothing happened because force = 0
%
	if nargin < 6; mfname = 'makefile'; end
	if nargin < 5; force = 1; end
	if nargin < 4; help(mfilename); error(mfilename); return; end
	eval(['global ', mfname, ';'])
	if eval(['isfield(', mfname, ',target)'])
		s = 1;
		if force == 0
			s = 2;
			return;
		end
	end
	t.deps = deps;
	t.fdeps = fdeps;
	t.rule = rule;
	t.timestamp = 0;
	eval([mfname, '.', target, ' = t;']);
