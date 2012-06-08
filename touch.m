function status = touch(target,mfname)
% function status = touch(target,mfname)
%
% Touches a target in a makefile, marking it dirty and in need of
% re-making.
%
% in:
%	target; name of target to touch
%	mfname; optional, default 'makefile'; makefile to use
%
% out:
%	status; -1 if the target doesn't exist, 0 on success
%
    if nargin < 2; mfname = 'makefile'; end
    if nargin < 1; help(mfilename); error(mfilename); return; end
    mf = evalin('base',mfname);
    if not(isKey(mf,target))
        status = -1;
        fprintf('no such target: %s\n',target);
    else
        mf(target).timestamp = 0;
        status = 0;
        assignin('base',mfname,mf);
    end