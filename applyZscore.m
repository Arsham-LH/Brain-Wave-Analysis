function z_data = applyZscore(dataset)
    if ndims(dataset) == 2
        [z_data, mu, sigma] = zscore(dataset, [] , 2);
    elseif ndims(dataset) == 3
        [z_data, mu, sigma] = zscore(dataset, [] , 1);
    end
%     [site1_norm, mu, sigma] = zscore(site1, [], 2);
%     [site2_norm, mu, sigma] = zscore(site2, [], 2);
%     [site3_norm, mu, sigma] = zscore(site3, [], 2);
%     [site4_norm, mu, sigma] = zscore(site4, [], 2);
%     [site5_norm, mu, sigma] = zscore(site5, [], 2);
%     [site6_norm, mu, sigma] = zscore(site6, [], 2);
end