function meanTheta = circularMean(theta)


    num = sum(sin(theta));
    denum = sum(cos(theta));
    
    meanTheta = atan2(num,denum);
end