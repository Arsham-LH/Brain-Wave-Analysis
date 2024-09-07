function z = epoching(befTime, Fs, aftTime, eventsMat, eventType, data)
%eventType: event type based on which we want to create epochs
%assumption: data dimension = samples*channels
%assumption: epoched data dimension = samples*channels*trials
%assumption: eventsMat dimension = time*eventTypes
%assumption: eventsMat contains 2 columns. column 1 shows latency of events and column 2 shows type of events
    befSamps = befTime*Fs - 1; %NOTE: -1 is the new change for this function (since August 2nd). This corrects the frequencies in FFT and any other frequency analysis
    aftSamps = aftTime*Fs;
    trialSampsLen = aftSamps+befSamps+1; %total length of each trial, by samples

    eventInds = find(eventsMat(:,2) == eventType);
    eventTimes = eventsMat(eventInds,1);
    eventSamps = round(eventTimes*Fs); %Deleted "+1" from August 9 2023, for ArshamData_DecisionTask


    chNum=size(data,2);
    trialNum=size(eventInds,1);
    z=zeros(trialSampsLen,chNum,trialNum);
    for i=1:trialNum
        z(:,:,i)=data(eventSamps(i,1)-befSamps:eventSamps(i,1)+aftSamps,:);
    end
end