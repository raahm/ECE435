clear
clc

% defining QAM parameters
M = 16;
j = log2(M);
numSamplesPerSymbol = 1;

ebnoVec = [-6 -3 0 3 6 8 10 12 13 14 15 16 17 18 19];
berVec = zeros(size(ebnoVec));

n = 15;
k = 11;
p1 = [0;0;0;0;1;1;1;1;1;1;1];
p2 = [0;1;1;1;0;0;0;1;1;1;1];
p3 = [1;0;1;1;0;1;1;0;0;1;1];
p4 = [1;1;0;1;1;0;1;0;1;0;1];
i = eye(11);
G = [p1 p2 p3 p4 i];
encode = [];
for i = 1:30000
    data = randi([0 1],k,1)';
    encode = [encode mod(data*G, 2)];
end
encode = matintrlv(encode, 30000, n);
% encode = [encode(1:15) ; encode(16:30) ; encode(31:45) ; encode(46:60)];

encodeMatrix = reshape(encode, length(encode) / j, j);
dataSymbolsIn = bi2de(encodeMatrix);
dataMod = qammod(dataSymbolsIn, M, 'gray');

for i = 1:length(ebnoVec)
    snr = ebnoVec(i) + 10*log10(j) - 10*log10(numSamplesPerSymbol);
    receivedSignal = awgn(dataMod, snr, 'measured');
    dataSymbolsOut = qamdemod(receivedSignal, M, 'gray');
    dataOutMatrix = de2bi(dataSymbolsOut,j);
    dataOut = dataOutMatrix(:);
    encodeCol = encode';
    [numErrors,berVec(i)] = biterr(encodeCol,dataOut);    
end

berTheory = berawgn(ebnoVec, 'qam', 16);

figure
semilogy(ebnoVec, [berVec;berTheory])
xlabel('Eb/No (dB)')
ylabel('BER')
grid