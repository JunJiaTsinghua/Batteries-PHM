function [ index ] = charge_index_get( I )
%STILL_INDEX_GET ���ڻ�ȡ��ֹ״̬��index
%   �˴���ʾ��ϸ˵��
index=zeros(1,length(I));
num=0;
for i=1:length(I)-1
    
if I(i)<0
    num=num+1;
    index(num)=i;
     
end
index(index==0)=[];

end