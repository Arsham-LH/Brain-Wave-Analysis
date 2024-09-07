function filt_data = butter_bandFilt(order, fc, bandw, Fs, plotFreqz, dim, data)
    %assumption: data dimension=samples*channels, or samples*channels*trials
    %(depends on dim==2 or 3)
    % [b,a]=butter(order,[fc-bandw,fc+bandw]/(Fs/2),'bandpass');
    % figure;
    % freqz(b,a);
    %filt_data=filter(b,a,data,[],2); %dimension=samples*channels

    butter_filt=designfilt('bandpassiir','FilterOrder',order,...
        'HalfPowerFrequency1',fc-bandw/2,'HalfPowerFrequency2',fc+bandw/2,'SampleRate',Fs,'DesignMethod','butter');
    if (plotFreqz)
        freqz(butter_filt);
    end
    %     fvtool(butter_filt);
    if (dim==2)
        filt_data=filter(butter_filt,data); %dimension=samples*channels
    else
        filt_data=zeros(size(data,1),size(data,2),size(data,3));
        trials=size(data,3);
        for i=1:trials
            filt_data(:,:,i)=filter(butter_filt,data(:,:,i));
        end
    end
end