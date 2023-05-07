%% crear trama
clc
clear
TextTx = 'Hola MundoHola Mundo';
u8TX = uint8(TextTx);
a1=dec2bin(u8TX,8);
a2 = '';
for i = 1:length(a1)
    a2 = [a2 a1(i,:)];
end
a2 = a2';
data = bin2dec(a2);


%%PLCP Physical Layer Convergence
%%SYMBOL SIGNAL

%% simbolo de configuracion 
%%QPSK 1/2
%bits
RATE = 4;
R=1;
P=1;
RESERVED = 1; 
LENGHT = 12; % numero de octetos a transmitir
TAIL = 6;
rate = [0 1 0 1]';
r = 0;
tail = [0 0 0 0 0 0]';
SERVICE = 16;
service = ones(SERVICE,1);
Nbpsc = 2;
Ncbps = 96;
Ndbps = 48;
NDATA = SERVICE+length(data); %debe ser multiplo de Ndbps
lenght = bin2dec(dec2bin(NDATA/8,LENGHT)');
PAD =  (Ndbps*(round(NDATA/Ndbps))+1) - NDATA; 
pad = zeros (PAD,1);
a4= mod(RATE+R+LENGHT+P+TAIL+SERVICE+NDATA+TAIL+PAD,2);
if a4 == 0; p=1; else p=0; end 
PLCPHeader = [rate;r;lenght;p;tail;service];
SIGNAL = [rate;r;lenght;p;tail];
DATA = [service;data;tail;pad];
Nsym= (NDATA+PAD)/Ndbps;
FRAMEIEE80211aTX = [SIGNAL;DATA];
%%
% escribir archivo 
fileID = fopen('archivooriginal.txt','wb');
fwrite(fileID,FRAMEIEE80211aTX);

%%
%leer archivo

f = fopen('archivooriginal.txt', 'rb');
RX = fread(f, Inf,"uint8");
delay = 470; % delay obtenido con BER_GnuRadio
FRAMEIEE80211aRX = RX(delay:delay+223-1);


rateRx =  FRAMEIEE80211aRX(1:RATE);
rRX = FRAMEIEE80211aRX(RATE+1);
lengthRX = FRAMEIEE80211aRX(RATE+R+1:RATE+R+LENGHT);
pRx = FRAMEIEE80211aRX(RATE+R+LENGHT+P);
tailRX = FRAMEIEE80211aRX(RATE+R+LENGHT+P+1:RATE+R+LENGHT+P+TAIL);
serviceRX = FRAMEIEE80211aRX(RATE+R+LENGHT+P+TAIL+1:RATE+R+LENGHT+P+TAIL+SERVICE);
dataRx = FRAMEIEE80211aRX(RATE+R+LENGHT+P+TAIL+SERVICE+1:RATE+R+LENGHT+P+TAIL+SERVICE+length(data));

%%BER
BER = biterr(FRAMEIEE80211aTX,FRAMEIEE80211aRX);
BERdata = biterr(data,dataRx);

%%
% convertir a char
a4 = dec2bin(dataRx);
u8RX = zeros (1,length(dataRx)/8);
for i = 1:length(dataRx)/8
     a5 = a4(1:8,1);
     u8RX(1,i) = bin2dec(a5');
     a4 = a4(9:length(a4));
end
u8RX = uint8(u8RX);
TextRx = char(u8RX);