function fig = subjProf(plots_str, prct, sess, t_excit, t_react, t_rest, epochData_struct, epochParams, chanArrays, erpParams, erspParams, pgdFreqParams, powTopo_chansLabel, reactionsDelay, root, path)
    % A general profile containing main result figures for a given subject
    % plots_str: an array of strings containing the name of the plots or quantities to be plotted
    %   POSSIBLE STRINGS:
    %       acc, rt, ersp, pgd_vs_freq, erp_react, erp_stim

    fig = [];
    subjParams_path = sprintf('%sParams/subjParams.mat',path);
    if exist(subjParams_path)
        subjParams = load(subjParams_path).subjParams;
    else
        return;
    end

    trialArrays_path = sprintf('%sMatrices/trialArrays.mat',path);
    if exist(trialArrays_path)
        trialArrays = load(trialArrays_path).trialArrays;
    else
        return;
    end


    fig = figure('Name', sprintf('%s profile - sess%d', prct, sess));
    set(fig, 'Units', 'normalized', 'OuterPosition', [0 0 1 1]);

    plots_num = length(plots_str);
%     rows = ceil(sqrt(plots_num));
%     cols = floor(plots_num/rows);
    cols = 2;
    rows = ceil(plots_num/cols);

    % Load the saved positions and sizes
    load(sprintf('%sFigTemplatePositions/axes_positions_sort_16plots.mat',root));
    load(sprintf('%sFigTemplatePositions/legend_positions_sort_14plots_6legends.mat',root));

    saveName = "prof";
    for i = 1:plots_num
        currentStr = plots_str(i);
        if (plots_num >= 16)
            if i < 17
                ax = axes('Position', axes_positions_sort(i).Position);
            end
        else
        h = subplot(rows, cols, i);        
        end

        if (currentStr == "acc")
            saveName = saveName + "_" + currentStr;

            tot_acc = length(trialArrays.correctAns_trials) / subjParams.trials;
            acc_arr = tot_acc;
            acc_ticks = ["tot"];
            if ~isempty(trialArrays.freq12_trials)
                freq12_acc = length(find(ismember(trialArrays.freq12_trials, trialArrays.correctAns_trials)))/ length(trialArrays.freq12_trials);
                acc_arr = [acc_arr, freq12_acc];
                acc_ticks = [acc_ticks, "freq12"];
            end
            if ~isempty(trialArrays.freq13_trials)
                freq13_acc = length(find(ismember(trialArrays.freq13_trials, trialArrays.correctAns_trials)))/ length(trialArrays.freq13_trials);
                acc_arr = [acc_arr, freq13_acc];
                acc_ticks = [acc_ticks, "freq13"];
            end
            if ~isempty(trialArrays.freq23_trials)
                freq23_acc = length(find(ismember(trialArrays.freq23_trials, trialArrays.correctAns_trials)))/ length(trialArrays.freq23_trials);
                acc_arr = [acc_arr, freq23_acc];
                acc_ticks = [acc_ticks, "freq23"];
            end

            bar(acc_arr);
            title("Accuracy");
            ylim([0.5, 1]);
            xticks(1:length(acc_arr));
            xticklabels(acc_ticks);
            ylabel("%Acc");

        elseif contains(currentStr, "rt")
            saveName = saveName + "_" + currentStr;
            if contains(currentStr, "bar")
                tot_rt = mean(reactionsDelay);
                rt_arr = tot_rt;
                rt_ticks = ["tot"];
                if ~isempty(trialArrays.freq12_trials)
                    freq12_rt = mean(reactionsDelay(trialArrays.react_freq12_trials));
                    rt_arr = [rt_arr, freq12_rt];
                    rt_ticks = [rt_ticks, "freq12"];
                end
                if ~isempty(trialArrays.freq13_trials)
                    freq13_rt = mean(reactionsDelay(trialArrays.react_freq13_trials));
                    rt_arr = [rt_arr, freq13_rt];
                    rt_ticks = [rt_ticks, "freq13"];
                end
                if ~isempty(trialArrays.freq23_trials)
                    freq23_rt = mean(reactionsDelay(trialArrays.react_freq23_trials));
                    rt_arr = [rt_arr, freq23_rt];
                    rt_ticks = [rt_ticks, "freq23"];
                end

                bar(rt_arr);
                title("RT");
                ylim([min(rt_arr)-0.3, max(rt_arr)+0.2])
                xticks(1:length(rt_arr));
                xticklabels(rt_ticks);
                xtickangle(45);
                ylabel("RT[s]");
            else
                scatter(trialArrays.react_freq12_trials, reactionsDelay(trialArrays.react_freq12_trials), 20, "filled", 'o', 'MarkerFaceAlpha', 0.6);
                hold on;
                scatter(trialArrays.react_freq23_trials, reactionsDelay(trialArrays.react_freq23_trials), 20, "filled", "square", 'MarkerFaceAlpha', 0.6);
                scatter(trialArrays.react_freq13_trials, reactionsDelay(trialArrays.react_freq13_trials), 20, "filled", '^', 'MarkerFaceAlpha', 0.6);

                p_12 = polyfit(trialArrays.react_freq12_trials, reactionsDelay(trialArrays.react_freq12_trials), 1);
                p_23 = polyfit(trialArrays.react_freq23_trials, reactionsDelay(trialArrays.react_freq23_trials), 1);
                p_13 = polyfit(trialArrays.react_freq13_trials, reactionsDelay(trialArrays.react_freq13_trials), 1);

                tr_arr = trialArrays.react_notMissedTrials;
                plot(tr_arr, p_12(1)*tr_arr + p_12(2), 'Color', 'blue', 'Linewidth', 1.5, 'LineStyle','-');
                plot(tr_arr, p_23(1)*tr_arr + p_23(2), 'Color', 'red', 'Linewidth', 1.5, 'LineStyle','-');
                plot(tr_arr, p_13(1)*tr_arr + p_13(2), 'Color', 'yellow', 'Linewidth', 1.5, 'LineStyle','-');

                lgd = legend("freq12", "freq23", "freq13");
                set(lgd, 'Position', legend_positions_sort(1).Position);
                title("RT")
                xlabel("Trial");
                ylabel("RT [s]");
            end
        elseif contains(currentStr, "ersp")
            saveName = saveName + "_" + currentStr;
            shouldDraw = true;
            [ersp_fig, f, P1, lgd] = ersp(epochData_struct, erspParams.sampRange_strct, ...
            erspParams.target_epoched_data, erspParams.createFig, shouldDraw, ...
            subjParams.Fs, erspParams.lockStr, erspParams.chansList, ...
            erspParams.chansLabel, erspParams.trialLabel, ...
            erspParams.figNameLabel, path, prct, sess);

            set(lgd, 'Position', legend_positions_sort(2).Position);
            title("ERSP");
            xlim([1,55]);
            if contains(currentStr, "zoom")
                title("");
                xlabel("");
                ylabel("");
                xlim([20, 35]);
                ylim('auto');

                xline(subjParams.Stf(1), '--', 'Color','k');
                xline(subjParams.Stf(2), '--', 'Color','k');
                xline(subjParams.Stf(3), '--', 'Color','k');

                delete(lgd);
            end
            
        elseif (currentStr == "erp_react")
            saveName = saveName + "_" + currentStr;
            opengl('software');
            opengl('save', 'software');
            chansList = chanArrays.midlineChans;
            reactRange = erpParams.sampRange_strct.reactRange;
            plot(t_rest(reactRange),...
              squeeze(mean(epochData_struct.unfiltered_epochedOnReact_data(reactRange, chansList, :), 3)), 'LineWidth', 0.75);
            hold on;
            xline(0,'--');
            title("ERP, Locked on reaction");
            xlabel("Time [s]");
            ylabel("ERP");
            chans_leg = chanName(chansList);
