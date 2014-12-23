% gyroChar_instr_E5061B_script

close all;
clear all;

DATE = '12-22-14';

na = gyroChar_instr_NA_init('USB0::0x0957::0x1309::MY49204103::0::INSTR','ifbw',1000);
na = gyroChar_instr_NA_initFreqResponse(na);
[na, Freqs, MAG, Phase, M1] = gyroChar_instr_NA_measFreqResponse(na);

% for i=1:10
%     pause(1)
%     [Freqs, MAG, Phase] = gyroChar_instr_E5061B('USB0::0x0957::0x1309::MY49204103::0::INSTR');
% end

gyroChar_instr_NA_close(na);

figure;
plot(Freqs,MAG)

figure;
plot(Freqs,Phase)



