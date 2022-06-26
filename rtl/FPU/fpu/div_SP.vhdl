--------------------------------------------------------------------------------
--                       SelFunctionTable_r4_comb_uid4
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Maxime Christ, Florent de Dinechin (2015)
--------------------------------------------------------------------------------
library ieee; 
use ieee.std_logic_1164.all;
library work;
entity SelFunctionTable_r4_comb_uid4 is
   port ( X : in  std_logic_vector(4 downto 0);
          Y : out  std_logic_vector(2 downto 0)   );
end entity;

architecture arch of SelFunctionTable_r4_comb_uid4 is
signal TableOut :  std_logic_vector(2 downto 0);
begin
  with X select TableOut <= 
   "000" when "00000",
   "000" when "00001",
   "001" when "00010",
   "001" when "00011",
   "010" when "00100",
   "001" when "00101",
   "011" when "00110",
   "010" when "00111",
   "011" when "01000",
   "011" when "01001",
   "011" when "01010",
   "011" when "01011",
   "011" when "01100",
   "011" when "01101",
   "011" when "01110",
   "011" when "01111",
   "101" when "10000",
   "101" when "10001",
   "101" when "10010",
   "101" when "10011",
   "101" when "10100",
   "101" when "10101",
   "101" when "10110",
   "101" when "10111",
   "101" when "11000",
   "110" when "11001",
   "110" when "11010",
   "110" when "11011",
   "111" when "11100",
   "111" when "11101",
   "111" when "11110",
   "111" when "11111",
   "---" when others;
    Y <= TableOut;
end architecture;

--------------------------------------------------------------------------------
--                            FPDiv_8_23_comb_uid2
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: Maxime Christ, Florent de Dinechin (2015)
--------------------------------------------------------------------------------
-- combinatorial

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FPDiv_8_23_comb_uid2 is
   port ( X : in  std_logic_vector(8+23+2 downto 0);
          Y : in  std_logic_vector(8+23+2 downto 0);
          RM : in std_logic_vector(2 downto 0);
          R : out  std_logic_vector(8+23+2 downto 0);
          INEXACT : out  std_logic   );
end entity;

architecture arch of FPDiv_8_23_comb_uid2 is
   component SelFunctionTable_r4_comb_uid4 is
      port ( X : in  std_logic_vector(4 downto 0);
             Y : out  std_logic_vector(2 downto 0)   );
   end component;
   
   component Rounding_Mode_SP is
    port (
          EXP_FRAC : in std_logic_vector(32 downto 0);
          Rounding_Mode : in std_logic_vector(2 downto 0);
          Guard_Bits : in std_logic_vector(2 downto 0);
          Sign : in  std_logic;
          OUT_EXP_FRAC : out  std_logic_vector(32 downto 0);
          INEXACT : out  std_logic
          );
  end component;
signal Guard_Bits :  std_logic_vector(2 downto 0);  

