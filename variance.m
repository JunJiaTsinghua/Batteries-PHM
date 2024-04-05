function [ var ] = variance( list )
%UNTITLED7 此处显示有关此函数的摘要
%   此处显示详细说明
n=length(list);
m=mean(list);
sum=0;
for i =1:n
   sum=sum+ (list(i)-m)^2;
end
var=sum/(n-1);

