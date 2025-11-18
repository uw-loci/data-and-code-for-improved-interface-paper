set(0, 'DefaultAxesFontName', 'Times New Roman');
set(0, 'DefaultTextFontName', 'Times New Roman');

%%load all the data

load ../../Data/processed_thin_film_reflection_waveforms/tpxdata30.mat
tpxdata = data;
tpxorder = order;
tpxorder = {"PMP", "0.25mm Matte", "0.5mm Gloss", "0.5mm Matte"};

load ../../Data/processed_thin_film_reflection_waveforms/pc.pet.data.mat
pcpetdata = data;
pcpetorder = order;

load ../../Data/processed_thin_film_reflection_waveforms/cop.pmma.pdms.mat
coppmmapdmsdata = data;
coppmmapdmsorder = order;

load ../../Data/processed_thin_film_reflection_waveforms/ibidi_coc6013_8007.mat
ibidicocdata = data;
ibidicocorder = {"Ibidi\newlineuncoated", "COC\newline6013", "COC"};

load ../../Data/processed_thin_film_reflection_waveforms/glass.mat
glass = data;


data = [tpxdata pcpetdata coppmmapdmsdata ibidicocdata {glass}];
order = [tpxorder pcpetorder coppmmapdmsorder ibidicocorder 'Glass'];
order{7} = "Ibidi";
order{5} = "PC";
order{6} = "PET";
order{8} = "PMMA";

data(9) = [];
order(9) = [];
%% Process reflection coefficients and attenuation data

reflectioncoeffsall = cell(1,12);
refcoefs_mean_std = zeros(12,2);

linestyle_order = {'-','--',':','-.'};
% marker_order = {'o','+','*','.','x','square','diamond','^','v','>','<','pentagram','hexagram'};
marker_order = {'o','square','^','v','>','<','hexagram','+','*','x','pentagram','diamond','.'};

for i = 1:12
    i
    reflectioncoeffsall{i} = 0.37 * sqrt(data{i}{1}{1}{1}(data{i}{2},1:end)./mean(data{i}{1}{2}{1}(data{i}{2},1:end),2)); 
    [jj,len] = size(reflectioncoeffsall{i});
    if len>100
        num = len / 500;
        temp  = zeros(jj,num);
        for j=1:num
            temp(:,j) = mean(reflectioncoeffsall{i}(:,(1+(j-1)*500) : (j*500)),2);
        end
        reflectioncoeffsall{i} = temp;
    end
    refcoefs_mean_std(i,1) = mean(reflectioncoeffsall{i}(23,:));
    refcoefs_mean_std(i,2) = std(reflectioncoeffsall{i}(23,:));

end


ds = [0.25 0.25 0.5 0.5 0.203 0.203 0.180 0.5 0.18 0.24 0.24 0.17]; %mm
attenuation = cell(1,1);
for i=1:12
    i
%     if i<5
%         refcoef = 0;
%         for j=1:4
%         refcoef = refcoef + mean(reflectioncoeffsall{j}(23,:));
%         end
%         refcoef = refcoef/4;
%         
%     else
%         refcoef = mean(reflectioncoeffsall{i}(23,:));
%     end
    
    refcoef = refcoefs_mean_std(i,1);
    
    if i<=4 %if TPX
        refcoefff = refcoef;
        if i == 1 || i == 3
            refcoefbf = refcoefs_mean_std(i+1,1);
        elseif i == 2 || i == 4
            refcoefbf = refcoefs_mean_std(i-1,1);
        end
        
        attenuation{i} = 8.686 * log((data{i}{1}{1}{2}(data{i}{2}(1):data{i}{2}(end),1:end)./data{i}{1}{1}{1}(data{i}{2}(1):data{i}{2}(end),1:end)) / (((1-refcoefff^2)^2) * ((refcoefbf / refcoefff)^2) ))  / (-4 * (ds(i)/10));  
%     elseif i == 7 %if ibidi ibitreat one side
% %         refcoefff = refcoef;
%         refcoefff = refcoefs_mean_std(9,1);
%         refcoefbf = refcoef;
% %         refcoefbf = refcoefs_mean_std(9,1);
%         
%         attenuation{i} = 8.686 * log((data{i}{1}{1}{2}(data{i}{2}(1):data{i}{2}(end),1:end)./data{i}{1}{1}{1}(data{i}{2}(1):data{i}{2}(end),1:end)) / (((1-refcoefff^2)^2) * ((refcoefbf / refcoefff)^2) ))  / (-4 * (ds(i)/10));  
    else
        attenuation{i} = 8.686 * log((data{i}{1}{1}{2}(data{i}{2}(1):data{i}{2}(end),1:end)./data{i}{1}{1}{1}(data{i}{2}(1):data{i}{2}(end),1:end)) / ((1-refcoef^2)^2)) / (-4 * (ds(i)/10));
    
    end
    
    
    [jj,len] = size(attenuation{i});
    if len>100
        num = len / 500;
        temp  = zeros(jj,num);
        for j=1:num
            temp(:,j) = mean(attenuation{i}(:,(1+(j-1)*500) : (j*500)),2);
        end
        attenuation{i} = temp;
    end
    
