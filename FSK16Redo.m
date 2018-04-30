M = 16;
k = log2(M);
n = 30000;
numSamplesPerSymbol = 16;
Fs = 360;
freq_sep = 10;

ebnoVec = [-6 -3 0 3 6 8 10 12 13 14 15 16 17 18 19];

berVec = zeros(size(ebnoVec));

rng default
data = randi([0 M-1],n,1);
dataInMatrix = reshape(data,length(data)/k,k);
dataSymbolsIn = bi2de(dataInMatrix);

dataMod = fskmod(data,M,freq_sep,numSamplesPerSymbol, Fs);

for i = 1:length(ebnoVec)
    snr = ebnoVec(i) + 10*log10(k) - 10*log10(numSamplesPerSymbol);
    receivedSignal = awgn(dataMod, snr,'measured');
    dataSymbolsOut = fskdemod(receivedSignal, M,freq_sep,numSamplesPerSymbol,Fs);
    dataOutMatrix = de2bi(dataSymbolsOut, k);
    dataOut = dataOutMatrix(:);
    [numErrors,berVec(i)] = biterr(data,dataOut);
end

berTheory = berawgn(ebnoVec, 'fsk', 16, coherent);
figure
semilogy(ebnoVec, [berVec;berTheory])
xlabel('Eb/No (dB)')
ylabel('BER')
grid
legend('Simulation','Theory','location','ne')