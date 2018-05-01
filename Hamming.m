% clear
% clc
% 
% % defining QAM parameters
% M = 16;
% j = log2(M);
% numSamplesPerSymbol = 1;
% 
% ebnoVec = [-6 -3 0 3 6 8 10 12 13 14 15 16 17 18 19];
% berVec = zeros(size(ebnoVec));
% 
% n = 15;
% k = 11;
% p1 = [0;0;0;0;1;1;1;1;1;1;1];
% p2 = [0;1;1;1;0;0;0;1;1;1;1];
% p3 = [1;0;1;1;0;1;1;0;0;1;1];
% p4 = [1;1;0;1;1;0;1;0;1;0;1];
% i = eye(11);
% G = [p1 p2 p3 p4 i];
% encode = [];
% for i = 1:30000
%     data = randi([0 1],k,1)';
%     encode = [encode mod(data*G, 2)];
% end
% encode = matintrlv(encode, 30000, n);
% % encode = [encode(1:15) ; encode(16:30) ; encode(31:45) ; encode(46:60)];
% 
% encodeMatrix = reshape(encode, length(encode) / j, j);
% dataSymbolsIn = bi2de(encodeMatrix);
% dataMod = qammod(dataSymbolsIn, M, 'gray');
% 
% for i = 1:length(ebnoVec)
%     snr = ebnoVec(i) + 10*log10(j) - 10*log10(numSamplesPerSymbol);
%     receivedSignal = awgn(dataMod, snr, 'measured');
%     dataSymbolsOut = qamdemod(receivedSignal, M, 'gray');
%     dataOutMatrix = de2bi(dataSymbolsOut,j);
%     dataOut = dataOutMatrix(:);
%     encodeCol = encode';
%     [numErrors,berVec(i)] = biterr(encodeCol,dataOut);    
% end
% 
% berTheory = berawgn(ebnoVec, 'qam', 16);
% 
% figure
% semilogy(ebnoVec, [berVec;berTheory])
% xlabel('Eb/No (dB)')
% ylabel('BER')
% grid

clear
clc

clear
clc

% defining QAM parameters
M = 16;
j = log2(M);
numSamplesPerSymbol = 1;

ebnoVec = [-6 -3 0 3 6 8 10 12 13 14 15 16 17 18 19];
berVec = zeros(size(ebnoVec));
berVecNotEncoded = zeros(size(ebnoVec));

n = 15;
k = 11;
p1 = [0;0;0;0;1;1;1;1;1;1;1];
p2 = [0;1;1;1;0;0;0;1;1;1;1];
p3 = [1;0;1;1;0;1;1;0;0;1;1];
p4 = [1;1;0;1;1;0;1;0;1;0;1];
i = eye(11);
G = [p1 p2 p3 p4 i];
encode = [];
dataVec = [];
for i = 1:4
    data = randi([0 1],k,1)';
    dataVec = [dataVec data];
    encode = [encode mod(data*G, 2)];
end
encode = matintrlv(encode, 4, n);
H = eye(4);
p = [p1' ; p2' ; p3'; p4'];
H = [H p];
decode = [];

dataInMatrixNotEncoded = reshape(dataVec, length(dataVec)/j, j);
dataSymbolsInNotEncoded = bi2de(dataInMatrixNotEncoded);
dataModNotEncoded = qammod(dataSymbolsInNotEncoded, M, 'gray');

for i = 1:length(ebnoVec)
    snr = ebnoVec(i) + 10*log10(j) - 10*log10(numSamplesPerSymbol);
    receivedSignalNotEncoded = awgn(dataModNotEncoded, snr, 'measured');
    dataSymbolsOutNotEncoded = qamdemod(receivedSignalNotEncoded, M, 'gray');
    dataOutMatrixNotEncoded = de2bi(dataSymbolsOutNotEncoded,j);
    dataOutNotEncoded = dataOutMatrixNotEncoded(:);
    dataVecCol = dataVec';
    [numErrorsNotEncoded,berVecNotEncoded(i)] = biterr(dataVecCol,dataOutNotEncoded);    
end

berTheory = berawgn(ebnoVec, 'qam', 16);

