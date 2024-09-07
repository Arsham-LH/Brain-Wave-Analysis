function SC = spatial_coherence(data, chansList, T, overlap, W, f)
% Assumption: data dimension = samples*channels*trials
%Fs: sampling freq
%fmax: maximum freq to calculate SC for
%chansList: list of channels to calculate SC for
%w: NORMALIZED(*sampling rate) bandwidth for slepian functions 
%T: slepian functions (and selected signals) length (samples)
%overlap: windows' overlap (%)
%final SC dimension= trials*1


data = data(:,chansList,:);
samples = size(data,1);
channels = size(data,2); %NEW number of channels
trials = size(data,3);
windows = ceil((samples-T)/(T*(1-overlap/100))); %number of windows for each trial 


slepians=dpss(T,T*W); %dimension = T*K (K is the number of slepian functions, equals floor(2*T*W))
K=size(slepians,2); %number of slepians
t=(1:T).';


windows_SC=zeros(trials,windows); %spatial coherence for each trial and sliding window. dimension= trials*windows
SC=zeros(trials,1);%spatial coherence for each trial. dimension= trials*1

slct_V = zeros(channels,K); %dimension= channels*K

for g = 1:trials
    for win = 1:windows
        slct_data = squeeze(data((win-1)*T*(1-overlap/100)+1:T+(win-1)*T*(1-overlap/100),:,g));%dimension= T*channels
        for k=1:K
            slct_V(:,k) = sum(slct_data.*(exp(1i*2*pi*f*t).*slepians(:,k)),1).'; %dimension = sum(T*channels,1).'=(1*channels).'=channels*1        
        end
        lambda = svd(slct_V); %dimension= min(channels,K)*1=  K*1

        windows_SC(g,win) = (abs(lambda(1,1))^2)/sum(abs(lambda).^2,1);
    end
end
SC = mean(windows_SC,2); %Average across windows
end