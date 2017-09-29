
function I_compress = SVD_Image(Image,Percentage)

% Image = data{Order(i)}.imageBF';
% Image = imresize(Image,[256,256]);

I = double(Image);
I = I/max(max(I)); 


[U S V] = svd(I) ;

I_compress=I*0;


for j=1:256

I_compress = I_compress +  U(:,j)*S(j,j)*V(:,j)';

if sum(diag(S(1:j,1:j)))/sum(diag(S))>Percentage
   break
end
end


