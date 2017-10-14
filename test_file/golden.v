module   USBC(PCICLK,  RST_, DI, DO,   /* asdasdasdad
                                       asdasdasdasdasdasdasdasdasdasdsaasdasd,
              asdasdasdasdasd */ DO2); //#$%^1234ASDFascb

input  PCICLK,
       RST_;
input  [31:0] DI;
output [31:0] DO,DO2;

wire clk,a
,b;                          //aa
/*always @(posedge clk) begin             //  asdasdasd
  a <= b;                              //asdasdasd
end        */                            //asdasdasdasdasd!@#!@%$%#@v !!@#!@#1 
//asdasdasdasd
UTM3 utm3();
endmodule//abcd

module PORTSM_6 (BABOPT, PM_NORM, SOFGEN, CLK_12M, LSDEV, SDP, SDN, SUSACK, 
        RSE0, ENABLE, DISABLE, SUSPEND, PD, DIS, TXE, PM_SUS, CLRHCRST, 
        PORTACT, CONN, EOFBAB, ENPORT, SUSPORT, EOT, EOF2, RESM_DET, CONNCHG, 
        ENCHG, TRST_, PORTRST, PM_EN, CONSCHG, ATPG_ENI, CLK_12M_CTS_CLK_0, 
        CLK_12M_CTS_CLK_1, UCMDRST3_CTS_CLK);
