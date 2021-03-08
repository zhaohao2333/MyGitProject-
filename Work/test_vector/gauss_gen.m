a = normrnd(1000,20,1,100);
a1 = round(a);
b = normrnd(1000,50,1,100);
b1 = round(b);
c = normrnd(1000,100,1,100);
figure();
histfit(a1);
histfit(b1);