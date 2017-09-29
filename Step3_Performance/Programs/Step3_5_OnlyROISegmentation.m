clear;
clc;


load ../Result/PredictionName.mat

% Step1: Read "prediction.csv"
load('../Result/prediction.mat');

Size   = sqrt(size(Data_whole,2));
Frames = size(Data_whole,1);

% Step2: Parameters for segmenation
CellSize =  20;  % budding ~30  fission ~100
Level    =  .6;   % budding <1   fission 2
disp('--------*------------*------------')
disp(['CellSize is :',num2str(CellSize)]  )
disp(['Level is :',num2str(Level)]  )
disp('--------*------------*------------')

tic;

% Step3: Parameters for segmenation
for i=1:Frames

% Step3.1: Get prediction
Prediction = reshape(Data_whole(i,:),Size,Size);
Image      = reshape(Data_whole_image(i,:),Size,Size);

% Step3.2: Water_segmentation
BW = bwareaopen(water_segmentation(im2bw(Prediction),Level,CellSize),CellSize);

% Step3.3: Avoid when fail!!
[L,num] = bwlabel(BW);
if num==0
    continue;
    disp('No Cell!!!')    
end


% Step3.4: Generate centroids!!
s  = regionprops(BW, 'centroid');
centroids = cat(1, s.Centroid);

% Step3.5: Generate ROIs!!
ROIs  = regionprops(BW, 'ConvexHull');


%  Scale ROIs!!
ScaleFactor = 1.1;
for m=1:length(ROIs)
    ROIs(m).ConvexHull(:,1) = (ROIs(m).ConvexHull(:,1)-centroids(m,1))*ScaleFactor+centroids(m,1);
    ROIs(m).ConvexHull(:,2) = (ROIs(m).ConvexHull(:,2)-centroids(m,2))*ScaleFactor+centroids(m,2);
end



Output(i).Image=Image;
Output(i).Prediction=Prediction;
Output(i).Name=File(i).name;
Output(i).ROIs = ROIs;
Output(i).centroids = centroids;

end

clearvars -except Output
save('../Result/Output.mat')

YeastbowROI=rmfield(Output,{'Image','Prediction'});
clearvars Output

save('../Result/YeastbowROI.mat')
toc;

disp('Segmentation Done!')


% Step4: Generate Fiji ROI files!!
tic;
Step3_8_GenerateFijiRoi('../Result/')
toc;

disp('Fiji ROI have been generated!')