%             legend(chans_leg);

        elseif (currentStr == "erp_rest")
            saveName = saveName + "_" + currentStr;
            opengl('software');
            opengl('save', 'software');
            chansList = chanArrays.midlineChans;

            restRange = erpParams.sampRange_strct.restRange;
            plot(t_rest(restRange),...
              squeeze(mean(epochData_struct.unfiltered_epochedOnRest_data(restRange, chansList, :), 3)), 'LineWidth', 0.75);
            hold on;
            xline(0,'--');
            title("ERP, Locked on rest");
            xlabel("Time [s]");
            ylabel("ERP");
            chans_leg = chanName(chansList);
%             legend(chans_leg);

        elseif (currentStr == "erp_stim")
            saveName = saveName + "_" + currentStr;
            opengl('software');
            opengl('save', 'software');
            chansList = chanArrays.midlineChans;
            stimRange = erpParams.sampRange_strct.stimRange;
            plot(t_rest(stimRange),...
              squeeze(mean(epochData_struct.unfiltered_epoched_data(stimRange, chansList, :), 3)), 'LineWidth', 0.75);
            hold on;
            xline(0,'--');
            title("ERP, Locked on stimuli");
            xlabel("Time [s]");
            ylabel("ERP");
            chans_leg = chanName(chansList);
