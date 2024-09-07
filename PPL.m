function ppl = PPL(inst_phase, chansList, bins)
% This function computes Percent Phase Locking (PPL) value for given instantaneous phase matrix
% assumption: data(inst_phase) dimension= samples*channels*trials
% bins= number of bins for computing pk
% chansList: list of channels to compute ppl for

trials = size(inst_phase,3);
samples = size(inst_phase,1);
ppl = zeros(samples,length(chansList));
Hmax = log2(bins);
for i = chansList
    slct_phase = squeeze(inst_phase(:,i,:));
    slct_phase = slct_phase.'; %new slct_phase dimension=trials*samples
    
    counts = hist(slct_phase,bins); %dimension=bins*samples
    pk = counts/trials; %dimension=bins*samples
    pk(pk==0) = 0.0000001; %replaing 0 values in pk with a small number, thus: pk*log2(pk)~0
    disp(find(pk==0));
    H = -sum(pk.*log2(pk));
    ind = (chansList==i);
    ppl(:,ind) = 100*(1-H/Hmax);
end
end