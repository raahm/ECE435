M = 16;
k = log2(M);
n = 30000;

% defining vector of Eb/No values to be tested
ebnoVec = [-6 -3 0 3 6 8 10 12 13 14 15 16 17 18 19];

% Generating data vector
rng default
data = randi([0 1], n, 1);
dataInMatrix = reshape(data, length(data)/k, k);
dataSymbolsIn = bi2de(dataInMatrix);

dataMod = pskmod(dataSymbolsIn,M);

for i = 1:length(ebnoVec)
    snr = ebnoVec(i) + 10*log10(k) - 10*log10(numSamplesPerSymbol);
    receivedSignal = awgn(dataMod, snr,'measured');
    dataSymbolsOut = pskdemod(receivedSignal, M);
    dataOutMatrix = de2bi(dataSymbolsOut, k);
    dataOut = dataOutMatrix(:);
    [numErrorsBer,berVec(i)] = biterr(data,dataOut);
    [numErrorsSer,serVec(i)] = symerr(dataSymbolsIn, dataSymbolsOut);
end

% snr = 19 + 10*log10(k) - 10*log10(numSamplesPerSymbol);
% receivedSignal = awgn(dataMod, snr,'measured');
% scatterplot(receivedSignal)
% scatterplot(dataMod)
[berTheory,serTheory] = berawgn(ebnoVec, 'qam', 16);
figure
semilogy(ebnoVec, [berVec;berTheory])
title('BER vs. Eb/No')
xlabel('Eb/No (dB)')
ylabel('BER')
grid
legend('Simulation','Theory','location','ne')

figure
semilogy(ebnoVec, [serVec;serTheory])
title('SER vs. Eb/No')
xlabel('Eb/No (dB)')
ylabel('SER')
grid
legend('Simulation','Theory','location','ne')

