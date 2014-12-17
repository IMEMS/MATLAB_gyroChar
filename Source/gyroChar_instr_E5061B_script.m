% gyroChar_instr_E5061B_script
% E5061B Instrument Control Script
%  Under Development 12-16-14
% 

[Freqs, MAG, Phase] = gyroChar_instr_E5061B('USB0::0x0957::0x1309::MY49204103::0::INSTR');

for i=1:10
    pause(1)
    [Freqs, MAG, Phase] = gyroChar_instr_E5061B('USB0::0x0957::0x1309::MY49204103::0::INSTR');
end
figure;
plot(Freqs,Phase)

figure;
plot(Freqs,MAG)

