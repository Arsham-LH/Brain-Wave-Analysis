function z = epochingGivenEvents(befTime, Fs, aftTime, eventTimes, data)
% assumption: data dimension = samples*channels
% assumption: epoched data dimension = samples*channels*trials
% eventTimes: a vector containing time points in data that should be considered as events

    befSamps = befTime*Fs - 1; %NOTE: -1 is the new change for this function (since August 2nd). This corrects the frequencies in FFT and any other frequency analysis
    aftSamps = aftTime*Fs;
    trialSampsLen = aftSamps+befSamps+1; %total length of each trial, by samples
    eventSamps = round(eventTimes*Fs).'; %Deleted "+1" from August 9 2023, for ArshamData_DecisionTask

    chNum = size(data,2);
    trialNum = length(eventTimes);
    z = zeros(trialSampsLen,chNum,trialNum);
    for i = 1:trialNum
        z(:,:,i) = data(eventSamps(i)-befSamps:eventSamps(i)+aftSamps,:);
    end
end