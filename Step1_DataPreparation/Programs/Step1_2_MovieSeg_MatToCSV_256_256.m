clear;clc;
load('/Volumes/Nevaeh/FindCell/Step1_DataPreparation/D1_Training_Data/Zothers/Yeastbow1_layer2.mat')


Temp=data{1};
for i=2:length(data)
Temp = [Temp,data{i}];
end

data=Temp;
clearvars Temp


resolution = size(data,2)*size(data,1);

Train = [];
Test  = [];
j=1;

Order = randperm(size(data,2)*size(data,1));

% Order = 1:(size(data,2)*size(data,1));

tic;

for i=1:(size(data,2)*size(data,1))

% Step2.1: Image reshape and normalization
Image = data{Order(i)}.imageBF';
Image = imresize(Image,[256,256]);
% Image = SVD_Image(Image,0.99);
Image = double(Image)./max(max(double(Image)));
Image = (Image-mean(Image(:)))/std(Image(:));   % whitening

% Step2.2: Generate Truth
ROIs  = data{Order(i)}.cellseg;


if ~iscell(ROIs)

if size(ROIs,3)==2  
    for j=1:size(ROIs,1)
    Temps{j} = reshape(ROIs(j,:,:),[size(ROIs,2) 2]);
    end
    clearvars ROIs
    ROIs = Temps;
else
    continue;
end

end

ROIs(cellfun(@isempty,ROIs))=[];

scalefactor=256/size(data{i}.imageBF',1);

for m=1:length(ROIs)
    ROIs{m}=double(ROIs{m})*scalefactor;
end

Truth = double(Truth_Filled(ROIs));
  

% figure(1)
% 
% subplot(1,2,1);imshow(imadjust(Image));
% subplot(1,2,2);imagesc(Truth);
% 
% title(num2str(i))
% pause(0.1)



% Step2.3: Save
Output.Data=[Truth(:);Image(:)]';

if mod(i,resolution)<resolution*0.8
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

Name_x = strcat('csvwrite(''../D2_CSV_data/Yeastbow1_train',num2str(j),'_layer4.csv'',Train)');
Name_y = strcat('csvwrite(''../D2_CSV_data/Yeastbow1_test',num2str(j),'_layer4.csv'',Test)');

eval(Name_x)
eval(Name_y)

j=j+1;

Train=[];
Test=[];

end

end

toc;

disp('fission_train.csv Generated!')
                     




