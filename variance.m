function [ var ] = variance( list )
%UNTITLED7 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
n=length(list);
m=mean(list);
sum=0;
for i =1:n
   sum=sum+ (list(i)-m)^2;
end
var=sum/(n-1);

