function  Step3_8_GenerateFijiRoi(Path)
%%
%Step3_8_GenerateFijiRoi - FUNCTION Write ImageJ ROI.
%
%Usage: Generate Fiji ROI documents from yeastbow Result
%
% need StandardFijiROI.mat and Output.mat 
%%

if ~exist([Path 'YeastbowROI'])
    mkdir([Path 'YeastbowROI'])
end 

% Step1: read standard Fiji ROI document
load StandardFijiROI.mat

% Step2: read yeastbow output
load ../Result/Output.mat
load ../Result/PredictionName.mat

% Step2: read yeastbow output

for i=1:length(Output)

% Step3.1: Prepare Image_i and ROIs

Predict_Cells = Output(i).ROIs; % Read Image_i 's ROI

Yeastbow_ROI  = ROIs; % Copy standard Fiji ROI

Factor        = File(i).ScaleFactor;%

    % Step3.2: Revise Fiji ROI for Image_i: name, boundary,coordinates
    for m=1:length(Predict_Cells)

        Yeastbow_ROI(m)  = Yeastbow_ROI(1); 
        
        if m>9
            Yeastbow_ROI{m}.strName = num2str(m);
        else
            Yeastbow_ROI{m}.strName = ['0' num2str(m)];
        end
            
        Yeastbow_ROI{m}.mnCoordinates= Factor * Predict_Cells(m).ConvexHull;
        Yeastbow_ROI{m}.vnRectBounds = [min(Yeastbow_ROI{m}.mnCoordinates(:,2)) min(Yeastbow_ROI{m}.mnCoordinates(:,1)) max(Yeastbow_ROI{m}.mnCoordinates(:,2)) max(Yeastbow_ROI{m}.mnCoordinates(:,1))];

    end

    % Step3.2: write Fiji ROI for Image_i
    
    WriteImageJROI(Yeastbow_ROI,[Path 'YeastbowROI'],File(i).name(1:end-4))

%     imwrite(imadjust(Output(i).Image),[Path, 'YeastbowROI/', File(i).name(1:end-4),'.png'])
    
end

