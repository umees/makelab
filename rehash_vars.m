function ovdeps = rehash_vars(vdeps)
    ovdeps = vdeps;
    vks = ovdeps.keys;
    for i = 1:length(vdeps)
        vk = vks{i};
        vd = ovdeps(vk);
        
        try
            [hh, stat] = fnvhash(evalin('base',vk));
        catch
            stat = -2;
        end
        
        if stat == 0
            ovdeps(vk) = {1, hh};
        else
            warning('The variable %s is unhashable, and will not be used to calculate dependencies',vk);
            ovdeps(vk) = {2, 0};
        end
    end
    