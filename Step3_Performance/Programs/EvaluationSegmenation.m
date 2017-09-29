function [Predict Fact] = EvaluationSegmenation(BW,BW_truth)

s     = regionprops(BW, 'centroid');
centroids = cat(1, s.Centroid);
ROIs  = regionprops(BW, 'ConvexHull');

s_truth     = regionprops(BW_truth, 'centroid');
centroids_truth = cat(1, s_truth.Centroid);

ROIs_truth  = regionprops(BW_truth, 'ConvexHull');



for i=1:length(ROIs)
    Predict(i).Ifin=0;

for j=1:length(ROIs_truth)
    
    Predict(i).Ifin=Predict(i).Ifin+inpolygon(centroids(i,1),centroids(i,2),ROIs_truth(j).ConvexHull(:,1),ROIs_truth(j).ConvexHull(:,2));
    if Predict(i).Ifin~=0
        break;
    end
end

end


for i=1:length(centroids_truth)   

    Fact(i).Ifin=0;

for j=1:length(ROIs)    
    Fact(i).Ifin=Fact(i).Ifin+inpolygon(centroids_truth(i,1),centroids_truth(i,2),ROIs(j).ConvexHull(:,1),ROIs(j).ConvexHull(:,2));
    if Fact(i).Ifin~=0
        break;
    end
end

end


end




