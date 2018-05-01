fsk = comm.FSKModulator(16);
fskDemod = comm.FSKDemodulator(16);
channel = comm.AWGNChannel('BitsPerSymbol',4);
errorRate = comm.ErrorRate;
ebnoVec = [-6 -3 0 3 6 8 10 12 13 14 15 16 17 18 19];
ber = zeros(size(ebnoVec));

for k = 1:length(ebnoVec)
    reset(errorRate)
    errVec = [0 0 0];
    channel.EbNo = ebnoVec(k);
    
    while errVec(2) < 200 && errVec(3) < 1e7
        data = randi([0 1], 4000, 1);
        signal = fsk(data);
        receivedSignal = channel(signal);
        receivedData = fskDemod(receivedSignal);
        errVec = errorRate(data, receivedData);
    end
    
    %save first element of ber vect (numerrs)
    ber(k) = errVec(1);
end

berTheory = berawgn(ebnoVec, 'fsk', 16, 'nondiff');
figure
semilogy(ebnoVec, [ber;berTheory])
title('BER vs. Eb/No');
xlabel('Eb/No (dB)')
ylabel('BER')
grid
legend('Simulation','Theory','location','ne')