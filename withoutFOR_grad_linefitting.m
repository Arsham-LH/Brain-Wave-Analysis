function coeffs = withoutFOR_grad_linefitting(phase)
   
% for pgd measure
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% numerical %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xloc = 1:length(phase); %Dimesion = 1*locs

coeff1 = -0.9999999999:0.01:0.9999999999; %= a. Dimension = 1*coeffs
% remove slope zero
coeff1(find(coeff1 == 0)) = [];

error = zeros(1,length(coeff1));

tmp_mat = (coeff1.') * xloc; %dimension = coeffs*locs

error = sqrt((mean(cos(phase - 2*pi*tmp_mat), 2)).^2 + ...
    (mean(sin(phase - 2*pi*tmp_mat), 2)).^2).';

max_err_ind = find(error >= (max(error) - 0.01));
% disp("max_err_ind = " + max_err_ind);
% disp("max_err = " + error(max_err_ind));
% 
% disp("coeff1 = " + coeff1(max_err_ind));
% 
[~, coeff1_final_ind] = min(abs(coeff1(max_err_ind)));
% disp("coeff1_final_ind = " + coeff1_final_ind);

coeff1_final = coeff1(max_err_ind(coeff1_final_ind)); % = a^
% disp("coeff1_final = " + coeff1_final);


% figure;
% plot(coeff1,error)
% hold on;
% scatter(coeff1_final,error(find(coeff1 == coeff1_final)))
% hold off;
% pause(0.1);
% close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% gradient descent %%%%%%%%%%%%%%%%%%%%%%%%%
%     coeffs = rand(1,2)-0.3;
%     LR = 0.01;
%     xloc = 1:length(phase);
%     
%     [err, MSE_val] = MSE_pfit(coeffs, xloc, phase);
%     
%     i = 1;
%     MSE_val1 = MSE_val;
%     % gradient ascent
%     while MSE_val < 0.9 && i < 1000
% %         MSE_val
%         coeffs(1) = coeffs(1) + LR*err;
%         if(coeffs(1) < -0.3)
%             coeffs(1) = rand(1,1)-0.3;
%         elseif(coeffs(1) > 0.3)
%             coeffs(1) = rand(1,1)-0.3;
%         end
%         [err, MSE_val] = MSE_pfit(coeffs, xloc, phase);
%         i = i+1;
%     end
%      [MSE_val1 MSE_val]

%%%%%%%%%%%%%%%%%%%%%%%%% MATLAB FUNCTION %%%%%%%%%%%%%%%%%%%%%%%%%
%     xloc = 1:length(phase);
%     coeffs = polyfit(xloc,phase,1);

%%%%%% offest

num = sum(sin(phase-2*pi*coeff1_final.*xloc));
denum = sum(cos(phase-2*pi*coeff1_final.*xloc));

coeff2 = atan2(num,denum); % = fi0^

coeffs = [coeff1_final coeff2];
end