clear;
clc;

load('../Result/Output.mat')

% index for frame
for i=1:length(Output)

Image = Output(i).Image;
Prediction = Output(i).Prediction;
ROIs  = Output(i).ROIs;
centroids = Output(i).centroids;

close all;

figure(1);set(1,'Position',[100,100,300,300],'color','w');

% 1. Image
imagesc(Image); axis off; colormap(gray);freezeColors;
title('Prediction')

% 2. centroids
hold on
plot(centroids(:,1), centroids(:,2), 'w+','markersize',5,'linewidth',1)
hold off

% 3. ROIs
Colors = jet(length(ROIs));
for j=1:length(ROIs)
    patch('XData',ROIs(j).ConvexHull(:,1),'YData',ROIs(j).ConvexHull(:,2),'facecolor','none','edgecolor',Colors(j,:),'linewidth',1.5,'edgealpha',0.57)
end


Gif(['../Result/Prediction.gif'],i)

end


disp('Movie Prediction Done!')


%% png of prediction
Step3_7_Final_Prediction

