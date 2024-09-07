function filtData_struct = BPF(bpParams, dataset, Fs)
    % Band-pass filter around stimuli freqs
    freqs_arr = bpParams.freqs_arr;
    bandw_arr = bpParams.bandw_arr;
    order = bpParams.order;

    filtData_struct.filtered_data0 = butter_bandFilt(dataset.', freqs_arr(1), bandw_arr(1), order, Fs,2, 0);
    filtData_struct.filtered_data1 = butter_bandFilt(dataset.', freqs_arr(2), bandw_arr(2), order, Fs,2, 0);
    filtData_struct.filtered_data2 = butter_bandFilt(dataset.', freqs_arr(3), bandw_arr(3), order, Fs,2, 0);

    if length(freqs_arr) == 4 %If there are more than 2 stimuli in the task
        filtData_struct.filtered_data3 = butter_bandFilt(dataset.', freqs_arr(4), bandw_arr(4), order, Fs,2, 0);
    end
end