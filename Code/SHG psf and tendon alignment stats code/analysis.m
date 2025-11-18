set(0, 'DefaultAxesFontName', 'Times New Roman');
set(0, 'DefaultTextFontName', 'Times New Roman');

% Define the main directory

mainDir = '..\..\Data\SHG_PSFs';
% Get a list of all folders in the main directory
folders = dir(mainDir);
folders = folders([folders.isdir]); % Keep only directories
folders = folders(3:end-1) %[output:34664e30]

labels = {'COC','GLASS','IBIDI','PC','PET','PMMA','TPX'};
keys = [2 5 5 1 1 3 3 2 2 2 2 4 4 4 4 5 5 5 6 6 6 7 7 7 7 7];

fwhms = cell(7,2);
for i=1:7
    for j=1:2
        fwhms{i,j} = [];
    end
end

% Loop through each folder

for k = 1:length(folders)
    key = keys(k);
    folderName = folders(k).name;
    
    
    % Construct the full path of the folder
    folderPath = fullfile(mainDir, folderName);
    
    % Display the folder name (or perform your processing here)
%     disp(['Processing folder: ', folderPath]);
    
    % Example: Get a list of all files in the current folder
    files = dir(fullfile(folderPath, '*.csv')); % Adjust the file extension as needed
    
    % Loop through each file in the current folder
    for j = 1:length(files)
        fileName = files(j).name;
        filePath = fullfile(folderPath, fileName);
        data = readmatrix(filePath);
        data(:,2) = data(:,2) - min(data(:,2));
        maxval = max(data(:,2));
        
        xs = linspace(min(data(:,1)),max(data(:,1)),1000);
        vs = interp1(data(:,1),data(:,2),xs);
        
        i1 = find(vs >= maxval/2,1,'first');
        i2 = find(vs >= maxval/2,1,'last');
        fwhm = xs(i2) - xs(i1);

        if fwhm > 7
            fwhm = fwhm / 15;
        end
        
        
        if fileName(1) == 'x'
            fwhms{key,1} = [fwhms{key,1} fwhm];
        else
            fwhms{key,2} = [fwhms{key,2} fwhm];
        end
       
        
        % Display the file name (or perform your processing here)
%         disp(['Processing file: ', filePath]);
        
        % Example: Read the file content
        % fileContent = fileread(filePath);
        % Process the file content as needed
    end
end
%%

xmeans_stds = zeros(7,2);
ymeans_stds = zeros(7,2);
for i=1:7
    xmeans_stds(i,1) = mean(fwhms{i,1});
    ymeans_stds(i,1) = mean(fwhms{i,2});
    xmeans_stds(i,2) = std(fwhms{i,1});
    ymeans_stds(i,2) = std(fwhms{i,2});
end
%%
labels %[output:4a97ff4c]
xmeans_stds %[output:2b72c9c2]
ymeans_stds %[output:27d333c6]
%%
labels = {'COC','GLASS','IBIDI','PC','PET','PMMA','TPX'};
for i=[1 2 3 4 5 6 7] %[output:group:1abae5f6]
    % [h,p,ci,stats]=ttest2(fwhms{2,1},fwhms{i,1});
    % disp([labels{i} ' - x: h = ' num2str(h) ', p = ' num2str(p)])
    % 
    % [h,p,ci,stats]=ttest2(fwhms{2,2},fwhms{i,2});
    % disp([labels{i} ' - y: h = ' num2str(h) ', p = ' num2str(p)])

    med = median(fwhms{i,1}); ran = max(fwhms{i,1})-min(fwhms{i,1});
    disp([labels{i} ' - x: median = ' num2str(med) ', range = ' num2str(ran)]) %[output:386d2e17] %[output:775309e0] %[output:25d9a0ee] %[output:3f958dc6] %[output:20d05fa5] %[output:5c6a80ed] %[output:6d08c7bf]

    med = median(fwhms{i,2}); ran = max(fwhms{i,2})-min(fwhms{i,2});
    disp([labels{i} ' - y: median = ' num2str(med) ', range = ' num2str(ran)]) %[output:6f4076b3] %[output:8fe051ff] %[output:88dd9dce] %[output:594da7e6] %[output:8c40a19c] %[output:434e42ed] %[output:89936a11]
