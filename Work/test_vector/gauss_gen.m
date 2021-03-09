N = 3000;
a = normrnd(200,1000,1,750);
b = normrnd(5000,100,1,250);
a = round(a);
b = round(b);
c = [a b];

subplot(2,2,1);
    histfit(a);
    title('a');
subplot(2,2,2);
    histfit(b);
    title('b');
subplot(2,2,[3,4]);
    histfit(c);
    title('c');