end

att_coefs = zeros(12,2);% cell(1,11);
att_30 = zeros(12,2);%cell(1,11);

for i=1:12
    [~,num_points] = size(attenuation{i});
    temp1 = zeros(1,num_points);
    temp2 = zeros(1,num_points);
    for j = 1:num_points
        attfitlinear = fit(data{i}{3}(data{i}{2}).',attenuation{i}(:,j),'poly1');
        temp1(j) = attfitlinear.p1;
        temp2(j) = attenuation{i}(23,j);
    end
    
    att_coefs(i,1) = mean(temp1);
    att_coefs(i,2) = std(temp1);
    att_30(i,1) = mean(temp2);
    att_30(i,2) = std(temp2);
end
%% reflection coefficient of non tpx figure
figure();
fontsize(12,'points')

% sequence1 = [6 8 5 7 9 11 10]; % top to bottom order
sequence1 = [6 8 5 7 11 4 12]; % top to bottom order

hold on
% tpx1 = mean(reflectioncoeffsall{1},2);
% tpx2 = mean(reflectioncoeffsall{2},2);
% tpx3 = mean(reflectioncoeffsall{3},2);
% tpx4 = mean(reflectioncoeffsall{4},2);

% tpx_all = [tpx1 tpx2 tpx3 tpx4];

fsize = 15;
lw = 1.5;
for i=1:length(sequence1)
    ii=i;
    i = sequence1(i);
    errorbar(data{i}{3}(data{i}{2}(1:4:end)),mean(reflectioncoeffsall{i}(1:4:end,:),2),std(reflectioncoeffsall{i}(1:4:end,:),0,2),[linestyle_order{1} marker_order{ii}], "LineWidth",lw,'MarkerSize',12)
end

% errorbar(data{1}{3}(data{1}{2}),mean(tpx_all,2),std(tpx_all,0,2),"LineWidth",lw)
% errorbar(data{1}{3}(data{1}{2}),mean(reflectioncoeffsall{1},2),std(reflectioncoeffsall{1},0,2),"LineWidth",lw)


hold off
legend(order(sequence1),'Location','northwest')
xlabel('Frequency (MHz)')
ylabel('Reflection Coefficient')
colororder('dye')
%% reflection coefficient of TPX


figure();
fontsize(12,'points')
hold on


for i=1:4
    errorbar(data{i}{3}(data{i}{2}(1:4:end)),mean(reflectioncoeffsall{i}(1:4:end,:),2),std(reflectioncoeffsall{i}(1:4:end,:),0,2),[linestyle_order{1} marker_order{i}],"LineWidth",lw,'MarkerSize',12)
end

hold off
legend(order(1:4),'Location','northwest')
xlabel('Frequency (MHz)')
ylabel('Reflection Coefficient')
colororder('dye')
%% attenuation plot - non TPX
figure();
fontsize(12,'points')

hold on
% sequence2 = [5 7 9 10 11 8 6];
% sequence2 = [5 7 11 1 8 6];
sequence2 = [6 8 5 7 11 4];
% order{4} = "TPX";

for i=1:length(sequence2)
    ii=i;
    i = sequence2(i);
    errorbar(data{i}{3}(data{i}{2}(1:4:end)),mean(attenuation{i}(1:4:end,:),2),std(attenuation{i}(1:4:end,:),0,2),[linestyle_order{1} marker_order{ii}],"LineWidth",lw,'MarkerSize',12)
end 
xlabel("Frequency (MHz)")
ylabel("Attenuation (dB/cm)")
legend(order(sequence2),"Location","northwest")
colororder('dye')

%% attenuation plot - TPX
figure();
fontsize(12,'points')

hold on

for i=1:4
    errorbar(data{i}{3}(data{i}{2}(1:4:end)),mean(attenuation{i}(1:4:end,:),2),std(attenuation{i}(1:4:end,:),0,2),[linestyle_order{1} marker_order{i}],"LineWidth",lw,'MarkerSize',12)
end

xlabel("Frequency (MHz)")
ylabel("Attenuation (dB/cm)")
legend(order(1:4),"Location","northwest")
colororder('dye')

% [~,num_points] = size(tpxatt); 
% attfitlinear = fit(reshape(repmat(data{1}{3}(data{1}{2}),num_points,1)',[],1),reshape(tpxatt,[],1),'poly1')

%% waveforms and spectrums

% [time_data,amp_data] = load_waveforms("ibidinocoat.30*.csv","plexi30*.csv",500);

% load ibidi_coc6013_8007.mat

% film_first_index = 1861;
% film_second_index = 2561;
% film_third_index = 2521;
% plexi_first_index =film_first_index;% 831;
% windowsize = film_second_index - film_first_index;
% 
% figure()
% tiledlayout(2,1,'TileSpacing','Compact');
% nexttile;
% hold on; 
% area(1e6*[time_data{1}(plexi_first_index,1),time_data{1}(plexi_first_index + windowsize,1)],[0.6,0.6],'BaseValue',-0.6,"FaceColor",'b',"FaceAlpha",0.5)
% plot(time_data{2}(1500:3500,1)*1e6,amp_data{2}(1500:3500),"LineWidth",2,'Color','k')
% ylim([-0.6,0.6])
% % ylabel('Amplitude (mV)',"FontSize",fsize)
% % xlabel('Time (\mus)',"FontSize",fsize)
% % ylabel('Amplitude (mV)',"FontSize",20)
% nexttile;
% % figure()
% hold on; 
% area(1e6*[time_data{1}(film_first_index,1),time_data{1}(film_first_index + windowsize,1)],[0.6,0.6],'BaseValue',-0.6,"FaceColor",'r',"FaceAlpha",0.5)
% area(1e6*[time_data{1}(film_third_index,1),time_data{1}(film_third_index + windowsize,1)],[0.6,0.6],'BaseValue',-0.6,"FaceColor",'y',"FaceAlpha",0.5)
% plot(time_data{1}(1500:3500,1)*1e6,amp_data{1}(1500:3500,1),'LineWidth',2,'Color','k')
% ylim([-0.6,0.6])
% ylabel('                        Amplitude (mV)',"FontSize",fsize)
% % ylabel('Amplitude (mV)',"FontSize",fsize)
% xlabel('Time (\mus)',"FontSize",fsize)
% 
% figure()
% hold on
% interval = 1:100;
% 
% plot(data{1}{3}(interval),data{1}{1}{2}{1}(interval,1),"LineWidth",2)
% plot(data{1}{3}(interval),data{1}{1}{1}{1}(interval,1),"LineWidth",2)
% plot(data{1}{3}(interval),data{1}{1}{1}{2}(interval,1),"LineWidth",2)
% xlim([-10,50])
% xlabel('Frequency (MHz)',"FontSize",fsize)
% ylabel('Power Spectrum Magnitude',"FontSize",fsize)
% legend({'Planar reflector', "Sample Front Face","Sample Back Face"},"FontSize",fsize,"Location","northwest")

figure()
tiledlayout(1,2,'TileSpacing','tight','Padding','tight')
nexttile
fontsize(12,'points')

% sequence1 = [6 8 5 7 9 11 10]; % top to bottom order
sequence1 = [6 8 5 7 11 4 12]; % top to bottom order

hold on
% tpx1 = mean(reflectioncoeffsall{1},2);
% tpx2 = mean(reflectioncoeffsall{2},2);
% tpx3 = mean(reflectioncoeffsall{3},2);
% tpx4 = mean(reflectioncoeffsall{4},2);

% tpx_all = [tpx1 tpx2 tpx3 tpx4];

fsize = 15;
lw = 1.5;
for i=1:length(sequence1)
    ii=i;
    i = sequence1(i);
    errorbar(data{i}{3}(data{i}{2}(1:4:end)),mean(reflectioncoeffsall{i}(1:4:end,:),2),std(reflectioncoeffsall{i}(1:4:end,:),0,2),[linestyle_order{1} marker_order{ii}], "LineWidth",lw,'MarkerSize',12)
end

% errorbar(data{1}{3}(data{1}{2}),mean(tpx_all,2),std(tpx_all,0,2),"LineWidth",lw)
% errorbar(data{1}{3}(data{1}{2}),mean(reflectioncoeffsall{1},2),std(reflectioncoeffsall{1},0,2),"LineWidth",lw)


hold off
legend(order(sequence1),'Location','northwest')
xlabel('Frequency (MHz)')
ylabel('Reflection Coefficient')
colororder('dye')
%% reflection coefficient of TPX


nexttile
fontsize(12,'points')

hold on
% sequence2 = [5 7 9 10 11 8 6];
% sequence2 = [5 7 11 1 8 6];
sequence2 = [6 8 5 7 11 4];
% order{4} = "TPX";

for i=1:length(sequence2)
    ii=i;
    i = sequence2(i);
    errorbar(data{i}{3}(data{i}{2}(1:4:end)),mean(attenuation{i}(1:4:end,:),2),std(attenuation{i}(1:4:end,:),0,2),[linestyle_order{1} marker_order{ii}],"LineWidth",lw,'MarkerSize',12)
end 
xlabel("Frequency (MHz)")
ylabel("Attenuation (dB/cm)")
legend(order(sequence2),"Location","northwest")
colororder('dye')
fontsize(12,'points')


function [time_data,amp_data] = load_waveforms(filmfiles,plexi_files,varargin)
filmfiles
if isempty(varargin)

    % filmfiles = "pmma*.csv";
    % plexi_files = "plexi*.csv";
    
    
    filmfiles = dir(filmfiles);
    plexifiles = dir(plexi_files);
    
    
    filmtimes = cell(1,length(filmfiles));
    filmamplitudes = cell(1,length(filmfiles));
    for i=1:length(filmfiles)
        datum = readmatrix(filmfiles(i).name);
        datum = datum(3:end,1:2);
        filmtimes{i} = datum(:,1);
        filmamplitudes{i} = datum(:,2);
    end
    
    
    plexitimes = cell(1,length(plexifiles));
    plexiamplitudes = cell(1,length(plexifiles));
    for i=1:length(plexifiles)
        datum = readmatrix(plexifiles(i).name);
        datum = datum(3:end,1:2);
        plexitimes{i} = datum(:,1);
        plexiamplitudes{i} = datum(:,2);
    end
    
    
    filmtimes = cell2mat(filmtimes);
    filmamplitudes = cell2mat(filmamplitudes);
    
    plexitimes = cell2mat(plexitimes);
    plexiamplitudes = cell2mat(plexiamplitudes);
    % plexi30times = cell2mat(plexi30times);
    % plexi30amplitudes = cell2mat(plexi30amplitudes);
    
    
    time_data = cell(1,2);
    amp_data = cell(1,2);
    
    time_data{1} = filmtimes;
    time_data{2} = plexitimes;
    
    
    amp_data{1} = filmamplitudes;
    amp_data{2} = plexiamplitudes;    
else
    seq_length = varargin{1};
    
    filmfiles = dir(filmfiles);
    plexifiles = dir(plexi_files);
    
    
    filmtimes = cell(1,length(filmfiles));
    filmamplitudes = cell(1,length(filmfiles));
    for i=1:length(filmfiles)
        datum = readmatrix(filmfiles(i).name);
        datum = datum((seq_length+2):end,1:2);
        filmtimes{i} = reshape(datum(:,1),[],seq_length);
        filmamplitudes{i} = reshape(datum(:,2),[],seq_length);
    end
    
    
    
    
    plexitimes = cell(1,length(plexifiles));
    plexiamplitudes = cell(1,length(plexifiles));
    for i=1:length(plexifiles)
        datum = readmatrix(plexifiles(i).name);
        datum = datum((seq_length+2):end,1:2);
        plexitimes{i} = reshape(datum(:,1),[],seq_length);
        plexiamplitudes{i} = reshape(datum(:,2),[],seq_length);
    end
%     for i=1:length(plexifiles)
%         datum = readmatrix(plexifiles(i).name);
%         datum = datum(3:end,1:2);
%         plexitimes{i} = datum(:,1);
%         plexiamplitudes{i} = datum(:,2);
%     end
    
    
    filmtimes = cell2mat(filmtimes);
    filmamplitudes = cell2mat(filmamplitudes);
    
    plexitimes = cell2mat(plexitimes);
    plexiamplitudes = cell2mat(plexiamplitudes);
    % plexi30times = cell2mat(plexi30times);
    % plexi30amplitudes = cell2mat(plexi30amplitudes);
    
    
    time_data = cell(1,2);
    amp_data = cell(1,2);
    
    time_data{1} = filmtimes;
    time_data{2} = plexitimes;
    
    amp_data{1} = filmamplitudes;
    amp_data{2} = plexiamplitudes;
    
    % amp_data{1} = averaged;
    % time_data{1} = filmtimes{1}(:,1:5);

    
    
end
    
    
end