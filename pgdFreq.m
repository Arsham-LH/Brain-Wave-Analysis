function [f_arr, fig, pgd_mat_aft, pgd_mat_bef] = pgdFreq(pgdFreqParams, targTrials, lockReact, dirLabels_struct, path, labels_struct, figNameLabel, Fs, dataset, old_eventsMat, eventType, chansList, prct, sess)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %lockReact: a boolean:
    %   If true, PGDs before&after reaction are plotted
    %   If false, PGDs before&after stimulus are plotted

    % labels_struct: a struct for the figure and the data. containing these strings respectively:
    %   trial_label, chansList_label
    % NOTE: You can leave some of them empty by setting them to []. But all of
    %   them should be defined.
    
    % dirLabels_struct: a struct for name of the folders in the directory. containing these strings respectively:
    %   chansList_label
    % NOTE: You can leave some of them empty by setting them to []. But all of
    %   them should be defined.
    % NOTE: For now, codes for chansList_label in this struct is commented
    %   in the function, because the list of channles is already declared by
    %   the name of the folder.
    
    % figNameLabel: a label at the end of the name of the figure.
    %   Enter the name of the TRIALS array you averaged over to plot this.
    %   ALSO additional labels like 'accVSrej' might be entered here.

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    befEventTime = pgdFreqParams.befEventTime;
    aftEventTime = pgdFreqParams.aftEventTime;
    fmin = pgdFreqParams.fmin;
    fstep = pgdFreqParams.fstep;
    bandw = pgdFreqParams.bandw;
    order = pgdFreqParams.order;
    fmax = pgdFreqParams.fmax;

    f_arr = fmin:fstep:fmax;
    
    trialArr = 1:length(targTrials);

    %********Creating savePath
    if lockReact
        if ~isempty(dirLabels_struct.trial_label)
            savePath = path + "Result Figures\PGDFreq\Locked on reaction\" + ...
                dirLabels_struct.trial_label + "\" + ...
                dirLabels_struct.chansList_label + "\";
        else
            savePath = path + "Result Figures\PGDFreq\Locked on reaction\" + ...
                dirLabels_struct.chansList_label + "\";
        end
    else
        if ~isempty(dirLabels_struct.trial_label)
            savePath = path + "Result Figures\PGDFreq\Locked on stimuli\" + ...
                dirLabels_struct.trial_label + "\" + ...
                dirLabels_struct.chansList_label + "\";
        else
            savePath = path + "Result Figures\PGDFreq\Locked on stimuli\" + ...
                dirLabels_struct.chansList_label + "\";
        end
    end

    if ~isfolder(savePath)
        mkdir(savePath);
    end

    %********Creating the name of the saved variables
    labelName = "";
    if ~isempty(labels_struct.trial_label)
        labelName = labels_struct.trial_label;
    end

    saveName_aft = savePath + "pgdFreq_aft_" + labelName + "_[-" + befEventTime + "," + aftEventTime + "].mat";
    saveName_bef = savePath + "pgdFreq_bef_" + labelName + "_[-" + befEventTime + "," + aftEventTime + "].mat";

    figName = labelName + "_" + figNameLabel + "_[-" + befEventTime + "," + aftEventTime + "].fig";

    if exist(saveName_aft)
        fig = [];
        pgd_mat_aft = cell2mat(struct2cell(load(saveName_aft)));
        pgd_mat_bef = cell2mat(struct2cell(load(saveName_bef)));
    else
        %***********For stimuli & rest periods**********************
        t = -befEventTime + 1/Fs : 1/Fs : aftEventTime;
        pgd_mat = zeros(length(f_arr), length(t), length(trialArr));

        for k = 1:length(f_arr)
            filtered_data = butter_bandFilt(dataset.',f_arr(k),bandw,order,Fs,2,0);

            notEpoched_inst_phase = inst_phase_cal(filtered_data,1); %dimension= samples*channels

            inst_phase = epoching(notEpoched_inst_phase, befEventTime, aftEventTime, Fs, old_eventsMat, eventType); %dimension= samples*channels*trials
            inst_phase = inst_phase(:, chansList, targTrials);

            clear notEpoched_inst_phase;
            clear filtered_data;
            
            for i=1:length(t)
                for j = trialArr
                    grad = withoutFOR_grad_linefitting(squeeze(inst_phase(i,:,j)));
                    pgd_mat(k,i,j) = pgdAlter(grad,inst_phase(i,:,j));
                end
            end
            disp("f = "+f_arr(k));
            clear inst_phase;
            clear bef_inst_phase;
        end

        pgd_mat_aft = pgd_mat(:, befEventTime*Fs+1 : end, :);
        pgd_mat_bef = pgd_mat(:, 1:befEventTime*Fs, :);

        mean_pgd_mat_aft = squeeze(mean(pgd_mat_aft, [2])); %Average over time
        mean_pgd_mat_bef = squeeze(mean(pgd_mat_bef, [2])); %Average over time

        save(saveName_aft, 'pgd_mat_aft');
        save(saveName_bef, 'pgd_mat_bef');

        fig = figure;
        Linewidth = 1;
        p1 = shade_plot(f_arr, mean_pgd_mat_bef, '-', 'blue', Linewidth);
        hold on;
        p2 = shade_plot(f_arr, mean_pgd_mat_aft, '-', 'red', Linewidth);

        title(sprintf('PGD for %s - sess%d', prct, sess));
        xlabel('Frequency [Hz]');
        ylabel('Mean PGD');
        if lockReact
            legend("Before Reaction","After Reaction");
        else
            legend("Rest","Stimuli");
        end
        % %*****************************************************************

    end
    savefig(fig, savePath + figName);
end