function s = addrule(target,deps,fdeps,rule,mfname)
% function addrule(target,deps,fdeps,rule,mfname)
%
% Adds a rule to a makefile. Make sure the makefile is global.
%
% in:
%	target; name of target being added - if the target exists
%		it gets clobbered (unless force == 0)
%	deps; cell array of other targets this depends on
%	fdeps; cell array of filenames this depends on
%	rule; string that will build the target when evaluated
%	mfname; optional, default 'makefile'; makefile to use
%
% out: 0 if the rule was added and didn't exist
%      1 if the rule replaced a previous rule
%      2 if the rule already existed and was identical
%
    if nargin < 5; mfname = 'makefile'; end
    % common pattern:
    % expand addrule('x',{'y'}) to addrule('x',{'y'},{'x.m'},'x')
    if nargin == 2
        addrule(target,deps,{[target, '.m']},target);
        return;
    end
    if nargin < 4; help(mfilename); error(mfilename); return; end
    
    mf = evalin('base', mfname);
    same = 0;
    s = 0;
    if isfield(mf,target)
        s = 1;
        cur = mf.(target);
        same = isequal(cur.deps,deps) && ...
               isequal(cur.fdeps,fdeps) && ...
               isequal(cur.rule,rule);
    end
    if not(same)
        mf.(target).deps = deps;
        mf.(target).fdeps = fdeps;
        mf.(target).rule = rule;
        mf.(target).timestamp = 0;
        assignin('base', mfname, mf);
    else
        s = 2;
    end