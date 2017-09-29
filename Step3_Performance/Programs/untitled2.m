addpath('/Volumes/Nevaeh/Apoptosis/Searching_08_04/IMassAction_Cluster')

clc;
clear;
 
eval(strcat('Name=dir(''Group*0.mat'');'))

Init=[];
Cutspeed=[];

for num=1:sum(size(Name))-1
    
eval(strcat('load(''' ,Name(num).name,''')'));

Init=[Init;  Params.SR_C3/Params.SR_XIAP];
 Params.A_C9starC3
Cutspeed=[Cutspeed; Params.A_C3XIAP/Params.A_XIAPC3];
end

% Cutspeed
% 
% Init
