function [low_shade, up_shade, plv] = PLV(phaseMat1, phaseMat2, shufflesNum, doShade)
    %**********************Phase-Locking Value**************************

    % Assumption: phaseMat dimension = samples*trials.
    % Assumption: the dimensions of phaseMat1 & phaseMat2 are equal in size
    % Output plv dimension = 1*trials

    low_shade = 0;
    up_shade = 0;

    n = size(phaseMat1,1);
    plv = abs(sum( exp(1i*(phaseMat1-phaseMat2)), 1) / n);

    if shufflesNum > 0        
        bg_plv = 0;
        for i = 1:shufflesNum
% %*************If you want to shuffle across samples:***************
%             shufMat1 = phaseMat1(randperm(size(phaseMat1,1)), :); %random shuffling for the order of videos
%             shufMat2 = phaseMat2(randperm(size(phaseMat2,1)), :); %random shuffling for the order of videos
%             bg_plv = bg_plv + abs(sum( exp(1i*(shufMat1-shufMat2)), 1) / n);
% %******************************************************************

%*************If you want to shuffle across trials:***************
            tmp_arr = randperm(size(phaseMat2,2));

            %Making sure that all trials are moved from their main place:
            while ~isempty(find(tmp_arr == 1:size(phaseMat2,2), 1)) 
                tmp_arr = randperm(size(phaseMat2,2));
            end

            shufMat2 = phaseMat2(:, tmp_arr); %random shuffling for the order of videos
            
            bg_plv = bg_plv + abs(sum( exp(1i*(phaseMat1-shufMat2)), 1) / n);
%*****************************************************************

        end
        bg_plv = bg_plv / shufflesNum;
        plv = plv - bg_plv;
    end

    if doShade
        low_shade = mean(plv) - std(plv) / sqrt(length(plv));
        up_shade = mean(plv) + std(plv) / sqrt(length(plv));
    end
end