function get_DB_LDPC(MOD_M,MOD_S,wav_MIMO,wav_SISO,cor_MIMO,snr,exp,CR)
%% ����������
flag_chanel = 'RAYL'; % 'AWGN' ,'RAYL','RIC','RAYL_SPECIAL','STATIC', 'BAD' 
flag_cor_MIMO = cor_MIMO; % 1-��������� ��� (���������� ��� MIMO) 2-��������
flag_cor_SISO = 1; % ��������� ��� (���������� ��� SISO)
flag_wav_MIMO = wav_MIMO; % ������� �������������� ��� MIMO
flag_wav_SISO = wav_SISO; % ������� �������������� ��� SISO
flag_coder_LDPC = 1; % ����� LDPC ���/����
%% ��������� ������� MIMO
prm.numTx = 2; % ���-�� ���������� �����
prm.numRx = 2; % ���-�� �������� �����
prm.numSTS = prm.numTx; % ���-�� �������
prm.M = MOD_M;% ������� ���������
prm.bps = log2(prm.M); % ����-�� ��� �� ������ � �������
prm.CodeRate = 1; % CONST �� ������. �� ���������
prm.LEVEL = 3;% ������� ������������ ������� �������������� min(wmaxlev(N,'db4'),floor(log2(N)))
%% ��������� ������� SISO
prm.M_siso = MOD_S;% ������� ���������
prm.bps_siso = log2(prm.M_siso); % ����-�� ��� �� ������ � �������
prm.Nsymb_ofdm_p = 1; % ���-�� �������� �������� OFDM 
%% ��������� ������
codeRate = CR; % 1/4, 1/3, 2/5, 1/2, 3/5, 2/3, 3/4, 4/5, 5/6, 8/9, or 9/10
CODEWORD_LENGTH = 64800;
N_CodeWord = 2; % ���-�� ������� ����
ofdm_symb = 36; % �� n = 64800; 
%% ��������� OFDM 
prm.numSC = 450; % ���-�� �����������
prm.N_FFT = 512; % ����� FFT ��� OFDM
prm.Nsymb_ofdm = 100; % ���-�� �������� OFDM �� ������ �������
prm.CyclicPrefixLength = 64;  % ����� �������� ���������� = 2*Ngi
prm.tmp_NCI = prm.N_FFT - prm.numSC;
prm.NullCarrierIndices = [1:prm.tmp_NCI/2 prm.N_FFT-prm.tmp_NCI/2+1:prm.N_FFT]'; % Guards and DC
%% ��������� ������
prm.KFactor = 1;% ��� 'RIC'
prm.SEED = 122;% ��� 'RAYL_SPECIAL' 586 122 12   
prm.SampleRate = 40e6;
dt = 1/prm.SampleRate;
switch flag_chanel
    case "RAYL"       
        prm.tau = [2*dt 5*dt 7*dt];
        prm.pdB = [-3 -9 -12];
        % prm.tau = [2*dt 7*dt 15*dt];
        % prm.pdB = [-3 -9 -12]
    otherwise
        prm.tau = 5*dt;
        prm.pdB = -10;
end
%%
if flag_cor_MIMO == 2
    ostbcEnc = comm.OSTBCEncoder('NumTransmitAntennas',prm.numTx);
    ostbcComb = comm.OSTBCCombiner('NumReceiveAntennas',prm.numRx);
    numTx = 1;
else
    numTx = prm.numTx;
end
if flag_coder_LDPC == 1
%% ������� ������ LDPC
    LDPCParityCheckMatrix = dvbs2ldpc(codeRate);
    ldpcEnc = comm.LDPCEncoder(LDPCParityCheckMatrix);
    ldpcDec = comm.LDPCDecoder(LDPCParityCheckMatrix);
    prm.Nsymb_ofdm = ofdm_symb;
    prm.CodeRate = codeRate;
    Nsymb_ofdm_mimo = ofdm_symb/numTx;
    prm.Nsymb_ofdm = ofdm_symb;
    expfactbps = prm.bps/prm.bps_siso;
    Nsymb_ofdm_siso = ofdm_symb*expfactbps;
