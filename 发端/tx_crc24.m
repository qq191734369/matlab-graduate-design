function ret = tx_crc24(bits)
poly = [1 1 0 0 0 0 1 1 0 0 1 0 0 1 1 0 0 1 1 1 1 1 1 1 1]';
bits = bits(:);

% Flip first 24 bits
bits(1:24) = 1 - bits(1:24);
% Add 24 zeros at the back
bits = [bits; zeros(24,1)];

% Initialize remainder to 0
rem = zeros(24,1);
% Main compution loop for the CRC32
for i = 1:length(bits)
    rem = [rem; bits(i)]; %#ok<AGROW>
    if rem(1) == 1
        rem = xor(rem,poly);%mod(rem + poly, 2);
    end
    rem = rem(2:25);
end

% Flip the remainder before returning it
ret = (1 - rem).';
end