input   BABOPT, PM_NORM, SOFGEN, CLK_12M, LSDEV, SDP, SDN;
output  SUSACK;
input   RSE0;
output  ENABLE, DISABLE, SUSPEND, PD, DIS;
input   TXE, PM_SUS, CLRHCRST;
output  PORTACT;
input   CONN;
output  EOFBAB;
input   ENPORT, SUSPORT, EOT, EOF2;
output  RESM_DET, CONNCHG, ENCHG;
input   TRST_, PORTRST, PM_EN, CONSCHG, ATPG_ENI, CLK_12M_CTS_CLK_0;
inout   CLK_12M_CTS_CLK_1, UCMDRST3_CTS_CLK;
    zmux21hb DNTATPGCLK1 ( .A(PKSTART_P), .B(CLK_12M), .S(ATPG_ENI), .Y(net61)
         );
    zmux21hb DNTATPGCLK2 ( .A(CONSCHG_CLK_P), .B(CLK_12M), .S(ATPG_ENI), .Y(
        CONSCHG_CLK) );
    zan3b DNTKTOK ( .A(K_T), .B(K_2T), .C(n_26), .Y(JTOK) );
    zan2b U127 ( .A(PM_NORM), .B(JTOK), .Y(PKSTART_P) );
    zxo2b U128 ( .A(n562), .B(SUSPEND), .Y(n570) );
    zxo2b U129 ( .A(CONN_T), .B(CONN_2T), .Y(CONSCHG_CLK_P) );
    zor2b U130 ( .A(SUSPEND), .B(n547), .Y(n578) );
    zan2b U131 ( .A(n565), .B(n557), .Y(n564) );
    zor2b U132 ( .A(n581), .B(n579), .Y(n582) );
    zivb U133 ( .A(n580), .Y(n581) );
    zor3b U134 ( .A(ENABLE), .B(PORTST_3), .C(n570), .Y(n580) );
    zor3b U135 ( .A(SUSPEND), .B(n544), .C(n547), .Y(n572) );
    zmux21lb U136 ( .A(n569), .B(n566), .S(SDN), .Y(n575) );
    zan2b U137 ( .A(SDP), .B(LSDEV), .Y(n569) );
    zan2b U138 ( .A(n567), .B(n568), .Y(n566) );
    zivb U139 ( .A(LSDEV), .Y(n567) );
    zivb U140 ( .A(SDP), .Y(n568) );
    zao21b U141 ( .A(ENABLE), .B(JTOK), .C(RESM_DET), .Y(n_125) );
    znr5b U142 ( .A(n555), .B(n556), .C(n557), .D(PORTRST), .E(n558), .Y(
        PORTSTNXT_2) );
    zivb U143 ( .A(n565), .Y(n555) );
    zoai21b U144 ( .A(n572), .B(n573), .C(n580), .Y(n565) );
    zivb U145 ( .A(ENPORT), .Y(n557) );
    zao21b U146 ( .A(PORTST_3), .B(DISABLE), .C(n558), .Y(n559) );
    zxo2b U147 ( .A(n544), .B(n578), .Y(n560) );
    znd2b U148 ( .A(K_T), .B(PM_NORM), .Y(n550) );
    zoai21b U149 ( .A(n544), .B(n545), .C(n546), .Y(ENCHG_T367) );
    zoa22b U150 ( .A(n576), .B(n577), .C(PORTST_3), .D(CONN), .Y(n546) );
    zan3b U151 ( .A(CONN_T), .B(n553), .C(n554), .Y(PORTSTNXT_1) );
    zivb U152 ( .A(PORTRST), .Y(n553) );
    zao32b U153 ( .A(n582), .B(n556), .C(ENPORT), .D(n579), .E(n573), .Y(n554)
         );
    zivb U154 ( .A(SUSPORT), .Y(n556) );
    zivb U155 ( .A(n572), .Y(n579) );
    zivb U156 ( .A(EOT), .Y(n573) );
    zan2b U157 ( .A(n552), .B(CONN_T), .Y(PORTSTNXT_0) );
    zivb U158 ( .A(n549), .Y(K) );
    zor3b U159 ( .A(TXE), .B(n574), .C(n575), .Y(n549) );
    zor2b U160 ( .A(n551), .B(CLRHCRST), .Y(ENCHG) );
    zivb U161 ( .A(JTOK), .Y(n571) );
    zivb U162 ( .A(n545), .Y(EOFBAB) );
    zor3b U163 ( .A(BABOPT), .B(PKEND), .C(n576), .Y(n545) );
    zivb U164 ( .A(EOF2), .Y(n576) );
    zan3b U165 ( .A(n547), .B(n548), .C(PM_EN), .Y(DIS) );
    zor2b U166 ( .A(DISABLE), .B(PORTST_3), .Y(n547) );
    zoa211b U167 ( .A(PM_SUS), .B(SUSPEND), .C(PM_EN), .D(n548), .Y(PD) );
    zivb U168 ( .A(TXE), .Y(n548) );
    zan2b U169 ( .A(SUSPORT), .B(n544), .Y(SUSACK) );
    zdffrb K_3T_reg ( .CK(CLK_12M_CTS_CLK_0), .D(n585), .R(TRST_), .QN(n_26)
         );
    zdffqrb CONN_T_reg ( .CK(CLK_12M_CTS_CLK_0), .D(CONN), .R(TRST_), .Q(
        CONN_T) );
    zivb U170 ( .A(CONN_T), .Y(n558) );
    zdffqrb K_2T_reg ( .CK(CLK_12M_CTS_CLK_0), .D(n584), .R(TRST_), .Q(K_2T)
         );
    zdffqrb PORTST_reg_2 ( .CK(CLK_12M_CTS_CLK_0), .D(PORTSTNXT_2), .R(TRST_)
        , .Q(SUSPEND) );
    zivb U171 ( .A(SUSPEND), .Y(n563) );
    zdffqrb ENCHG_2T_reg ( .CK(CLK_12M_CTS_CLK_0), .D(n583), .R(TRST_), .Q(
        ENCHG_2T) );
    zdffqsb PORTST_reg_3 ( .CK(CLK_12M_CTS_CLK_0), .D(PORTSTNXT_3), .S(TRST_)
        , .Q(PORTST_3) );
    zdffqsb PKEND_reg ( .CK(CLK_12M_CTS_CLK_0), .D(PKEND322), .S(RSTPKEND), 
        .Q(PKEND) );
    zdffqrb ENCHG_T_reg ( .CK(CLK_12M_CTS_CLK_0), .D(ENCHG_T367), .R(TRST_), 
        .Q(ENCHG_T) );
    zivb U172 ( .A(ENCHG_T), .Y(n577) );
    zdffqrb PORTST_reg_1 ( .CK(CLK_12M_CTS_CLK_0), .D(PORTSTNXT_1), .R(TRST_)
        , .Q(ENABLE) );
    zivb U173 ( .A(ENABLE), .Y(n544) );
    zdffrb PORTST_reg_0 ( .CK(CLK_12M_CTS_CLK_1), .D(PORTSTNXT_0), .R(TRST_), 
        .QN(n562), .Q(DISABLE) );
    zdffrb CONN_2T_reg ( .CK(CLK_12M_CTS_CLK_1), .D(b2b0), .R(UCMDRST3_CTS_CLK
        ), .QN(n574), .Q(CONN_2T) );
    zdffqrb K_T_reg ( .CK(CLK_12M_CTS_CLK_1), .D(K), .R(UCMDRST3_CTS_CLK), .Q(
        K_T) );
    znr2b U174 ( .A(n571), .B(n563), .Y(RESM_DET) );
    zor2d U175 ( .A(n541), .B(ATPG_ENI), .Y(n543) );
    zinr2d U176 ( .A(UCMDRST3_CTS_CLK), .B(CONSCHG), .Y(n541) );
    zdffrb CONSCHG_STS_reg ( .CK(CONSCHG_CLK), .D(1'b1), .R(n543), .Q(
        CONSCHG_STS) );
    zoa21d U178 ( .A(n549), .B(n550), .C(PKEND), .Y(PKEND322) );
    zao211b U179 ( .A(SUSPEND), .B(n547), .C(n559), .D(n560), .Y(PORTSTNXT_3)
         );
    zan4b U180 ( .A(PORTST_3), .B(n562), .C(n563), .D(n544), .Y(n561) );
    zinr2d U181 ( .A(ENCHG_T), .B(ENCHG_2T), .Y(n551) );
    zao211b U182 ( .A(PORTRST), .B(n582), .C(n561), .D(n564), .Y(n552) );
    zor2d S_5 ( .A(n_29), .B(SOFGEN), .Y(n_30) );
    zivh S_3 ( .A(UCMDRST3_CTS_CLK), .Y(n_28) );
    zor2d S_4 ( .A(n_28), .B(RSE0), .Y(n_29) );
    zor2d S_41 ( .A(CONSCHG_STS), .B(CONSCHG_CLK), .Y(n_122) );
    zivh S_6 ( .A(n_30), .Y(n_31) );
    zor2d S_45 ( .A(n_125), .B(CONNCHG), .Y(PORTACT) );
    zor2d S_7 ( .A(n_31), .B(ATPG_ENI), .Y(RSTPKEND) );
    zor2d S_42 ( .A(n_122), .B(CLRHCRST), .Y(CONNCHG) );
    zbfb U183 ( .A(ENCHG_T), .Y(n583) );
    zbfb U184 ( .A(K_T), .Y(n584) );
    zbfb U185 ( .A(K_2T), .Y(n585) );
    zdl1b B2B0 ( .A(CONN_T), .Y(b2b0) );
