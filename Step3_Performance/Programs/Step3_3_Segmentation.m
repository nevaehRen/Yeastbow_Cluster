cd /Users/Nevaeh/PythonCSCourse/XcodePython/FindCell2/Step3_Performance

clear;
clc;

if ~exist('Result')
    mkdir('Result')
end 

Data_whole   = csvread('prediction.csv');
Data_whole   = Data_whole(2:end,:);
Size   = sqrt(0.5*size(Data_whole,1));
Frames = size(Data_whole,2);

% parameters for segmentation

CellSize = 10;  % budding ~30  fission ~100
Level = 3;   % budding <1   fission 2 

% index for frame
for i=1:Frames;

Data = Data_whole(:,i);

Prediction = reshape(Data(1:(Size^2)),Size,Size);
Image      = reshape(Data((1+Size^2):end),Size,Size);

close all;

figure(1)
set(1,'Position',[100,100,1000,300],'color','w')

subplot(131);
imagesc(Image); axis off; colormap(gray);freezeColors;
title('Input')

subplot(132);
imagesc(Prediction); axis off; colormap(gray);freezeColors;
title('Prediction')
%  1. binary image
BW= im2bw(Prediction) ;

BW = water_segmentation(BW,Level,CellSize);


%  2. get all area, display smallest 5 cells
A = regionprops(BW,'Area');
As = cat(1, A.Area);
As = sort(As);
disp('--------------------')
disp('five smallest cells:')
% As(1:5)
disp('--------------------')


%  3. threshold is 15, remove smallest cells
BW = bwareaopen(BW,CellSize);
A = regionprops(BW,'Area');
As = cat(1, A.Area);
As = sort(As);
disp('--------------------')
disp('five smallest cells:')
% As(1:5)
disp('--------------------')

%  4. labeled image
[L,num] = bwlabel(BW);

subplot(133);%set(2,'Position',[500,100,400,400],'color','w')
imagesc(L); axis off ; colormap(jet);freezeColors;
title('Output')

disp('--------------------')
disp('cell number is:')
num

if num==0
    continue;
    disp('No Yeast!!!')
    
end
disp('--------------------')

%  5. find center points of different area
s  = regionprops(BW, 'centroid');
centroids = cat(1, s.Centroid);

hold on
plot(centroids(:,1), centroids(:,2), 'w+','markersize',5,'linewidth',1)
hold off



% 6. PixelIdxList
ROIs  = regionprops(BW, 'ConvexHull');

for j=1:length(ROIs)
    patch('XData',ROIs(j).ConvexHull(:,1),'YData',ROIs(j).ConvexHull(:,2),'facecolor','none','edgecolor','w')
end



% save
saveas(1,strcat('Result/',num2str(i),'.png'));

end

close all;

disp('Segmentation Done!')

