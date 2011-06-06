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
	eval(['global ', mfname, ';'])
	if not(eval(['isfield(', mfname, ',target)']))
		status = -1;
		printf('no such target: %s\n',target)
	else
		eval(sprintf('%s.%s.timestamp = 0;', mfname, target));
		status = 0;
	end
