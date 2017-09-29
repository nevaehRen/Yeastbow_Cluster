

clear

ImageName='GZM';


delete('.*.zip'); % delete hidden file
File = dir('*.zip');

Total=117;

for i=1:Total

s = strcmp({File.name},[num2str(i),'.zip']);% {S.name} :convert to cell
if sum(s)
    continue;
end

copyfile([num2str(i-1),'.zip'],[num2str(i),'.zip'])

end




delete('.*.zip'); % delete hidden file
File = dir('*.zip');
Name=10000-1;

for i=1:length(File)

Temp=Name+i;
movefile(File(i).name,[ImageName,num2str(Temp),'.zip'])

end
