外部`start`信号，其脉宽、频率为多少；对应于两个TDC来说，应当同时开始计数，锁存的`start phase`也应当相同；

`trigger`有`固定10ns的dead time`，长度10ns？？？还是说加上sync拉低的时间？，每个TDC会至多记录五个`tof data`；

两个TDC记录的`trigger`数目是否一致；是否会出现TDC1记录了5个而TDC2记录了3个的情况；如果出现该情况，则输出TDC1和TDC2的前三个记录的数据，舍弃TDC1记录的后两个数据，保证输出是成对的；
后续的计算单元分为两个独立计算，或者合并10个数据计算；
TDC计满后分别进行后续处理，处理后启动状态机，当两个TDC的`valid`分别拉高时，主控单元分别从两个TDC中get数据，存入core内部；
当user通过`spi`发送读取命令后，主控单元通过`spi`分别从内部存储发送数据；发送次序为TDC1和TDC2的第1组数据、TDC1和TDC2的第2组数据...
根据user配置的输出数据的数目，主控单元每次通过`spi`发送出一个数据后，待发送的`num`减一，输出的24bit数据:`19bit tof + 5bit tag`
其中`5bit tag的最高位`表示接下来是否还有数据没有发送出来，如果该位为1，则需要user继续发送读数据命令，否则表示已经读完.
使用`sync`作为采样stop latch的时钟，保证采样时stop latch稳定，且只会采样一次；如果`start`脉冲时间足够，则`start latch`也可采用此方案.`cnt_en`作为`start`的`sync`信号

start sync 方案：clk5 和clk5_i，两路（rise和fall）采到`start为1并且屏蔽信号为低`时，两路（rise和fall）一直拉高，sync根据latch—module输出的最低位（s）选择产生（`mux的延迟很大`？？？，可以在mux后加一级reg），计数器根据sync（cnt_en）为高开始计数；当计数器（clk5）计到量程（不用非得3000km，只判断高几位即可）后，overflow拉高，两路rise和fall拉低（从而使cnt_en拉低）；若start足够长（4ns以上），可用sync上升沿采样latch，或者仍在clk5时钟下，根据逻辑来采样latch（`更优`）

stop sync 方案： clk5 和clk5_i,两路（rise和fall）采到`stop为1并且屏蔽信号为低`时，两路（rise和fall）拉高，sync根据latch—module输出的最低位（s）选择产生（`mux的延迟很大`？？？，可以在mux后加一级reg），加一级`sync_d`（clk5），当`sync & !sync_d == 1`,触发此时的计数器保存粗计数值；同时触发reg保存latch中锁存的数据;同时`num`加一；当`!sync & sync_d == 1`,触发所有数据保存到buffer中？

当stop0、1拉高，同时产生屏蔽信号，计数器加一，当计数器到3时，复位，屏蔽信号撤销；

时钟buffer问题

`5-200ns 的 trigger pulse`,对sync进行若干级的delay,当trigger上升沿时刻，sync_d仍为高电平，则此次trigger屏蔽

DLL PHASE延迟500ps锁存

两个stop路径，各自采一个counter，trigger下降沿处判断并存储；

多周期路径，下降沿到上升沿的路径需要加buffer延迟（最好情况和最坏情况下加的buffer延迟多大区别？？），ck-q的时间＋mux+延迟+setup time < 3ns 

上升沿和下降沿到start0和start1的两条路径都需要加延迟，stop0和stop1同样；

向后进位的计数器结构？需要手动替换逻辑门的顺序？

sync_d做多周期，延迟一周期，然后用他的上升沿采粗计数器？

上电后，25M晶振时钟工作，同时定时器打开，搬运efuse给模拟，PLL工作一段时间后，启动无毛刺切换电路；

计数器等TDC_Olast清零，或者直接外部清零

两个TDC与core之间的通信顺序