end %[output:group:1abae5f6]
%%
labels = {'COC','GLASS','IBIDI','PC','PET','PMMA','TPX'};
alignments = [1 1 1 1;... 
    1 1 1 1;...
    0.98 0.97 0.95 0.96;...
    0.99 1 1 1;...
    0.04 0.04 0.08 0.07;...
    0.84 0.9 0.89 0.91;...
    0.71 0.89 0.97 0.98];

for i=[1 3 4 5 6 7] %[output:group:64a2a392]
    % [h,p,ci,stats]=ttest2(alignments(i,:),alignments(2,:),'Tail','left');
    % disp([labels{i} ': h = ' num2str(h) ', p = ' num2str(p)])
    medians = median(alignments(i,:));
    ranges = max(alignments(i,:)) - min(alignments(i,:));
    disp([labels{i} ': median = ' num2str(medians) ', range = ' num2str(ranges)]) %[output:45e8fb63]
end %[output:group:64a2a392]
%%
labels = {'COC','GLASS','IBIDI','PC','PET','PMMA','TPX'};
for i=[1 2 3 4 5 6 7] %[output:group:0c89a706]
    [h,p,ci,stats]=ttest2(fwhms{2,1},fwhms{i,1},"Vartype","unequal");
    disp([labels{i} ' - x: h = ' num2str(h) ', p = ' num2str(p)]) %[output:934f62ea] %[output:473d9f69] %[output:77ddc988] %[output:176af5c1] %[output:4493e5d2] %[output:65e838b6] %[output:56f77cd0]

    [h,p,ci,stats]=ttest2(fwhms{2,2},fwhms{i,2},"Vartype","unequal");
    disp([labels{i} ' - y: h = ' num2str(h) ', p = ' num2str(p)]) %[output:8d7310f5] %[output:9df09be1] %[output:12030288] %[output:332aef3b] %[output:14b3f67f] %[output:29aef1bb] %[output:6e447205]

    % med = median(fwhms{i,1}); ran = max(fwhms{i,1})-min(fwhms{i,1});
    % disp([labels{i} ' - x: median = ' num2str(med) ', range = ' num2str(ran)])
    % 
    % med = median(fwhms{i,2}); ran = max(fwhms{i,2})-min(fwhms{i,2});
    % disp([labels{i} ' - y: median = ' num2str(med) ', range = ' num2str(ran)])
end %[output:group:0c89a706]

%%
labels = {'COC','GLASS','IBIDI','PC','PET','PMMA','TPX'};
alignments = [1 1 1 0.99999999999;... 
    1 1 1 1;...
    0.98 0.97 0.95 0.96;...
    0.99 1 1 1;...
    0.04 0.04 0.08 0.07;...
    0.84 0.9 0.89 0.91;...
    0.71 0.89 0.97 0.98];

for i=[1 3 4 5 6 7] %[output:group:3f3198f2]
    [h,p,ci,stats]=ttest2(alignments(i,:),alignments(2,:),'Tail','left','Vartype','unequal');
    disp([labels{i} ': h = ' num2str(h) ', p = ' num2str(p)]) %[output:76b5da51]
    % medians = median(alignments(i,:));
    % ranges = max(alignments(i,:)) - min(alignments(i,:));
    % disp([labels{i} ': median = ' num2str(medians) ', range = ' num2str(ranges)])
end %[output:group:3f3198f2]

