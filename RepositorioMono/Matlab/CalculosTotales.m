%Calculos Totales
clc
clear
%% Calculos de portadoras
clc
N= 128;
CP = 12;
Nfft = N-CP;
Bguard = 16;
BguardHigh = 8;
BguardLow = 8;
Pilot = 4;
pilotIndex = [23;39;67;82];
DcCarrier = 1;
Nused = Nfft - Bguard ;
Ndata = Nused - Pilot - DcCarrier;
%ver mappig data
ofdmMod = comm.OFDMModulator();
ofdmMod.FFTLength = Nfft-CP;
ofdmMod.NumGuardBandCarriers = [BguardLow;BguardHigh];
ofdmMod.InsertDCNull = true;
ofdmMod.CyclicPrefixLength = CP;
ofdmMod.NumSymbols = 1;
ofdmMod.PilotInputPort = true;
ofdmMod.PilotCarrierIndices =  pilotIndex;
showResourceMapping(ofdmMod);
%% Codificacion
clc
Txt = char("Hola MundoHola MundoHola Mundo");
unicode = uint8 (Txt); %conversion para 8 bits
Nbits = length(unicode)*8;
P = 6; %Los símbolos del código son secuencias binarias de longitud M
N = 2^P -1; 
Kmax = N-2; % Kmax rango [1 Kmax]
K = Nbits/P;
%% Modulaciones y Bits
clc
M = 16; %16 QAM
nPortadoras = Ndata; %
bitsPorSimbolo = log2(M);
nBits = nPortadoras*bitsPorSimbolo;
%% SISO channel
%Doppler máximo que se calcula como v*f/c
v = 0.1; %velocidad del movil
f = 2.7e9; % frecuencia de portadora
c = physconst('LightSpeed');%velocidad de la luz
maxDopplerShift = v*f/c;
%% interpolacion / LS
clc
close all
PilotTx  =  [0 1 0 1 1 1 0 1 1 1 1 1 0 1 1 1]';
QAMPilotsTx = qammod(PilotTx,M,"InputType","bit","UnitAveragePower",true);
scatterplot(QAMPilotsTx);
title ("QAMPilotsTx")
SNR = 15;
QAMPilotsRx = awgn(QAMPilotsTx,SNR,"measured");
scatterplot(QAMPilotsRx);
title ("QAMPilotsRx")
% MagQAMPilotsRx = abs(QAMPilotsRx);
%PilotRX = qamdemod(QAMPilotsRx,M,"OutputType","bit","UnitAveragePower",true);
%% 
% Estimar el canal
Hpilots = QAMPilotsRx ./ QAMPilotsTx;
%interpolate spline
H=interp1(pilotIndex,Hpilots,(1:4)','spline','extrap');
% figure();
% plot(pilotIndex,real(Hpilots),'*r',(1:4)',real(H),'--b')
% hold on
% plot(pilotIndex,imag(Hpilots),'*g',(1:4)',imag(H),'--c')
%
EqH= conj(H)./(conj(H).*H);
EqSignal = QAMPilotsRx.*EqH;
scatterplot(EqSignal);
title ("QAM Equalizado")
%% Channel estimation
clc
%y(k) = hx(k) + v(k)
v = 3; %dB
vl =  10^(v*0.1);
PilotTx  =  [0 1 0 1 1 1 0 1 1 1 1 1 0 1 1 1]';
QAMPilotsTx = qammod(PilotTx,16,"InputType","bit","UnitAveragePower",true);
X = QAMPilotsTx;
Y = out.PilotsRx(40421:40424);
h_hat = (X'*Y)/(norm(X)^2);
X1 = Y/h_hat;

%% FDE estimation
clc
clear
v = [0 0 0 0];%noise 
% x = [1+1i 1-1i -1-1i 1-1i]; %
h = [1 0.5 zeros(1,93)]';
% y = [1 0.5 0.5 1];
y = randi([1 10],1,95)';
Y = fft(y,95);
H = fft(h,95);
X_hat = Y./H; %simbolos transmitidos estimados
x_hat = ifft (X_hat,95)
%% OFDM
BW=1500000
Nc=64;
deltaf =BW/Nc;
M = 4 %QPSK
Rb = log2(M)*BW;
