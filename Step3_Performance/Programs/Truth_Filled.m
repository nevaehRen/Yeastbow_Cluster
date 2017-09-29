function Truth = Truth_Filled(ROIs)
%% Given ROIs, generate 256*256 image with ROIs filled with 1
%% ScaleFacor is used in case of overlap
%%

ScaleFactor = 0.8;

bw = poly2mask([],[],256,256);

for m=1:length(ROIs)
    
x_center = mean(ROIs{m}(:,1));
y_center = mean(ROIs{m}(:,2));

x = (ROIs{m}(:,1)-x_center)*ScaleFactor+x_center;
y = (ROIs{m}(:,2)-y_center)*ScaleFactor+y_center;

bw = bw|poly2mask(x,y,256,256);

end

Truth=bw;

end