%             legend(chans_leg);

        elseif (contains(currentStr, "pgd_vs_freq_react"))
            saveName = saveName + "_" + currentStr;
            savePath = path + "Result Figures\PGDFreq\Locked on reaction\" + ...
                "midlineChans\";
            saveName_aft = savePath + "pgdFreq_aft_NMTr.mat";
            saveName_bef = savePath + "pgdFreq_bef_NMTr.mat";

            pgd_mat_aft = cell2mat(struct2cell(load(saveName_aft)));
            pgd_mat_bef = cell2mat(struct2cell(load(saveName_bef)));

            mean_pgd_mat_aft = squeeze(mean(pgd_mat_aft, [2])); %Average over time
            mean_pgd_mat_bef = squeeze(mean(pgd_mat_bef, [2])); %Average over time
            
            if contains(currentStr, "correct")
                mean_pgd_mat_aft = mean_pgd_mat_aft(:, trialArrays.react_correctAns_trials);
                mean_pgd_mat_bef = mean_pgd_mat_bef(:, trialArrays.react_correctAns_trials);
            end

            f_arr = pgdFreqParams.fmin:pgdFreqParams.fstep:pgdFreqParams.fmax;

            Linewidth = 1;
            p1 = shade_plot(f_arr, mean_pgd_mat_bef, '-', 'blue', Linewidth);
            hold on;
            p2 = shade_plot(f_arr, mean_pgd_mat_aft, '-', 'red', Linewidth);
            xline(subjParams.Stf(1), '--', 'Color','k');
            xline(subjParams.Stf(2), '--', 'Color','k');
            xline(subjParams.Stf(3), '--', 'Color','k');

            title('PGD');
            xlabel('Frequency [Hz]');
            ylabel('Mean PGD');
            lgd = legend("Before Reaction","After Reaction");
            set(lgd, 'Position', legend_positions_sort(3).Position);

        elseif (contains(currentStr, "pgd_vs_freq_stim"))
            saveName = saveName + "_" + currentStr;
            savePath = path + "Result Figures\PGDFreq\Locked on stimuli\" + ...
                "midlineChans\";
            saveName_aft = savePath + "pgdFreq_aft_AllTr" + ...
                "_[-"+pgdFreqParams.befEventTime+","+pgdFreqParams.aftEventTime+"].mat";
            saveName_bef = savePath + "pgdFreq_bef_AllTr" + ...
                "_[-"+pgdFreqParams.befEventTime+","+pgdFreqParams.aftEventTime+"].mat";

            pgd_mat_aft = cell2mat(struct2cell(load(saveName_aft)));
            pgd_mat_bef = cell2mat(struct2cell(load(saveName_bef)));

            mean_pgd_mat_aft = squeeze(mean(pgd_mat_aft, [2])); %Average over time
            mean_pgd_mat_bef = squeeze(mean(pgd_mat_bef, [2])); %Average over time
            
            if contains(currentStr, "correct")
                mean_pgd_mat_aft = mean_pgd_mat_aft(:, trialArrays.react_correctAns_trials);
                mean_pgd_mat_bef = mean_pgd_mat_bef(:, trialArrays.react_correctAns_trials);
            end
            f_arr = pgdFreqParams.fmin:pgdFreqParams.fstep:pgdFreqParams.fmax;

            Linewidth = 1;
            p1 = shade_plot(f_arr, mean_pgd_mat_bef, '-', 'blue', Linewidth);
            hold on;
            p2 = shade_plot(f_arr, mean_pgd_mat_aft, '-', 'red', Linewidth);
            xline(subjParams.Stf(1), '--', 'Color','k');
            xline(subjParams.Stf(2), '--', 'Color','k');
            xline(subjParams.Stf(3), '--', 'Color','k');

            title('PGD');
            xlabel('Frequency [Hz]');
            ylabel('Mean PGD');
            lgd = legend("Rest","Stimuli");
            set(lgd, 'Position', legend_positions_sort(3).Position);

        elseif (contains(currentStr, "pgd_acc_vs_rej") || contains(currentStr, "pgd_acc_vs_rej_hist"))
            saveName = saveName + "_" + currentStr;
            if currentStr == "pgd_acc_vs_rej_hist"
                isHist = true;
            else
                isHist = false;
            end
            %             savePath_mid = path + "Result Figures\PGD\Locked on reaction\Gamma\" + ...
            %                 "\midlineChans_rmvPOandO\";
            savePath_mid = path + "Result Figures\PGD\Locked on reaction\Gamma\" + ...
                "\midlineChans\";

            if ~isfolder(savePath_mid)
                fprintf('Not Found: %s - %d', prct, sess);
                return;
            end

            pgd1_mid = cell2mat(struct2cell(load(savePath_mid + ...
                "pgd_" + subjParams.Stf(1) + "Hz.mat")));
            pgd2_mid = cell2mat(struct2cell(load(savePath_mid + ...
                "pgd_" + subjParams.Stf(2) + "Hz.mat")));

            if length(subjParams.Stf) == 3
                pgd3_mid = cell2mat(struct2cell(load(savePath_mid + ...
                    "pgd_" + subjParams.Stf(3) + "Hz.mat")));
            end

            pgd_type = "";

            if contains(currentStr, "correct")
                nMiss_corr_tr = ismember(trialArrays.react_notMissedTrials, trialArrays.react_correctAns_trials);
                if contains(currentStr, "12")
                    pgd_type = "12";
                    pgd_mid_acc = [pgd1_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.acc_fc1_12_trials))),...
                        pgd2_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.acc_fc2_12_trials)))];
                    pgd_mid_rej = [pgd1_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.rej_fc1_12_trials))),...
                        pgd2_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.rej_fc2_12_trials)))];
                elseif contains(currentStr, "13")
                    pgd_type = "13";
                    pgd_mid_acc = [pgd1_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.acc_fc1_13_trials))),...
                        pgd3_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.acc_fc3_13_trials)))];
                    pgd_mid_rej = [pgd1_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.rej_fc1_13_trials))),...
                        pgd3_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.rej_fc3_13_trials)))];
                elseif contains(currentStr, "23")
                    pgd_type = "23";
                    pgd_mid_acc = [pgd2_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.acc_fc2_23_trials))),...
                        pgd3_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.acc_fc3_23_trials)))];
                    pgd_mid_rej = [pgd2_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.rej_fc2_23_trials))),...
                        pgd3_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.rej_fc3_23_trials)))];
                else
                    %*******An exception:
                    if prct == "Khosravipour" && sess == 2
                        pgd_mid_acc = [pgd1_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.acc_fc1_trials))),...
                            pgd2_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.acc_fc3_trials)))];
                        pgd_mid_rej = [pgd1_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.rej_fc1_trials))),...
                            pgd2_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.rej_fc3_trials)))];
                    else
                        pgd_mid_acc = [pgd1_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.acc_fc1_trials))),...
                            pgd2_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.acc_fc2_trials)))];
                        pgd_mid_rej = [pgd1_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.rej_fc1_trials))),...
                            pgd2_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.rej_fc2_trials)))];
                    end
                    if length(subjParams.Stf) == 3
                        pgd_mid_acc = [pgd_mid_acc, pgd3_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.acc_fc3_trials)))];
                        pgd_mid_rej = [pgd_mid_rej, pgd3_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.rej_fc3_trials)))];
                    end
                    %*******An exception:
                    if prct == "Beigi" && sess == 2
                        pgd_mid_acc = [pgd3_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.react_freq13_trials)))];
                        pgd_mid_rej = [pgd1_mid(:, nMiss_corr_tr  & ismember(trialArrays.react_notMissedTrials, find(trialArrays.react_freq13_trials)))];
                    end
                end
            else
                if contains(currentStr, "12")
                    pgd_type = "12";
                    pgd_mid_acc = [pgd1_mid(:, trialArrays.acc_fc1_12_trials),...
                        pgd2_mid(:, trialArrays.acc_fc2_12_trials)];
                    pgd_mid_rej = [pgd1_mid(:, trialArrays.rej_fc1_12_trials),...
                        pgd2_mid(:, trialArrays.rej_fc2_12_trials)];
                elseif contains(currentStr, "13")
                    pgd_type = "13";
                    pgd_mid_acc = [pgd1_mid(:, trialArrays.acc_fc1_13_trials),...
                        pgd3_mid(:, trialArrays.acc_fc3_13_trials)];
                    pgd_mid_rej = [pgd1_mid(:, trialArrays.rej_fc1_13_trials),...
                        pgd3_mid(:, trialArrays.rej_fc3_13_trials)];
                elseif contains(currentStr, "23")
                    pgd_type = "23";
                    pgd_mid_acc = [pgd2_mid(:, trialArrays.acc_fc2_23_trials),...
                        pgd3_mid(:, trialArrays.acc_fc3_23_trials)];
                    pgd_mid_rej = [pgd2_mid(:, trialArrays.rej_fc2_23_trials),...
                        pgd3_mid(:, trialArrays.rej_fc3_23_trials)];
                else
                    %*******An exception:
                    if prct == "Khosravipour" && sess == 2
                        pgd_mid_acc = [pgd1_mid(:, trialArrays.acc_fc1_trials),...
                            pgd2_mid(:, trialArrays.acc_fc3_trials)];
                        pgd_mid_rej = [pgd1_mid(:, trialArrays.rej_fc1_trials),...
                            pgd2_mid(:, trialArrays.rej_fc3_trials)];
                    else
                        pgd_mid_acc = [pgd1_mid(:, trialArrays.acc_fc1_trials),...
                            pgd2_mid(:, trialArrays.acc_fc2_trials)];
                        pgd_mid_rej = [pgd1_mid(:, trialArrays.rej_fc1_trials),...
                            pgd2_mid(:, trialArrays.rej_fc2_trials)];
                    end
                    if length(subjParams.Stf) == 3
                        pgd_mid_acc = [pgd_mid_acc, pgd3_mid(:, trialArrays.acc_fc3_trials)];
                        pgd_mid_rej = [pgd_mid_rej, pgd3_mid(:, trialArrays.rej_fc3_trials)];
                    end
                    %*******An exception:
                    if prct == "Beigi" && sess == 2
                        pgd_mid_acc = [pgd3_mid(:, trialArrays.react_freq13_trials)];
                        pgd_mid_rej = [pgd1_mid(:, trialArrays.react_freq13_trials)];
                    end
                end
            end

            if pgd_type==""
                pgd_type = "allfreqs";
            end

            %*********Debug (If this is displayed, something is wrong!)
            if (size(pgd_mid_acc, 2) ~= size(pgd_mid_rej, 2))
                disp("NOT EQUAL SIZE DETECTED!!!!");
            end

            % Initialize variables to store min and max y-axis limits
            minY = inf;
            maxY = -inf;

            %*********** Mid

            if isHist
                p1 = hist_plot(pgd_mid_acc(1000:2000, :), nbin); hold on;
                p2 = hist_plot(pgd_mid_rej(1000:2000, :), nbin);
            else
                Linewidth = 1;
                p1 = shade_plot(t_react, pgd_mid_acc, '-', 'blue', Linewidth);
                hold on;
                p2 = shade_plot(t_react, pgd_mid_rej, '-', 'red', Linewidth);
                xline(0,'--');
            end
            lgd = legend({"Accepted", "rejected", ""}, 'Location', 'best');
            subtitle(sprintf('PGD near reaction, midline, %s', pgd_type));
            xlabel('t [s]');
            ylabel('Mean PGD');
        elseif (currentStr == "topo_alpha_react")
            saveName = saveName + "_" + currentStr;
            powTopoParams.slct_befEventTime = epochParams.react_befEventTime;
            powTopoParams.start = (powTopoParams.slct_befEventTime - 0.5) * subjParams.Fs + 1;
            powTopoParams.finish = (powTopoParams.slct_befEventTime + 0.5) * subjParams.Fs;
            powTopoParams.winLen = 1 * subjParams.Fs;
            powTopoParams.overlap = 0;
            powTopoParams.frange = [subjParams.alpha - 2, subjParams.alpha + 2];
            createFig = false;
            lockStr = "reaction";

            mean_topo_power = ...
                powTopo(epochData_struct.unfiltered_epochedOnReact_data, createFig, ...
                lockStr, {trialArrays.react_notMissedTrials}, ...
                {"PersonalAlpha"}, ...
                subjParams.Fs, path, powTopo_chansLabel, powTopoParams);

            title("");
            subtitle(sprintf('Alpha PowTopo,\n Locked on %s', lockStr));

        elseif (currentStr == "topo_alpha_rest")
            saveName = saveName + "_" + currentStr;
            powTopoParams.slct_befEventTime = epochParams.rest_befEventTime;
            powTopoParams.start = (powTopoParams.slct_befEventTime + 1) * subjParams.Fs + 1;
            powTopoParams.finish = (powTopoParams.slct_befEventTime + 2) * subjParams.Fs;
            powTopoParams.winLen = 1 * subjParams.Fs;
            powTopoParams.overlap = 0;
            powTopoParams.frange = [subjParams.alpha - 2, subjParams.alpha + 2];
            createFig = false;
            lockStr = "rest";

            mean_topo_power = ...
                powTopo(epochData_struct.unfiltered_epochedOnRest_data, createFig, ...
                lockStr, {trialArrays.react_notMissedTrials}, ...
                {"PersonalAlpha"}, ...
                subjParams.Fs, path, powTopo_chansLabel, powTopoParams);

            title("");
            subtitle(sprintf('Alpha PowTopo,\n Locked on %s', lockStr));

        elseif (currentStr == "midlinechans_topo_color")
            saveName = saveName + "_" + currentStr;
            colors = [
                0 0.4470 0.7410;    
                0.8500 0.3250 0.0980;   
                0.9290 0.6940 0.1250;   
                0.4940 0.1840 0.5560;   
                0.4660 0.6740 0.1880;   
                0.3010 0.7450 0.9330;    
                0.6350 0.0780 0.1840; 
                0.00,0.45,0.74;  
                ];
            plot_midlineChansColor(cellstr(upper(powTopo_chansLabel(chanArrays.midlineChans))), ...
                colors, false, '10-20', ...
                true, false, 1000);
            title("");
            subtitle(sprintf('Channels Map'));

        elseif (currentStr == "es")
            saveName = saveName + "_" + currentStr;
            bandw = 2/2;
            lockStr = "stimuli";
            createFig = false;
            shouldDraw = true;

            ES = entrainScore(epochData_struct, bandw, lockStr, createFig, ...
                shouldDraw, erspParams, subjParams, chanArrays, ...
                powTopo_chansLabel, path, prct, sess);

        elseif (currentStr == "es_norm")
            saveName = saveName + "_" + currentStr;
            bandw = 2/2;
            lockStr = "stimuli";
            createFig = false;
            shouldDraw = false;

            ES = entrainScore(epochData_struct, bandw, lockStr, createFig, ...
                shouldDraw, erspParams, subjParams, chanArrays, ...
                powTopo_chansLabel, path, prct, sess);

            lockStr = "base";
            ES_b = entrainScore(epochData_struct, bandw, lockStr, createFig, ...
                shouldDraw, erspParams, subjParams, chanArrays, ...
                powTopo_chansLabel, path, prct, sess);

            ES_norm = ES - ES_b; % Dim = channels*1
            plot_topography(cellstr(upper(powTopo_chansLabel)), ES_norm, 1, '10-20', 1, 0, 1000);
            title("");
            subtitle(sprintf('ES norm, Locked on stimuli'));

        elseif currentStr == "desc"
            saveName = saveName + "_" + currentStr;
