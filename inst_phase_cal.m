function ph = inst_phase_cal(filtered_data, doWrap)
    %assumption: data dimension= samples*channels
    %output ph dimension= samples*channels
    hb = hilbert(filtered_data);
    if doWrap
        ph=wrapTo2Pi(angle(hb));
    else
          ph=unwrap(angle(hb));
%         ph = angle(hb);
    end
end