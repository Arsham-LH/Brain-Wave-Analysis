function es = entrainScore(epochData_struct, erspParams, subjParams, chanArrays, path, prct, sess, lockStr, bandw, shouldDraw, createFig, powTopo_chansLabel)
    ersp_shouldDraw = false;
    ersp_createFig = false;
    [ersp_fig, f, P1, lgd] = ersp(epochData_struct, erspParams.sampRange_strct, ...
        erspParams.target_epoched_data, ersp_createFig, ersp_shouldDraw, ...
        subjParams.Fs, erspParams.lockStr, chanArrays.allChans, ...
        erspParams.chansLabel, erspParams.trialLabel, ...
        erspParams.figNameLabel, path, prct, sess);
    if lockStr == "stimuli"
        slct_f = f.f_stim;
        slct_P1 = P1.P1_stim;
    elseif lockStr == "reaction"
        slct_f = f.f_react;
        slct_P1 = P1.P1_react;
    elseif lockStr == "rest"
        slct_f = f.f_rest;
        slct_P1 = P1.P1_rest;
    elseif lockStr == "base"
        slct_f = f.f_base;
        slct_P1 = P1.P1_base;
    end


    fc1_loc = (slct_f == subjParams.Stf(1));
    fc2_loc = (slct_f == subjParams.Stf(2));
    fc3_loc = (slct_f == subjParams.Stf(3));
    
    frange_fc1 = (slct_f >= (subjParams.Stf(1)-bandw) & slct_f <= (subjParams.Stf(1)+bandw));
    frange_fc2 = (slct_f >= (subjParams.Stf(2)-bandw) & slct_f <= (subjParams.Stf(2)+bandw));
    frange_fc3 = (slct_f >= (subjParams.Stf(3)-bandw) & slct_f <= (subjParams.Stf(3)+bandw));
    
    fc1_ind = find(fc1_loc,1) - find(frange_fc1,1) + 1;
    fc2_ind = find(fc2_loc,1) - find(frange_fc2,1) + 1;
    fc3_ind = find(fc3_loc,1) - find(frange_fc3,1) + 1;
    
    P1_fc1 = slct_P1(frange_fc1, :, :); % Dim = 3*channels*trials
    P1_fc2 = slct_P1(frange_fc2, :, :);
    P1_fc3 = slct_P1(frange_fc3, :, :);
    
    P1_fc1 = squeeze(mean(P1_fc1, 3)); % Dim = 3*channels
    P1_fc2 = squeeze(mean(P1_fc2, 3));
    P1_fc3 = squeeze(mean(P1_fc3, 3));
    
    P1_fc1 = zscore(P1_fc1, [], 1); % Dim = 3*channels
    P1_fc2 = zscore(P1_fc2, [], 1);
    P1_fc3 = zscore(P1_fc3, [], 1);
    
    final_arr = [P1_fc1(fc1_ind,:);
        P1_fc2(fc2_ind,:);
        P1_fc3(fc3_ind,:)]; % Dim = 3(fc1,fc2,fc3) * channels
    mean_final_arr = mean(final_arr, 1);
    es = mean_final_arr;
    if shouldDraw
        if createFig
            fig = figure;
        end
        plot_topography(cellstr(upper(powTopo_chansLabel)), es, 1, '10-20', 1, 0, 1000);
        title("");
        subtitle(sprintf('ES, Locked on %s', lockStr));
    end
end