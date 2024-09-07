function chans_erp = plot_erp(data, chans, befEventTime, Fs, aftEventTime)
% Assumption: data dimension = samples*channels*trials
% Assumption: chans is a row vector
chans_erp=squeeze(mean(data,3));
figure('Name','channels ERP');
totalPlots=size(chans,2);
plotsPerRow=round(sqrt(length(chans)));
totalRows=ceil(totalPlots/plotsPerRow);
t = -befEventTime + 1/Fs :1/Fs:aftEventTime;
for i=1:length(chans)
    subplot(totalRows,plotsPerRow,i);
    plot(t,chans_erp(:,chans(i)));
    xline(0,'LineStyle','--');
    title("ch"+chans(i) + " (" + chanName(chans(i)) + ")");
    xlabel('Time(s)');
    ylabel('Potential(uV)');
end
end