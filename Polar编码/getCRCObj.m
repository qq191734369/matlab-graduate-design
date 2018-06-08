function [CRCEncObj, CRCDecObj] = getCRCObj(crcLen)
switch crcLen
    case 0
        CRCEncObj = 0;
        CRCDecObj = 0;
    case 6
        CRCEncObj = comm.CRCGenerator('Polynomial',de2bi(hex2dec('43')));
        CRCDecObj = comm.CRCDetector('Polynomial',de2bi(hex2dec('43')));
    case 11
        CRCEncObj = comm.CRCGenerator('Polynomial',de2bi(hex2dec('847')));
        CRCDecObj = comm.CRCDetector('Polynomial',de2bi(hex2dec('847')));
    case 24
        CRCEncObj = comm.CRCGenerator('Polynomial',de2bi(hex2dec('1D11A9B')));
        CRCDecObj = comm.CRCDetector('Polynomial',de2bi(hex2dec('1D11A9B')));
    otherwise
        error('CRC length not supported')
end
end