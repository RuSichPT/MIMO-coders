clc; clear;close all;
Eb_N0 = 0:40;
% �� MIMO QAM16
figure(1)
load('DataBase/corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=256_Exp=100.mat');
SNR = SNR(1:size(ber_mean,2));
plot_ber(ber_mean,SNR,prm.bps,'k',1.5,0);
load('DataBase/CR=23_31_corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=16_Exp=100.mat');
plot_ber(ber_mean,SNR,prm.bps,'-.k',1.5,0);
load('DataBase/CR=15_31_corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=16_Exp=100.mat');
SNR = SNR(1:size(ber_mean,2));
plot_ber(ber_mean,SNR,prm.bps,':k',1.5,0);
load('DataBase/CR=9_31_corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=256_Exp=100.mat');
plot_ber(ber_mean,SNR,prm.bps,'--k',1.5,0);
xlim([0 40]);
ylim([10^-4 10^0]);
title('MIMO QAM16')
legend ('��� ������','�������� ���� 3/4 (23/31)','�������� ���� 1/2 (15/31)',...
    '�������� ���� 1/4 (9/31)');
% ����  MIMO QAM16
figure(2)
load('DataBase/corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=256_Exp=100.mat');
SNR = SNR(1:size(ber_mean,2));
plot_ber(ber_mean,SNR,prm.bps,'k',1.5,0);
load('DataBase/CR=23_31_corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=16_Exp=100.mat');
plot_ber(ber_mean,SNR,prm.bps,'r',1.5,0);
load('DataBase/CR=15_31_corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=16_Exp=100.mat');
SNR = SNR(1:size(ber_mean,2));
plot_ber(ber_mean,SNR,prm.bps,'b',1.5,0);
load('DataBase/CR=9_31_corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=256_Exp=100.mat');
plot_ber(ber_mean,SNR,prm.bps,'g',1.5,0);
xlim([0 40]);
ylim([10^-4 10^0]);
title('MIMO QAM16')
legend ('��� ������','�������� ���� 3/4 (23/31)','�������� ���� 1/2 (15/31)',...
    '�������� ���� 1/4 (9/31)');

% �� SISO QAM16
figure(3)
load('DataBase/corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=4_Ms=16_Exp=100.mat');
plot_ber(ber_siso_mean,SNR,prm.bps_siso,'k',1.5,0);
load('DataBase/CR=23_31_corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=16_Exp=100.mat');
plot_ber(ber_siso_mean,SNR,prm.bps_siso,'-.k',1.5,0);
load('DataBase/CR=15_31_corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=16_Exp=100.mat');
SNR = SNR(1:size(ber_siso_mean,2));
plot_ber(ber_siso_mean,SNR,prm.bps_siso,':k',1.5,0);
load('DataBase/CR=9_31_corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=16_Exp=100.mat');
plot_ber(ber_siso_mean,SNR,prm.bps_siso,'--k',1.5,0);
xlim([0 40]);
ylim([10^-4 10^0]);
title('SISO QAM16')
legend ('��� ������','�������� ���� 3/4 (23/31)','�������� ���� 1/2 (15/31)',...
    '�������� ���� 1/4 (9/31)');

% ���� SISO QAM16
figure(4)
load('DataBase/corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=4_Ms=16_Exp=100.mat');
plot_ber(ber_siso_mean,SNR,prm.bps_siso,'k',1.5,0);
load('DataBase/CR=23_31_corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=16_Exp=100.mat');
plot_ber(ber_siso_mean,SNR,prm.bps_siso,'r',1.5,0);
load('DataBase/CR=15_31_corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=16_Exp=100.mat');
SNR = SNR(1:size(ber_siso_mean,2));
plot_ber(ber_siso_mean,SNR,prm.bps_siso,'b',1.5,0);
load('DataBase/CR=9_31_corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=16_Exp=100.mat');
plot_ber(ber_siso_mean,SNR,prm.bps_siso,'g',1.5,0);
xlim([0 40]);
ylim([10^-4 10^0]);
title('SISO QAM16')
legend ('��� ������','�������� ���� 3/4 (23/31)','�������� ���� 1/2 (15/31)',...
    '�������� ���� 1/4 (9/31)');

% �� ���������� ��������
figure(5)
load('DataBase/corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=256_Exp=100.mat');
SNR = SNR(1:size(ber_mean,2));
plot_ber(ber_mean,SNR,prm.bps,'k',1.5,0);
plot_ber(ber_siso_mean,SNR,prm.bps_siso,'-',1.5,0,[0.45 0.45 0.45]);
load('DataBase/CR=9_31_corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=256_Exp=100.mat');
plot_ber(ber_mean,SNR,prm.bps,'--k',1.5,0);
plot_ber(ber_siso_mean,SNR,prm.bps_siso,'--',1.5,0,[0.45 0.45 0.45]);
legend ('��� ������ MIMO','��� ������ SISO','MIMO 1/4 (9/31)',...
    'SISO 1/4 (9/31)');
xlim([0 40]);
ylim([10^-4 10^0]);
% ���� ���������� ��������
figure(6)
load('DataBase/corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=256_Exp=100.mat');
SNR = SNR(1:size(ber_mean,2));
plot_ber(ber_mean,SNR,prm.bps,'k',1.5,0);
plot_ber(ber_siso_mean,SNR,prm.bps_siso,'r',1.5,0);
load('DataBase/CR=9_31_corM=1_2x2_RAYL_Wm=1_Ws=1_Mm=16_Ms=256_Exp=100.mat');
plot_ber(ber_mean,SNR,prm.bps,'--k',1.5,0);
plot_ber(ber_siso_mean,SNR,prm.bps_siso,'--r',1.5,0);
legend ('��� ������ MIMO','��� ������ SISO','MIMO 1/4 (9/31)',...
    'SISO 1/4 (9/31)');
xlim([0 40]);
ylim([10^-4 10^0]);