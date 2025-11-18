function [das_data,xs,zs] = das(RM,t_start,c,Trans,Receive,focus,fnum,corners,filter)

%RM is the response matrix of whatever imaging sequence chosen, sampled at frequency found in the recieve struct. 
%t_start,what time does the data of RM start? in microseconds
%c, speed of sound, mm/us
% Trans, struct with transducer geometry and system info, as found in
% verasonics. 
%recieve, verasonics struct, though used only to get the sampling
%freqeuncy. MHz
%focus, what is the recieve focus, in mm?
%what is the fnum? chances how many elements are used in reconstruction for
%each aperture
%corners, how to treat the edges of the trasndcuer.

% uses linear interpolation to delay rf lines appropriately and sum them.


if length(size(RM)) == 3

    [~,~,len] = size(RM);
    pitch = Trans.spacingMm;
    if isstruct(Receive) 
        sampling_frequency = Receive(1).decimSampleRate;
    else
        sampling_frequency = Receive;
    end
    dt = 1/sampling_frequency; %in microseconds
    ts = t_start + (dt * (0:(len-1)));
    
    if fnum ==0
        maxaper = Trans.numelements-1;
    else
        aper = focus/fnum;
        nelems = ceil(aper / pitch);
        nelems = nelems + ~mod(nelems,2); %symmetric aperture
        maxaper = nelems;
        if maxaper >Trans.numelements-1
            maxaper = Trans.numelements-1;
        end
    end

    if strcmp(filter,'boxcar')
        apod = ones(nelems,1);
    elseif strcmp(filter,'hanning')
        apod = hann(nelems);
    elseif strcmp(filter,'hamming')
        apod = hamming(nelems);
    elseif strcmp(filter,'blackman')
        apod = blackman(nelems);
    elseif strcmp(filter,'flattopwin')
        apod = flattopwin(nelems);
    else
        disp('filter must be boxcar, hanning, hamming, blackman or flattopwin')
    end
    
    halfap = ((maxaper-1)/2);
    deltam = pitch;
    deltams = (0:(maxaper-1))*deltam;
    ts_temp = repmat(ts,length(deltams),1).';
    t_delays = 0.5*(ts_temp + sqrt(ts_temp.^2 + 4*(deltams/c).^2)).';
    
    
    
    xs = ((-(Trans.numelements/2 -1):(Trans.numelements/2))-0.5)*Trans.spacingMm;
    zs = ts * c /2;
    
    
    das_data = zeros(length(xs),length(zs));
    for i =1:length(xs)
        
        if strcmp(corners,'full')
        % Asymmetric, full aperture
            aps = i + (-halfap:halfap);
            aps = aps - sum(aps > Trans.numelements) + sum(aps<1);
        elseif strcmp(corners,'a_shrink')   
        % Asymmetric, shrinking aperture
            aps = i + (-halfap:halfap);
            aps = aps((aps>=1) & (aps <= Trans.numelements));
        elseif strcmp(corners,'s_shrink')
        % Symmetric shrinking aperture
            aps = i + (-halfap:halfap);
            aps = aps((aps>=1) & (aps <= Trans.numelements));
            if sum(aps<i) < sum(aps>i)
                aps = aps(1:(2*sum(aps<i) +1));
            elseif sum(aps<i) > sum(aps>i)
                aps = aps((end - 2*sum(aps>i)):end);
            end
        end
        
        relative_aps = aps-i;
        
        temp_das = zeros(1,length(zs));
        send_to_parfor_RM = squeeze(RM(i,:,:));
        % delayed_lines_to_sum = zeros(length(aps),length(zs));
        for j=relative_aps
            % delayed_lines_to_sum(j+i+1,:) = interp1(ts,send_to_parfor_RM(i+j,:),t_delays(1 + abs(j),:));
            temp_das = temp_das + apod(j+halfap +1)* interp1(ts,send_to_parfor_RM(i+j,:),t_delays(1 + abs(j),:));   
        end
        % channels{i} = delayed_lines_to_sum;
        temp_das = temp_das / length(aps);
        
        das_data(i,:) = temp_das;
    end

else
    [~,len] = size(RM);
    pitch = Trans.spacingMm;
    if isstruct(Receive) 
        sampling_frequency = Receive(1).decimSampleRate;
    else
        sampling_frequency = Receive;
    end
    dt = 1/sampling_frequency; %in microseconds
    ts = t_start + (dt * (0:(len-1)));

    aper = focus/fnum;
    nelems = ceil(aper / pitch);
    nelems = nelems + ~mod(nelems,2); %symmetric aperture

    maxaper = nelems;
    halfap = ((maxaper-1)/2);
    deltam = pitch;
    deltams = (0:(maxaper-1))*deltam;
    ts_temp = repmat(ts,length(deltams),1)';
    t_delays = 0.5*(ts_temp + sqrt(ts_temp.^2 + 4*(deltams/c).^2))';



    xs = ((-(Trans.numelements/2 -1):(Trans.numelements/2))-0.5)*pitch;
    zs = ts * c /2;

    das_data = zeros(length(xs),length(zs));
    for i =1:length(xs)
        
        
        if strcmp(corners,'full')
        % Asymmetric, full aperture
            aps = i + (-halfap:halfap);
            aps = aps - sum(aps > Trans.numelements) + sum(aps<1);
        elseif strcmp(corners,'a_shrink')   
        % Asymmetric, shrinking aperture
            aps = i + (-halfap:halfap);
            aps = aps((aps>=1) & (aps <= Trans.numelements));
        elseif strcmp(corners,'s_shrink')
        % Symmetric shrinking aperture
            aps = i + (-halfap:halfap);
            aps = aps((aps>=1) & (aps <= Trans.numelements));
            if sum(aps<i) < sum(aps>i)
                aps = aps(1:(2*sum(aps<i) +1));
            elseif sum(aps<i) > sum(aps>i)
                aps = aps((end - 2*sum(aps>i)):end);
            end
        end
        
        relative_aps = aps-i;
        
        temp_das = zeros(1,length(zs));
        
        for j=relative_aps
            temp_das = temp_das + interp1(ts,RM(i+j,:),t_delays(1 + abs(j),:));   
        end
        temp_das = temp_das / length(aps);
        
        das_data(i,:) = temp_das;
    end

end

end