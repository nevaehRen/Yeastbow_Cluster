

clear;

load ../D1_Training_Data/seg_im_data.mat

resolution = 100;

Train = [];Test  = [];
j=15;

Order = randperm(size(data,2)*size(data,1));

tic;
for i=1:(size(data,2)*size(data,1))
       
% Step2.1: Image reshape and normalization
Image = data{Order(i)}.imageBF';
Image = imresize(Image,[256,256]);
Image = double(Image)./max(max(double(Image)));
Image = (Image-mean(Image(:)))/std(Image(:));   % whitening

% Step2.2: Generate Truth
ROIs  = data{Order(i)}.cellseg{1};

if ~iscell(ROIs)
    continue;
end

ROIs(cellfun(@isempty,ROIs))=[];

scalefactor=256/size(data{i}.imageBF',1);

for m=1:length(ROIs)
    ROIs{m}=double(ROIs{m})*scalefactor;
end

Truth = double(Truth_Filled(ROIs));
  
  
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

disp('fission_train.csv Generated!')
