clear;

% Step1: Read ".tif" Image from "../D1_Training_Data"
DataPath = '../D1_Training_Data/';
delete([DataPath,'.*.tif']); % delete hidden file
File = dir([DataPath,'*.tif']);

% Step2: Generate "train.csv" and "test.csv"
Train=[]; Test=[]; j=1;

if length(File)>500
    resolution = 500; 
else
    resolution = length(File);
end

Order = randperm(length(File));

tic;
for i=1:length(File)
    
% Step2.1: Image reshape and normalization
Name=[DataPath,File(Order(i)).name];
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

if mod(i,resolution)<resolution*0.9
    Train = [Train; Output.Data;];
else
    Test = [Test; Output.Data;];
end


if mod(i,resolution)==0
    unique(Train(:,1:256*256))
    Train = Train';
    Test  = Test';
    Train = [Train(1,:)*0;Train];
    Test  = [Test(1,:)*0;Test];

    Name_x = strcat('csvwrite(''../D2_CSV_data/fissionyeast_train',num2str(j),'.csv'',Train)');
    Name_y = strcat('csvwrite(''../D2_CSV_data/fissionyeast_test',num2str(j),'.csv'',Test)');

    eval(Name_x)
    eval(Name_y)

    j=j+1;

    Train=[];
    Test=[];
end


end

toc;

disp('fission_train.csv Generated!')
                     



