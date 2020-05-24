function [H,H_siso] = create_chanel(flag_my_chanel,prm)
    switch flag_my_chanel
        case 'STATIC'
%             rng(167)
            for i= 1:prm.numTx
                for j = 1:prm.numRx           
                    H(i,j) = (randn(1)+1i*randn(1))/sqrt(2);
                end
            end 
            H_siso = (randn(1)+1i*randn(1))/sqrt(2);
        case 'AWGN'        
            H = eye(prm.numTx,prm.numRx);
            H_siso = 1;
%         case 'BAD'
%             H = zeros(prm.numTx,prm.numRx);
%             H(1,1) = 1.1 - i*1;
%             H(1,2) = 1 - i*1;
%             H(2,1) = -1 - i*1;        
%             H(2,2) = -1 - i*1;
        case 'RAYL' 
            H = comm.MIMOChannel(...
                'SampleRate',                prm.SampleRate,...
                'PathDelays',                prm.tau_mimo,...
                'AveragePathGains',          prm.pdB_mimo,...
                'MaximumDopplerShift',       0,...
                'SpatialCorrelationSpecification', 'None',...              
                'PathGainsOutputPort', true);
%                             'RandomStream',             'mt19937ar with seed', ...
%                 'Seed',SEED,...586 122 12   
%                 'Seed',586,...586 122 12
%                 'Visualization','Impulse and frequency responses', ...
%                 'AntennaPairsToDisplay',[1,2],...
%                 'AntennaPairsToDisplay',[1,2]);
%                 'TransmitCorrelationMatrix', cat(3, eye(2), [1 0.01;0.01 1]),...
%                 'ReceiveCorrelationMatrix',  cat(3, [1 0.1;0.1 1], eye(2)),...
            H_siso =  comm.RayleighChannel(...
                'SampleRate',               prm.SampleRate, ...
                'PathDelays',               prm.tau_siso, ...
                'AveragePathGains',         prm.pdB_siso,...
                'MaximumDopplerShift',      0,...
                'PathGainsOutputPort',true);
%                             'RandomStream',             'mt19937ar with seed', ...
%                 'Seed',SEED,...%314
%                 'Visualization','Impulse and frequency responses', ...                
%                 'Visualization','Impulse and frequency responses'); %,... $;
%                 'RandomStream',             'mt19937ar with seed', ...
%                 'Seed',89,...
            
    end
end    



