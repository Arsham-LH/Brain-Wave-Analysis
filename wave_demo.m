function [frame, writerObj] = wave_demo(inst_phase, chansList, selectedTrial, fc, frameRate, befEventTime, startTime, Fs, endTime)
    % Assumption: inst_phase dimension = samples*channels*trials
    % If chansList == -1, demo will be shown for all channels
    % StartTime: start time of trial to show (from -befEventTime to
    %+aftEventTime)


    %***************** CREATING PhiHeadModel AND PhiHeadModelNew ******************

    headModel = createHeadMatrix_56ch_newDevice();

    PhiHeadModel = nan*zeros(9,9,size(inst_phase,3),size(inst_phase,1)); %dimension = row*col*trial*sample

    for k = 1:size(inst_phase,2) % ichan
        for j = 1:size(inst_phase,3) %itrial
            for i = 1:size(inst_phase,1) %time
                [yy, xx] = find(ismember(headModel,k));
                PhiHeadModel(yy,xx,j,i) = inst_phase(i,k,j);
            end
        end
    end


    if chansList == -1
        PhiHeadModelNew = PhiHeadModel;
    else
        PhiHeadModelNew = nan*PhiHeadModel; %dimension = row*col*trial*samples

        for i = 1:length(chansList)
            [yy, xx] = find(ismember(headModel,chansList(i)));
            PhiHeadModelNew(yy,xx,:,:) = PhiHeadModel(yy,xx,:,:);
        end
    end

    %**********************************************************




    selectedPhi = squeeze(PhiHeadModelNew(:,:,selectedTrial,:)); %dimension = row*col*samples
    x = 1:9; y = 1:9;

    colormap hot
    formatSpec = '%0.4f';
    frame = [];

    figure
    
    writerObj = VideoWriter(fc+" Hz_finallinewave_trial "+selectedTrial);
    writerObj.FrameRate = frameRate;
    writerObj.Quality = 100;

    % open the video writer
%     open(writerObj);

    for i = (befEventTime+startTime)*Fs+1 : (befEventTime+endTime)*Fs
        colormap winter
        imagesc(y,x,cos(selectedPhi(:,:,i)),'AlphaData',~isnan(cos(selectedPhi(:,:,i))));
        colorbar
        caxis([-1 1])
        h=gca;
        h.XAxis.TickLength = [0 0];
        h.YAxis.TickLength = [0 0];
        dispTime = (i)/Fs - befEventTime;
        title("Wave - time(s) = " + compose(formatSpec,dispTime) +...
             " - StimuliTrialNum = " + selectedTrial, 'interpreter', 'latex');
        currentFrame = getframe(gcf);
        frame = cat(2,frame, currentFrame);
%         writeVideo(writerObj,currentFrame);
        drawnow
        
    end



    % write the frames to the video
%     for i=1:length(frame)
%         % convert the image to a frame
%         frames = frame(i) ;
%         writeVideo(writerObj,frames);
%     end
%     % close the writer o bject
%     close(writerObj)
end