else
    Nsymb_ofdm_mimo = prm.Nsymb_ofdm;
    Nsymb_ofdm_siso = prm.Nsymb_ofdm;
    N_CodeWord = 1;
end
%% ������ 
prm.n = prm.bps*Nsymb_ofdm_mimo*prm.numSC*numTx*prm.CodeRate;% ����� ��������� ������
prm.n_pilot = prm.Nsymb_ofdm_p*prm.numSC; % ���-�� ��� �� ������ SISO
prm.n_siso = prm.bps_siso*Nsymb_ofdm_siso*prm.numSC*prm.CodeRate;% ����� ��������� ������
%% ---------��� ������--------
SNR_MAX = snr;
SNR = 0+floor(10*log10(prm.bps)):SNR_MAX+floor(10*log10(prm.bps*prm.numTx));
% SNR = [floor(10*log10(prm.bps)):9  9.2:0.2:SNR_MAX SNR_MAX+1:SNR_MAX+floor(10*log10(prm.bps*prm.numTx))];
prm.MinNumErr = 100; % ����� ������ ��� ����� 
prm.conf_level = 0.95; % ������� �������������
prm.MAX_indLoop = 10;% ������������ ����� �������� � ����� while
Koeff = 1/15;%���-�� ��������� �� BER  7%
Exp = exp;% ���-�� ������
for indExp = 1:Exp
    %% �������� ������
    [H,H_siso] = create_chanel(flag_chanel,prm);  
    for indSNR = 1:length(SNR)
        berconf_M = 0;
        berconf_S = 0;
        ErrNum_M = 0; % ���-�� ������ MIMO 
        ErrNum_S = 0; % ���-�� ������ MIMO 
        indLoop = 0;  % ��������� �������� ����� while
        LenIntLoop_S = 100;
        LenIntLoop_M = 100;
        condition_M = ((LenIntLoop_M > berconf_M*Koeff)||(ErrNum_M < prm.MinNumErr));
        condition_S = ((LenIntLoop_S > berconf_S*Koeff)||(ErrNum_S < prm.MinNumErr));
        while (condition_M || condition_S) && (indLoop < prm.MAX_indLoop)
            %% ��������� ������ 
            if flag_coder_LDPC == 1
                Inp_data = randi([0 1],prm.n*N_CodeWord,1); % ������������ ������
                EncData = [];
                for i=1:N_CodeWord
                    EncData = cat(1,EncData,ldpcEnc(Inp_data(1+(i-1)*prm.n:prm.n+(i-1)*prm.n))); % ����� LDPC
                end
                IntrData= randintrlv(EncData,prm.SEED); %������������
            else
                Inp_data = randi([0 1],prm.n,1); % ������������ ������
                IntrData = Inp_data;
            end
            % SISO
            if flag_coder_LDPC == 1
                Inp_data_siso = randi([0 1],prm.n_siso*N_CodeWord,1); % ������������ ������
                EncData_siso = [];
                for i=1:N_CodeWord
                    EncData_siso = cat(1,EncData_siso,ldpcEnc(Inp_data_siso(1+(i-1)*prm.n:prm.n+(i-1)*prm.n))); % ����� LDPC
                end
                IntrData_siso = randintrlv(EncData_siso,prm.SEED); %������������
            else
                Inp_data_siso = randi([0 1],prm.n_siso,1); % ������������ ������
                IntrData_siso = Inp_data_siso;
            end          
            % ��������� ������ ��� SISO 
            Inp_data_pilot = randi([0 1],prm.n_pilot,1);%  ����� ������� � �����
            %% ���������
            % MIMO
            Mod_data_inp_tmp = qammod(IntrData,prm.M,'InputType','bit');% ��������� QAM-M ��� �������� ���
            if flag_cor_MIMO == 2
                Mod_data_inp_tmp = ostbcEnc(Mod_data_inp_tmp);
            end 
            Mod_data_inp = reshape(Mod_data_inp_tmp,prm.numSC,Nsymb_ofdm_mimo*N_CodeWord,prm.numTx);
            % ��������� �������  MIMO
            [preambula,ltfSC] = My_helperGenPreamble(prm);
            % ��������� �������  SISO
            Mod_data_inp_pilot = pskmod(Inp_data_pilot,2);
            % SISO
            Mod_data_inp_tmp_siso = qammod(IntrData_siso,prm.M_siso,'InputType','bit');% ��������� QAM-M ��� �������� ���
            Mod_data_inp_tmp_siso1 = cat(1,Mod_data_inp_pilot,Mod_data_inp_tmp_siso );
            Mod_data_inp_siso = reshape(Mod_data_inp_tmp_siso1,prm.numSC,Nsymb_ofdm_siso*N_CodeWord+prm.Nsymb_ofdm_p,1);
            %% ��������� OFDM
            OFDM_data = ofdmmod(Mod_data_inp,prm.N_FFT,prm.CyclicPrefixLength,...
                         prm.NullCarrierIndices);               
            OFDM_data_siso = ofdmmod(Mod_data_inp_siso,prm.N_FFT,prm.CyclicPrefixLength,...
                         prm.NullCarrierIndices);        
            OFDM_data = [preambula ; OFDM_data];        
            %% ����������� ������
            switch flag_chanel
                case {'RAYL','RIC','RAYL_SPECIAL'}
    %                 H.Visualization = 'Impulse and frequency responses';
    %                 H.AntennaPairsToDisplay = [2,2];
    %                 H_siso.Visualization = 'Impulse and frequency responses';
                    [Chanel_data, H_ist] = H(OFDM_data);
                    [Chanel_data_siso, H_ist_siso] = H_siso(OFDM_data_siso);
                otherwise                  
                    Chanel_data  = OFDM_data*H;
                    Chanel_data_siso  = OFDM_data_siso*H_siso; 

            end    
            %% �����������  ���
            [Noise_data,sigma] = my_awgn(Chanel_data,SNR(indSNR));%SNR(indSNR)
            [Noise_data_siso,sigma_siso] = my_awgn(Chanel_data_siso,SNR(indSNR));%SNR(indSNR)
            %% ����������� OFDM
            Mod_data_out = ofdmdemod(Noise_data,prm.N_FFT,prm.CyclicPrefixLength,prm.CyclicPrefixLength, ...
                prm.NullCarrierIndices);
            Mod_data_out_siso = ofdmdemod(Noise_data_siso,prm.N_FFT,prm.CyclicPrefixLength,prm.CyclicPrefixLength, ...
                prm.NullCarrierIndices);  
            %% ������ ������  
            H_estim = My_helperMIMOChannelEstimate(Mod_data_out(:,1:prm.numSTS,:),ltfSC,prm);
            H_estim_siso = Mod_data_out_siso(:,1)./Mod_data_inp_pilot;
            Mod_data_out_siso(:,1:prm.Nsymb_ofdm_p) = [];
            %% ������� ��������������
            if flag_wav_SISO == 1
                H_estim_siso = H_WAV_my(H_estim_siso,prm.LEVEL);
            end
            if flag_wav_MIMO == 1
                H_estim = H_WAV_my_mimo(H_estim,prm.LEVEL);
            end
            %% ���������� 
            %ZF MIMO
            if flag_cor_MIMO == 1
                Mod_data_out_ZF_tmp= My_MIMO_Equalize_ZF_numSC(Mod_data_out(:,prm.numTx+1:end,:),H_estim);
                Mod_data_out_ZF = reshape(Mod_data_out_ZF_tmp,prm.numSC*Nsymb_ofdm_mimo*N_CodeWord,prm.numRx);
            elseif flag_cor_MIMO == 2
                Mod_data_out_ZF_tmp = Mod_data_out(:,prm.numTx+1:end,:);
                for i = 1:prm.Nsymb_ofdm*N_CodeWord
                    Mod_data_out_ZF(:,i) = ostbcComb(squeeze(Mod_data_out_ZF_tmp(:,i,:)),H_estim);
                end
            else
                Mod_data_out_ZF_tmp = Mod_data_out(:,prm.numTx+1:end,:);
                Mod_data_out_ZF = reshape(Mod_data_out_ZF_tmp,prm.numSC*prm.Nsymb_ofdm*N_CodeWord,prm.numRx);
            end
            %ZF SISO
            if flag_cor_SISO == 1
                for i = 1:size(Mod_data_out_siso,2)
                    Mod_data_out_siso_ZF(:,i) = Mod_data_out_siso(:,i)./H_estim_siso;
                end
            else
                Mod_data_out_siso_ZF = Mod_data_out_siso;
            end        
            %% �����������
            Mod_data_out_tmp = Mod_data_out_ZF(:);  
            Mod_data_out_siso_tmp = Mod_data_out_siso_ZF(:);     
            if(flag_coder_LDPC == 1)
                CWL = CODEWORD_LENGTH;
                Out_encode = qamdemod(Mod_data_out_tmp,prm.M,'OutputType','approxllr');
                DeintData = randdeintrlv(Out_encode,prm.SEED);
                Out_data = [];
                for i = 1:N_CodeWord
                    Out_data = cat(1,Out_data,ldpcDec(DeintData(1+(i-1)*CWL:CWL+(i-1)*CWL)));% ������� LDPC
                end
            else
                Out_data = qamdemod(Mod_data_out_tmp,prm.M,'OutputType','bit');  
            end
            if(flag_coder_LDPC == 1)
                Out_encode_siso = qamdemod(Mod_data_out_siso_tmp,prm.M_siso,'OutputType','approxllr');
                DeintData_siso = randdeintrlv(Out_encode_siso,prm.SEED);
                Out_data_siso = [];
                for i = 1:N_CodeWord
                    Out_data_siso = cat(1,Out_data_siso,ldpcDec(DeintData_siso(1+(i-1)*CWL:CWL+(i-1)*CWL))); % ������� LDPC
                end
            else
                Out_data_siso = qamdemod(Mod_data_out_siso_tmp,prm.M_siso,'OutputType','bit');  
            end
            ErrNum_M = ErrNum_M+sum(abs(Out_data-Inp_data));          
            ErrNum_S = ErrNum_S+sum(abs(Out_data_siso-Inp_data_siso));
            %%
            indLoop = indLoop+1;
            [berconf_M,conf_int_M] = berconfint(ErrNum_M,indLoop*length(Inp_data),prm.conf_level);
            [berconf_S,conf_int_S] = berconfint(ErrNum_S,indLoop*length(Inp_data_siso),prm.conf_level);
            LenIntLoop_M = conf_int_M(2)-conf_int_M(1);
            LenIntLoop_S = conf_int_S(2)-conf_int_S(1);
            condition_M = ((LenIntLoop_M > berconf_M/15)||(ErrNum_M < prm.MinNumErr));
            condition_S = ((LenIntLoop_S > berconf_S/15)||(ErrNum_S < prm.MinNumErr));
        end
        ber(indExp,indSNR) = berconf_M;
        ber_siso(indExp,indSNR) = berconf_S;
