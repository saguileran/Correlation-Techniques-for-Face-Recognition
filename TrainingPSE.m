%% Program for Assesing MACE Filter Performance in Trainning set
% Date: 02 - 06 - 20
% Author: Diego Herrera
% Description: In this program a single MACE filter is computed
%              for a sample image and PSE is computed for the
%              correlation output of the other images in the
%              set. A plot of PSE vs. Image number is generated

%% Clear Workspace
clear all; close all; clc;
colormap jet;

%% Parameters of True Folder location
curr_loc = pwd();                % Current MATLABPATH
dataFolder = '/Diego';           % Name of data folder
MatchName = '/sample*.png';      % Sample name of image files

%% Parameters of False Folder location
falseFolder = '/Diego';          % Name of data folder
FalseName = '/false*.png';       % Sample name of image files

%% Definition of True data location
folderLocation = [curr_loc dataFolder MatchName];

%% Defnition of False data location
falseLocation = [curr_loc falseFolder FalseName];

%% Read True images on folder
Data = dir(folderLocation);      % Read data from folder

%% Read False images on folder
Fake = dir(falseLocation);

%% Read Template Image
refimag = 7;
thereshold = 5;                  % For High Pass
sigma = 0.4; alpha = 0.5;        % For Laplacian
base = Data.folder;              % Because YOLO
filename = [base '/' Data(refimag).name];
% Optional preprocessing
% sample = locallapfilt(...
%         rgb2gray(imread(...
%         filename)),sigma,alpha);
% sample = EnhanceBorder(imread(filename),thereshold);
sample = rgb2gray(imread(filename));

%% Compute 1-Sample MACE
orgsize = size(sample);          % Original size of sample
fftsamp = fft2(sample);          % Compute fft of sample
% Compute filter
x = fftsamp(:);                  % Matrix of images
D = conj(x) .* x;                % Mean Power Spectrum
iDx = x .* (1.0 ./ D);           % D^{-1}x
MACE = iDx / (conj(x') * iDx);   % MACE Filter formula
% Resize for correlation computation
MACE = reshape(MACE,orgsize(1),orgsize(2));

%% Compute PSE and Peak location for True Data
corrplane = zeros(size(MACE));
peakloc = zeros(numel(Data),2);
psevals = zeros(numel(Data),1);
randomNum = 9;
figure(4);
for k = 1:numel(Data)
    % Read training-test image
    filename = [base '/' Data(k).name];
%     im = locallapfilt(...
%         rgb2gray(imread(...
%         filename)),sigma,alpha);
%     im = EnhanceBorder(imread(filename),thereshold);
    im = rgb2gray(imread(filename));
    % Compute correlation
    corrplane = abs(fftshift(ifft2(...
        conj(MACE) .* fft2(im)...
        )));
    if k == refimag
        subplot(2,3,2);
        surf(corrplane);
        title('Correlation output for reference');
    end
    if k == randomNum
        subplot(2,3,4);
        surf(corrplane);
        title(['Correlation output for true sample ' ...
            num2str(randomNum)]);
    end
    % Compute PSE and Peak Location
    [pse, location] = PSE(corrplane);
    psevals(k) = pse;
    peakloc(k,1) = location(1);
    peakloc(k,2) = location(2);
end

%% Compute PSE and Peak Location for False Data
fake_peakloc = zeros(numel(Fake),2);
fake_psevals = zeros(numel(Fake),1);
fake_randomNum = 9;
for k = 1:numel(Fake)
    % Read training-test image
    filename = [base '/' Fake(k).name];
%     im = locallapfilt(...
%         rgb2gray(imread(...
%         filename)),sigma,alpha);
%     im = EnhanceBorder(imread(filename),thereshold);
    im = rgb2gray(imread(filename));
    % Compute correlation
    corrplane = abs(fftshift(ifft2(...
        conj(MACE) .* fft2(im)...
        )));
    if k == fake_randomNum
        subplot(2,3,6);
        surf(corrplane);
        title(['Correlation output for fake sample ' ...
            num2str(fake_randomNum)]);
    end
    % Compute PSE and Peak Location
    [pse, location] = PSE(corrplane);
    fake_psevals(k) = pse;
    fake_peakloc(k,1) = location(1);
    fake_peakloc(k,2) = location(2);
end

%% Get paths for reference + rand images
% Define filenames
filename1 = [base '/' Data(refimag).name];
filename2 = [base '/' Data(randomNum).name];
filename3 = [base '/' Fake(fake_randomNum).name];

%% Compute enhanced images
% im1 = locallapfilt(...
%         rgb2gray(imread(...
%         filename1)),sigma,alpha);
% im2 = locallapfilt(...
%         rgb2gray(imread(...
%         filename2)),sigma,alpha);
    
% im1 = EnhanceBorder(imread(filename1),thereshold);
% im2 = EnhanceBorder(imread(filename2),thereshold);

im1 = imread(filename1);
im2 = imread(filename2);
im3 = imread(filename3);

%% Plot images
figure(5);
subplot(2,3,2); imshow(im1,[]);
title('Reference Trainig Image');
subplot(2,3,4); imshow(im2,[]);
title(['Trainig Image ' num2str(randomNum)]);
subplot(2,3,6); imshow(im3,[]);
title(['Fake Image ' num2str(randomNum)]);

%% Plot PSE Results
figure(1);
plot(1:numel(Data),psevals,'-o','LineWidth',1.5,'Color','b'); hold on;
plot(1:numel(Fake),fake_psevals,'-o','LineWidth',1.5,'Color','r');
xlabel('No. Figura');
ylabel('PSE');
title(['PSE con referencia a imagen ' num2str(...
    refimag)]);
legend('True','False','Location','best');

%% Plot Location Results
figure(2);
plot(1:numel(Data),peakloc(:,1),'-o',...
    'LineWidth',1.5,'Color','b'); hold on;
plot(1:numel(Data),peakloc(:,2),'-o',...
    'LineWidth',1.5,'Color','r'); hold on;
xlabel('No. Figura');
ylabel('Peak Location');
title('Localizaci�n M�ximo');
legend('Corrd. y','Coord. x','Location','best');
