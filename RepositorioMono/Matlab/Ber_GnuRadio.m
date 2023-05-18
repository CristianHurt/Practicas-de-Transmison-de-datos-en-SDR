%Ber
clc
clear
f = fopen('In.txt', 'rb');
values = fread(f, Inf,"uint8");
f2 = fopen('Out.txt', 'rb');
values2 = fread(f2, Inf,"uint8");
%%
clc
bits = 223; 
L = length(values2)-bits + 1
bitIn = values(1:bits);
Errors = zeros(L,1);
for i = 1:L
  bitOut = values2(i:bits+i-1);
  Errors(i) = biterr(bitIn,bitOut);
end

[error,I] = min(Errors)
ErrorP1 = error*100/bits;
[error2,I2] = max(Errors);
ErrorP2 = error2*100/bits;
bitsp = values2(I:I+bits-1);
errorP = biterr(bitIn,bitsp);