%         ber1(indExp,indSNR) = ErrNum_M/(indLoop*length(Inp_data));
%         ber_siso1(indExp,indSNR) = ErrNum_S/(indLoop*length(Inp_data_siso));
        if ErrNum_M>ErrNum_S
            ErrNum_disp = ErrNum_S;
            name = 'Er_SISO';
        else
            ErrNum_disp = ErrNum_M;
            name = 'Er_MIMO';
        end
        fprintf(['Complete %d db ' name ' = %d, ind = %d\n'],SNR(indSNR),ErrNum_disp,indLoop);
    end
    fprintf('Exp %d  \n',indExp);
end
if flag_cor_MIMO ~= 2 
    prm.bps = prm.bps*prm.numTx;
end
ber_mean = mean(ber,1);
ber_siso_mean = mean(ber_siso,1);
str = ['DataBase/CR=' num2str(prm.CodeRate) '_corM=' num2str(flag_cor_MIMO) '_' num2str(prm.numTx) 'x' num2str(prm.numRx) '_' flag_chanel '_Wm=' num2str(flag_wav_MIMO)...
    '_Ws=' num2str(flag_wav_SISO) '_Mm=' num2str(prm.M)...
    '_Ms=' num2str(prm.M_siso) '_Exp=' num2str(Exp) '.mat'];
save(str,'ber_mean','ber_siso_mean','SNR','prm','ber','ber_siso')
end