signal fX :  std_logic_vector(23 downto 0);
signal fY :  std_logic_vector(23 downto 0);
signal expR0 :  std_logic_vector(9 downto 0);
signal sR :  std_logic;
signal exnXY :  std_logic_vector(3 downto 0);
signal exnR0 :  std_logic_vector(1 downto 0);
signal fYTimes3 :  std_logic_vector(25 downto 0);
signal w13 :  std_logic_vector(25 downto 0);
signal sel13 :  std_logic_vector(4 downto 0);
signal q13 :  std_logic_vector(2 downto 0);
signal q13D :  std_logic_vector(26 downto 0);
signal w13pad :  std_logic_vector(26 downto 0);
signal w12full :  std_logic_vector(26 downto 0);
signal w12 :  std_logic_vector(25 downto 0);
signal sel12 :  std_logic_vector(4 downto 0);
signal q12 :  std_logic_vector(2 downto 0);
signal q12D :  std_logic_vector(26 downto 0);
signal w12pad :  std_logic_vector(26 downto 0);
signal w11full :  std_logic_vector(26 downto 0);
signal w11 :  std_logic_vector(25 downto 0);
signal sel11 :  std_logic_vector(4 downto 0);
signal q11 :  std_logic_vector(2 downto 0);
signal q11D :  std_logic_vector(26 downto 0);
signal w11pad :  std_logic_vector(26 downto 0);
signal w10full :  std_logic_vector(26 downto 0);
signal w10 :  std_logic_vector(25 downto 0);
signal sel10 :  std_logic_vector(4 downto 0);
signal q10 :  std_logic_vector(2 downto 0);
signal q10D :  std_logic_vector(26 downto 0);
signal w10pad :  std_logic_vector(26 downto 0);
signal w9full :  std_logic_vector(26 downto 0);
signal w9 :  std_logic_vector(25 downto 0);
signal sel9 :  std_logic_vector(4 downto 0);
signal q9 :  std_logic_vector(2 downto 0);
signal q9D :  std_logic_vector(26 downto 0);
signal w9pad :  std_logic_vector(26 downto 0);
signal w8full :  std_logic_vector(26 downto 0);
signal w8 :  std_logic_vector(25 downto 0);
signal sel8 :  std_logic_vector(4 downto 0);
signal q8 :  std_logic_vector(2 downto 0);
signal q8D :  std_logic_vector(26 downto 0);
signal w8pad :  std_logic_vector(26 downto 0);
signal w7full :  std_logic_vector(26 downto 0);
signal w7 :  std_logic_vector(25 downto 0);
signal sel7 :  std_logic_vector(4 downto 0);
signal q7 :  std_logic_vector(2 downto 0);
signal q7D :  std_logic_vector(26 downto 0);
signal w7pad :  std_logic_vector(26 downto 0);
signal w6full :  std_logic_vector(26 downto 0);
signal w6 :  std_logic_vector(25 downto 0);
signal sel6 :  std_logic_vector(4 downto 0);
signal q6 :  std_logic_vector(2 downto 0);
signal q6D :  std_logic_vector(26 downto 0);
signal w6pad :  std_logic_vector(26 downto 0);
signal w5full :  std_logic_vector(26 downto 0);
signal w5 :  std_logic_vector(25 downto 0);
signal sel5 :  std_logic_vector(4 downto 0);
signal q5 :  std_logic_vector(2 downto 0);
signal q5D :  std_logic_vector(26 downto 0);
signal w5pad :  std_logic_vector(26 downto 0);
signal w4full :  std_logic_vector(26 downto 0);
signal w4 :  std_logic_vector(25 downto 0);
signal sel4 :  std_logic_vector(4 downto 0);
signal q4 :  std_logic_vector(2 downto 0);
signal q4D :  std_logic_vector(26 downto 0);
signal w4pad :  std_logic_vector(26 downto 0);
signal w3full :  std_logic_vector(26 downto 0);
signal w3 :  std_logic_vector(25 downto 0);
signal sel3 :  std_logic_vector(4 downto 0);
signal q3 :  std_logic_vector(2 downto 0);
signal q3D :  std_logic_vector(26 downto 0);
signal w3pad :  std_logic_vector(26 downto 0);
signal w2full :  std_logic_vector(26 downto 0);
signal w2 :  std_logic_vector(25 downto 0);
signal sel2 :  std_logic_vector(4 downto 0);
signal q2 :  std_logic_vector(2 downto 0);
signal q2D :  std_logic_vector(26 downto 0);
signal w2pad :  std_logic_vector(26 downto 0);
signal w1full :  std_logic_vector(26 downto 0);
signal w1 :  std_logic_vector(25 downto 0);
signal sel1 :  std_logic_vector(4 downto 0);
signal q1 :  std_logic_vector(2 downto 0);
signal q1D :  std_logic_vector(26 downto 0);
signal w1pad :  std_logic_vector(26 downto 0);
signal w0full :  std_logic_vector(26 downto 0);
signal w0 :  std_logic_vector(25 downto 0);
signal q0 :  std_logic_vector(2 downto 0);
signal qP13 :  std_logic_vector(1 downto 0);
signal qM13 :  std_logic_vector(1 downto 0);
signal qP12 :  std_logic_vector(1 downto 0);
signal qM12 :  std_logic_vector(1 downto 0);
signal qP11 :  std_logic_vector(1 downto 0);
signal qM11 :  std_logic_vector(1 downto 0);
signal qP10 :  std_logic_vector(1 downto 0);
signal qM10 :  std_logic_vector(1 downto 0);
signal qP9 :  std_logic_vector(1 downto 0);
signal qM9 :  std_logic_vector(1 downto 0);
signal qP8 :  std_logic_vector(1 downto 0);
signal qM8 :  std_logic_vector(1 downto 0);
signal qP7 :  std_logic_vector(1 downto 0);
signal qM7 :  std_logic_vector(1 downto 0);
signal qP6 :  std_logic_vector(1 downto 0);
signal qM6 :  std_logic_vector(1 downto 0);
signal qP5 :  std_logic_vector(1 downto 0);
signal qM5 :  std_logic_vector(1 downto 0);
signal qP4 :  std_logic_vector(1 downto 0);
signal qM4 :  std_logic_vector(1 downto 0);
signal qP3 :  std_logic_vector(1 downto 0);
signal qM3 :  std_logic_vector(1 downto 0);
signal qP2 :  std_logic_vector(1 downto 0);
signal qM2 :  std_logic_vector(1 downto 0);
signal qP1 :  std_logic_vector(1 downto 0);
signal qM1 :  std_logic_vector(1 downto 0);
signal qP0 :  std_logic_vector(1 downto 0);
signal qM0 :  std_logic_vector(1 downto 0);
signal qP :  std_logic_vector(27 downto 0);
signal qM :  std_logic_vector(27 downto 0);
signal fR0 :  std_logic_vector(27 downto 0);
signal fR :  std_logic_vector(26 downto 0);
signal fRn1 :  std_logic_vector(24 downto 0);
signal expR1 :  std_logic_vector(9 downto 0);
signal round :  std_logic;
signal expfrac :  std_logic_vector(32 downto 0);
signal expfracR :  std_logic_vector(32 downto 0);
signal exnR :  std_logic_vector(1 downto 0);
signal exnRfinal :  std_logic_vector(1 downto 0);
begin
   fX <= "1" & X(22 downto 0);
   fY <= "1" & Y(22 downto 0);
   -- exponent difference, sign and exception combination computed early, to have less bits to pipeline
   expR0 <= ("00" & X(30 downto 23)) - ("00" & Y(30 downto 23));
   sR <= X(31) xor Y(31);
   -- early exception handling 
   exnXY <= X(33 downto 32) & Y(33 downto 32);
   with exnXY select
      exnR0 <= 
         "01"  when "0101",                   -- normal
         "00"  when "0001" | "0010" | "0110", -- zero
         "10"  when "0100" | "1000" | "1001", -- overflow
         "11"  when others;                   -- NaN
    -- compute 3Y
   fYTimes3 <= ("00" & fY) + ("0" & fY & "0");
   w13 <=  "00" & fX;
   sel13 <= w13(25 downto 22) & fY(22);
   SelFunctionTable13: SelFunctionTable_r4_comb_uid4
      port map ( X => sel13,
                 Y => q13);

   with q13 select
      q13D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (26 downto 0 => '0')  when others;

   w13pad <= w13 & "0";
   with q13(2) select
   w12full<= w13pad - q13D when '0',
         w13pad + q13D when others;

   w12 <= w12full(24 downto 0) & "0";
   sel12 <= w12(25 downto 22) & fY(22);
   SelFunctionTable12: SelFunctionTable_r4_comb_uid4
      port map ( X => sel12,
                 Y => q12);

   with q12 select
      q12D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (26 downto 0 => '0')  when others;

   w12pad <= w12 & "0";
   with q12(2) select
   w11full<= w12pad - q12D when '0',
         w12pad + q12D when others;

   w11 <= w11full(24 downto 0) & "0";
   sel11 <= w11(25 downto 22) & fY(22);
   SelFunctionTable11: SelFunctionTable_r4_comb_uid4
      port map ( X => sel11,
                 Y => q11);

   with q11 select
      q11D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (26 downto 0 => '0')  when others;

   w11pad <= w11 & "0";
   with q11(2) select
   w10full<= w11pad - q11D when '0',
         w11pad + q11D when others;

   w10 <= w10full(24 downto 0) & "0";
   sel10 <= w10(25 downto 22) & fY(22);
   SelFunctionTable10: SelFunctionTable_r4_comb_uid4
      port map ( X => sel10,
                 Y => q10);

   with q10 select
      q10D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (26 downto 0 => '0')  when others;

   w10pad <= w10 & "0";
   with q10(2) select
   w9full<= w10pad - q10D when '0',
         w10pad + q10D when others;

   w9 <= w9full(24 downto 0) & "0";
   sel9 <= w9(25 downto 22) & fY(22);
   SelFunctionTable9: SelFunctionTable_r4_comb_uid4
      port map ( X => sel9,
                 Y => q9);

   with q9 select
      q9D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (26 downto 0 => '0')  when others;

   w9pad <= w9 & "0";
   with q9(2) select
   w8full<= w9pad - q9D when '0',
         w9pad + q9D when others;

   w8 <= w8full(24 downto 0) & "0";
   sel8 <= w8(25 downto 22) & fY(22);
   SelFunctionTable8: SelFunctionTable_r4_comb_uid4
      port map ( X => sel8,
                 Y => q8);

   with q8 select
      q8D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (26 downto 0 => '0')  when others;

   w8pad <= w8 & "0";
   with q8(2) select
   w7full<= w8pad - q8D when '0',
         w8pad + q8D when others;

   w7 <= w7full(24 downto 0) & "0";
   sel7 <= w7(25 downto 22) & fY(22);
   SelFunctionTable7: SelFunctionTable_r4_comb_uid4
      port map ( X => sel7,
                 Y => q7);

   with q7 select
      q7D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (26 downto 0 => '0')  when others;

   w7pad <= w7 & "0";
   with q7(2) select
   w6full<= w7pad - q7D when '0',
         w7pad + q7D when others;

   w6 <= w6full(24 downto 0) & "0";
   sel6 <= w6(25 downto 22) & fY(22);
   SelFunctionTable6: SelFunctionTable_r4_comb_uid4
      port map ( X => sel6,
                 Y => q6);

   with q6 select
      q6D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (26 downto 0 => '0')  when others;

   w6pad <= w6 & "0";
   with q6(2) select
   w5full<= w6pad - q6D when '0',
         w6pad + q6D when others;

   w5 <= w5full(24 downto 0) & "0";
   sel5 <= w5(25 downto 22) & fY(22);
   SelFunctionTable5: SelFunctionTable_r4_comb_uid4
      port map ( X => sel5,
                 Y => q5);

   with q5 select
      q5D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (26 downto 0 => '0')  when others;

   w5pad <= w5 & "0";
   with q5(2) select
   w4full<= w5pad - q5D when '0',
         w5pad + q5D when others;

   w4 <= w4full(24 downto 0) & "0";
   sel4 <= w4(25 downto 22) & fY(22);
   SelFunctionTable4: SelFunctionTable_r4_comb_uid4
      port map ( X => sel4,
                 Y => q4);

   with q4 select
      q4D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (26 downto 0 => '0')  when others;

   w4pad <= w4 & "0";
   with q4(2) select
   w3full<= w4pad - q4D when '0',
         w4pad + q4D when others;

   w3 <= w3full(24 downto 0) & "0";
   sel3 <= w3(25 downto 22) & fY(22);
   SelFunctionTable3: SelFunctionTable_r4_comb_uid4
      port map ( X => sel3,
                 Y => q3);

   with q3 select
      q3D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (26 downto 0 => '0')  when others;

   w3pad <= w3 & "0";
   with q3(2) select
   w2full<= w3pad - q3D when '0',
         w3pad + q3D when others;

   w2 <= w2full(24 downto 0) & "0";
   sel2 <= w2(25 downto 22) & fY(22);
   SelFunctionTable2: SelFunctionTable_r4_comb_uid4
      port map ( X => sel2,
                 Y => q2);

   with q2 select
      q2D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (26 downto 0 => '0')  when others;

   w2pad <= w2 & "0";
   with q2(2) select
   w1full<= w2pad - q2D when '0',
         w2pad + q2D when others;

   w1 <= w1full(24 downto 0) & "0";
   sel1 <= w1(25 downto 22) & fY(22);
   SelFunctionTable1: SelFunctionTable_r4_comb_uid4
      port map ( X => sel1,
                 Y => q1);

   with q1 select
      q1D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (26 downto 0 => '0')  when others;

   w1pad <= w1 & "0";
   with q1(2) select
   w0full<= w1pad - q1D when '0',
         w1pad + q1D when others;

   w0 <= w0full(24 downto 0) & "0";
   q0(2 downto 0) <= "000" when  w0 = (25 downto 0 => '0')
                else w0(25) & "10";
   qP13 <=      q13(1 downto 0);
   qM13 <=      q13(2) & "0";
   qP12 <=      q12(1 downto 0);
   qM12 <=      q12(2) & "0";
   qP11 <=      q11(1 downto 0);
   qM11 <=      q11(2) & "0";
   qP10 <=      q10(1 downto 0);
   qM10 <=      q10(2) & "0";
   qP9 <=      q9(1 downto 0);
   qM9 <=      q9(2) & "0";
   qP8 <=      q8(1 downto 0);
   qM8 <=      q8(2) & "0";
   qP7 <=      q7(1 downto 0);
   qM7 <=      q7(2) & "0";
   qP6 <=      q6(1 downto 0);
   qM6 <=      q6(2) & "0";
   qP5 <=      q5(1 downto 0);
   qM5 <=      q5(2) & "0";
   qP4 <=      q4(1 downto 0);
   qM4 <=      q4(2) & "0";
   qP3 <=      q3(1 downto 0);
   qM3 <=      q3(2) & "0";
   qP2 <=      q2(1 downto 0);
   qM2 <=      q2(2) & "0";
   qP1 <=      q1(1 downto 0);
   qM1 <=      q1(2) & "0";
   qP0 <= q0(1 downto 0);
   qM0 <= q0(2)  & "0";
   qP <= qP13 & qP12 & qP11 & qP10 & qP9 & qP8 & qP7 & qP6 & qP5 & qP4 & qP3 & qP2 & qP1 & qP0;
   qM <= qM13(0) & qM12 & qM11 & qM10 & qM9 & qM8 & qM7 & qM6 & qM5 & qM4 & qM3 & qM2 & qM1 & qM0 & "0";
   fR0 <= qP - qM;
   fR <= fR0(27 downto 1);  -- odd wF
   -- normalisation
   with fR(26) select
      fRn1 <= fR(25 downto 2) & (fR(1) or fR(0)) when '1',
              fR(24 downto 0)                    when others;
   expR1 <= expR0 + ("000" & (6 downto 1 => '1') & fR(26)); -- add back bias
   --round <= fRn1(1) and (fRn1(2) or fRn1(0)); -- fRn1(0) is the sticky bit
   -- final rounding
   expfrac <= expR1 & fRn1(24 downto 2) ;
   
   Guard_Bits <= (fRn1(1) & fRn1(0) & '0');
   rounding : Rounding_Mode_SP
    port map (  EXP_FRAC => expfrac,
              Rounding_Mode => RM,
              Guard_Bits => Guard_Bits,
              Sign => sR,
              OUT_EXP_FRAC => expfracR,
              INEXACT => INEXACT
              );
   --expfracR <= expfrac + ((32 downto 1 => '0') & round);
   exnR <=      "00"  when expfracR(32) = '1'   -- underflow
           else "10"  when  expfracR(32 downto 31) =  "01" -- overflow
           else "01";      -- 00, normal case
   with exnR0 select
      exnRfinal <= 
         exnR   when "01", -- normal
         exnR0  when others;
   R <= exnRfinal & sR & expfracR(30 downto 0);
end architecture;

