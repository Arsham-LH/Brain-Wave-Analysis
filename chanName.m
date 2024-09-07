function name = chanName(chanNum)
% DESIGNED FOR 56 CHANNEL IN NEW DEVICE. CHANGE THIS FUNCTION IF SETUP CHANGED

for i = 1:length(chanNum)
    switch chanNum(i)
        case 1
            name(i) = "AF3";
        case 2
            name(i) = "AFz";
        case 3
            name(i) = "AF4";
        case 4
            name(i) = "F7";
        case 5
            name(i) = "F5";
        case 6
            name(i) = "F3";
        case 7
            name(i) = "F1";
        case 8
            name(i) = "Fz";
        case 9
            name(i) = "F2";
        case 10
            name(i) = "F4";
        case 11
            name(i) = "F6";
        case 12
            name(i) = "F8";
        case 13
            name(i) = "FT7";
        case 14
            name(i) = "FC5";
        case 15
            name(i) = "FC3";
        case 16
            name(i) = "FC1";
        case 17
            name(i) = "FCz";
        case 18
            name(i) = "FC2";
        case 19
            name(i) = "FC4";
        case 20
            name(i) = "FC6";
        case 21
            name(i) = "FT8";
        case 22
            name(i) = "T7";
        case 23
            name(i) = "C5";
        case 24
            name(i) = "C3";
        case 25
            name(i) = "C1";
        case 26
            name(i) = "Cz";
        case 27
            name(i) = "C2";
        case 28
            name(i) = "C4";
        case 29
            name(i) = "C6";
        case 30
            name(i) = "T8";
        case 31
            name(i) = "TP7";
        case 32
            name(i) = "CP5";
        case 33
            name(i) = "CP3";
        case 34
            name(i) = "CP1";
        case 35
            name(i) = "CPz";
        case 36
            name(i) = "CP2";
        case 37
            name(i) = "CP4";
        case 38
            name(i) = "CP6";
        case 39
            name(i) = "TP8";
        case 40
            name(i) = "P7";
        case 41
            name(i) = "P5";
        case 42
            name(i) = "P3";
        case 43
            name(i) = "P1";
        case 44
            name(i) = "Pz";
        case 45
            name(i) = "P2";
        case 46
            name(i) = "P4";
        case 47
            name(i) = "P6";
        case 48
            name(i) = "P8";
        case 49
            name(i) = "PO7";
        case 50
            name(i) = "PO3";
        case 51
            name(i) = "POz";
        case 52
            name(i) = "PO4";
        case 53
            name(i) = "PO8";
        case 54
            name(i) = "O1";
        case 55
            name(i) = "Oz";
        case 56
            name(i) = "O2";
        otherwise
            name(i) = "";
    end
end
end