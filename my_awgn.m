function [Y,sigma] = my_awgn(X,snr)
for i = 1:size(X,2)
    E_tmp(i) = sum(abs(X(:,i)).^2); % �������
    P(i) = E_tmp(i)/(size(X,1));% ������� �������� 
    A(i) = sqrt(P(i)); % ������� ���������
    sigma(i) = A(i)*10^((-snr)/20); % ���
end
sigma =  diag(sigma);
Y =  X+(randn(size(X,1),size(X,2))+ 1i * randn(size(X,1),size(X,2)))*0.707 * sigma;
end

