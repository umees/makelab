function s = rule(varargin)

% states:
% 0 = waiting for rule name
% 1 = expecting a : or ;
% 2 = in parameter list (takes a rule name or ;)
state = 0;

rn = '';
deplist = {};

for arg = varargin
    arg = arg{1};
    switch state
        case 0
            rn = arg;
            state = 1;
        case 1
            if isequal(arg,':')
                state = 2;
            elseif isequal(arg,';')
                addrule(rn,{});
                rn = ''; state = 0;
            else
                error('expecting : or ; in ar!');
                s = -1;
                return;
            end
        case 2
            if isequal(arg,';')
                addrule(rn,deplist);
                rn = ''; deplist = {};
                state = 0;
            else
                deplist{length(deplist)+1} = arg;
            end
    end
end

if not(isequal(rn,''))
    addrule(rn,deplist);
end