%[appendix]
%---
%[metadata:view]
%   data: {"layout":"inline","rightPanelPercent":35.8}
%---
%[output:34664e30]
%   data: {"dataType":"tabular","outputData":{"columnNames":["name","folder","date","bytes","isdir","datenum"],"columns":6,"cornerText":"Fields","dataTypes":["char","char","char","double","logical","double"],"header":"25×1 struct array with fields:","name":"folders","rows":25,"type":"struct","value":[["'1_24_25_glass_60_degree_0.1pr_1024_zoom30_2timepoints_1'","'C:\\Users\\jonat\\OneDrive - UW-Madison\\QUL\\Papers\\Link Materials Paper\\Coda and Data\\data-and-code-for-improved-interfaces-paper\\Data\\SHG_PSFs'","'28-Aug-2025 20:53:17'","0","1","7.3986e+05"],["'3.7.25_pet_256_45_2'","'C:\\Users\\jonat\\OneDrive - UW-Madison\\QUL\\Papers\\Link Materials Paper\\Coda and Data\\data-and-code-for-improved-interfaces-paper\\Data\\SHG_PSFs'","'28-Aug-2025 20:53:18'","0","1","7.3986e+05"],["'3.7.25_pet_256_45_4'","'C:\\Users\\jonat\\OneDrive - UW-Madison\\QUL\\Papers\\Link Materials Paper\\Coda and Data\\data-and-code-for-improved-interfaces-paper\\Data\\SHG_PSFs'","'28-Aug-2025 20:53:18'","0","1","7.3986e+05"],["'4.18.25.coc.deg50_1'","'C:\\Users\\jonat\\OneDrive - UW-Madison\\QUL\\Papers\\Link Materials Paper\\Coda and Data\\data-and-code-for-improved-interfaces-paper\\Data\\SHG_PSFs'","'28-Aug-2025 20:53:18'","0","1","7.3986e+05"],["'4.18.25.coc.deg50_2'","'C:\\Users\\jonat\\OneDrive - UW-Madison\\QUL\\Papers\\Link Materials Paper\\Coda and Data\\data-and-code-for-improved-interfaces-paper\\Data\\SHG_PSFs'","'28-Aug-2025 20:53:18'","0","1","7.3986e+05"],["'4.18.25.ibidi.deg50_1'","'C:\\Users\\jonat\\OneDrive - UW-Madison\\QUL\\Papers\\Link Materials Paper\\Coda and Data\\data-and-code-for-improved-interfaces-paper\\Data\\SHG_PSFs'","'28-Aug-2025 20:53:18'","0","1","7.3986e+05"],["'4.18.25.ibidi.deg50_2'","'C:\\Users\\jonat\\OneDrive - UW-Madison\\QUL\\Papers\\Link Materials Paper\\Coda and Data\\data-and-code-for-improved-interfaces-paper\\Data\\SHG_PSFs'","'28-Aug-2025 20:53:18'","0","1","7.3986e+05"],["'Glass_1_2_4_25_0.2ygglass_60_degree_0.1pr_256_zoom30_2timepoints_4'","'C:\\Users\\jonat\\OneDrive - UW-Madison\\QUL\\Papers\\Link Materials Paper\\Coda and Data\\data-and-code-for-improved-interfaces-paper\\Data\\SHG_PSFs'","'28-Aug-2025 20:53:18'","0","1","7.3986e+05"],["'Glass_2_2_4_25_0.2ygglass_60_degree_0.1pr_256_zoom30_2timepoints_3'","'C:\\Users\\jonat\\OneDrive - UW-Madison\\QUL\\Papers\\Link Materials Paper\\Coda and Data\\data-and-code-for-improved-interfaces-paper\\Data\\SHG_PSFs'","'28-Aug-2025 20:53:18'","0","1","7.3986e+05"],["'Glass_3_2_4_25_0.2ygglass_60_degree_0.1pr_256_zoom30_2timepoints_2'","'C:\\Users\\jonat\\OneDrive - UW-Madison\\QUL\\Papers\\Link Materials Paper\\Coda and Data\\data-and-code-for-improved-interfaces-paper\\Data\\SHG_PSFs'","'28-Aug-2025 20:53:18'","0","1","7.3986e+05"],["'Glass_4_2_4_25_0.2ygglass_60_degree_0.1pr_256_zoom30_2timepoints_1'","'C:\\Users\\jonat\\OneDrive - UW-Madison\\QUL\\Papers\\Link Materials Paper\\Coda and Data\\data-and-code-for-improved-interfaces-paper\\Data\\SHG_PSFs'","'28-Aug-2025 20:53:18'","0","1","7.3986e+05"],["'PC_1_2.13.25_45PCdeg_0.1pr_256_zoom30_2tps_1'","'C:\\Users\\jonat\\OneDrive - UW-Madison\\QUL\\Papers\\Link Materials Paper\\Coda and Data\\data-and-code-for-improved-interfaces-paper\\Data\\SHG_PSFs'","'28-Aug-2025 20:53:18'","0","1","7.3986e+05"],["'PC_2_2_4_25_0.2ygpc_60_degree_0.1pr_256_zoom30_2timepoints_1nope'","'C:\\Users\\jonat\\OneDrive - UW-Madison\\QUL\\Papers\\Link Materials Paper\\Coda and Data\\data-and-code-for-improved-interfaces-paper\\Data\\SHG_PSFs'","'28-Aug-2025 20:53:18'","0","1","7.3986e+05"],["'PC_3_2.13.25_50PCdeg_0.1pr_256_zoom30_2tps_2'","'C:\\Users\\jonat\\OneDrive - UW-Madison\\QUL\\Papers\\Link Materials Paper\\Coda and Data\\data-and-code-for-improved-interfaces-paper\\Data\\SHG_PSFs'","'28-Aug-2025 20:53:18'","0","1","7.3986e+05"]]}}
%---
%[output:4a97ff4c]
%   data: {"dataType":"matrix","outputData":{"columns":7,"header":"1×7 cell array","name":"labels","rows":1,"type":"cell","value":[["'COC'","'GLASS'","'IBIDI'","'PC'","'PET'","'PMMA'","'TPX'"]]}}
%---
%[output:2b72c9c2]
%   data: {"dataType":"matrix","outputData":{"columns":2,"name":"xmeans_stds","rows":7,"type":"double","value":[["0.9174","0.0464"],["0.7796","0.1861"],["0.8884","0.0445"],["0.9656","0.0876"],["1.2082","0.2949"],["0.9723","0.0788"],["0.9263","0.0213"]]}}
%---
%[output:27d333c6]
%   data: {"dataType":"matrix","outputData":{"columns":2,"name":"ymeans_stds","rows":7,"type":"double","value":[["0.8964","0.0555"],["0.7325","0.1014"],["0.9472","0.0411"],["1.0777","0.2088"],["1.2640","0.4266"],["1.0509","0.1732"],["0.9289","0.1033"]]}}
%---
%[output:386d2e17]
%   data: {"dataType":"text","outputData":{"text":"COC - x: median = 0.92099, range = 0.12339\n","truncated":false}}
%---
%[output:6f4076b3]
%   data: {"dataType":"text","outputData":{"text":"COC - y: median = 0.92813, range = 0.12633\n","truncated":false}}
%---
%[output:775309e0]
%   data: {"dataType":"text","outputData":{"text":"GLASS - x: median = 0.7988, range = 0.44698\n","truncated":false}}
%---
%[output:8fe051ff]
%   data: {"dataType":"text","outputData":{"text":"GLASS - y: median = 0.77558, range = 0.23083\n","truncated":false}}
%---
%[output:25d9a0ee]
%   data: {"dataType":"text","outputData":{"text":"IBIDI - x: median = 0.87044, range = 0.11832\n","truncated":false}}
%---
%[output:88dd9dce]
%   data: {"dataType":"text","outputData":{"text":"IBIDI - y: median = 0.93213, range = 0.10844\n","truncated":false}}
%---
%[output:3f958dc6]
%   data: {"dataType":"text","outputData":{"text":"PC - x: median = 0.9653, range = 0.17518\n","truncated":false}}
%---
%[output:594da7e6]
%   data: {"dataType":"text","outputData":{"text":"PC - y: median = 1.0277, range = 0.40854\n","truncated":false}}
%---
%[output:20d05fa5]
%   data: {"dataType":"text","outputData":{"text":"PET - x: median = 1.0753, range = 0.69963\n","truncated":false}}
%---
%[output:8c40a19c]
%   data: {"dataType":"text","outputData":{"text":"PET - y: median = 1.06, range = 1.0098\n","truncated":false}}
%---
%[output:5c6a80ed]
%   data: {"dataType":"text","outputData":{"text":"PMMA - x: median = 0.92793, range = 0.13754\n","truncated":false}}
%---
%[output:434e42ed]
%   data: {"dataType":"text","outputData":{"text":"PMMA - y: median = 0.96229, range = 0.31051\n","truncated":false}}
%---
%[output:6d08c7bf]
%   data: {"dataType":"text","outputData":{"text":"TPX - x: median = 0.93087, range = 0.057189\n","truncated":false}}
%---
%[output:89936a11]
%   data: {"dataType":"text","outputData":{"text":"TPX - y: median = 0.88088, range = 0.24758\n","truncated":false}}
%---
%[output:45e8fb63]
%   data: {"dataType":"text","outputData":{"text":"COC: median = 1, range = 0\nIBIDI: median = 0.965, range = 0.03\nPC: median = 1, range = 0.01\nPET: median = 0.055, range = 0.04\nPMMA: median = 0.895, range = 0.07\nTPX: median = 0.93, range = 0.27\n","truncated":false}}
%---
%[output:934f62ea]
%   data: {"dataType":"text","outputData":{"text":"COC - x: h = 0, p = 0.17564\n","truncated":false}}
%---
%[output:8d7310f5]
%   data: {"dataType":"text","outputData":{"text":"COC - y: h = 1, p = 0.018491\n","truncated":false}}
%---
%[output:473d9f69]
%   data: {"dataType":"text","outputData":{"text":"GLASS - x: h = 0, p = 1\n","truncated":false}}
%---
%[output:9df09be1]
%   data: {"dataType":"text","outputData":{"text":"GLASS - y: h = 0, p = 1\n","truncated":false}}
%---
%[output:77ddc988]
%   data: {"dataType":"text","outputData":{"text":"IBIDI - x: h = 0, p = 0.26481\n","truncated":false}}
%---
%[output:12030288]
%   data: {"dataType":"text","outputData":{"text":"IBIDI - y: h = 1, p = 0.0064797\n","truncated":false}}
%---
%[output:176af5c1]
%   data: {"dataType":"text","outputData":{"text":"PC - x: h = 0, p = 0.10553\n","truncated":false}}
%---
%[output:332aef3b]
%   data: {"dataType":"text","outputData":{"text":"PC - y: h = 0, p = 0.088199\n","truncated":false}}
%---
%[output:4493e5d2]
%   data: {"dataType":"text","outputData":{"text":"PET - x: h = 1, p = 0.029614\n","truncated":false}}
%---
%[output:14b3f67f]
%   data: {"dataType":"text","outputData":{"text":"PET - y: h = 1, p = 0.047734\n","truncated":false}}
%---
%[output:65e838b6]
%   data: {"dataType":"text","outputData":{"text":"PMMA - x: h = 0, p = 0.090688\n","truncated":false}}
%---
%[output:29aef1bb]
%   data: {"dataType":"text","outputData":{"text":"PMMA - y: h = 0, p = 0.066542\n","truncated":false}}
%---
%[output:56f77cd0]
%   data: {"dataType":"text","outputData":{"text":"TPX - x: h = 0, p = 0.15293\n","truncated":false}}
%---
%[output:6e447205]
%   data: {"dataType":"text","outputData":{"text":"TPX - y: h = 1, p = 0.016197\n","truncated":false}}
%---
%[output:76b5da51]
%   data: {"dataType":"text","outputData":{"text":"COC: h = 0, p = 0.1955\nIBIDI: h = 1, p = 0.0061538\nPC: h = 0, p = 0.1955\nPET: h = 1, p = 1.4418e-06\nPMMA: h = 1, p = 0.0025546\nTPX: h = 0, p = 0.08484\n","truncated":false}}
%---
