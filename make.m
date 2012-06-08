function [status, omf, vtable] = make(target,mfname,dlvl,depth,parents,imf,vtable)
% function status = make(target,mfname,dlvl,depth)
% 
% Makes a specific target, resolving dependencies and building anything
% not up to date.
%
% in:
%	target; name of the target to build
%	mfname; makefile name, optional, default 'makefile'.  Note that this isn't
%		actually a file, but rather the name of a variable containing
%		information about build dependencies.
%	dlvl; debug level, optional, default 1.
%		0: No information except errors, probably too little.
%		1: Various and sundry information, a comfortable amount
%		2: More information, probably too much.
%
% out:
%	-1: error somewhere in the build tree
%	>0: success, unix time that the build is up-to-date to
%

    mstart = tic;
    
    if exist('OCTAVE_VERSION')
        is_octave = 1;
    else
        is_octave = 0;
    end

    if nargin < 7; vtable = containers.Map(); end
    if nargin < 6; imf = {}; end
    if nargin < 5; parents = {}; end
    if nargin < 4; depth = 0; end
    if nargin < 3; dlvl = 1; end
    if nargin < 2; mfname = 'makefile'; end
    if nargin < 1; help(mfilename); error(mfilename); return; end
    
    if ischar(mfname)
        mf = evalin('base',mfname);
    else
        mf = imf;
    end

    pi = @() putindent(depth*1);
    
    %% Check errors:
    if incell(parents, target)
        status = -2;
        if (dlvl >= 0)
            if (dlvl >= 2); pi(); end
            fprintf('circular dependency involving %s, aborting.\n',target);
        end
        return;
    end

    if not(isKey(mf,target))
        status = -1;
        if (dlvl >= 0)
            if (dlvl >= 2); pi(); end
            fprintf('no such target ''%s'', aborting.\n',target);
        end
        return;
    end

    %% Build all subtargets:
    tinfo = mf(target);
    clean = 1;
    try; deps = tinfo.deps; catch; deps = {}; end
    dr = zeros(length(deps),1);
    if (dlvl >= 2); pi(); fprintf('looking at %s:\n', target); end
    for i = 1:length(deps)
        if (dlvl >= 2); pi(); fprintf('%s making %s...\n', target, deps{i}); end
        parents{length(parents) + 1} = target;
        [dr(i), mf, vtable] = make(deps{i},0,dlvl,depth+1,parents,mf,vtable);
        if dr(i) < 0
            if (dlvl >= 1)
                if (dlvl >= 2); pi(); end
                fprintf('error %d making %s\n',dr(i),target);
            end
        end
    end
    
    % if all are in (0, timestamp) then we are up-to-date; return timestamp
    % if any are <0; error, we can't build, return -1
    % if all are >0 but some are >timestamp then we should build
    %	and return (time) if it worked, -1 if it didn't
    
    try; fdeps = tinfo.fdeps; catch; fdeps = {}; end
    fdr = file_update_times(fdeps,dlvl,pi);

    if (dlvl >= 3)
        fprintf('in making %s, results are:\n',target);
        results = int32([dr; fdr])
        fprintf('and current time tt is %d for %s.\n',tinfo.timestamp,target);
    end
    results = [dr; fdr];
    
    err = any(results < 0);
    dirty = any(results > tinfo.timestamp) || tinfo.timestamp == 0; %% assume t = 0 implies it is unmade
    if not(dirty)
        [dirty, vtable] = variables_dirty(mf(target).vdeps,vtable);
    end
    
    if err
        status = -1;
        if (dlvl >= 2); pi(); fprintf('not making %s.\n', target); end
    elseif dirty
        if (dlvl >= 1)
            if (dlvl >= 2); pi(); end
            fprintf('now making \033[1m%s\033[0m: ', target);
            if (dlvl >= 2); fprintf('\n'); end
        end
        try
            tic;
            evalin('base', tinfo.rule);
            if (dlvl >= 3); pi(); fprintf('getting timestamp for %s now!...',target); end;
            t = toc;
            if is_octave
                tt = time;
            else
                tt = gettimeofday_mex;
            end
            if (dlvl >= 3); pi(); fprintf('it is %d.\n',tt); end;
            mf(target) = setfield(mf(target),'timestamp', tt);
            mf(target) = setfield(mf(target),'vdeps',rehash_vars(mf(target).vdeps));
            status = tt;
            tall = toc(mstart);
            if (dlvl >= 1)
                if (dlvl >= 2); pi(); end
                fprintf('made %s in %0.3f s (%0.3f s with dependencies).\n',...
                        target,t,tall);
            end
        catch err
            mf(target) = setfield(mf(target),'timestamp', 0);
            if (dlvl >= 0)
                pi(); fprintf('\n\n*** error making %s:\n', target);
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
        if (dlvl >= 2 || (dlvl >= 1 && depth == 0))
            pi(); fprintf('nothing to do for %s.\n', target);
        end
        status = tinfo.timestamp;
    end
    if ischar(mfname)
        assignin('base',mfname,mf);
    else
        omf = mf;
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

function fdr = file_update_times(fdeps,dlvl,pi)
    fdr = zeros(length(fdeps),1);
    e = 0;
    for i = 1:length(fdeps)
        if exist('OCTAVE_VERSION') % this version is probably more reliable
            [s,e] = stat(fdeps{i});
            mt = s.mtime;
        else
            try
                st = stat_mex(fdeps{i});
                mt = st(10);
                e = 0;
            catch
                e = 1;
            end
        end
        if e == 0
            fdr(i) = mt;
        else
            fdr(i) = -1;
            if (dlvl >= 0)
                if (dlvl >= 2); pi(); end
                fprintf('error making %s: file "%s" not found\n', target, fdeps{i});
            end
        end
    end
    
function [d,ovtable] = variables_dirty(vdeps,vtable)
    vks = vdeps.keys;
    d = 0;
    out = {};
    ovtable = vtable;
    for i = 1:length(vdeps)
        vk = vks{i};
        vd = vdeps(vk);
        if vd{1} == 0 % pre-marked dirty
            d = 1;
            return;
        elseif vd{1} == 1 % 
            if isKey(ovtable, vk) % we have a cached current value for this variable's hash
                if vd{2} ~= ovtable(vk) % dirty
                    d = 1;
                    return;
                end
            else % no cache, rehash
                [hh,stat] = fnvhash(evalin('base',vk));
                % this is not really needed, but maybe:
                %-------------------------
                %if stat == -1 % only happens if var was hashable b4 and then replaced
                %    warning('The variable %s is unhashable, and will not be used to calculate dependencies',vk);
                %    out{1} = 2;
                %else
                %-------------------------
                if stat == 0
                    ovtable(vk) = hh;
                    if vd{2} ~= hh
                        d = 1;
                        return;
                    end
                end
            end
        elseif vd{1} == 2
            % do nothing, this is marked unhashable.
        else
            d = 1;
            error(sprintf('guru meditation #%d',vd{1}));
            return;
        end
    end