function [wt, f, coi] = cal_cwt(data, wname, Fs)
    % take Continuous Wavelet Transform of a data with n_sample*n_channels*n_trials and average over all
    % trials
    wt = 0;
    
    n_channels = size(data,2);
    n_trials = size(data,3);
    
    for i = 1:n_channels
        for j = 1:n_trials
            fprintf("Now calculating cwt of chann " + i + " , trial " + j + "\n");
            selected_data = squeeze(data(:,i,j));
            [wt_temp, f,coi] = cwt(selected_data, wname, Fs);
            wt = wt + abs(wt_temp);
        end
    end
    wt = wt./(n_trials*n_channels);
end