endmodule

module UTM2 (PP1,PP2,PP3,PP4,/* ,PP5 ;
              PP6 */ PP7, /*PP8,*/ PP9, /*PP10
              */PP11); 
input PP1,PP2
      ,PP3,
      PP4;
output PP7,
       PP9,PP11;
/*reg clk,a,b;     
always@(posedge clk) begin 
  a <= b;
end// asdasd*/
PORTSM_6 p6();
endmodule

module port_ctl ( CLK12M, RST_, RXC,RXD   //$$$
                 /*SDP,*/ ,SDN, ENABLE, HALT);  //!@#$%12

input CLK12M
      ,RST_ , RXC, RXD, SDN, ENABLE;
output HALT;
endmodule

/* sdfsadf */ module UTM;              //asdasdasdasd
//reg clk,a,b;                           // asd
//always@(posedge clk) begin 
//  a <= b;
//end                                    // asdasd
endmodule

/* 
module mark ( CLK12M); //asdasdasdasd
reg clk,a,b;     // asd
always@(posedge clk) begin 
  a <= b;
end// asdasd
endmodule
*/

//module UTM (/*CLK12M*/,CLK11M); //asdasdasdasd
module 
UTM3 
(CLK12M,CLK11M); //asdasdasdasd
input CLK11M;
input CLK12M;
usb usb1 (.A(),
.B(PIN2));
usb usb2 (.A(1'b0)    ,.B());
usb usb3 (.A(1'b1)    ,.B(PIN5));
usb usb4 (.A(PIN3),.B(PIN8));
UTM utm (.A(PIN3),.B(PIN8));
UTM2 utm2 (.A(PIN3),.B(PIN8));
endmodule

/* */ /*asdas
da*/ 
/* */ /*
*/

//module 
//mark ( CLK12M);
//endmodule


