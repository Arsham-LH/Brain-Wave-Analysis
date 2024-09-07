function [ersp_fig, f, P1, lgd] = ersp(lockStr, path, trialLabel, chansLabel, figNameLabel, createFig, shouldDraw, epochData_struct, sampRange_strct, chansList, Fs, prct, sess, target_epoched_data)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % epochData_struct: should contain unfiltered epoch data,
    %   locked on all desired events
    %   NOTE: This function assumes that the given 3D matrices are all 
    %   epoched in the range [-2,2]s.
    
    % shouldDraw: a boolean. 
    %   False = No 'plot' command is run and no figure is created (only f,P1 are computed).
    %   True = 'plot' is used, but creation of figures depends on the value of createFig.
    
    % target_epoched_data: 3D data matrix, with desired list of channels and trials.
    %   NOTE: This varibale is used ONLY if you set lockStr something
    %   other than "all".
    
    % lockStr: a string, indicating which event the data is locked on.
    %   Possible values: "reaction", "stimuli",
    %   "all" (Means locked on stimuli, reaction, rest and baseline rest)
      
    
    % createFig: a boolean: 
    %   If true, it creates a figure and plots ERSP and saves the figure.
    %   If false, it neither creates a figure nor saves anything - For example, this code should be written beofre using this function: figure; subplot(2,2,1);  

    % figNameLabel: a label at the end of the name of the figure.
    %   Enter the time range based on what event you locked on.
    %   Example: '[-0.5,0.5]'.

    % f: If lockStr = "all", it is a struct containing f_stim to f_base.
    %   If lockStr is something else, it is a vector.

    % P1: If lockStr = "all", it is a struct containing P1_stim to P1_base. 
    %   If lockStr is something else, it is a 3D matrix.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    ersp_fig = [];
    f = [];
    P1 = [];
    lgd = [];
    if lockStr == "all"
        savePath = path + "Result Figures\ERSP\For channels\Locked on all\";
        if ~isfolder(savePath)
            mkdir(savePath);
        end

        saveName = sprintf('%s%s_%s_%s.fig', savePath, trialLabel, chansLabel, figNameLabel);
        if (exist(saveName) && createFig && shouldDraw)
            openfig(saveName);
            fprintf("ERSP exists\n");
        else
            target_epoched_data_stim = epochData_struct.unfiltered_epoched_data(sampRange_strct.stimRange, chansList, :);
            target_epoched_data_react = epochData_struct.unfiltered_epochedOnReact_data(sampRange_strct.reactRange, chansList, :);
            target_epoched_data_rest = epochData_struct.unfiltered_epochedOnRest_data(sampRange_strct.restRange, chansList, :);
            target_epoched_data_base = epochData_struct.unfiltered_epochedOnBase_data(:, chansList, :);

            sampDur_stim = size(target_epoched_data_stim,1);
            sampDur_react = size(target_epoched_data_react,1);
            sampDur_rest = size(target_epoched_data_rest,1);
            sampDur_base = size(target_epoched_data_base,1);

            f_stim = Fs*(0:floor(sampDur_stim/2))/sampDur_stim; %freqs to plot
            f_react = Fs*(0:floor(sampDur_react/2))/sampDur_react; %freqs to plot
            f_rest = Fs*(0:floor(sampDur_rest/2))/sampDur_rest; %freqs to plot
            f_base = Fs*(0:floor(sampDur_base/2))/sampDur_base; %freqs to plot

            signal_fft_stim = fft(target_epoched_data_stim);
            signal_fft_react = fft(target_epoched_data_react);
            signal_fft_rest = fft(target_epoched_data_rest);
            signal_fft_base = fft(target_epoched_data_base);

            P2_stim = abs(signal_fft_stim/sampDur_stim);
            P2_react = abs(signal_fft_react/sampDur_react);
            P2_rest = abs(signal_fft_rest/sampDur_rest);
            P2_base = abs(signal_fft_base/sampDur_base);

            P1_stim = P2_stim(1:floor(sampDur_stim/2)+1,:,:);
            P1_react = P2_react(1:floor(sampDur_react/2)+1,:,:);
            P1_rest = P2_rest(1:floor(sampDur_rest/2)+1,:,:);
            P1_base = P2_base(1:floor(sampDur_base/2)+1,:,:);

            P1_stim(2:end-1,:,:) = 2*P1_stim(2:end-1,:,:); %Dimension = freqs*channels*trials
            P1_react(2:end-1,:,:) = 2*P1_react(2:end-1,:,:);
            P1_rest(2:end-1,:,:) = 2*P1_rest(2:end-1,:,:);
            P1_base(2:end-1,:,:) = 2*P1_base(2:end-1,:,:);

            target_P1_stim = squeeze(mean(P1_stim, [2]));
            target_P1_react = squeeze(mean(P1_react, [2]));
            target_P1_rest = squeeze(mean(P1_rest, [2]));
            target_P1_base = squeeze(mean(P1_base, [2]));

            if shouldDraw
                if createFig
                    ersp_fig = figure;
                end
                Linewidth = 1.5;
                p_stim = shade_plot(f_stim, target_P1_stim, '-', 'blue', Linewidth); hold on;
                p_react = shade_plot(f_react, target_P1_react, '-', 'red', Linewidth);
                p_rest = shade_plot(f_rest, target_P1_rest, '-', 'yellow', Linewidth);
                p_base = shade_plot(f_base, target_P1_base, '-', 'magenta', Linewidth);

                lgd = legend([p_stim,p_react,p_rest,p_base], ...
                    ["Stimuli", "Reaction", "Rest", "Baseline"]);

                title(sprintf('ERSP for %s - sess%d - %s - %s\n', prct, sess, chansLabel, trialLabel));
                xlabel('f(Hz)');
                ylabel('FFT');
                xlim([0,70]);
                if createFig
                    savefig(saveName);
                end
            end

            P1.P1_stim = P1_stim;
            P1.P1_react = P1_react;
            P1.P1_rest = P1_rest;
            P1.P1_base = P1_base;
 
            f.f_stim = f_stim;
            f.f_react = f_react;
            f.f_rest = f_rest;
            f.f_base = f_base;
        end
    else
        savePath = path + "Result Figures\ERSP\For channels\Locked on " + ...
            lockStr + "\";
        if ~isfolder(savePath)
            mkdir(savePath);
        end

        saveName = sprintf('%s%s_%s_%s.fig', savePath, trialLabel, chansLabel, figNameLabel);
        if (exist(saveName) && createFig && shouldDraw)
            openfig(saveName);
            fprintf("ERSP exists\n");
        else
            sampDur = size(target_epoched_data,1);
            f = Fs*(0:floor(sampDur/2))/sampDur; %freqs to plot
            signal_fft = fft(target_epoched_data);
            P2 = abs(signal_fft/sampDur);
            P1 = P2(1:floor(sampDur/2)+1,:,:);
            P1(2:end-1,:,:) = 2*P1(2:end-1,:,:); %Dimension = freqs*channels*trials

            target_P1 = squeeze(mean(P1, [2,3])); %Dimesnion = freqs*1
            
            if shouldDraw
                if createFig
                    ersp_fig = figure;
                end
                plot(f, target_P1);
                title(sprintf('ERSP for %s - sess%d - %s - %s\n', prct, sess, chansLabel, trialLabel));
                xlabel('f(Hz)');
                ylabel('FFT');
                xlim([0,70]);

                if createFig
                    savefig(saveName);
                end
            end
        end
    end
end