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
--                           FPDiv_11_52_comb_uid2
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

entity FPDiv_11_52_comb_uid2 is
   port ( X : in  std_logic_vector(11+52+2 downto 0);
          Y : in  std_logic_vector(11+52+2 downto 0);
          RM : in std_logic_vector(2 downto 0);
          R : out  std_logic_vector(11+52+2 downto 0);
          INEXACT : out  std_logic   );
end entity;

architecture arch of FPDiv_11_52_comb_uid2 is
   component SelFunctionTable_r4_comb_uid4 is
      port ( X : in  std_logic_vector(4 downto 0);
             Y : out  std_logic_vector(2 downto 0)   );
   end component;
   
   component Rounding_Mode_DP is
       port (
             EXP_FRAC : in std_logic_vector(64 downto 0);
             Rounding_Mode : in std_logic_vector(2 downto 0);
             Guard_Bits : in std_logic_vector(2 downto 0);
             Sign : in  std_logic;
             OUT_EXP_FRAC : out  std_logic_vector(64 downto 0);
             INEXACT : out  std_logic
             );
     end component;
   signal Guard_Bits :  std_logic_vector(2 downto 0);

signal fX :  std_logic_vector(52 downto 0);
signal fY :  std_logic_vector(52 downto 0);
signal expR0 :  std_logic_vector(12 downto 0);
signal sR :  std_logic;
signal exnXY :  std_logic_vector(3 downto 0);
signal exnR0 :  std_logic_vector(1 downto 0);
signal fYTimes3 :  std_logic_vector(54 downto 0);
signal w28 :  std_logic_vector(54 downto 0);
signal sel28 :  std_logic_vector(4 downto 0);
signal q28 :  std_logic_vector(2 downto 0);
signal q28D :  std_logic_vector(55 downto 0);
signal w28pad :  std_logic_vector(55 downto 0);
signal w27full :  std_logic_vector(55 downto 0);
signal w27 :  std_logic_vector(54 downto 0);
signal sel27 :  std_logic_vector(4 downto 0);
signal q27 :  std_logic_vector(2 downto 0);
signal q27D :  std_logic_vector(55 downto 0);
signal w27pad :  std_logic_vector(55 downto 0);
signal w26full :  std_logic_vector(55 downto 0);
signal w26 :  std_logic_vector(54 downto 0);
signal sel26 :  std_logic_vector(4 downto 0);
signal q26 :  std_logic_vector(2 downto 0);
signal q26D :  std_logic_vector(55 downto 0);
signal w26pad :  std_logic_vector(55 downto 0);
signal w25full :  std_logic_vector(55 downto 0);
signal w25 :  std_logic_vector(54 downto 0);
signal sel25 :  std_logic_vector(4 downto 0);
signal q25 :  std_logic_vector(2 downto 0);
signal q25D :  std_logic_vector(55 downto 0);
signal w25pad :  std_logic_vector(55 downto 0);
signal w24full :  std_logic_vector(55 downto 0);
signal w24 :  std_logic_vector(54 downto 0);
signal sel24 :  std_logic_vector(4 downto 0);
signal q24 :  std_logic_vector(2 downto 0);
signal q24D :  std_logic_vector(55 downto 0);
signal w24pad :  std_logic_vector(55 downto 0);
signal w23full :  std_logic_vector(55 downto 0);
signal w23 :  std_logic_vector(54 downto 0);
signal sel23 :  std_logic_vector(4 downto 0);
signal q23 :  std_logic_vector(2 downto 0);
signal q23D :  std_logic_vector(55 downto 0);
signal w23pad :  std_logic_vector(55 downto 0);
signal w22full :  std_logic_vector(55 downto 0);
signal w22 :  std_logic_vector(54 downto 0);
signal sel22 :  std_logic_vector(4 downto 0);
signal q22 :  std_logic_vector(2 downto 0);
signal q22D :  std_logic_vector(55 downto 0);
signal w22pad :  std_logic_vector(55 downto 0);
signal w21full :  std_logic_vector(55 downto 0);
signal w21 :  std_logic_vector(54 downto 0);
signal sel21 :  std_logic_vector(4 downto 0);
signal q21 :  std_logic_vector(2 downto 0);
signal q21D :  std_logic_vector(55 downto 0);
signal w21pad :  std_logic_vector(55 downto 0);
signal w20full :  std_logic_vector(55 downto 0);
signal w20 :  std_logic_vector(54 downto 0);
signal sel20 :  std_logic_vector(4 downto 0);
signal q20 :  std_logic_vector(2 downto 0);
signal q20D :  std_logic_vector(55 downto 0);
signal w20pad :  std_logic_vector(55 downto 0);
signal w19full :  std_logic_vector(55 downto 0);
signal w19 :  std_logic_vector(54 downto 0);
signal sel19 :  std_logic_vector(4 downto 0);
signal q19 :  std_logic_vector(2 downto 0);
signal q19D :  std_logic_vector(55 downto 0);
signal w19pad :  std_logic_vector(55 downto 0);
signal w18full :  std_logic_vector(55 downto 0);
signal w18 :  std_logic_vector(54 downto 0);
signal sel18 :  std_logic_vector(4 downto 0);
signal q18 :  std_logic_vector(2 downto 0);
signal q18D :  std_logic_vector(55 downto 0);
signal w18pad :  std_logic_vector(55 downto 0);
signal w17full :  std_logic_vector(55 downto 0);
signal w17 :  std_logic_vector(54 downto 0);
signal sel17 :  std_logic_vector(4 downto 0);
signal q17 :  std_logic_vector(2 downto 0);
signal q17D :  std_logic_vector(55 downto 0);
signal w17pad :  std_logic_vector(55 downto 0);
signal w16full :  std_logic_vector(55 downto 0);
signal w16 :  std_logic_vector(54 downto 0);
signal sel16 :  std_logic_vector(4 downto 0);
signal q16 :  std_logic_vector(2 downto 0);
signal q16D :  std_logic_vector(55 downto 0);
signal w16pad :  std_logic_vector(55 downto 0);
signal w15full :  std_logic_vector(55 downto 0);
signal w15 :  std_logic_vector(54 downto 0);
signal sel15 :  std_logic_vector(4 downto 0);
signal q15 :  std_logic_vector(2 downto 0);
signal q15D :  std_logic_vector(55 downto 0);
signal w15pad :  std_logic_vector(55 downto 0);
signal w14full :  std_logic_vector(55 downto 0);
signal w14 :  std_logic_vector(54 downto 0);
signal sel14 :  std_logic_vector(4 downto 0);
signal q14 :  std_logic_vector(2 downto 0);
signal q14D :  std_logic_vector(55 downto 0);
signal w14pad :  std_logic_vector(55 downto 0);
signal w13full :  std_logic_vector(55 downto 0);
signal w13 :  std_logic_vector(54 downto 0);
signal sel13 :  std_logic_vector(4 downto 0);
signal q13 :  std_logic_vector(2 downto 0);
signal q13D :  std_logic_vector(55 downto 0);
signal w13pad :  std_logic_vector(55 downto 0);
signal w12full :  std_logic_vector(55 downto 0);
signal w12 :  std_logic_vector(54 downto 0);
signal sel12 :  std_logic_vector(4 downto 0);
signal q12 :  std_logic_vector(2 downto 0);
signal q12D :  std_logic_vector(55 downto 0);
signal w12pad :  std_logic_vector(55 downto 0);
signal w11full :  std_logic_vector(55 downto 0);
signal w11 :  std_logic_vector(54 downto 0);
signal sel11 :  std_logic_vector(4 downto 0);
signal q11 :  std_logic_vector(2 downto 0);
signal q11D :  std_logic_vector(55 downto 0);
signal w11pad :  std_logic_vector(55 downto 0);
signal w10full :  std_logic_vector(55 downto 0);
signal w10 :  std_logic_vector(54 downto 0);
signal sel10 :  std_logic_vector(4 downto 0);
signal q10 :  std_logic_vector(2 downto 0);
signal q10D :  std_logic_vector(55 downto 0);
signal w10pad :  std_logic_vector(55 downto 0);
signal w9full :  std_logic_vector(55 downto 0);
signal w9 :  std_logic_vector(54 downto 0);
signal sel9 :  std_logic_vector(4 downto 0);
signal q9 :  std_logic_vector(2 downto 0);
signal q9D :  std_logic_vector(55 downto 0);
signal w9pad :  std_logic_vector(55 downto 0);
signal w8full :  std_logic_vector(55 downto 0);
signal w8 :  std_logic_vector(54 downto 0);
signal sel8 :  std_logic_vector(4 downto 0);
signal q8 :  std_logic_vector(2 downto 0);
signal q8D :  std_logic_vector(55 downto 0);
signal w8pad :  std_logic_vector(55 downto 0);
signal w7full :  std_logic_vector(55 downto 0);
signal w7 :  std_logic_vector(54 downto 0);
signal sel7 :  std_logic_vector(4 downto 0);
signal q7 :  std_logic_vector(2 downto 0);
signal q7D :  std_logic_vector(55 downto 0);
signal w7pad :  std_logic_vector(55 downto 0);
signal w6full :  std_logic_vector(55 downto 0);
signal w6 :  std_logic_vector(54 downto 0);
signal sel6 :  std_logic_vector(4 downto 0);
signal q6 :  std_logic_vector(2 downto 0);
signal q6D :  std_logic_vector(55 downto 0);
signal w6pad :  std_logic_vector(55 downto 0);
signal w5full :  std_logic_vector(55 downto 0);
signal w5 :  std_logic_vector(54 downto 0);
signal sel5 :  std_logic_vector(4 downto 0);
signal q5 :  std_logic_vector(2 downto 0);
signal q5D :  std_logic_vector(55 downto 0);
signal w5pad :  std_logic_vector(55 downto 0);
signal w4full :  std_logic_vector(55 downto 0);
signal w4 :  std_logic_vector(54 downto 0);
signal sel4 :  std_logic_vector(4 downto 0);
signal q4 :  std_logic_vector(2 downto 0);
signal q4D :  std_logic_vector(55 downto 0);
signal w4pad :  std_logic_vector(55 downto 0);
signal w3full :  std_logic_vector(55 downto 0);
signal w3 :  std_logic_vector(54 downto 0);
signal sel3 :  std_logic_vector(4 downto 0);
signal q3 :  std_logic_vector(2 downto 0);
signal q3D :  std_logic_vector(55 downto 0);
signal w3pad :  std_logic_vector(55 downto 0);
signal w2full :  std_logic_vector(55 downto 0);
signal w2 :  std_logic_vector(54 downto 0);
signal sel2 :  std_logic_vector(4 downto 0);
signal q2 :  std_logic_vector(2 downto 0);
signal q2D :  std_logic_vector(55 downto 0);
signal w2pad :  std_logic_vector(55 downto 0);
signal w1full :  std_logic_vector(55 downto 0);
signal w1 :  std_logic_vector(54 downto 0);
signal sel1 :  std_logic_vector(4 downto 0);
signal q1 :  std_logic_vector(2 downto 0);
signal q1D :  std_logic_vector(55 downto 0);
signal w1pad :  std_logic_vector(55 downto 0);
signal w0full :  std_logic_vector(55 downto 0);
signal w0 :  std_logic_vector(54 downto 0);
signal q0 :  std_logic_vector(2 downto 0);
signal qP28 :  std_logic_vector(1 downto 0);
signal qM28 :  std_logic_vector(1 downto 0);
signal qP27 :  std_logic_vector(1 downto 0);
signal qM27 :  std_logic_vector(1 downto 0);
signal qP26 :  std_logic_vector(1 downto 0);
signal qM26 :  std_logic_vector(1 downto 0);
signal qP25 :  std_logic_vector(1 downto 0);
signal qM25 :  std_logic_vector(1 downto 0);
signal qP24 :  std_logic_vector(1 downto 0);
signal qM24 :  std_logic_vector(1 downto 0);
signal qP23 :  std_logic_vector(1 downto 0);
signal qM23 :  std_logic_vector(1 downto 0);
signal qP22 :  std_logic_vector(1 downto 0);
signal qM22 :  std_logic_vector(1 downto 0);
signal qP21 :  std_logic_vector(1 downto 0);
signal qM21 :  std_logic_vector(1 downto 0);
signal qP20 :  std_logic_vector(1 downto 0);
signal qM20 :  std_logic_vector(1 downto 0);
signal qP19 :  std_logic_vector(1 downto 0);
signal qM19 :  std_logic_vector(1 downto 0);
signal qP18 :  std_logic_vector(1 downto 0);
signal qM18 :  std_logic_vector(1 downto 0);
signal qP17 :  std_logic_vector(1 downto 0);
signal qM17 :  std_logic_vector(1 downto 0);
signal qP16 :  std_logic_vector(1 downto 0);
signal qM16 :  std_logic_vector(1 downto 0);
signal qP15 :  std_logic_vector(1 downto 0);
signal qM15 :  std_logic_vector(1 downto 0);
signal qP14 :  std_logic_vector(1 downto 0);
signal qM14 :  std_logic_vector(1 downto 0);
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
signal qP :  std_logic_vector(57 downto 0);
signal qM :  std_logic_vector(57 downto 0);
signal fR0 :  std_logic_vector(57 downto 0);
signal fR :  std_logic_vector(55 downto 0);
signal fRn1 :  std_logic_vector(53 downto 0);
signal expR1 :  std_logic_vector(12 downto 0);
signal round :  std_logic;
signal expfrac :  std_logic_vector(64 downto 0);
signal expfracR :  std_logic_vector(64 downto 0);
signal exnR :  std_logic_vector(1 downto 0);
signal exnRfinal :  std_logic_vector(1 downto 0);
begin
   fX <= "1" & X(51 downto 0);
   fY <= "1" & Y(51 downto 0);
   -- exponent difference, sign and exception combination computed early, to have less bits to pipeline
   expR0 <= ("00" & X(62 downto 52)) - ("00" & Y(62 downto 52));
   sR <= X(63) xor Y(63);
   -- early exception handling 
   exnXY <= X(65 downto 64) & Y(65 downto 64);
   with exnXY select
      exnR0 <= 
         "01"  when "0101",                   -- normal
         "00"  when "0001" | "0010" | "0110", -- zero
         "10"  when "0100" | "1000" | "1001", -- overflow
         "11"  when others;                   -- NaN
    -- compute 3Y
   fYTimes3 <= ("00" & fY) + ("0" & fY & "0");
   w28 <=  "00" & fX;
   sel28 <= w28(54 downto 51) & fY(51);
   SelFunctionTable28: SelFunctionTable_r4_comb_uid4
      port map ( X => sel28,
                 Y => q28);

   with q28 select
      q28D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w28pad <= w28 & "0";
   with q28(2) select
   w27full<= w28pad - q28D when '0',
         w28pad + q28D when others;

   w27 <= w27full(53 downto 0) & "0";
   sel27 <= w27(54 downto 51) & fY(51);
   SelFunctionTable27: SelFunctionTable_r4_comb_uid4
      port map ( X => sel27,
                 Y => q27);

   with q27 select
      q27D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w27pad <= w27 & "0";
   with q27(2) select
   w26full<= w27pad - q27D when '0',
         w27pad + q27D when others;

   w26 <= w26full(53 downto 0) & "0";
   sel26 <= w26(54 downto 51) & fY(51);
   SelFunctionTable26: SelFunctionTable_r4_comb_uid4
      port map ( X => sel26,
                 Y => q26);

   with q26 select
      q26D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w26pad <= w26 & "0";
   with q26(2) select
   w25full<= w26pad - q26D when '0',
         w26pad + q26D when others;

   w25 <= w25full(53 downto 0) & "0";
   sel25 <= w25(54 downto 51) & fY(51);
   SelFunctionTable25: SelFunctionTable_r4_comb_uid4
      port map ( X => sel25,
                 Y => q25);

   with q25 select
      q25D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w25pad <= w25 & "0";
   with q25(2) select
   w24full<= w25pad - q25D when '0',
         w25pad + q25D when others;

   w24 <= w24full(53 downto 0) & "0";
   sel24 <= w24(54 downto 51) & fY(51);
   SelFunctionTable24: SelFunctionTable_r4_comb_uid4
      port map ( X => sel24,
                 Y => q24);

   with q24 select
      q24D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w24pad <= w24 & "0";
   with q24(2) select
   w23full<= w24pad - q24D when '0',
         w24pad + q24D when others;

   w23 <= w23full(53 downto 0) & "0";
   sel23 <= w23(54 downto 51) & fY(51);
   SelFunctionTable23: SelFunctionTable_r4_comb_uid4
      port map ( X => sel23,
                 Y => q23);

   with q23 select
      q23D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w23pad <= w23 & "0";
   with q23(2) select
   w22full<= w23pad - q23D when '0',
         w23pad + q23D when others;

   w22 <= w22full(53 downto 0) & "0";
   sel22 <= w22(54 downto 51) & fY(51);
   SelFunctionTable22: SelFunctionTable_r4_comb_uid4
      port map ( X => sel22,
                 Y => q22);

   with q22 select
      q22D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w22pad <= w22 & "0";
   with q22(2) select
   w21full<= w22pad - q22D when '0',
         w22pad + q22D when others;

   w21 <= w21full(53 downto 0) & "0";
   sel21 <= w21(54 downto 51) & fY(51);
   SelFunctionTable21: SelFunctionTable_r4_comb_uid4
      port map ( X => sel21,
                 Y => q21);

   with q21 select
      q21D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w21pad <= w21 & "0";
   with q21(2) select
   w20full<= w21pad - q21D when '0',
         w21pad + q21D when others;

   w20 <= w20full(53 downto 0) & "0";
   sel20 <= w20(54 downto 51) & fY(51);
   SelFunctionTable20: SelFunctionTable_r4_comb_uid4
      port map ( X => sel20,
                 Y => q20);

   with q20 select
      q20D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w20pad <= w20 & "0";
   with q20(2) select
   w19full<= w20pad - q20D when '0',
         w20pad + q20D when others;

   w19 <= w19full(53 downto 0) & "0";
   sel19 <= w19(54 downto 51) & fY(51);
   SelFunctionTable19: SelFunctionTable_r4_comb_uid4
      port map ( X => sel19,
                 Y => q19);

   with q19 select
      q19D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w19pad <= w19 & "0";
   with q19(2) select
   w18full<= w19pad - q19D when '0',
         w19pad + q19D when others;

   w18 <= w18full(53 downto 0) & "0";
   sel18 <= w18(54 downto 51) & fY(51);
   SelFunctionTable18: SelFunctionTable_r4_comb_uid4
      port map ( X => sel18,
                 Y => q18);

   with q18 select
      q18D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w18pad <= w18 & "0";
   with q18(2) select
   w17full<= w18pad - q18D when '0',
         w18pad + q18D when others;

   w17 <= w17full(53 downto 0) & "0";
   sel17 <= w17(54 downto 51) & fY(51);
   SelFunctionTable17: SelFunctionTable_r4_comb_uid4
      port map ( X => sel17,
                 Y => q17);

   with q17 select
      q17D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w17pad <= w17 & "0";
   with q17(2) select
   w16full<= w17pad - q17D when '0',
         w17pad + q17D when others;

   w16 <= w16full(53 downto 0) & "0";
   sel16 <= w16(54 downto 51) & fY(51);
   SelFunctionTable16: SelFunctionTable_r4_comb_uid4
      port map ( X => sel16,
                 Y => q16);

   with q16 select
      q16D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w16pad <= w16 & "0";
   with q16(2) select
   w15full<= w16pad - q16D when '0',
         w16pad + q16D when others;

   w15 <= w15full(53 downto 0) & "0";
   sel15 <= w15(54 downto 51) & fY(51);
   SelFunctionTable15: SelFunctionTable_r4_comb_uid4
      port map ( X => sel15,
                 Y => q15);

   with q15 select
      q15D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w15pad <= w15 & "0";
   with q15(2) select
   w14full<= w15pad - q15D when '0',
         w15pad + q15D when others;

   w14 <= w14full(53 downto 0) & "0";
   sel14 <= w14(54 downto 51) & fY(51);
   SelFunctionTable14: SelFunctionTable_r4_comb_uid4
      port map ( X => sel14,
                 Y => q14);

   with q14 select
      q14D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w14pad <= w14 & "0";
   with q14(2) select
   w13full<= w14pad - q14D when '0',
         w14pad + q14D when others;

   w13 <= w13full(53 downto 0) & "0";
   sel13 <= w13(54 downto 51) & fY(51);
   SelFunctionTable13: SelFunctionTable_r4_comb_uid4
      port map ( X => sel13,
                 Y => q13);

   with q13 select
      q13D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w13pad <= w13 & "0";
   with q13(2) select
   w12full<= w13pad - q13D when '0',
         w13pad + q13D when others;

   w12 <= w12full(53 downto 0) & "0";
   sel12 <= w12(54 downto 51) & fY(51);
   SelFunctionTable12: SelFunctionTable_r4_comb_uid4
      port map ( X => sel12,
                 Y => q12);

   with q12 select
      q12D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w12pad <= w12 & "0";
   with q12(2) select
   w11full<= w12pad - q12D when '0',
         w12pad + q12D when others;

   w11 <= w11full(53 downto 0) & "0";
   sel11 <= w11(54 downto 51) & fY(51);
   SelFunctionTable11: SelFunctionTable_r4_comb_uid4
      port map ( X => sel11,
                 Y => q11);

   with q11 select
      q11D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w11pad <= w11 & "0";
   with q11(2) select
   w10full<= w11pad - q11D when '0',
         w11pad + q11D when others;

   w10 <= w10full(53 downto 0) & "0";
   sel10 <= w10(54 downto 51) & fY(51);
   SelFunctionTable10: SelFunctionTable_r4_comb_uid4
      port map ( X => sel10,
                 Y => q10);

   with q10 select
      q10D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w10pad <= w10 & "0";
   with q10(2) select
   w9full<= w10pad - q10D when '0',
         w10pad + q10D when others;

   w9 <= w9full(53 downto 0) & "0";
   sel9 <= w9(54 downto 51) & fY(51);
   SelFunctionTable9: SelFunctionTable_r4_comb_uid4
      port map ( X => sel9,
                 Y => q9);

   with q9 select
      q9D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w9pad <= w9 & "0";
   with q9(2) select
   w8full<= w9pad - q9D when '0',
         w9pad + q9D when others;

   w8 <= w8full(53 downto 0) & "0";
   sel8 <= w8(54 downto 51) & fY(51);
   SelFunctionTable8: SelFunctionTable_r4_comb_uid4
      port map ( X => sel8,
                 Y => q8);

   with q8 select
      q8D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w8pad <= w8 & "0";
   with q8(2) select
   w7full<= w8pad - q8D when '0',
         w8pad + q8D when others;

   w7 <= w7full(53 downto 0) & "0";
   sel7 <= w7(54 downto 51) & fY(51);
   SelFunctionTable7: SelFunctionTable_r4_comb_uid4
      port map ( X => sel7,
                 Y => q7);

   with q7 select
      q7D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w7pad <= w7 & "0";
   with q7(2) select
   w6full<= w7pad - q7D when '0',
         w7pad + q7D when others;

   w6 <= w6full(53 downto 0) & "0";
   sel6 <= w6(54 downto 51) & fY(51);
   SelFunctionTable6: SelFunctionTable_r4_comb_uid4
      port map ( X => sel6,
                 Y => q6);

   with q6 select
      q6D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w6pad <= w6 & "0";
   with q6(2) select
   w5full<= w6pad - q6D when '0',
         w6pad + q6D when others;

   w5 <= w5full(53 downto 0) & "0";
   sel5 <= w5(54 downto 51) & fY(51);
   SelFunctionTable5: SelFunctionTable_r4_comb_uid4
      port map ( X => sel5,
                 Y => q5);

   with q5 select
      q5D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w5pad <= w5 & "0";
   with q5(2) select
   w4full<= w5pad - q5D when '0',
         w5pad + q5D when others;

   w4 <= w4full(53 downto 0) & "0";
   sel4 <= w4(54 downto 51) & fY(51);
   SelFunctionTable4: SelFunctionTable_r4_comb_uid4
      port map ( X => sel4,
                 Y => q4);

   with q4 select
      q4D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w4pad <= w4 & "0";
   with q4(2) select
   w3full<= w4pad - q4D when '0',
         w4pad + q4D when others;

   w3 <= w3full(53 downto 0) & "0";
   sel3 <= w3(54 downto 51) & fY(51);
   SelFunctionTable3: SelFunctionTable_r4_comb_uid4
      port map ( X => sel3,
                 Y => q3);

   with q3 select
      q3D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w3pad <= w3 & "0";
   with q3(2) select
   w2full<= w3pad - q3D when '0',
         w3pad + q3D when others;

   w2 <= w2full(53 downto 0) & "0";
   sel2 <= w2(54 downto 51) & fY(51);
   SelFunctionTable2: SelFunctionTable_r4_comb_uid4
      port map ( X => sel2,
                 Y => q2);

   with q2 select
      q2D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w2pad <= w2 & "0";
   with q2(2) select
   w1full<= w2pad - q2D when '0',
         w2pad + q2D when others;

   w1 <= w1full(53 downto 0) & "0";
   sel1 <= w1(54 downto 51) & fY(51);
   SelFunctionTable1: SelFunctionTable_r4_comb_uid4
      port map ( X => sel1,
                 Y => q1);

   with q1 select
      q1D <= 
         "000" & fY            when "001" | "111",
         "00" & fY & "0"       when "010" | "110",
         "0" & fYTimes3        when "011" | "101",
         (55 downto 0 => '0')  when others;

   w1pad <= w1 & "0";
   with q1(2) select
   w0full<= w1pad - q1D when '0',
         w1pad + q1D when others;

   w0 <= w0full(53 downto 0) & "0";
   q0(2 downto 0) <= "000" when  w0 = (54 downto 0 => '0')
                else w0(54) & "10";
   qP28 <=      q28(1 downto 0);
   qM28 <=      q28(2) & "0";
   qP27 <=      q27(1 downto 0);
   qM27 <=      q27(2) & "0";
   qP26 <=      q26(1 downto 0);
   qM26 <=      q26(2) & "0";
   qP25 <=      q25(1 downto 0);
   qM25 <=      q25(2) & "0";
   qP24 <=      q24(1 downto 0);
   qM24 <=      q24(2) & "0";
   qP23 <=      q23(1 downto 0);
   qM23 <=      q23(2) & "0";
   qP22 <=      q22(1 downto 0);
   qM22 <=      q22(2) & "0";
   qP21 <=      q21(1 downto 0);
   qM21 <=      q21(2) & "0";
   qP20 <=      q20(1 downto 0);
   qM20 <=      q20(2) & "0";
   qP19 <=      q19(1 downto 0);
   qM19 <=      q19(2) & "0";
   qP18 <=      q18(1 downto 0);
   qM18 <=      q18(2) & "0";
   qP17 <=      q17(1 downto 0);
   qM17 <=      q17(2) & "0";
   qP16 <=      q16(1 downto 0);
   qM16 <=      q16(2) & "0";
   qP15 <=      q15(1 downto 0);
   qM15 <=      q15(2) & "0";
   qP14 <=      q14(1 downto 0);
   qM14 <=      q14(2) & "0";
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
   qP <= qP28 & qP27 & qP26 & qP25 & qP24 & qP23 & qP22 & qP21 & qP20 & qP19 & qP18 & qP17 & qP16 & qP15 & qP14 & qP13 & qP12 & qP11 & qP10 & qP9 & qP8 & qP7 & qP6 & qP5 & qP4 & qP3 & qP2 & qP1 & qP0;
   qM <= qM28(0) & qM27 & qM26 & qM25 & qM24 & qM23 & qM22 & qM21 & qM20 & qM19 & qM18 & qM17 & qM16 & qM15 & qM14 & qM13 & qM12 & qM11 & qM10 & qM9 & qM8 & qM7 & qM6 & qM5 & qM4 & qM3 & qM2 & qM1 & qM0 & "0";
   fR0 <= qP - qM;
   fR <= fR0(57 downto 3)  & (fR0(2) or fR0(1));  -- even wF, fixing the round bit
   -- normalisation
   with fR(55) select
      fRn1 <= fR(54 downto 2) & (fR(1) or fR(0)) when '1',
              fR(53 downto 0)                    when others;
   expR1 <= expR0 + ("000" & (9 downto 1 => '1') & fR(55)); -- add back bias
   --round <= fRn1(1) and (fRn1(2) or fRn1(0)); -- fRn1(0) is the sticky bit
   -- final rounding
   expfrac <= expR1 & fRn1(53 downto 2) ;
   
   Guard_Bits <= (fRn1(1) & fRn1(0) & '0');
   rounding : Rounding_Mode_DP
   port map (  EXP_FRAC => expfrac,
             Rounding_Mode => RM,
             Guard_Bits => Guard_Bits,
             Sign => sR,
             OUT_EXP_FRAC => expfracR,
             INEXACT => INEXACT
             );
                 
   --expfracR <= expfrac + ((64 downto 1 => '0') & round);
   exnR <=      "00"  when expfracR(64) = '1'   -- underflow
           else "10"  when  expfracR(64 downto 63) =  "01" -- overflow
           else "01";      -- 00, normal case
   with exnR0 select
      exnRfinal <= 
         exnR   when "01", -- normal
         exnR0  when others;
   R <= exnRfinal & sR & expfracR(62 downto 0);
end architecture;