figure
semilogy(ebnoVec, [berVecNotEncoded;berTheory])
title('BER for Non-Encoded Data')
xlabel('Eb/No (dB)')
ylabel('BER')
grid

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
    
    for i = 0:2
    decode = [decode mod(H*(dataOut(60*(i/4)+1:60*((i+1)/4))), 2)];
    end
    decode = [decode mod(H*(dataOut(46:60)), 2)];
    decode
    dec1 = decode(:, 1);
    dec2 = decode(:, 2);
    dec3 = decode(:, 3);
    dec4 = decode(:, 4);
    ind1 = 0;
    ind2 = 0;
    ind3 = 0;
    ind4 = 0;
    for i = 1:15
        if dec1 == H(:,i)
        ind1 = i;
        end
        if dec2 == H(:,i)
            ind2 = i;
        end
        if dec3 == H(:,i)
            ind3 = i;
        end
        if dec4 == H(:,i)
            ind4 = i;
        end
    end

    % fix encoded message
    if (ind1 ~= 0)
        dataOut(ind1) = mod((dataOut(ind1)+1),2); 
    end
    if (ind2 ~= 0)
        dataOut(15+ind2) = mod((dataOut(15+ind2)+1),2); 
    end
    if (ind3 ~= 0)
        dataOut(30+ind3) = mod((dataOut(30+ind3)+1),2); 
    end
    if (ind4 ~= 0)
        dataOut(45+ind4) = mod((dataOut(45+ind4)+1),2); 
    end

% decode = [];
% for i = 0:3
%     decode = [decode mod(H*(dataOut(60*(i/4)+1:60*((i+1)/4)))', 2)];
% end
% decode
% the encoded message has been corrected meaning that the decoded message
% should be all zeros.

    dataOutVec = [];
    for count = 1:11
        dataOutVec(count) = dataOut(count);
    end

    for count = 16:26
        dataOutVec(count - 4) = dataOut(count);
    end

    for count = 31:41
        dataOutVec(count-8) = dataOut(count);
    end

    for count = 46:56;
        dataOutVec(count-12) = dataOut(count);
    end
    [numErr, berVec(i)] = biterr(dataVec, dataOutVec);
end




% for i = 0:2
%     decode = [decode mod(H*(dataOut(60*(i/4)+1:60*((i+1)/4))), 2)];
% end
% decode = [decode mod(H*(dataOut(46:60)), 2)];
% decode
% dec1 = decode(:, 1);
% dec2 = decode(:, 2);
% dec3 = decode(:, 3);
% dec4 = decode(:, 4);
% ind1 = 0;
% ind2 = 0;
% ind3 = 0;
% ind4 = 0;
% for i = 1:15
%     if dec1 == H(:,i)
%         ind1 = i;
%     end
%     if dec2 == H(:,i)
%         ind2 = i;
%     end
%     if dec3 == H(:,i)
%         ind3 = i;
%     end
%     if dec4 == H(:,i)
%         ind4 = i;
%     end
% end
% 
% % fix encoded message
% if (ind1 ~= 0)
%   dataOut(ind1) = mod((dataOut(ind1)+1),2); 
% end
% if (ind2 ~= 0)
%   dataOut(15+ind2) = mod((dataOut(15+ind2)+1),2); 
% end
% if (ind3 ~= 0)
%   dataOut(30+ind3) = mod((dataOut(30+ind3)+1),2); 
% end
% if (ind4 ~= 0)
%   dataOut(45+ind4) = mod((dataOut(45+ind4)+1),2); 
% end
% 
% % decode = [];
% % for i = 0:3
% %     decode = [decode mod(H*(dataOut(60*(i/4)+1:60*((i+1)/4)))', 2)];
% % end
% % decode
% % the encoded message has been corrected meaning that the decoded message
% % should be all zeros.
% 
% dataOutVec = [];
% for count = 1:11
%     dataOutVec(count) = dataOut(count);
% end
% 
% for count = 16:26
%     dataOutVec(count - 4) = dataOut(count);
% end
% 
% for count = 31:41
%     dataOutVec(count-8) = dataOut(count);
% end
% 
% for count = 46:56;
%     dataOutVec(count-12) = dataOut(count);
% end

% [endErr = biterr(dataVec, dataOutVec);
berapprox = bercoding(ebnoVec, 'Hamming','hard',15)


figure
semilogy(ebnoVec, [berVec;berapprox])
title('BER for Encoded Data')
xlabel('Eb/No (dB)')
ylabel('BER')
grid