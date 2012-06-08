function rule(varargin)

rn = '';
deplist = {};
fdlist = {};
vdlist = {};
rule = '';

short = 0;

rn = varargin{1};
for i = 2:nargin
    a = varargin{i};
    if a(1) == '#'
        n = a(2:end);
        fdlist{length(fdlist)+1} = n;
    elseif a(1) == '@'
        n = a(2:end);
        deplist{length(deplist)+1} = n;
    elseif a(1) == '&'
        n = a(2:end);
        vdlist{length(vdlist)+1} = n;
    elseif a(1) == '!'
        short = 1;
        break;
    elseif a(1) == ':'
        break;
    end
end

pad = '';
for j = (i+1):nargin
    if strcmp(varargin{j},'$')
        w = ';';
    else
        w = varargin{j};
    end
    rule = [rule pad w];
    pad = ' ';
end

if short
    addrule(rn,deplist);
else
    addrule(rn,deplist,fdlist,vdlist,rule);
end
