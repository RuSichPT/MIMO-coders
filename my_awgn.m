function [Y,sigma] = my_awgn(X,snr)
for i = 1:1
    E_tmp(i) = sum(abs(X(:,i)).^2); % �������       
end
E = sum(E_tmp);
P = E/(size(X,1));% ������� ��������   
A = sqrt(P); % ������� ���������
sigma = A*10^((-snr)/20); % ���
Y =  X+0.707 * sigma * (randn(size(X,1),size(X,2))+ 1i * randn(size(X,1),size(X,2)));
end