%             text_position = [0.008616974972797,0.61156186612576,...
%                 0.108902067464635,0.366125760649085];
%             text_position = [0.008616974972797,0.61156186612576];
%             text_position = [-0.3621,11.7757,0];
            descTable = readtable(sprintf('%sSubjDesc/BlindSubjectsData.xlsx', root));
            
            % NOTE: Change this code if the columns in excel fie were modified.
            SubjInd = str2double(regexp(prct, '\d+', 'match'));
            BIS = descTable(SubjInd, 10); BIS = BIS{1, 1};
            BAS = descTable(SubjInd, 9); BAS = BAS{1, 1};
            Glasses = descTable(SubjInd, 6); Glasses = Glasses{1, 1};
            Age = descTable(SubjInd, 4); Age = Age{1, 1};

            Sex = descTable(SubjInd, 3); Sex = Sex{1, 1}; Sex = string(Sex{1});
            if Sex == "مرد"
                Sex = "Male";
            elseif Sex == "زن"
                Sex = "Female";
            end

            
            text_content = sprintf('Index: %s\nChooseHigh: %d\nBIS: %d\nBAS: %d\nGlasses: %d\nSex: %s\nAge: %d', ...
                prct, subjParams.shouldChooseHigh, BIS, BAS, Glasses, Sex, Age);
            fig = gcf;
            annotation('textbox', [0,0.9,0,0], 'String', text_content, 'FitBoxToText','on', 'Units', 'normalized',...
             'VerticalAlignment','top','HorizontalAlignment','left', 'FontSize',12);
        end
    end
        
    saveDir = path + "Result Figures\Profile\";
    if ~isfolder(saveDir)
        mkdir(saveDir);
    end

    if exist(saveDir + saveName + ".fig")
        fprintf('Profile exists for %s - sess%d. The old profile was overwritten.', prct, sess);
    end
    savefig(fig, saveDir + saveName + ".fig");
    saveas(fig, saveDir + saveName + ".jpg");
end
