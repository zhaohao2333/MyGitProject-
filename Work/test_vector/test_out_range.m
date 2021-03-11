    N = 1000;
    a = normrnd(20000,100,1,N);   
    %b = normrnd(10000,100,1,N);
    a1 = round(a);
    n1 = randi([2 5],1,N);
    n2 = randi([2 6],1,N);
%-------------------设定range--------------------
    range = 10000;
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
    input_delay1 = reshape(input_delay, 1, 3 * N);
    input_delay2 = input_delay1/0.0625;
    input_bin = dec2bin(input_delay2, 15);
    input_bin1 = cellstr(input_bin); %竖排
    %input_bin2 = reshape(input_bin1, 1, 3 * N); %转换为横排格式
    %writecell(input_bin2,'D:\Workplace\Work\test_vector\vector\test\vector_delay.txt','Delimiter',' ');
    writecell(input_bin1,'D:\Workplace\Work\test_vector\vector\range\vector_delay_v3.txt','Delimiter',' ');
%-----------------------------------------------
    x1 = find(delay_data1 >= range * 0.0625);
    delay_data1(x1) = 32767 * 0.0625; 
    x2 = find(delay_data2 >= range * 0.0625);
    delay_data2(x2) = 0;
    x3 = find(delay_data3 >= range * 0.0625);
    delay_data3(x3) = 0;
%--------------产生输出tof vector------------------ 
    delay_1 = [delay_data1;
               delay_data2;
               delay_data3];
    delay_3 = reshape(delay_1, 1, 3 * N);
    delay_4 = delay_3/0.0625;
    del_out_range = delay_4;
    del_out_range(del_out_range == 0) = [ ];
    data_bin = dec2bin(del_out_range,15);
    data_bin1 = cellstr(data_bin);
    %data_bin2 = reshape(data_bin1,1,[ ]);
    %writecell(data_bin2,'D:\Workplace\Work\test_vector\vector\test\vector_tof.txt','Delimiter',' ');
    writecell(data_bin1,'D:\Workplace\Work\test_vector\vector\range\vector_tof_v3.txt','Delimiter',' ');
    %----------------------------------------------    
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