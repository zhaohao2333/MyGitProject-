N = 100;
%n = randi([1500 1600],1,100);
a = normrnd(20000,100,1,100);
b = normrnd(10000,100,1,100);
a1 = round(a+b);
n1 = randi([2 5],1,100);
n2 = randi([2 6],1,100);
%-----------------------------------------------
    delay_data1 = 0.0625 * a1;
    delay_data2 = delay_data1 + 11 + n1;
    delay_data3 = delay_data2 + 11 + n2;
    delay_1 = [delay_data1;
               delay_data2;
               delay_data3];
    %delay_2 = rot90(delay_1);
    delay_3 = reshape(delay_1,1,300);
    delay_4 = delay_3/0.0625;
    data_bin = dec2bin(delay_4,15);
    data_bin1 = cellstr(data_bin);
    data_bin2 = reshape(data_bin1,1,300);
    %databin = str2num(data_bin);
    writecell(data_bin2,'D:\Workplace\Work\test_vector\vector\5\vector_delay.txt','Delimiter',' ');
%----------------------------------------------    
%     fid = fopen('C:\Users\zhaohao\Desktop\copy\TDC_spad\RTL\vector_1.txt','w');
%     fprintf(fid,'%g\t',data_bin);
%     fclose(fid);
    int_data = randi([1 65535],1,300);
    int_bin = dec2bin(int_data,16);
    int_bin1 = cellstr(int_bin);
    int_bin2 = reshape(int_bin1,1,300);
    %databin = str2num(data_bin);
    writecell(int_bin2,'D:\Workplace\Work\test_vector\vector\5\vector_int.txt','Delimiter',' ');
    
    int_out = zeros(1,300);
%     int_out = cell2mat(int_bin2);
%     sum(b-'0')
    for i = 1:300
        s=int_data(1,i);
        int_bin1=dec2bin(s,16);
        int_out(1,i) = sum(int_bin1-'0') - 1;
    end
    
    int_out_d = dec2bin(int_out,4);
    int_out_d1 = cellstr(int_out_d);
    int_out_d2 = reshape(int_out_d1,1,300);
    %databin = str2num(data_bin);
    writecell(int_out_d2,'D:\Workplace\Work\test_vector\vector\5\vector_int_b.txt','Delimiter',' ');
%     fid = fopen('C:\Users\zhaohao\Desktop\copy\TDC_spad\RTL\vector_int_d.txt','w');
%     fprintf(fid,'%g\t',int_out);
%     fclose(fid);
    