function RM = FMCtoFocused_frequency(IRM,c,Receive,Trans,focus,fnum,corners,filter,varargin)

% folder = 'C:\Users\jhhale\OneDrive - UW-Madison\LOCI\Jonathan\US_Clutter\2.5.2025';
% files = {'glassfmc.mat','Ibidifmc.mat','coc140fmc.mat','coc240fmc.mat','PETfmc.mat','PCfmc.mat','PMMAfmc.mat','TPX5milfmc.mat'};
% load(fullfile(folder,files{1}))


% load("C:\Users\jhhale\OneDrive - UW-Madison\QUL\Vantage-4.7.6-2206101100\speckle_FMC.mat")
% IRM = RFtoRM(RcvData,Receive);
% c=1.48;
% focus = 14;
% fnum = 2;
% corners = 'a_shrink';




[~,~,len] = size(IRM);
if isstruct(Receive) 
    sampleRate = Receive(1).decimSampleRate;
else
    sampleRate = Receive;
end
pitch = Trans.spacingMm;
xs = ((-(Trans.numelements/2 -1):(Trans.numelements/2))-0.5)*pitch;
TM = fftshift(fft(IRM,len,3),3);
fs = sampleRate * (-(len/2):(len/2-1))/len;


aper = focus/fnum;
nelems = ceil(aper / pitch);
nelems = nelems - ~mod(nelems,2); %symmetric aperture
nelems

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



pos = xs - xs(1);
distances = sqrt(pos.^2 + focus.^2);
distances = distances - distances(1);
distances = -distances(1:nelems);
t_delays_transmit_focus = distances / c;
% t_delays_aperature = nelems;
halfap = ((nelems-1)/2);

modulations = exp(-1j * 2*pi*t_delays_transmit_focus' * fs);
modulations = [flipud(modulations(2:end,:)) ; modulations];
tic;

FRM = zeros(Trans.numelements,Trans.numelements,length(fs));
for i=1:Trans.numelements
    
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
    
    mod_temp = modulations(aps - i + nelems,:);
    mod_temp = reshape(mod_temp,length(aps),1,[]);
    FRM(i,:,:) = sum((mod_temp.*TM(aps,:,:)).*apod(aps-i+(nelems-1)/2+1),1) / length(aps);
    FRM(i,:,:) = sum((mod_temp.*TM(aps,:,:)).*apod(aps-i+(nelems-1)/2+1),1);
%     FRM(i,:,:) = sum(mod_temp.*TM(aps,:,:),1);
    
end

% RM = ifft(ifftshift(squeeze(FRM),3),len,3);
% RM = ifft(ifftshift(squeeze(FRM),3),len,3) * nelems;
% RM = ifft(ifftshift(squeeze(FRM),3),len,3) * nelems / 2.2892;

normalizing_factors =  [2.8241    2.2829
                        2.5456    2.3974
                        2.3781    2.3455
                        2.3565    2.3739
                        2.5010    2.0133
                        2.6933    2.4905
                        1.9313    2.1207]; %dry, then wet. Makes the peaks of the rayline and safb the same height. 
if numel(varargin) == 0
    factor = 1;
else
    factor = normalizing_factors(varargin{1},varargin{2});
end

% RM = ifft(ifftshift(squeeze(FRM),3),len,3) * nelems / factor;
RM = ifft(ifftshift(squeeze(FRM),3),len,3);

% toc
% 
% FRM = RM;
% 
% 
% figure()
% [das_data,xs,zs] = das(squeeze(FRM(64,:,:)),c,Trans,Receive,8.38,2,'s_shrink');
% imagesc(xs,zs,log(abs(das_data.')+1))
% colormap gray