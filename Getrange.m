
function sRangez = Getrange (sumz,thre)
% sumthrz = 0.3*max(sumz);%5
% temp = sumz>sumthrz; temp(1)=1;
% temp2 = find(temp);
% temp2s =diff(temp2); temp2ss = find(temp2s>1);
% if ~isempty(temp2ss)
%     if length(temp2ss)>1
%         mm=[];
%         for i = 1:length(temp2ss)-1
%             mm(i,1)=temp2ss(i+1)-temp2ss(i);
%         end
% 
%         index = find(mm==max(mm));
%         sRangez = temp2(index+1):temp2(temp2ss(index+1));
%     else
%         sRangez = temp2(2):temp2(end);
%     end
%         
% else
%     sRangez = temp2;
% end
% 
sumthrz = thre*max(sumz);%5
temp = sumz>sumthrz; %temp(1)=1;
temp2 = find(temp);
temp2s =diff(temp2); 
temp2ss = find(temp2s>1);
range=[];
if ~isempty(temp2ss)

    mm=[];
    mm(1,1) = temp2(temp2ss(1)+1)-temp2(1);
    range(1,1:2)=[temp2(1) temp2(temp2ss(1)+1) ];
    i=1;
    if length(temp2ss)>1
        for i = 2:length(temp2ss)
            mm(i,1)=temp2(temp2ss(i))-temp2(temp2ss(i-1)+1);
            range(i,1:2)=[temp2(temp2ss(i-1)+1) temp2(temp2ss(i))];

        end
    end
    mm(i+1,1) = temp2(end)-temp2(temp2ss(i)+1);
    range(i+1,1:2)=[ temp2(temp2ss(i)+1) temp2(end)];
%     mm(mm>50)=0;
    for j=1:length(range)
        suvm(j,1) = mean(sumz(range(j,:)));
    end
    indsuv = find(suvm==max(suvm));
    if mm(indsuv)>5
        sRangez = range(indsuv,:);
    else
        sRangez = range(find(mm==max(mm)),:);
    end


else
    sRangez = temp2;
end
sRangez = sRangez(1):sRangez(end);