function RM = RFtoRM(RcvData,Receive)
    i1 = Receive(2).startSample;
    i2 = Receive(2).endSample;
    len = i2-i1+1;
    rawdata = double(squeeze(RcvData{1,1}(1:128*len,:,1))).';
    % data = reshape(data,len,128,128);
    RM = zeros(128,128,len);
    for i = 1:128
        i1 = Receive(i).startSample;
        i2 = Receive(i).endSample;
        RM(i,:,:) = hilbert(rawdata(:,i1:i2).').';
        % RM(i,:,:) = rawdata(:,i1:i2);
    end

end
