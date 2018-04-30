% Defining elements for QAM modulation
M = 16;
k = log2(M);
n = 300000;
numSamplesPerSymbol = 1;

% defining vector of Eb/No values to be tested
ebnoVec = [-6 -3 0 3 6 8 10 12 13 14 15 16 17 18 19];

% defining vector for BER
berVec = zeros(size(ebnoVec));

% Generating data vector
rng default
data = randi([0 1], n, 1);
dataInMatrix = reshape(data, length(data)/k, k);
dataSymbolsIn = bi2de(dataInMatrix);

dataMod = qammod(dataSymbolsIn, M, 'bin');

for i = 1:length(ebnoVec)
    snr = ebnoVec(i) + 10*log10(k) - 10*log10(numSamplesPerSymbol);
    receivedSignal = awgn(dataMod, snr,'measured');
    dataSymbolsOut = qamdemod(receivedSignal, M, 'bin');
    dataOutMatrix = de2bi(dataSymbolsOut, k);
    dataOut = dataOutMatrix(:);
    [numErrors,berVec(i)] = biterr(data,dataOut);
end

% snr = 19 + 10*log10(k) - 10*log10(numSamplesPerSymbol);
% receivedSignal = awgn(dataMod, snr,'measured');
% scatterplot(receivedSignal)
% scatterplot(dataMod)
berTheory = berawgn(ebnoVec, 'qam', 16);
figure
semilogy(ebnoVec, [berVec;berTheory])
xlabel('Eb/No (dB)')
ylabel('BER')
grid
legend('Simulation','Theory','location','ne')