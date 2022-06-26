
--                                FPSqrt_8_23
-- This operator is part of the Infinite Virtual Library FloPoCoLib
-- All rights reserved 
-- Authors: 
--------------------------------------------------------------------------------
-- combinatorial

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library std;
use std.textio.all;
library work;

entity FPSqrt_8_23 is
   port ( X : in  std_logic_vector(8+23+2 downto 0);
          RM : in std_logic_vector(2 downto 0);
          R : out  std_logic_vector(8+23+2 downto 0);
          INEXACT : out  std_logic   );
end entity;

architecture arch of FPSqrt_8_23 is

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
signal expfrac : std_logic_vector(32 downto 0);
signal expfracR : std_logic_vector(32 downto 0);

signal fracX :  std_logic_vector(22 downto 0);
signal eRn0 :  std_logic_vector(7 downto 0);
signal xsX :  std_logic_vector(2 downto 0);
signal eRn1 :  std_logic_vector(7 downto 0);
signal w26 :  std_logic_vector(26 downto 0);
signal d25 :  std_logic;
signal x25 :  std_logic_vector(27 downto 0);
signal ds25 :  std_logic_vector(3 downto 0);
signal xh25 :  std_logic_vector(3 downto 0);
signal wh25 :  std_logic_vector(3 downto 0);
signal w25 :  std_logic_vector(26 downto 0);
signal s25 :  std_logic_vector(0 downto 0);
signal d24 :  std_logic;
signal x24 :  std_logic_vector(27 downto 0);
signal ds24 :  std_logic_vector(4 downto 0);
signal xh24 :  std_logic_vector(4 downto 0);
signal wh24 :  std_logic_vector(4 downto 0);
signal w24 :  std_logic_vector(26 downto 0);
signal s24 :  std_logic_vector(1 downto 0);
signal d23 :  std_logic;
signal x23 :  std_logic_vector(27 downto 0);
signal ds23 :  std_logic_vector(5 downto 0);
signal xh23 :  std_logic_vector(5 downto 0);
signal wh23 :  std_logic_vector(5 downto 0);
signal w23 :  std_logic_vector(26 downto 0);
signal s23 :  std_logic_vector(2 downto 0);
signal d22 :  std_logic;
signal x22 :  std_logic_vector(27 downto 0);
signal ds22 :  std_logic_vector(6 downto 0);
signal xh22 :  std_logic_vector(6 downto 0);
signal wh22 :  std_logic_vector(6 downto 0);
signal w22 :  std_logic_vector(26 downto 0);
signal s22 :  std_logic_vector(3 downto 0);
signal d21 :  std_logic;
signal x21 :  std_logic_vector(27 downto 0);
signal ds21 :  std_logic_vector(7 downto 0);
signal xh21 :  std_logic_vector(7 downto 0);
signal wh21 :  std_logic_vector(7 downto 0);
signal w21 :  std_logic_vector(26 downto 0);
signal s21 :  std_logic_vector(4 downto 0);
signal d20 :  std_logic;
signal x20 :  std_logic_vector(27 downto 0);
signal ds20 :  std_logic_vector(8 downto 0);
signal xh20 :  std_logic_vector(8 downto 0);
signal wh20 :  std_logic_vector(8 downto 0);
signal w20 :  std_logic_vector(26 downto 0);
signal s20 :  std_logic_vector(5 downto 0);
signal d19 :  std_logic;
signal x19 :  std_logic_vector(27 downto 0);
signal ds19 :  std_logic_vector(9 downto 0);
signal xh19 :  std_logic_vector(9 downto 0);
signal wh19 :  std_logic_vector(9 downto 0);
signal w19 :  std_logic_vector(26 downto 0);
signal s19 :  std_logic_vector(6 downto 0);
signal d18 :  std_logic;
signal x18 :  std_logic_vector(27 downto 0);
signal ds18 :  std_logic_vector(10 downto 0);
signal xh18 :  std_logic_vector(10 downto 0);
signal wh18 :  std_logic_vector(10 downto 0);
signal w18 :  std_logic_vector(26 downto 0);
signal s18 :  std_logic_vector(7 downto 0);
signal d17 :  std_logic;
signal x17 :  std_logic_vector(27 downto 0);
signal ds17 :  std_logic_vector(11 downto 0);
signal xh17 :  std_logic_vector(11 downto 0);
signal wh17 :  std_logic_vector(11 downto 0);
signal w17 :  std_logic_vector(26 downto 0);
signal s17 :  std_logic_vector(8 downto 0);
signal d16 :  std_logic;
signal x16 :  std_logic_vector(27 downto 0);
signal ds16 :  std_logic_vector(12 downto 0);
signal xh16 :  std_logic_vector(12 downto 0);
signal wh16 :  std_logic_vector(12 downto 0);
signal w16 :  std_logic_vector(26 downto 0);
signal s16 :  std_logic_vector(9 downto 0);
signal d15 :  std_logic;
signal x15 :  std_logic_vector(27 downto 0);
signal ds15 :  std_logic_vector(13 downto 0);
signal xh15 :  std_logic_vector(13 downto 0);
signal wh15 :  std_logic_vector(13 downto 0);
signal w15 :  std_logic_vector(26 downto 0);
signal s15 :  std_logic_vector(10 downto 0);
signal d14 :  std_logic;
signal x14 :  std_logic_vector(27 downto 0);
signal ds14 :  std_logic_vector(14 downto 0);
signal xh14 :  std_logic_vector(14 downto 0);
signal wh14 :  std_logic_vector(14 downto 0);
signal w14 :  std_logic_vector(26 downto 0);
signal s14 :  std_logic_vector(11 downto 0);
signal d13 :  std_logic;
signal x13 :  std_logic_vector(27 downto 0);
signal ds13 :  std_logic_vector(15 downto 0);
signal xh13 :  std_logic_vector(15 downto 0);
signal wh13 :  std_logic_vector(15 downto 0);
signal w13 :  std_logic_vector(26 downto 0);
signal s13 :  std_logic_vector(12 downto 0);
signal d12 :  std_logic;
signal x12 :  std_logic_vector(27 downto 0);
signal ds12 :  std_logic_vector(16 downto 0);
signal xh12 :  std_logic_vector(16 downto 0);
signal wh12 :  std_logic_vector(16 downto 0);
signal w12 :  std_logic_vector(26 downto 0);
signal s12 :  std_logic_vector(13 downto 0);
signal d11 :  std_logic;
signal x11 :  std_logic_vector(27 downto 0);
signal ds11 :  std_logic_vector(17 downto 0);
signal xh11 :  std_logic_vector(17 downto 0);
signal wh11 :  std_logic_vector(17 downto 0);
signal w11 :  std_logic_vector(26 downto 0);
signal s11 :  std_logic_vector(14 downto 0);
signal d10 :  std_logic;
signal x10 :  std_logic_vector(27 downto 0);
signal ds10 :  std_logic_vector(18 downto 0);
signal xh10 :  std_logic_vector(18 downto 0);
signal wh10 :  std_logic_vector(18 downto 0);
signal w10 :  std_logic_vector(26 downto 0);
signal s10 :  std_logic_vector(15 downto 0);
signal d9 :  std_logic;
signal x9 :  std_logic_vector(27 downto 0);
signal ds9 :  std_logic_vector(19 downto 0);
signal xh9 :  std_logic_vector(19 downto 0);
signal wh9 :  std_logic_vector(19 downto 0);
signal w9 :  std_logic_vector(26 downto 0);
signal s9 :  std_logic_vector(16 downto 0);
signal d8 :  std_logic;
signal x8 :  std_logic_vector(27 downto 0);
signal ds8 :  std_logic_vector(20 downto 0);
signal xh8 :  std_logic_vector(20 downto 0);
signal wh8 :  std_logic_vector(20 downto 0);
signal w8 :  std_logic_vector(26 downto 0);
signal s8 :  std_logic_vector(17 downto 0);
signal d7 :  std_logic;
signal x7 :  std_logic_vector(27 downto 0);
signal ds7 :  std_logic_vector(21 downto 0);
signal xh7 :  std_logic_vector(21 downto 0);
signal wh7 :  std_logic_vector(21 downto 0);
signal w7 :  std_logic_vector(26 downto 0);
signal s7 :  std_logic_vector(18 downto 0);
signal d6 :  std_logic;
signal x6 :  std_logic_vector(27 downto 0);
signal ds6 :  std_logic_vector(22 downto 0);
signal xh6 :  std_logic_vector(22 downto 0);
signal wh6 :  std_logic_vector(22 downto 0);
signal w6 :  std_logic_vector(26 downto 0);
signal s6 :  std_logic_vector(19 downto 0);
signal d5 :  std_logic;
signal x5 :  std_logic_vector(27 downto 0);
signal ds5 :  std_logic_vector(23 downto 0);
signal xh5 :  std_logic_vector(23 downto 0);
signal wh5 :  std_logic_vector(23 downto 0);
signal w5 :  std_logic_vector(26 downto 0);
signal s5 :  std_logic_vector(20 downto 0);
signal d4 :  std_logic;
signal x4 :  std_logic_vector(27 downto 0);
signal ds4 :  std_logic_vector(24 downto 0);
signal xh4 :  std_logic_vector(24 downto 0);
signal wh4 :  std_logic_vector(24 downto 0);
signal w4 :  std_logic_vector(26 downto 0);
signal s4 :  std_logic_vector(21 downto 0);
signal d3 :  std_logic;
signal x3 :  std_logic_vector(27 downto 0);
signal ds3 :  std_logic_vector(25 downto 0);
signal xh3 :  std_logic_vector(25 downto 0);
signal wh3 :  std_logic_vector(25 downto 0);
signal w3 :  std_logic_vector(26 downto 0);
signal s3 :  std_logic_vector(22 downto 0);
signal d2 :  std_logic;
signal x2 :  std_logic_vector(27 downto 0);
signal ds2 :  std_logic_vector(26 downto 0);
signal xh2 :  std_logic_vector(26 downto 0);
signal wh2 :  std_logic_vector(26 downto 0);
signal w2 :  std_logic_vector(26 downto 0);
signal s2 :  std_logic_vector(23 downto 0);
signal d1 :  std_logic;
signal x1 :  std_logic_vector(27 downto 0);
signal ds1 :  std_logic_vector(27 downto 0);
signal xh1 :  std_logic_vector(27 downto 0);
signal wh1 :  std_logic_vector(27 downto 0);
signal w1 :  std_logic_vector(26 downto 0);
signal s1 :  std_logic_vector(24 downto 0);
signal d0 :  std_logic;
signal fR :  std_logic_vector(26 downto 0);
signal fRn1 :  std_logic_vector(24 downto 0);
signal round :  std_logic;
signal fRn2 :  std_logic_vector(22 downto 0);
signal Rn2 :  std_logic_vector(30 downto 0);
signal xsR :  std_logic_vector(2 downto 0);
begin
   fracX <= X(22 downto 0); -- fraction
   eRn0 <= "0" & X(30 downto 24); -- exponent
   xsX <= X(33 downto 31); -- exception and sign
   eRn1 <= eRn0 + ("00" & (5 downto 0 => '1')) + X(23);
   w26 <= "111" & fracX & "0" when X(23) = '0' else
          "1101" & fracX;
   -- Step 25
   d25 <= w26(26);
   x25 <= w26 & "0";
   ds25 <=  "0" &  (not d25) & d25 & "1";
   xh25 <= x25(27 downto 24);
   with d25 select
      wh25 <= xh25 - ds25 when '0',
            xh25 + ds25 when others;
   w25 <= wh25(2 downto 0) & x25(23 downto 0);
   s25 <= "" & (not d25) ;
   -- Step 24
   d24 <= w25(26);
   x24 <= w25 & "0";
   ds24 <=  "0" & s25 &  (not d24) & d24 & "1";
   xh24 <= x24(27 downto 23);
   with d24 select
      wh24 <= xh24 - ds24 when '0',
            xh24 + ds24 when others;
   w24 <= wh24(3 downto 0) & x24(22 downto 0);
   s24 <= s25 & not d24;
   -- Step 23
   d23 <= w24(26);
   x23 <= w24 & "0";
   ds23 <=  "0" & s24 &  (not d23) & d23 & "1";
   xh23 <= x23(27 downto 22);
   with d23 select
      wh23 <= xh23 - ds23 when '0',
            xh23 + ds23 when others;
   w23 <= wh23(4 downto 0) & x23(21 downto 0);
   s23 <= s24 & not d23;
   -- Step 22
   d22 <= w23(26);
   x22 <= w23 & "0";
   ds22 <=  "0" & s23 &  (not d22) & d22 & "1";
   xh22 <= x22(27 downto 21);
   with d22 select
      wh22 <= xh22 - ds22 when '0',
            xh22 + ds22 when others;
   w22 <= wh22(5 downto 0) & x22(20 downto 0);
   s22 <= s23 & not d22;
   -- Step 21
   d21 <= w22(26);
   x21 <= w22 & "0";
   ds21 <=  "0" & s22 &  (not d21) & d21 & "1";
   xh21 <= x21(27 downto 20);
   with d21 select
      wh21 <= xh21 - ds21 when '0',
            xh21 + ds21 when others;
   w21 <= wh21(6 downto 0) & x21(19 downto 0);
   s21 <= s22 & not d21;
   -- Step 20
   d20 <= w21(26);
   x20 <= w21 & "0";
   ds20 <=  "0" & s21 &  (not d20) & d20 & "1";
   xh20 <= x20(27 downto 19);
   with d20 select
      wh20 <= xh20 - ds20 when '0',
            xh20 + ds20 when others;
   w20 <= wh20(7 downto 0) & x20(18 downto 0);
   s20 <= s21 & not d20;
   -- Step 19
   d19 <= w20(26);
   x19 <= w20 & "0";
   ds19 <=  "0" & s20 &  (not d19) & d19 & "1";
   xh19 <= x19(27 downto 18);
   with d19 select
      wh19 <= xh19 - ds19 when '0',
            xh19 + ds19 when others;
   w19 <= wh19(8 downto 0) & x19(17 downto 0);
   s19 <= s20 & not d19;
   -- Step 18
   d18 <= w19(26);
   x18 <= w19 & "0";
   ds18 <=  "0" & s19 &  (not d18) & d18 & "1";
   xh18 <= x18(27 downto 17);
   with d18 select
      wh18 <= xh18 - ds18 when '0',
            xh18 + ds18 when others;
   w18 <= wh18(9 downto 0) & x18(16 downto 0);
   s18 <= s19 & not d18;
   -- Step 17
   d17 <= w18(26);
   x17 <= w18 & "0";
   ds17 <=  "0" & s18 &  (not d17) & d17 & "1";
   xh17 <= x17(27 downto 16);
   with d17 select
      wh17 <= xh17 - ds17 when '0',
            xh17 + ds17 when others;
   w17 <= wh17(10 downto 0) & x17(15 downto 0);
   s17 <= s18 & not d17;
   -- Step 16
   d16 <= w17(26);
   x16 <= w17 & "0";
   ds16 <=  "0" & s17 &  (not d16) & d16 & "1";
   xh16 <= x16(27 downto 15);
   with d16 select
      wh16 <= xh16 - ds16 when '0',
            xh16 + ds16 when others;
   w16 <= wh16(11 downto 0) & x16(14 downto 0);
   s16 <= s17 & not d16;
   -- Step 15
   d15 <= w16(26);
   x15 <= w16 & "0";
   ds15 <=  "0" & s16 &  (not d15) & d15 & "1";
   xh15 <= x15(27 downto 14);
   with d15 select
      wh15 <= xh15 - ds15 when '0',
            xh15 + ds15 when others;
   w15 <= wh15(12 downto 0) & x15(13 downto 0);
   s15 <= s16 & not d15;
   -- Step 14
   d14 <= w15(26);
   x14 <= w15 & "0";
   ds14 <=  "0" & s15 &  (not d14) & d14 & "1";
   xh14 <= x14(27 downto 13);
   with d14 select
      wh14 <= xh14 - ds14 when '0',
            xh14 + ds14 when others;
   w14 <= wh14(13 downto 0) & x14(12 downto 0);
   s14 <= s15 & not d14;
   -- Step 13
   d13 <= w14(26);
   x13 <= w14 & "0";
   ds13 <=  "0" & s14 &  (not d13) & d13 & "1";
   xh13 <= x13(27 downto 12);
   with d13 select
      wh13 <= xh13 - ds13 when '0',
            xh13 + ds13 when others;
   w13 <= wh13(14 downto 0) & x13(11 downto 0);
   s13 <= s14 & not d13;
   -- Step 12
   d12 <= w13(26);
   x12 <= w13 & "0";
   ds12 <=  "0" & s13 &  (not d12) & d12 & "1";
   xh12 <= x12(27 downto 11);
   with d12 select
      wh12 <= xh12 - ds12 when '0',
            xh12 + ds12 when others;
   w12 <= wh12(15 downto 0) & x12(10 downto 0);
   s12 <= s13 & not d12;
   -- Step 11
   d11 <= w12(26);
   x11 <= w12 & "0";
   ds11 <=  "0" & s12 &  (not d11) & d11 & "1";
   xh11 <= x11(27 downto 10);
   with d11 select
      wh11 <= xh11 - ds11 when '0',
            xh11 + ds11 when others;
   w11 <= wh11(16 downto 0) & x11(9 downto 0);
   s11 <= s12 & not d11;
   -- Step 10
   d10 <= w11(26);
   x10 <= w11 & "0";
   ds10 <=  "0" & s11 &  (not d10) & d10 & "1";
   xh10 <= x10(27 downto 9);
   with d10 select
      wh10 <= xh10 - ds10 when '0',
            xh10 + ds10 when others;
   w10 <= wh10(17 downto 0) & x10(8 downto 0);
   s10 <= s11 & not d10;
   -- Step 9
   d9 <= w10(26);
   x9 <= w10 & "0";
   ds9 <=  "0" & s10 &  (not d9) & d9 & "1";
   xh9 <= x9(27 downto 8);
   with d9 select
      wh9 <= xh9 - ds9 when '0',
            xh9 + ds9 when others;
   w9 <= wh9(18 downto 0) & x9(7 downto 0);
   s9 <= s10 & not d9;
   -- Step 8
   d8 <= w9(26);
   x8 <= w9 & "0";
   ds8 <=  "0" & s9 &  (not d8) & d8 & "1";
   xh8 <= x8(27 downto 7);
   with d8 select
      wh8 <= xh8 - ds8 when '0',
            xh8 + ds8 when others;
   w8 <= wh8(19 downto 0) & x8(6 downto 0);
   s8 <= s9 & not d8;
   -- Step 7
   d7 <= w8(26);
   x7 <= w8 & "0";
   ds7 <=  "0" & s8 &  (not d7) & d7 & "1";
   xh7 <= x7(27 downto 6);
   with d7 select
      wh7 <= xh7 - ds7 when '0',
            xh7 + ds7 when others;
   w7 <= wh7(20 downto 0) & x7(5 downto 0);
   s7 <= s8 & not d7;
   -- Step 6
   d6 <= w7(26);
   x6 <= w7 & "0";
   ds6 <=  "0" & s7 &  (not d6) & d6 & "1";
   xh6 <= x6(27 downto 5);
   with d6 select
      wh6 <= xh6 - ds6 when '0',
            xh6 + ds6 when others;
   w6 <= wh6(21 downto 0) & x6(4 downto 0);
   s6 <= s7 & not d6;
   -- Step 5
   d5 <= w6(26);
   x5 <= w6 & "0";
   ds5 <=  "0" & s6 &  (not d5) & d5 & "1";
   xh5 <= x5(27 downto 4);
   with d5 select
      wh5 <= xh5 - ds5 when '0',
            xh5 + ds5 when others;
   w5 <= wh5(22 downto 0) & x5(3 downto 0);
   s5 <= s6 & not d5;
   -- Step 4
   d4 <= w5(26);
   x4 <= w5 & "0";
   ds4 <=  "0" & s5 &  (not d4) & d4 & "1";
   xh4 <= x4(27 downto 3);
   with d4 select
      wh4 <= xh4 - ds4 when '0',
            xh4 + ds4 when others;
   w4 <= wh4(23 downto 0) & x4(2 downto 0);
   s4 <= s5 & not d4;
   -- Step 3
   d3 <= w4(26);
   x3 <= w4 & "0";
   ds3 <=  "0" & s4 &  (not d3) & d3 & "1";
   xh3 <= x3(27 downto 2);
   with d3 select
      wh3 <= xh3 - ds3 when '0',
            xh3 + ds3 when others;
   w3 <= wh3(24 downto 0) & x3(1 downto 0);
   s3 <= s4 & not d3;
   -- Step 2
   d2 <= w3(26);
   x2 <= w3 & "0";
   ds2 <=  "0" & s3 &  (not d2) & d2 & "1";
   xh2 <= x2(27 downto 1);
   with d2 select
      wh2 <= xh2 - ds2 when '0',
            xh2 + ds2 when others;
   w2 <= wh2(25 downto 0) & x2(0 downto 0);
   s2 <= s3 & not d2;
   -- Step 1
   d1 <= w2(26);
   x1 <= w2 & "0";
   ds1 <=  "0" & s2 &  (not d1) & d1 & "1";
   xh1 <= x1(27 downto 0);
   with d1 select
      wh1 <= xh1 - ds1 when '0',
            xh1 + ds1 when others;
   w1 <= wh1(26 downto 0);
   s1 <= s2 & not d1;
   d0 <= w1(26) ;
   fR <= s1 & not d0 & '1';
   -- normalisation of the result, removing leading 1
   with fR(26) select
      fRn1 <= fR(25 downto 2) & (fR(1) or fR(0)) when '1',
              fR(24 downto 0)                    when others;
          
    expfrac <= "00" & eRn1 & fRn1(24 downto 2) ;
    Guard_Bits <= (fRn1(1) & fRn1(0) & '0');
    rounding : Rounding_Mode_SP
    port map (  EXP_FRAC => expfrac,
            Rounding_Mode => RM,
            Guard_Bits => Guard_Bits,
            Sign => xsR(0),
            OUT_EXP_FRAC => expfracR,
            INEXACT => INEXACT
            );
   fRn2 <= expfracR(22 downto 0);
   --round <= fRn1(1) and (fRn1(2) or fRn1(0)) ; -- round  and (lsb or sticky) : that's RN, tie to even
   --fRn2 <= fRn1(24 downto 2) + ((22 downto 1 => '0') & round); -- rounding sqrt never changes exponents 
   Rn2 <= eRn1 & fRn2;
   -- sign and exception processing
   with xsX select
      xsR <= "010"  when "010",  -- normal case
             "100"  when "100",  -- +infty
             "000"  when "000",  -- +0
             "001"  when "001",  -- the infamous sqrt(-0)=-0
             "110"  when others; -- return NaN
   R <= xsR & Rn2; 
end architecture;

