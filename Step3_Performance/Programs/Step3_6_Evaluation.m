
clear;
clc;


% Read csv file

Files = dir('../Evaluation/CSV/Evaluation*.mat');

for ss=1:length(Files)

    
load(['../Evaluation/CSV/',Files(ss).name]);

Size   = sqrt(size(Image_whole,2));
Frames = size(Image_whole,1);

% parameters for segmentation
CellSize =  20;  % budding ~30  fission ~100
Level    = .6;   % budding <1   fission 2


for i=1:Frames

% 1. get Image, Prediction and Truth
    
Prediction = reshape(Prediction_whole(i,:),Size,Size);
Image      = reshape(Image_whole(i,:),Size,Size);
Truth      = reshape(Truth_whole(i,:),Size,Size);



%  2. get       BW,       s,       ROIs from prediction
%     and BW_truth, s_truth, ROIs_truth from ground truth
BW = water_segmentation(im2bw(Prediction),Level,CellSize);
BW = bwareaopen(BW,CellSize);

s     = regionprops(BW, 'centroid');
ROIs  = regionprops(BW, 'ConvexHull');


BW_truth = bwareaopen(im2bw(Truth),CellSize);
% BW_truth = im2bw(Truth);
% BW_truth = water_segmentation(im2bw(Truth),Level,CellSize);
s_truth     = regionprops(BW_truth, 'centroid');
ROIs_truth  = regionprops(BW_truth, 'ConvexHull');


%  3. plot Image, BW, BW_truth

% close all;

figure(i)
set(i,'Position',[100,100,1000,300*length(Files)],'color','w')

subplot(length(Files),3,3*ss-2);
imagesc(Image); axis off; colormap(gray);freezeColors;
title([Files(ss).name(15:end-4)])

subplot(length(Files),3,3*ss-1);
imagesc(BW); axis off; colormap(gray);freezeColors;
title('Prediction')
[L,num] = bwlabel(BW);
text(22,240,strcat('cell number:',num2str(num)),'color','w')

subplot(length(Files),3,3*ss);
imagesc(BW_truth); axis off; colormap(gray);freezeColors;
title('Ground Truth')
[L,num_truth] = bwlabel(BW_truth);
text(22,240,strcat('cell number:',num2str(num_truth)),'color','w')


% saveas(1,['../Evaluation/', Files_truth(ss).name(18:end-4),num2str(i),'.png' ]);
%  - easy visulization in terminal

disp('--------------------')
disp('Prediction cell number is:')
num

if num==0||num_truth==0
     continue;
    disp('No Yeast!!!')
end


%  4. list minimal cellsize
A = regionprops(bwareaopen(BW,CellSize),'Area');As = sort(cat(1, A.Area));
subplot(length(Files),3,3*ss-1);text(140,240,strcat('min size:',num2str(As(1))),'color','w')
disp(strcat('Prediction smallest size:',num2str(As(1))))

A = regionprops(BW_truth,'Area');As = sort(cat(1, A.Area));
subplot(length(Files),3,3*ss);text(140,240,strcat('min size:',num2str(As(1))),'color','w')
disp(strcat('Truth smallest size:',num2str(As(1))))



%%  5. plot centroid and convexhull

 
%
subplot(length(Files),3,3*ss-1); Colors = jet(length(ROIs));
for j=1:length(ROIs)
    patch('XData',ROIs(j).ConvexHull(:,1),'YData',ROIs(j).ConvexHull(:,2),'facecolor',Colors(j,:),'edgecolor',Colors(j,:),'linewidth',1.5,'edgealpha',0.57)
end

centroids = cat(1, s.Centroid);
hold on
plot(centroids(:,1), centroids(:,2), 'w+','markersize',5,'linewidth',1)

%
subplot(length(Files),3,3*ss); Colors = jet(length(ROIs_truth));
for j=1:length(ROIs_truth)
    patch('XData',ROIs_truth(j).ConvexHull(:,1),'YData',ROIs_truth(j).ConvexHull(:,2),'facecolor',Colors(j,:),'edgecolor',Colors(j,:),'linewidth',1.5,'edgealpha',0.57)
end

centroids_truth = cat(1, s_truth.Centroid);
hold on
plot(centroids_truth(:,1), centroids_truth(:,2), 'w+','markersize',5,'linewidth',1)


%
subplot(length(Files),3,3*ss-2);
[Predict Fact] = EvaluationSegmenation(BW,BW_truth);

for j=1:length(ROIs)
    if Predict(j).Ifin==1
        patch('XData',ROIs(j).ConvexHull(:,1),'YData',ROIs(j).ConvexHull(:,2),'facecolor','none','edgecolor','g','linewidth',1.5,'edgealpha',0.57)
    else
        patch('XData',ROIs(j).ConvexHull(:,1),'YData',ROIs(j).ConvexHull(:,2),'facecolor','none','edgecolor','r','linewidth',1.5,'edgealpha',0.57)
    end
end


for j=1:length(ROIs_truth)
    if Fact(j).Ifin~=1
      patch('XData',ROIs_truth(j).ConvexHull(:,1),'YData',ROIs_truth(j).ConvexHull(:,2),'facecolor','none','edgecolor','y','linewidth',1.5,'edgealpha',0.57)
    end
end

TP = sum( cat(1, Predict.Ifin));
FP = sum(~cat(1, Predict.Ifin));
% TP = sum( cat(1, Fact.Ifin));
FN = sum(~cat(1, Fact.Ifin));

Precision = roundn(TP/(TP+FP),-2);
Recall    = roundn(TP/(TP+FN),-2);
beta = 1;

F1 = roundn((1+beta^2)*Precision*Recall/(beta^2*Precision+Recall),-2);
if TP==0
    F1=0;
end

text( 25,220,strcat('TP:',num2str(TP)),'color','w')
text(85,220,strcat('FP:',num2str(FP)),'color','w')
text(145,220,strcat('FN:',num2str(FN)),'color','w')
text(5,240,strcat('Precision:',num2str(Precision)),'color','w')
text(110,240,strcat('Recall:',num2str(Recall)),'color','w')
text(185,240,strcat('F1:',num2str(F1)),'color','w')



Output(i).Image=Image;
% Output(i).Prediction=Prediction;
% Output(i).BW = BW;
Output(i).ROIs = ROIs;
% Output(i).s = s;
% Output(i).BW = BW_truth;
% Output(i).ROIs_truth = ROIs_truth;
% Output(i).s_truth = s_truth;
% Output(i).Predict = Predict;
Output(i).Fact = Fact;
Output(i).TP = TP;
Output(i).FP = FP;
Output(i).FN = FN;
Output(i).Precision = Precision;
Output(i).Recall = Recall;
Output(i).F1 = F1;

% saveas(1,strcat('../Evaluation/',num2str(i),'.png'));

% saveas(1,['../Evaluation/', Files_truth(ss).name(18:end-4),'_',num2str(i),'.png' ]);

end



% clearvars -except Output Files_truth Files_prediction ss Frames
save(['../Evaluation/Output_',Files(ss).name(18:end-4),'.mat'])

end

for i =1:Frames
saveas(i,['../Evaluation/Report_',num2str(i),'.png' ]);
end

close all;

disp('Segmentation Done!')
