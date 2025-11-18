function FRM = FMCtoFocused_time(IRM,c,Receive,Trans,focus,fnum,corners,filter)

% folder = 'C:\Users\jhhale\OneDrive - UW-Madison\LOCI\Jonathan\US_Clutter\2.5.2025';
% files = {'glassfmc.mat','Ibidifmc.mat','coc140fmc.mat','coc240fmc.mat','PETfmc.mat','PCfmc.mat','PMMAfmc.mat','TPX5milfmc.mat'};
% load(fullfile(folder,files{1}))


% load("C:\Users\jhhale\OneDrive - UW-Madison\QUL\Vantage-4.7.6-2206101100\speckle_FMC.mat")
% IRM = RFtoRM(RcvData,Receive);
% c=1.48;
% focus = 8.3;
% fnum = 1;
% corners = 'a_shrink';


[~,~,len] = size(IRM);
if isstruct(Receive) 
    sampleRate = Receive(1).decimSampleRate;
else
    sampleRate = Receive;
end
dt = 1/sampleRate;
ts = (0:(len-1)) * dt;
pitch = Trans.spacingMm;
xs = ((-(Trans.numelements/2 -1):(Trans.numelements/2))-0.5)*pitch;

aper = focus/fnum;
nelems = ceil(aper / pitch);
nelems = nelems - ~mod(nelems,2) %symmetric aperture
halfap = ((nelems-1)/2);

pos = xs - xs(1);
distances = sqrt(pos.^2 + focus.^2);
distances = distances - distances(1);
distances = -distances(1:nelems);
t_delays_transmit_focus = distances / c;

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


FRM = zeros(128,128,length(IRM));
for i=1:128
    
    
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
    relative_aps = aps - i;
    center_i = find(aps == i);
    FRM_temp = squeeze(IRM(i,:,:));
    small_irm = IRM(aps,:,:);
    for j=relative_aps
        if j~=0
            FRM_temp = FRM_temp + apod(j+halfap+1) * interp1(ts,squeeze(small_irm(center_i + j,:,:)).',ts - t_delays_transmit_focus(abs(j)+1)).';
        end
    end
    % FRM(i,:,:) = FRM_temp / length(aps);
    FRM(i,:,:) = FRM_temp;
%     FRM(i,:,:) = FRM_temp;
end

% FRM = FRM * nelems;

% figure()
% [das_data,xs,zs] = das(squeeze(FRM(64,:,:)),c,Trans,Receive,8.38,2,'a_shrink');
% imagesc(xs,zs,log(abs(das_data.')+1))
% colormap gray