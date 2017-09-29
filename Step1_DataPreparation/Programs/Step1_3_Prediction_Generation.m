
%%"------------------------------------------------------------------------------"
%%  This is used to transform "*.tif" to "*.csv" for the prediction of Yeastbow %%
%%"------------------------------------------------------------------------------"

clear;clc;

% Step1: Read ".tif" Image from "../D3_Prediction_Data"

DataPath = '../D3_Prediction_Data/';
delete(strcat(DataPath,'.*.tif')); % delete hidden file

File = dir(strcat(DataPath,'*.tif'));

Train = [];
Test  = [];

% Step2: Reshape Image and Recording Name and ScaleFactor

for i=1:length(File)
   
Image = imread(strcat(DataPath,File(i).name)) ; % Load Image_i

File(i).ScaleFactor = length(Image)/256;  % Record ScaleFactor

Image = imresize(Image,[256,256]); %  Reshape 

Image = double(Image)./max(max(double(Image))); % Normalization
Image = (Image-mean(Image(:)))/std(Image(:));   % whitening


Train = [Train; [1;Image(:)]'];

end

Train = Train';
Test  = Test';

Train = [Train(1,:)*0;Train];
Test  = Train(1,:)*0;

% Step3: Save "prediction_train0.csv" to "../D2_CSV_data"

Name_x = strcat('csvwrite(''../D2_CSV_data/prediction_train0.csv'',Train);');
Name_y = strcat('csvwrite(''../D2_CSV_data/prediction_test0.csv'',Test);');

eval(Name_x);
eval(Name_y);

disp('Prediction_train.csv Generated !')


% Step4: Save "PredictionName.mat" to "../../Step3_Performance"


if ~exist('../../Step3_Performance/Result')
    mkdir('../../Step3_Performance/Result')
else
    rmdir('../../Step3_Performance/Result','s')
    mkdir('../../Step3_Performance/Result')
end 

clearvars -except File
save('../../Step3_Performance/Result/PredictionName.mat')


disp('PredictionName.mat Generated !')






