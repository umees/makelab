function status = make(target,mfname,dlvl,depth,parents)
% function status = make(target,mfname,dlvl,depth)
% 
% Makes a specific target, resolving dependencies and building anything
% not up to date.
%
% in:
%	target; name of the target to build
%	mfname; makefile name, optional, default 'makefile'.  Note that this isn't
%		actually a file, but rather the name of a variable containing
%		information about build dependencies.  The variable is assumed
%		to be (and should be!) global.
%	dlvl; debug level, optional, default 1.
%		0: No information except errors, probably too little.
%		1: Various and sundry information, a comfortable amount
%		2: More information, probably too much.
%	depth; depth into the dependency tree, please omit, it's really
%		unused and defaults to 0.
%	parents; used to detect circular deps, please omit.
%
% out:
%	-1: error somewhere in the build tree
%	>0: success, unix time that the build is up-to-date to
%

	if exist('OCTAVE_VERSION')
		is_octave = 1;
	else
		is_octave = 0;
	end


	if nargin < 5; parents = {}; end
	if nargin < 4; depth = 0; end
	if nargin < 3; dlvl = 1; end
	if nargin < 2; mfname = 'makefile'; end
	if nargin < 1; help(mfilename); error(mfilename); return; end
	eval(['global ', mfname, ';'])

	pi = @() putindent(depth*0);
	
	if incell(parents, target)
		status = -2;
		if (dlvl >= 0)
			pi();
			fprintf('circular dependency involving %s, aborting.\n',target);
		end
		return;
	end

	if not(eval(['isfield(', mfname, ',target)']))
		status = -1;
		if (dlvl >= 0)
			pi();
			fprintf('no such target ''%s'', aborting.\n',target);
		end
		return;
	end

	tptr = [mfname, '.', target];
	ttptr = [tptr, '.timestamp'];
	tt = eval(ttptr);
	clean = 1;
	deps = eval([tptr '.deps'],'{}');
	dr = zeros(length(deps),1);
	if (dlvl >= 1); pi(); fprintf('making %s...\n', target); end
	for i = 1:length(deps)
		if (dlvl >= 2); pi(); fprintf('%s making %s...\n', target, deps{i}); end
		parents{length(parents) + 1} = target;
		dr(i) = make(deps{i},mfname,dlvl,depth+1,parents);
		if dr(i) < 0
			if (dlvl >= 1); pi(); fprintf('error %d making %s\n',dr(i),target); end
		end
	end
	% if all are in (0, timestamp) then we are up-to-date; return timestamp
	% if any are <0; error, we can't build, return -1
	% if all are >0 but some are >timestamp then we should build
	%	and return (time) if it worked, -1 if it didn't
	fdeps = eval([tptr '.fdeps'],'{}');
	fdr = zeros(length(fdeps),1);
	for i = 1:length(fdeps)
		if is_octave % this version is probably more reliable
			[s,e] = stat(fdeps{i});
			mt = s.mtime;
		else % hacky matlab way, ideally this should be a .mex maybe
			[status,out] = unix(['stat -c %Y ', fdeps{i}]);
			e = status;
			mt = str2num(out);
		end
		if e == 0
			fdr(i) = mt;
		else
			fdr(i) = -1;
			if (dlvl >= 0)
				pi(); fprintf('error making %s: file "%s" not found\n', target, fdeps{i});
			end
		end
	end
	results = [dr; fdr];
	err = any(results < 0);
	dirty = any(results >= tt) || tt == 0; %% assume tt = 0 implies it is unmade
	if err
		status = -1;
		if (dlvl >= 1); pi(); fprintf('not making %s.\n', target); end
	elseif dirty
		if (dlvl >= 1); pi(); fprintf('making %s...\n', target); end
		try	
			evalin('base', eval([tptr '.rule']))
			if is_octave
				tt = time;
			else
				[status, out] = unix('date +%s');
				tt = str2num(out);
			end
			eval(sprintf('%s = %f;',ttptr,tt));
			status = tt;
		catch err
			eval([ttptr ' = 0;']);
			if (dlvl >= 0)
				pi(); fprintf('*** error making %s:\n', target);
				pi(); fprintf('******************************\n\n');
				if is_octave
					pi(); fprintf('%s\n\n',lasterr());
				else
					pi(); fprintf('%s\n\n',getReport(err));
				end
				pi(); fprintf('******************************\n');
			end
			status = -1;
		end
	else
		if (dlvl >= 1); pi(); fprintf('nothing to do for %s...\n', target); end
		status = tt;
	end

function putindent(n)
	for i = 1:n
		fprintf('  ');
	end

function r = incell(c, s)
	r = 0;
	for i = c
		if strcmp(i, s)
			r = 1;
			return
		end
	end
