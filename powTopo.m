function mean_topo_power = powTopo(finish, start, data, winLen, overlap, Fs, target_trials_cell, figNameLabel_cell, frange, path, lockStr, slct_befEventTime, createFig, chansLabel)
    totalLen = finish - start + 1;

    target_data = data(start:finish,:,:); %[samples*channels*trials]

    windows = round((totalLen-winLen)/(winLen*(1-overlap/100)))+1;

    topo_power = zeros(windows, size(target_data, 2), size(target_data, 3)); %Dimension = windows*channels

    sampDur = winLen;
    f = Fs*(0:floor(sampDur/2))/sampDur; %freqs to plot

    for calc = 1:length(target_trials_cell)
        target_trials = target_trials_cell{calc};
        figNameLabel = figNameLabel_cell{calc};
        for win = 1:windows
            disp("win = "+win);
            T = (win-1)*winLen*(1-overlap/100)+1 : ...
                winLen+(win-1)*winLen*(1-overlap/100);
            T = round(T);
            signal_fft = fft(target_data(T,:,:));
            P2 = abs(signal_fft/sampDur);
            P1 = P2(1:floor(sampDur/2)+1,:,:);
            P1(2:end-1,:,:) = 2*P1(2:end-1,:,:); %Dimension = freqs*channels
            topo_power(win, :, :) = mean(P1(f>=frange(1) & f<=frange(end),:,:),1);
        end

        savePath = path + "Result Figures\Power Topotgraphy\Locked on " + ...
            lockStr + "\" + "/winLen"+(winLen/Fs)+"_overlap"+overlap+"/";
        if ~isfolder(savePath)
            mkdir(savePath);
        end

        save(savePath + ...
            "powTopoData_frange["+frange(1)+","+frange(end)+"]_time["+(start/Fs-slct_befEventTime)+","+(finish/Fs-slct_befEventTime)+"]" + ...
            ".mat", "topo_power");

        mean_topo_power = squeeze(mean(topo_power(:, :, target_trials),[1,3])); %Dimension = chans*1

        targ_fc = mean(frange);

        if createFig
            figure;
            h = plot_topography(cellstr(upper(chansLabel)), mean_topo_power, true);
        else
            plot_topography(cellstr(upper(chansLabel)), mean_topo_power, 1, '10-20', 1, 0, 1000);
        end
        colormap jet;
        title("Topography for "+targ_fc+"Hz trials (" + figNameLabel + "), " + ...
            "Locked on "+lockStr+", frange["+frange(1)+","+frange(end)+"], Time ["+(start/Fs-slct_befEventTime)+" , "+(finish/Fs-slct_befEventTime)+"]s")

        if createFig
        savefig(h, savePath + "frange["+frange(1)+","+frange(end)+"]_time["+ ...
            (start/Fs-slct_befEventTime)+","+(finish/Fs-slct_befEventTime)+"]" + ...
            "_"+figNameLabel+".fig");
        end

        %************************************************************************
    end
end