clear;

% Step1: Read ".tif" Image from "../D1_Training_Data"
DataPath = '';
delete([DataPath,'.*.tif']); % delete hidden file
File = dir([DataPath,'*.tif']);


tic;
for i=1:length(File)
    
% Step2.1: Image reshape and normalization
Name=[DataPath,File(i).name];
Image=imreadstack(Name);



for j=1:size(Image,3)
    imwrite(Image(:,:,j) ,[Name(1:end-4),'_',num2str(j),'.tif'])
end

Image(:,:,j)-min(min(Image(:,:,j)))


end

toc;

disp('Stack Seperated!')
                     



