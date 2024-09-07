function [pgd_out, fig] = pgd(slctInstPhase, chansList, dirLabels_struct, figNameLabel, path, labels_struct, t, targTrials_cell, legendLabels_cell)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % slctInstPhase: 3D phase matrix
    
    % targTrials_cell: a cell array (max of length 2) containing 1 or 2 arrays
    %   of trials to plot figures for. If there are 2 cells, the two pgd plots
    %   are plotted together using 'hold on';
    
    % legendLabels_cell: labels written on legend. Based on targTrials_cell
    
    % labels_struct: a struct for the figure and the data. containing these strings respectively:
    %   chansList_label, freq_label
    % NOTE: There is no trial_label here because data is always computed
    %   over all trials.
    % NOTE: You can leave some of them empty by setting them to []. But all of
    %   them should be defined.
    
    % dirLabels_struct: a struct for name of the folders in the directory. containing these strings respectively:
    %   chansList_label, freqBand_label, trial_label
    % NOTE: You can leave some of them empty by setting them to []. But all of
    %   them should be defined.
    % NOTE: For now, codes for chansList_label in this struct is commented
    %   in the function, because the list of channles is already declared by
    %   the name of the folder.
    
    % figNameLabel: a label at the end of the name of the figure.
    %   Enter the name of the TRIALS array you averaged over to plot this.
    %   ALSO additional labels like 'accVSrej' might be entered here.

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    slctInstPhase = slctInstPhase(:, chansList, :);
    trialArr = 1:size(slctInstPhase,3);
    
       %********Creating savePath
    if ~isempty(dirLabels_struct.trial_label)
        if figNameLabel == "Base"
            savePath = path + "Result Figures\PGD\Locked on baseline\" + ...
                dirLabels_struct.freqBand_label + "\" + ...
                dirLabels_struct.trial_label + "\" + ...
                dirLabels_struct.chansList_label + "\";
        else
            savePath = path + "Result Figures\PGD\Locked on reaction\" + ...
                dirLabels_struct.freqBand_label + "\" + ...
                dirLabels_struct.trial_label + "\" + ...
                dirLabels_struct.chansList_label + "\";
        end
    else
        if figNameLabel == "Base"
            savePath = path + "Result Figures\PGD\Locked on baseline\" + ...
                dirLabels_struct.freqBand_label + "\" + ...
                dirLabels_struct.chansList_label + "\";
        else
            savePath = path + "Result Figures\PGD\Locked on reaction\" + ...
                dirLabels_struct.freqBand_label + "\" + ...
                dirLabels_struct.chansList_label + "\";
        end
    end
    
    if ~isfolder(savePath)
        mkdir(savePath);
    end
    

    %********Creating the name of the saved variables
    labelName = "";
    if ~isempty(labels_struct.freq_label)
        labelName = labels_struct.freq_label;
    end
%     if labels_struct.chansList_label
%         labelName = labelName + "_" + labels_struct.chansList_label;
%     end
 
    if exist(savePath + "pgd_" + labelName + ".mat")
        pgd_out = cell2mat(struct2cell(load(savePath + "pgd_" + labelName + ".mat")));
    else
        grad_out = zeros(length(t),length(trialArr),2); % [samples*trials]
        pgd_out = zeros(length(t),length(trialArr)); % [samples*trials]
        
        
        for i=1:length(t)
            for j=trialArr
                grad_out(i,j,:) = withoutFOR_grad_linefitting(squeeze(slctInstPhase(i,:,j)));
                pgd_out(i,j) = pgdAlter(grad_out(i,j,:),slctInstPhase(i,:,j));
            end
        end
        
        save(savePath + "grad_" + labelName + ".mat", 'grad_out');
        save(savePath + "pgd_" + labelName + ".mat", 'pgd_out');
    end
    
    fig = figure;
    t = t.';
    
    Linewidth = 1;
    
    if figNameLabel == "Base"
        pgd_out1 = pgd_out;
        p1 = shade_plot(t, pgd_out1, '-', 'blue', Linewidth);
        hold on;
    elseif length(targTrials_cell) == 1
        pgd_out1 = pgd_out(:,targTrials_cell{1});
        p1 = shade_plot(t, pgd_out1, '-', 'blue', Linewidth);
        hold on;
    elseif length(targTrials_cell) == 2
        pgd_out1 = pgd_out(:,targTrials_cell{1});
        pgd_out2 = pgd_out(:,targTrials_cell{2});
        p1 = shade_plot(t, pgd_out1, '-', 'blue', Linewidth);
        hold on;
        p2 = shade_plot(t, pgd_out2, '-', 'red', Linewidth);

        legend([p1,p2], {legendLabels_cell{1}, legendLabels_cell{2}});
    end

    xline(0,'--');

    xlabel('Time [s]');
    ylabel('Mean PGD');

    %********Creating Title
    titleName = "";
    if ~isempty(labels_struct.freq_label)
        titleName = ", " + labels_struct.freq_label;
    end
    if ~isempty(dirLabels_struct.chansList_label)
        titleName = titleName + ", " + dirLabels_struct.chansList_label;
    end
    title("Average PGD " + titleName);
    set(gcf, 'Position', get(0, 'Screensize'));

    figName = labelName;
    if ~isempty(figNameLabel)
        figName = figName + "_" + figNameLabel;
    end
    savefig(fig, savePath + figName + ".fig");
end