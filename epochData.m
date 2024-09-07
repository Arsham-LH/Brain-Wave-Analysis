function [old_eventsMat, epochData_struct] = epochData(epochParams, raw_eventsMat, eventsType, Fs, dataset, filtData_struct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% epochParams: a struct containing befEventTime, afteEventTime, react_befEventTime, react_aftEventTime

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Epoching

    befEventTime = epochParams.befEventTime;
    aftEventTime = epochParams.aftEventTime;
    react_befEventTime = epochParams.react_befEventTime;
    react_aftEventTime = epochParams.react_aftEventTime;
    rest_befEventTime = epochParams.rest_befEventTime;
    rest_aftEventTime = epochParams.rest_aftEventTime;

    base_befEventTime = epochParams.base_befEventTime;
    base_aftEventTime = epochParams.base_aftEventTime;

    
    %**********Defining an older version for eventsMat, which can be used in epoching function
    old_eventsMat = raw_eventsMat(:,[2,3]);
    old_eventsMat(old_eventsMat(:,2) == eventsType.rightRespType | old_eventsMat(:,2) == eventsType.leftRespType, 2) = eventsType.reactionType; %Changing left/right reaction types into a single 'reaction' type
    %**********************
    base_step = ((old_eventsMat(1,1)-base_aftEventTime-1/Fs) - base_befEventTime) / 180; % Setting a step value such that almost 180 windows are created
    base_eventTimes = base_befEventTime + base_step : base_step : (old_eventsMat(1,1)-base_aftEventTime-1/Fs);

    epochData_struct = [];

    epochData_struct.unfiltered_epoched_data = epoching(dataset.', befEventTime, aftEventTime, Fs, old_eventsMat, eventsType.excitType);
    epochData_struct.unfiltered_epochedOnReact_data = epoching(dataset.', react_befEventTime, react_aftEventTime, Fs, old_eventsMat, eventsType.reactionType);
    epochData_struct.unfiltered_epochedOnRest_data = epoching(dataset.', rest_befEventTime, rest_aftEventTime, Fs, old_eventsMat, eventsType.restType);

    epochData_struct.unfiltered_epochedOnBase_data = ...
    epochingGivenEvents(dataset.', base_befEventTime, ...
    base_aftEventTime, Fs, base_eventTimes);
    
    epochData_struct.epoched_data=epoching(filtData_struct.filtered_data1, befEventTime, aftEventTime,Fs,old_eventsMat, eventsType.excitType);
    epochData_struct.epochedOnReact_data = epoching(filtData_struct.filtered_data1, react_befEventTime, react_aftEventTime,Fs,old_eventsMat, eventsType.reactionType);
    
    
    notEpoched_inst_phase0 = inst_phase_cal(filtData_struct.filtered_data0,1); %dimension= samples*channels
    notEpoched_inst_phase = inst_phase_cal(filtData_struct.filtered_data1,1); %dimension= samples*channels
    notEpoched_inst_phase2 = inst_phase_cal(filtData_struct.filtered_data2,1); %dimension= samples*channels
    notEpoched_inst_phase3 = inst_phase_cal(filtData_struct.filtered_data3,1); %dimension= samples*channels
    
    epochData_struct.inst_phase0 = epoching(notEpoched_inst_phase0, befEventTime, aftEventTime,Fs,old_eventsMat, eventsType.excitType); %dimension= samples*channels*trials
    epochData_struct.inst_phase = epoching(notEpoched_inst_phase, befEventTime, aftEventTime,Fs,old_eventsMat, eventsType.excitType); %dimension= samples*channels*trials
    epochData_struct.inst_phase2 = epoching(notEpoched_inst_phase2, befEventTime, aftEventTime,Fs,old_eventsMat, eventsType.excitType); %dimension= samples*channels*trials
    epochData_struct.inst_phase3 = epoching(notEpoched_inst_phase3, befEventTime, aftEventTime,Fs,old_eventsMat, eventsType.excitType); %dimension= samples*channels*trials
        
    epochData_struct.inst_phase_react0 = epoching(notEpoched_inst_phase0, react_befEventTime, react_aftEventTime,Fs,old_eventsMat, eventsType.reactionType); %dimension= samples*channels*trials
    epochData_struct.inst_phase_react = epoching(notEpoched_inst_phase, react_befEventTime, react_aftEventTime,Fs,old_eventsMat, eventsType.reactionType); %dimension= samples*channels*trials
    epochData_struct.inst_phase_react2 = epoching(notEpoched_inst_phase2, react_befEventTime, react_aftEventTime,Fs,old_eventsMat, eventsType.reactionType); %dimension= samples*channels*trials
    epochData_struct.inst_phase_react3 = epoching(notEpoched_inst_phase3, react_befEventTime, react_aftEventTime,Fs,old_eventsMat, eventsType.reactionType); %dimension= samples*channels*trials
    
    epochData_struct.inst_phase_base = epochingGivenEvents(notEpoched_inst_phase, base_befEventTime, base_aftEventTime, Fs, base_eventTimes);
    epochData_struct.inst_phase_base2 = epochingGivenEvents(notEpoched_inst_phase2, base_befEventTime, base_aftEventTime, Fs, base_eventTimes);
    epochData_struct.inst_phase_base3 = epochingGivenEvents(notEpoched_inst_phase3, base_befEventTime, base_aftEventTime, Fs, base_eventTimes);
end