    N = 1000;
    %n = randi([1500 1600],1,1000);
    a = normrnd(20000,100,1,1000);   
    %b = normrnd(10000,100,1,1000);
    a1 = round(a);
    a2 = round(a);
    n1 = randi([2 5],1,1000);
    n2 = randi([2 6],1,1000);
%-----------------------------------------------
    % a1(a1>=20100) = [ ];
%-------------------设定range--------------------
    range = 20100;
%-----------------------------------------------
    delay_data1 = 0.0625 * a1;
    delay_data2 = delay_data1 + 11 + n1;
    delay_data3 = delay_data2 + 11 + n2;
%---------------产生输入delay vector--------------
    data1 = delay_data1;
    data2 = delay_data2;
    data3 = delay_data3;
    input_delay = [data1;
               data2;
               data3];
    input_delay1 = reshape(input_delay,1,3000);
    input_delay2 = input_delay1/0.0625;
    input_bin = dec2bin(input_delay2,15);
    input_bin1 = cellstr(input_bin);
    input_bin2 = reshape(input_bin1,1,3000);
    %databin = str2num(data_bin);
    %writecell(input_bin2,'D:\Workplace\Work\test_vector\vector\test\vector_delay.txt','Delimiter',' ');
    writecell(input_bin2,'.\vector_delay.txt','Delimiter',' ');
%-----------------------------------------------
    x1 = find(delay_data1 >= 20100 * 0.0625);
    delay_data1(x1) = 32767 * 0.0625; % 32767 = 15'b11111_11111_11111
    x2 = find(delay_data2 >= 20100 * 0.0625);
    delay_data2(x2) = 0;
    x3 = find(delay_data3 >= 20100 * 0.0625);
    delay_data3(x3) = 0;
%--------------产生输出tof vector------------------ 
    delay_1 = [delay_data1;
               delay_data2;
               delay_data3];
    %delay_2 = rot90(delay_1);
    delay_3 = reshape(delay_1,1,300);
    delay_4 = delay_3/0.0625;
    del_out_range = delay_4;
    del_out_range(del_out_range == 0) = [ ];
    data_bin = dec2bin(del_out_range,15);
    data_bin1 = cellstr(data_bin);
    data_bin2 = reshape(data_bin1,1,[ ]);
    %databin = str2num(data_bin);
    %writecell(data_bin2,'D:\Workplace\Work\test_vector\vector\test\vector_tof.txt','Delimiter',' ');
    writecell(data_bin2,'.\vector_tof.txt','Delimiter',' ');
    %----------------------------------------------    
% %----------------------------------------------    
% %     fid = fopen('C:\Users\zhaohao\Desktop\copy\TDC_spad\RTL\vector_1.txt','w');
% %     fprintf(fid,'%g\t',data_bin);
% %     fclose(fid);
%     int_data = randi([1 65535],1,300);
%     int_bin = dec2bin(int_data,16);
%     int_bin1 = cellstr(int_bin);
%     int_bin2 = reshape(int_bin1,1,300);
%     %databin = str2num(data_bin);
%     writecell(int_bin2,'D:\Workplace\Work\test_vector\vector\test\vector_int.txt','Delimiter',' ');
%     
%     int_out = zeros(1,300);
% %     int_out = cell2mat(int_bin2);
% %     sum(b-'0')
%     for i = 1:300
%         s=int_data(1,i);
%         int_bin1=dec2bin(s,16);
%         int_out(1,i) = sum(int_bin1-'0') - 1;
%     end
%     
%     int_out_d = dec2bin(int_out,4);
%     int_out_d1 = cellstr(int_out_d);
%     int_out_d2 = reshape(int_out_d1,1,300);
%     %databin = str2num(data_bin);
%     writecell(int_out_d2,'D:\Workplace\Work\test_vector\vector\test\vector_int_b.txt','Delimiter',' ');
% %     fid = fopen('C:\Users\zhaohao\Desktop\copy\TDC_spad\RTL\vector_int_d.txt','w');
% %     fprintf(fid,'%g\t',int_out);
% %     fclose(fid);