function pgd = pgdAlter(coeffs, phase)
    
    n = length(phase);
    k = length(coeffs);
    xloc = 1:n;
    fitted = mod(2*pi*abs(coeffs(1)).*xloc,2*pi);
    
    ro_cc = sum(sin(phase-circularMean(phase)).*sin(fitted-circularMean(fitted)))/...
        sqrt(sum(sin(phase-circularMean(phase)).^2)*sum(sin(fitted-circularMean(fitted)).^2));
    
    pgd = abs(ro_cc);
    
    
%     pgd = sum((phase-mean(phase)).*(fitted-mean(fitted)))/...
%         sqrt(sum((phase-mean(phase)).^2).*sum((fitted-mean(fitted)).^2))
    
end