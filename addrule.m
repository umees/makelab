function s = addrule(target,deps,fdeps,vdeps,rule,mfname)
% function addrule(target,deps,fdeps,vdeps,rule,mfname)
%
% Adds a rule to a makefile.
%
% in:
%  target; name of target being added - if the target exists
%      it gets clobbered (unless force == 0)
%  deps; cell array of other targets this depends on
%  fdeps; cell array of filenames this depends on
%  vdeps: cell array of variables this depends on
%
%  rule; string that will build the target when evaluated
%  mfname; optional, default 'makefile'; makefile to use
%
% out: 0 if the rule was added and didn't exist
%      1 if the rule replaced a previous rule
%      2 if the rule already existed and was identical
%
    if nargin < 6; mfname = 'makefile'; end
    % common pattern:
    % expand addrule('x',{'y'}) to addrule('x',{'y'},{'x.m'},'x')
    if nargin == 2
        addrule(target,deps,{[target, '.m']},{},target);
        return;
    end
    if nargin == 4; rule = vdeps; vdeps = {}; end
    if nargin < 4; help(mfilename); error(mfilename); return; end
    
    try
        mf = evalin('base', mfname);
    catch % assume that error means the mf doesn't exist
        mf = containers.Map();
    end
    
    same = 0;
    s = 0;
    if isKey(mf,target)
        s = 1;
        cur = mf(target);
        same = isequal(cur.deps,deps) && ...
               isequal(cur.fdeps,fdeps) && ...
               isequal(cur.vdeps,vdeps) && ...
               isequal(cur.rule,rule);
    end
    if not(same)
        st.deps = deps;
        st.fdeps = fdeps;
        st.rule = rule;
        st.timestamp = 0;
        if isequal(vdeps,{})
            st.vdeps = containers.Map();
        else
            st.vdeps = containers.Map(vdeps, cellfun(@(x) {0,0},vdeps,'UniformOutput',false));
        end
        mf(target) = st;
        assignin('base', mfname, mf);
    else
        s = 2;
    end