function out= rmovmean(v1,r1,r2)% raw vector, r1=same kb input used in movmean,r2=amount of data points before timepoint of interst)

v2=movmean(v1,[r1 0]);
out=zeros(1,size(v1,2));

for i=1:size(v1,2);
  if i<=r1;
   out(1,i)=nan; 
  else
   out(1,i)=(r1*v2(i-r2))/(r1);
  end
end


% for i=1:size(v1,2);
%   if i<=r2;
%    out(1,i)=nan; 
%   else
%    out(1,i)=(v1(i)+(r1*v2(i-r2)))/(r1+numel(r1));
%   end
% end

end 