% this code is used for all the trash code that I'm not using but may still
% be useful. I will have a catalog at the beginning of the code, and will
% write down the date I add them in.
% 1. Aug 29 24, Traverse the TlisD.Photodiode_event to find the matched pdd time
% 2. Jan 21 25, Remove the last one if total number is odd

%% 1. Traverse the TlisD.Photodiode_event to find the matched pdd time
traverse the TlisD.Photodiode_event
for iPdd = 1:length(TlisD.photodiode_event{iTrial})
    diffTemp = []; % the temporal variable of diff bt sending time and pdd time
    diffTemp = Dataf.FlagTimeAl{iTrial}(:,2) - TlisD.photodiode_event{iTrial}(iPdd);
    find the max neg value is the location of pdd time
    pddLoc = find(diffTemp == max(diffTemp(diffTemp<0)));
    pddshift = abs(diffTemp(pddLoc)); % record the shift time in abs value
    set a value restriction and if na value write in this row of the 3rd colomn
    the restriction is set between 40 and 120 ms
    if pddshift <= 120 && isnan(Dataf.FlagTimeAl{iTrial}(pddLoc,3))
        Dataf.FlagTimeAl{iTrial}(pddLoc,3) = TlisD.photodiode_event{iTrial}(iPdd);
    end
end

%% 2. Remove the last one if total number is odd
if (mod(sum(stateCheck),2)==1 && length(pddTlisD)-sum(stateCheck)==1) || ...
        (mod(length(pddTlisD),2) == 1 && length(pddTlisD)-sum(stateCheck)==1)
    Datax.FlagTimeAl{iTrial}(stateCheck,3) = pddTlisD(1:end-1);
elseif sum(stateCheck) == length(pddTlisD)
    Datax.FlagTimeAl{iTrial}(stateCheck,3) = pddTlisD;
end