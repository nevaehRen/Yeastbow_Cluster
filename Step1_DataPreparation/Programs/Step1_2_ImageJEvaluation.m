
clear;

% Step1: Read ".tif" Image from "../D1_Training_Data"
DataPath = '../D1_Training_Data/';
delete([DataPath,'.*.tif']); % delete hidden file
File = dir([DataPath,'*.tif']);

% Step2: Generate "train.csv" and "test.csv"
if length(File)>500
    resolution = 500; 
else
    resolution = length(File);
end

Train=[]; Test=[]; j=1;

tic;
for i=1:length(File)
    
% Step2.1: Image reshape and normalization
Name=[DataPath,File(i).name];
Image=imread(Name);
[pixsize, ~, t] = size(Image);
Image = imresize(Image,[256,256]);
Image = double(Image)./max(max(double(Image)));
Image = (Image-mean(Image(:)))/std(Image(:));   % whitening


% Step2.2: Generate Truth
ROIs = ReadImageJROI([Name(1:end-4),'.zip']);
ROIs(cellfun(@isempty,ROIs))=[];

for m=1:length(ROIs)
    ROIs{m} = ROIs{m}.mnCoordinates*256/pixsize;
end

Truth = double(Truth_Filled(ROIs));
  

% figure;
% subplot(1,2,1);imshow(imadjust(Image));
% subplot(1,2,2);imagesc(Truth);


% Step2.3: Save
Output.Data=[Truth(:);Image(:)]';

Train = [Train; Output.Data;];


if mod(i,resolution)==0
    unique(Train(:,1:256*256))
    Train = Train';
    Test  = Test';

    Train = [Train(1,:)*0;Train];
    Test  = Train(1,:)*0;

    Name_x = strcat('csvwrite(''../D2_CSV_data/Evaluation_train',num2str(j),'.csv'',Train)');
    Name_y = strcat('csvwrite(''../D2_CSV_data/Evaluation_test',num2str(j),'.csv'',Test)');

    eval(Name_x)
    eval(Name_y)

    j=j+1;

    Train=[];
    Test=[];
end


end
toc;

disp('Evaluation_train.csv Generated!')
                     



