qam = comm.RectangularQAMModulator('BitInput', true);
qamDemod = comm.RectangularQAMDemodulator('BitOutput', true);
channel = comm.AWGNChannel('BitsPerSymbol',4);
errorRate = comm.ErrorRate;
ebnoVec = [-6 -3 0 3 6 8 10 12 13 14 15 16 17 18 19];
ber = zeros(size(ebnoVec));

for k = 1:length(ebnoVec)
    
    %Reset the error counter for each Eb/No value
    reset(errorRate)
    %Reset the array used to collect the error statistics
    errVec = [0 0 0];
    %set the channel Eb/No
    channel.EbNo = ebnoVec(k);
    
    while errVec(2) < 200 && errVec(3) < 1e7
        %Generate a 1000-symbol frame
        data = randi([0 1], 4000, 1);
        %modulate the binary data
        signal = qam(data);
        %pass the modulated data through the AWGN channel
        receivedSignal = channel(signal);
        %demodulate the received signal
        receivedData = qamDemod(receivedSignal);
        %statistics
        errVec = errorRate(data, receivedData);
    end
    
    %save BER data
    ber(k) = errVec(1);
end

berTheory = berawgn(ebnoVec, 'qam', 16, 'coherent');
figure
semilogy(ebnoVec, [ber;berTheory])
xlabel('Eb/No (dB)')
ylabel('BER')
grid
legend('Simulation','Theory','location','ne')