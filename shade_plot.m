function p = shade_plot(x, y, lineStyle, linewidth, shade_color)
    %****************Assumptions***************
    %x dimension = samples * 1 (sample = any quantity that forms x axis)
    
    %y dimension = samples * trials (trials can be anything else on which you 
    % want to average, and also calculate shades

    %lineStyle is a string like ':' or '--'
    %shade_color is a string like 'blue'
    %***************************************************
    if size(x,1) == 1
        x = x.'; %Transposing x if it is given as a row vector
    end
    
    mean_y = squeeze(mean(y, 2));
    std_y = squeeze(std(y, [] , 2));
    n = size(y, 2);
    
    xBetween=[x; flipud(x)];
%     disp(size(xBetween,1));
%     disp(size(xBetween,2));
    
    
    lowShade = mean_y - std_y / sqrt(n);
    upShade = mean_y + std_y / sqrt(n);
    
    yBetween = [lowShade; flipud(upShade)];
%     disp(size(yBetween,1));
%     disp(size(yBetween,2));


    p = plot(x, mean_y, lineStyle, 'Linewidth', linewidth);
    hold on;
    fill(xBetween, yBetween, shade_color,'LineStyle','none','FaceAlpha',0.1, ...
        'handlevisibility','off');
end