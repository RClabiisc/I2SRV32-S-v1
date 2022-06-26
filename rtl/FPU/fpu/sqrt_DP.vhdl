
--------------------------------------------------------------------------------
--                                FPSqrt_11_52
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

entity FPSqrt_11_52 is
   port ( X : in  std_logic_vector(11+52+2 downto 0);
          RM : in std_logic_vector(2 downto 0);
          R : out  std_logic_vector(11+52+2 downto 0);
          INEXACT : out  std_logic   );
end entity;

architecture arch of FPSqrt_11_52 is

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
   signal expfrac : std_logic_vector(64 downto 0);
   signal expfracR : std_logic_vector(64 downto 0);
   
signal fracX :  std_logic_vector(51 downto 0);
signal eRn0 :  std_logic_vector(10 downto 0);
signal xsX :  std_logic_vector(2 downto 0);
signal eRn1 :  std_logic_vector(10 downto 0);
signal w55 :  std_logic_vector(55 downto 0);
signal d54 :  std_logic;
signal x54 :  std_logic_vector(56 downto 0);
signal ds54 :  std_logic_vector(3 downto 0);
signal xh54 :  std_logic_vector(3 downto 0);
signal wh54 :  std_logic_vector(3 downto 0);
signal w54 :  std_logic_vector(55 downto 0);
signal s54 :  std_logic_vector(0 downto 0);
signal d53 :  std_logic;
signal x53 :  std_logic_vector(56 downto 0);
signal ds53 :  std_logic_vector(4 downto 0);
signal xh53 :  std_logic_vector(4 downto 0);
signal wh53 :  std_logic_vector(4 downto 0);
signal w53 :  std_logic_vector(55 downto 0);
signal s53 :  std_logic_vector(1 downto 0);
signal d52 :  std_logic;
signal x52 :  std_logic_vector(56 downto 0);
signal ds52 :  std_logic_vector(5 downto 0);
signal xh52 :  std_logic_vector(5 downto 0);
signal wh52 :  std_logic_vector(5 downto 0);
signal w52 :  std_logic_vector(55 downto 0);
signal s52 :  std_logic_vector(2 downto 0);
signal d51 :  std_logic;
signal x51 :  std_logic_vector(56 downto 0);
signal ds51 :  std_logic_vector(6 downto 0);
signal xh51 :  std_logic_vector(6 downto 0);
signal wh51 :  std_logic_vector(6 downto 0);
signal w51 :  std_logic_vector(55 downto 0);
signal s51 :  std_logic_vector(3 downto 0);
signal d50 :  std_logic;
signal x50 :  std_logic_vector(56 downto 0);
signal ds50 :  std_logic_vector(7 downto 0);
signal xh50 :  std_logic_vector(7 downto 0);
signal wh50 :  std_logic_vector(7 downto 0);
signal w50 :  std_logic_vector(55 downto 0);
signal s50 :  std_logic_vector(4 downto 0);
signal d49 :  std_logic;
signal x49 :  std_logic_vector(56 downto 0);
signal ds49 :  std_logic_vector(8 downto 0);
signal xh49 :  std_logic_vector(8 downto 0);
signal wh49 :  std_logic_vector(8 downto 0);
signal w49 :  std_logic_vector(55 downto 0);
signal s49 :  std_logic_vector(5 downto 0);
signal d48 :  std_logic;
signal x48 :  std_logic_vector(56 downto 0);
signal ds48 :  std_logic_vector(9 downto 0);
signal xh48 :  std_logic_vector(9 downto 0);
signal wh48 :  std_logic_vector(9 downto 0);
signal w48 :  std_logic_vector(55 downto 0);
signal s48 :  std_logic_vector(6 downto 0);
signal d47 :  std_logic;
signal x47 :  std_logic_vector(56 downto 0);
signal ds47 :  std_logic_vector(10 downto 0);
signal xh47 :  std_logic_vector(10 downto 0);
signal wh47 :  std_logic_vector(10 downto 0);
signal w47 :  std_logic_vector(55 downto 0);
signal s47 :  std_logic_vector(7 downto 0);
signal d46 :  std_logic;
signal x46 :  std_logic_vector(56 downto 0);
signal ds46 :  std_logic_vector(11 downto 0);
signal xh46 :  std_logic_vector(11 downto 0);
signal wh46 :  std_logic_vector(11 downto 0);
signal w46 :  std_logic_vector(55 downto 0);
signal s46 :  std_logic_vector(8 downto 0);
signal d45 :  std_logic;
signal x45 :  std_logic_vector(56 downto 0);
signal ds45 :  std_logic_vector(12 downto 0);
signal xh45 :  std_logic_vector(12 downto 0);
signal wh45 :  std_logic_vector(12 downto 0);
signal w45 :  std_logic_vector(55 downto 0);
signal s45 :  std_logic_vector(9 downto 0);
signal d44 :  std_logic;
signal x44 :  std_logic_vector(56 downto 0);
signal ds44 :  std_logic_vector(13 downto 0);
signal xh44 :  std_logic_vector(13 downto 0);
signal wh44 :  std_logic_vector(13 downto 0);
signal w44 :  std_logic_vector(55 downto 0);
signal s44 :  std_logic_vector(10 downto 0);
signal d43 :  std_logic;
signal x43 :  std_logic_vector(56 downto 0);
signal ds43 :  std_logic_vector(14 downto 0);
signal xh43 :  std_logic_vector(14 downto 0);
signal wh43 :  std_logic_vector(14 downto 0);
signal w43 :  std_logic_vector(55 downto 0);
signal s43 :  std_logic_vector(11 downto 0);
signal d42 :  std_logic;
signal x42 :  std_logic_vector(56 downto 0);
signal ds42 :  std_logic_vector(15 downto 0);
signal xh42 :  std_logic_vector(15 downto 0);
signal wh42 :  std_logic_vector(15 downto 0);
signal w42 :  std_logic_vector(55 downto 0);
signal s42 :  std_logic_vector(12 downto 0);
signal d41 :  std_logic;
signal x41 :  std_logic_vector(56 downto 0);
signal ds41 :  std_logic_vector(16 downto 0);
signal xh41 :  std_logic_vector(16 downto 0);
signal wh41 :  std_logic_vector(16 downto 0);
signal w41 :  std_logic_vector(55 downto 0);
signal s41 :  std_logic_vector(13 downto 0);
signal d40 :  std_logic;
signal x40 :  std_logic_vector(56 downto 0);
signal ds40 :  std_logic_vector(17 downto 0);
signal xh40 :  std_logic_vector(17 downto 0);
signal wh40 :  std_logic_vector(17 downto 0);
signal w40 :  std_logic_vector(55 downto 0);
signal s40 :  std_logic_vector(14 downto 0);
signal d39 :  std_logic;
signal x39 :  std_logic_vector(56 downto 0);
signal ds39 :  std_logic_vector(18 downto 0);
signal xh39 :  std_logic_vector(18 downto 0);
signal wh39 :  std_logic_vector(18 downto 0);
signal w39 :  std_logic_vector(55 downto 0);
signal s39 :  std_logic_vector(15 downto 0);
signal d38 :  std_logic;
signal x38 :  std_logic_vector(56 downto 0);
signal ds38 :  std_logic_vector(19 downto 0);
signal xh38 :  std_logic_vector(19 downto 0);
signal wh38 :  std_logic_vector(19 downto 0);
signal w38 :  std_logic_vector(55 downto 0);
signal s38 :  std_logic_vector(16 downto 0);
signal d37 :  std_logic;
signal x37 :  std_logic_vector(56 downto 0);
signal ds37 :  std_logic_vector(20 downto 0);
signal xh37 :  std_logic_vector(20 downto 0);
signal wh37 :  std_logic_vector(20 downto 0);
signal w37 :  std_logic_vector(55 downto 0);
signal s37 :  std_logic_vector(17 downto 0);
signal d36 :  std_logic;
signal x36 :  std_logic_vector(56 downto 0);
signal ds36 :  std_logic_vector(21 downto 0);
signal xh36 :  std_logic_vector(21 downto 0);
signal wh36 :  std_logic_vector(21 downto 0);
signal w36 :  std_logic_vector(55 downto 0);
signal s36 :  std_logic_vector(18 downto 0);
signal d35 :  std_logic;
signal x35 :  std_logic_vector(56 downto 0);
signal ds35 :  std_logic_vector(22 downto 0);
signal xh35 :  std_logic_vector(22 downto 0);
signal wh35 :  std_logic_vector(22 downto 0);
signal w35 :  std_logic_vector(55 downto 0);
signal s35 :  std_logic_vector(19 downto 0);
signal d34 :  std_logic;
signal x34 :  std_logic_vector(56 downto 0);
signal ds34 :  std_logic_vector(23 downto 0);
signal xh34 :  std_logic_vector(23 downto 0);
signal wh34 :  std_logic_vector(23 downto 0);
signal w34 :  std_logic_vector(55 downto 0);
signal s34 :  std_logic_vector(20 downto 0);
signal d33 :  std_logic;
signal x33 :  std_logic_vector(56 downto 0);
signal ds33 :  std_logic_vector(24 downto 0);
signal xh33 :  std_logic_vector(24 downto 0);
signal wh33 :  std_logic_vector(24 downto 0);
signal w33 :  std_logic_vector(55 downto 0);
signal s33 :  std_logic_vector(21 downto 0);
signal d32 :  std_logic;
signal x32 :  std_logic_vector(56 downto 0);
signal ds32 :  std_logic_vector(25 downto 0);
signal xh32 :  std_logic_vector(25 downto 0);
signal wh32 :  std_logic_vector(25 downto 0);
signal w32 :  std_logic_vector(55 downto 0);
signal s32 :  std_logic_vector(22 downto 0);
signal d31 :  std_logic;
signal x31 :  std_logic_vector(56 downto 0);
signal ds31 :  std_logic_vector(26 downto 0);
signal xh31 :  std_logic_vector(26 downto 0);
signal wh31 :  std_logic_vector(26 downto 0);
signal w31 :  std_logic_vector(55 downto 0);
signal s31 :  std_logic_vector(23 downto 0);
signal d30 :  std_logic;
signal x30 :  std_logic_vector(56 downto 0);
signal ds30 :  std_logic_vector(27 downto 0);
signal xh30 :  std_logic_vector(27 downto 0);
signal wh30 :  std_logic_vector(27 downto 0);
signal w30 :  std_logic_vector(55 downto 0);
signal s30 :  std_logic_vector(24 downto 0);
signal d29 :  std_logic;
signal x29 :  std_logic_vector(56 downto 0);
signal ds29 :  std_logic_vector(28 downto 0);
signal xh29 :  std_logic_vector(28 downto 0);
signal wh29 :  std_logic_vector(28 downto 0);
signal w29 :  std_logic_vector(55 downto 0);
signal s29 :  std_logic_vector(25 downto 0);
signal d28 :  std_logic;
signal x28 :  std_logic_vector(56 downto 0);
signal ds28 :  std_logic_vector(29 downto 0);
signal xh28 :  std_logic_vector(29 downto 0);
signal wh28 :  std_logic_vector(29 downto 0);
signal w28 :  std_logic_vector(55 downto 0);
signal s28 :  std_logic_vector(26 downto 0);
signal d27 :  std_logic;
signal x27 :  std_logic_vector(56 downto 0);
signal ds27 :  std_logic_vector(30 downto 0);
signal xh27 :  std_logic_vector(30 downto 0);
signal wh27 :  std_logic_vector(30 downto 0);
signal w27 :  std_logic_vector(55 downto 0);
signal s27 :  std_logic_vector(27 downto 0);
signal d26 :  std_logic;
signal x26 :  std_logic_vector(56 downto 0);
signal ds26 :  std_logic_vector(31 downto 0);
signal xh26 :  std_logic_vector(31 downto 0);
signal wh26 :  std_logic_vector(31 downto 0);
signal w26 :  std_logic_vector(55 downto 0);
signal s26 :  std_logic_vector(28 downto 0);
signal d25 :  std_logic;
signal x25 :  std_logic_vector(56 downto 0);
signal ds25 :  std_logic_vector(32 downto 0);
signal xh25 :  std_logic_vector(32 downto 0);
signal wh25 :  std_logic_vector(32 downto 0);
signal w25 :  std_logic_vector(55 downto 0);
signal s25 :  std_logic_vector(29 downto 0);
signal d24 :  std_logic;
signal x24 :  std_logic_vector(56 downto 0);
signal ds24 :  std_logic_vector(33 downto 0);
signal xh24 :  std_logic_vector(33 downto 0);
signal wh24 :  std_logic_vector(33 downto 0);
signal w24 :  std_logic_vector(55 downto 0);
signal s24 :  std_logic_vector(30 downto 0);
signal d23 :  std_logic;
signal x23 :  std_logic_vector(56 downto 0);
signal ds23 :  std_logic_vector(34 downto 0);
signal xh23 :  std_logic_vector(34 downto 0);
signal wh23 :  std_logic_vector(34 downto 0);
signal w23 :  std_logic_vector(55 downto 0);
signal s23 :  std_logic_vector(31 downto 0);
signal d22 :  std_logic;
signal x22 :  std_logic_vector(56 downto 0);
signal ds22 :  std_logic_vector(35 downto 0);
signal xh22 :  std_logic_vector(35 downto 0);
signal wh22 :  std_logic_vector(35 downto 0);
signal w22 :  std_logic_vector(55 downto 0);
signal s22 :  std_logic_vector(32 downto 0);
signal d21 :  std_logic;
signal x21 :  std_logic_vector(56 downto 0);
signal ds21 :  std_logic_vector(36 downto 0);
signal xh21 :  std_logic_vector(36 downto 0);
signal wh21 :  std_logic_vector(36 downto 0);
signal w21 :  std_logic_vector(55 downto 0);
signal s21 :  std_logic_vector(33 downto 0);
signal d20 :  std_logic;
signal x20 :  std_logic_vector(56 downto 0);
signal ds20 :  std_logic_vector(37 downto 0);
signal xh20 :  std_logic_vector(37 downto 0);
signal wh20 :  std_logic_vector(37 downto 0);
signal w20 :  std_logic_vector(55 downto 0);
signal s20 :  std_logic_vector(34 downto 0);
signal d19 :  std_logic;
signal x19 :  std_logic_vector(56 downto 0);
signal ds19 :  std_logic_vector(38 downto 0);
signal xh19 :  std_logic_vector(38 downto 0);
signal wh19 :  std_logic_vector(38 downto 0);
signal w19 :  std_logic_vector(55 downto 0);
signal s19 :  std_logic_vector(35 downto 0);
signal d18 :  std_logic;
signal x18 :  std_logic_vector(56 downto 0);
signal ds18 :  std_logic_vector(39 downto 0);
signal xh18 :  std_logic_vector(39 downto 0);
signal wh18 :  std_logic_vector(39 downto 0);
signal w18 :  std_logic_vector(55 downto 0);
signal s18 :  std_logic_vector(36 downto 0);
signal d17 :  std_logic;
signal x17 :  std_logic_vector(56 downto 0);
signal ds17 :  std_logic_vector(40 downto 0);
signal xh17 :  std_logic_vector(40 downto 0);
signal wh17 :  std_logic_vector(40 downto 0);
signal w17 :  std_logic_vector(55 downto 0);
signal s17 :  std_logic_vector(37 downto 0);
signal d16 :  std_logic;
signal x16 :  std_logic_vector(56 downto 0);
signal ds16 :  std_logic_vector(41 downto 0);
signal xh16 :  std_logic_vector(41 downto 0);
signal wh16 :  std_logic_vector(41 downto 0);
signal w16 :  std_logic_vector(55 downto 0);
signal s16 :  std_logic_vector(38 downto 0);
signal d15 :  std_logic;
signal x15 :  std_logic_vector(56 downto 0);
signal ds15 :  std_logic_vector(42 downto 0);
signal xh15 :  std_logic_vector(42 downto 0);
signal wh15 :  std_logic_vector(42 downto 0);
signal w15 :  std_logic_vector(55 downto 0);
signal s15 :  std_logic_vector(39 downto 0);
signal d14 :  std_logic;
signal x14 :  std_logic_vector(56 downto 0);
signal ds14 :  std_logic_vector(43 downto 0);
signal xh14 :  std_logic_vector(43 downto 0);
signal wh14 :  std_logic_vector(43 downto 0);
signal w14 :  std_logic_vector(55 downto 0);
signal s14 :  std_logic_vector(40 downto 0);
signal d13 :  std_logic;
signal x13 :  std_logic_vector(56 downto 0);
signal ds13 :  std_logic_vector(44 downto 0);
signal xh13 :  std_logic_vector(44 downto 0);
signal wh13 :  std_logic_vector(44 downto 0);
signal w13 :  std_logic_vector(55 downto 0);
signal s13 :  std_logic_vector(41 downto 0);
signal d12 :  std_logic;
signal x12 :  std_logic_vector(56 downto 0);
signal ds12 :  std_logic_vector(45 downto 0);
signal xh12 :  std_logic_vector(45 downto 0);
signal wh12 :  std_logic_vector(45 downto 0);
signal w12 :  std_logic_vector(55 downto 0);
signal s12 :  std_logic_vector(42 downto 0);
signal d11 :  std_logic;
signal x11 :  std_logic_vector(56 downto 0);
signal ds11 :  std_logic_vector(46 downto 0);
signal xh11 :  std_logic_vector(46 downto 0);
signal wh11 :  std_logic_vector(46 downto 0);
signal w11 :  std_logic_vector(55 downto 0);
signal s11 :  std_logic_vector(43 downto 0);
signal d10 :  std_logic;
signal x10 :  std_logic_vector(56 downto 0);
signal ds10 :  std_logic_vector(47 downto 0);
signal xh10 :  std_logic_vector(47 downto 0);
signal wh10 :  std_logic_vector(47 downto 0);
signal w10 :  std_logic_vector(55 downto 0);
signal s10 :  std_logic_vector(44 downto 0);
signal d9 :  std_logic;
signal x9 :  std_logic_vector(56 downto 0);
signal ds9 :  std_logic_vector(48 downto 0);
signal xh9 :  std_logic_vector(48 downto 0);
signal wh9 :  std_logic_vector(48 downto 0);
signal w9 :  std_logic_vector(55 downto 0);
signal s9 :  std_logic_vector(45 downto 0);
signal d8 :  std_logic;
signal x8 :  std_logic_vector(56 downto 0);
signal ds8 :  std_logic_vector(49 downto 0);
signal xh8 :  std_logic_vector(49 downto 0);
signal wh8 :  std_logic_vector(49 downto 0);
signal w8 :  std_logic_vector(55 downto 0);
signal s8 :  std_logic_vector(46 downto 0);
signal d7 :  std_logic;
signal x7 :  std_logic_vector(56 downto 0);
signal ds7 :  std_logic_vector(50 downto 0);
signal xh7 :  std_logic_vector(50 downto 0);
signal wh7 :  std_logic_vector(50 downto 0);
signal w7 :  std_logic_vector(55 downto 0);
signal s7 :  std_logic_vector(47 downto 0);
signal d6 :  std_logic;
signal x6 :  std_logic_vector(56 downto 0);
signal ds6 :  std_logic_vector(51 downto 0);
signal xh6 :  std_logic_vector(51 downto 0);
signal wh6 :  std_logic_vector(51 downto 0);
signal w6 :  std_logic_vector(55 downto 0);
signal s6 :  std_logic_vector(48 downto 0);
signal d5 :  std_logic;
signal x5 :  std_logic_vector(56 downto 0);
signal ds5 :  std_logic_vector(52 downto 0);
signal xh5 :  std_logic_vector(52 downto 0);
signal wh5 :  std_logic_vector(52 downto 0);
signal w5 :  std_logic_vector(55 downto 0);
signal s5 :  std_logic_vector(49 downto 0);
signal d4 :  std_logic;
signal x4 :  std_logic_vector(56 downto 0);
signal ds4 :  std_logic_vector(53 downto 0);
signal xh4 :  std_logic_vector(53 downto 0);
signal wh4 :  std_logic_vector(53 downto 0);
signal w4 :  std_logic_vector(55 downto 0);
signal s4 :  std_logic_vector(50 downto 0);
signal d3 :  std_logic;
signal x3 :  std_logic_vector(56 downto 0);
signal ds3 :  std_logic_vector(54 downto 0);
signal xh3 :  std_logic_vector(54 downto 0);
signal wh3 :  std_logic_vector(54 downto 0);
signal w3 :  std_logic_vector(55 downto 0);
signal s3 :  std_logic_vector(51 downto 0);
signal d2 :  std_logic;
signal x2 :  std_logic_vector(56 downto 0);
signal ds2 :  std_logic_vector(55 downto 0);
signal xh2 :  std_logic_vector(55 downto 0);
signal wh2 :  std_logic_vector(55 downto 0);
signal w2 :  std_logic_vector(55 downto 0);
signal s2 :  std_logic_vector(52 downto 0);
signal d1 :  std_logic;
signal x1 :  std_logic_vector(56 downto 0);
signal ds1 :  std_logic_vector(56 downto 0);
signal xh1 :  std_logic_vector(56 downto 0);
signal wh1 :  std_logic_vector(56 downto 0);
signal w1 :  std_logic_vector(55 downto 0);
signal s1 :  std_logic_vector(53 downto 0);
signal d0 :  std_logic;
signal fR :  std_logic_vector(55 downto 0);
signal fRn1 :  std_logic_vector(53 downto 0);
signal round :  std_logic;
signal fRn2 :  std_logic_vector(51 downto 0);
signal Rn2 :  std_logic_vector(62 downto 0);
signal xsR :  std_logic_vector(2 downto 0);
begin
   fracX <= X(51 downto 0); -- fraction
   eRn0 <= "0" & X(62 downto 53); -- exponent
   xsX <= X(65 downto 63); -- exception and sign
   eRn1 <= eRn0 + ("00" & (8 downto 0 => '1')) + X(52);
   w55 <= "111" & fracX & "0" when X(52) = '0' else
          "1101" & fracX;
   -- Step 54
   d54 <= w55(55);
   x54 <= w55 & "0";
   ds54 <=  "0" &  (not d54) & d54 & "1";
   xh54 <= x54(56 downto 53);
   with d54 select
      wh54 <= xh54 - ds54 when '0',
            xh54 + ds54 when others;
   w54 <= wh54(2 downto 0) & x54(52 downto 0);
   s54 <= "" & (not d54) ;
   -- Step 53
   d53 <= w54(55);
   x53 <= w54 & "0";
   ds53 <=  "0" & s54 &  (not d53) & d53 & "1";
   xh53 <= x53(56 downto 52);
   with d53 select
      wh53 <= xh53 - ds53 when '0',
            xh53 + ds53 when others;
   w53 <= wh53(3 downto 0) & x53(51 downto 0);
   s53 <= s54 & not d53;
   -- Step 52
   d52 <= w53(55);
   x52 <= w53 & "0";
   ds52 <=  "0" & s53 &  (not d52) & d52 & "1";
   xh52 <= x52(56 downto 51);
   with d52 select
      wh52 <= xh52 - ds52 when '0',
            xh52 + ds52 when others;
   w52 <= wh52(4 downto 0) & x52(50 downto 0);
   s52 <= s53 & not d52;
   -- Step 51
   d51 <= w52(55);
   x51 <= w52 & "0";
   ds51 <=  "0" & s52 &  (not d51) & d51 & "1";
   xh51 <= x51(56 downto 50);
   with d51 select
      wh51 <= xh51 - ds51 when '0',
            xh51 + ds51 when others;
   w51 <= wh51(5 downto 0) & x51(49 downto 0);
   s51 <= s52 & not d51;
   -- Step 50
   d50 <= w51(55);
   x50 <= w51 & "0";
   ds50 <=  "0" & s51 &  (not d50) & d50 & "1";
   xh50 <= x50(56 downto 49);
   with d50 select
      wh50 <= xh50 - ds50 when '0',
            xh50 + ds50 when others;
   w50 <= wh50(6 downto 0) & x50(48 downto 0);
   s50 <= s51 & not d50;
   -- Step 49
   d49 <= w50(55);
   x49 <= w50 & "0";
   ds49 <=  "0" & s50 &  (not d49) & d49 & "1";
   xh49 <= x49(56 downto 48);
   with d49 select
      wh49 <= xh49 - ds49 when '0',
            xh49 + ds49 when others;
   w49 <= wh49(7 downto 0) & x49(47 downto 0);
   s49 <= s50 & not d49;
   -- Step 48
   d48 <= w49(55);
   x48 <= w49 & "0";
   ds48 <=  "0" & s49 &  (not d48) & d48 & "1";
   xh48 <= x48(56 downto 47);
   with d48 select
      wh48 <= xh48 - ds48 when '0',
            xh48 + ds48 when others;
   w48 <= wh48(8 downto 0) & x48(46 downto 0);
   s48 <= s49 & not d48;
   -- Step 47
   d47 <= w48(55);
   x47 <= w48 & "0";
   ds47 <=  "0" & s48 &  (not d47) & d47 & "1";
   xh47 <= x47(56 downto 46);
   with d47 select
      wh47 <= xh47 - ds47 when '0',
            xh47 + ds47 when others;
   w47 <= wh47(9 downto 0) & x47(45 downto 0);
   s47 <= s48 & not d47;
   -- Step 46
   d46 <= w47(55);
   x46 <= w47 & "0";
   ds46 <=  "0" & s47 &  (not d46) & d46 & "1";
   xh46 <= x46(56 downto 45);
   with d46 select
      wh46 <= xh46 - ds46 when '0',
            xh46 + ds46 when others;
   w46 <= wh46(10 downto 0) & x46(44 downto 0);
   s46 <= s47 & not d46;
   -- Step 45
   d45 <= w46(55);
   x45 <= w46 & "0";
   ds45 <=  "0" & s46 &  (not d45) & d45 & "1";
   xh45 <= x45(56 downto 44);
   with d45 select
      wh45 <= xh45 - ds45 when '0',
            xh45 + ds45 when others;
   w45 <= wh45(11 downto 0) & x45(43 downto 0);
   s45 <= s46 & not d45;
   -- Step 44
   d44 <= w45(55);
   x44 <= w45 & "0";
   ds44 <=  "0" & s45 &  (not d44) & d44 & "1";
   xh44 <= x44(56 downto 43);
   with d44 select
      wh44 <= xh44 - ds44 when '0',
            xh44 + ds44 when others;
   w44 <= wh44(12 downto 0) & x44(42 downto 0);
   s44 <= s45 & not d44;
   -- Step 43
   d43 <= w44(55);
   x43 <= w44 & "0";
   ds43 <=  "0" & s44 &  (not d43) & d43 & "1";
   xh43 <= x43(56 downto 42);
   with d43 select
      wh43 <= xh43 - ds43 when '0',
            xh43 + ds43 when others;
   w43 <= wh43(13 downto 0) & x43(41 downto 0);
   s43 <= s44 & not d43;
   -- Step 42
   d42 <= w43(55);
   x42 <= w43 & "0";
   ds42 <=  "0" & s43 &  (not d42) & d42 & "1";
   xh42 <= x42(56 downto 41);
   with d42 select
      wh42 <= xh42 - ds42 when '0',
            xh42 + ds42 when others;
   w42 <= wh42(14 downto 0) & x42(40 downto 0);
   s42 <= s43 & not d42;
   -- Step 41
   d41 <= w42(55);
   x41 <= w42 & "0";
   ds41 <=  "0" & s42 &  (not d41) & d41 & "1";
   xh41 <= x41(56 downto 40);
   with d41 select
      wh41 <= xh41 - ds41 when '0',
            xh41 + ds41 when others;
   w41 <= wh41(15 downto 0) & x41(39 downto 0);
   s41 <= s42 & not d41;
   -- Step 40
   d40 <= w41(55);
   x40 <= w41 & "0";
   ds40 <=  "0" & s41 &  (not d40) & d40 & "1";
   xh40 <= x40(56 downto 39);
   with d40 select
      wh40 <= xh40 - ds40 when '0',
            xh40 + ds40 when others;
   w40 <= wh40(16 downto 0) & x40(38 downto 0);
   s40 <= s41 & not d40;
   -- Step 39
   d39 <= w40(55);
   x39 <= w40 & "0";
   ds39 <=  "0" & s40 &  (not d39) & d39 & "1";
   xh39 <= x39(56 downto 38);
   with d39 select
      wh39 <= xh39 - ds39 when '0',
            xh39 + ds39 when others;
   w39 <= wh39(17 downto 0) & x39(37 downto 0);
   s39 <= s40 & not d39;
   -- Step 38
   d38 <= w39(55);
   x38 <= w39 & "0";
   ds38 <=  "0" & s39 &  (not d38) & d38 & "1";
   xh38 <= x38(56 downto 37);
   with d38 select
      wh38 <= xh38 - ds38 when '0',
            xh38 + ds38 when others;
   w38 <= wh38(18 downto 0) & x38(36 downto 0);
   s38 <= s39 & not d38;
   -- Step 37
   d37 <= w38(55);
   x37 <= w38 & "0";
   ds37 <=  "0" & s38 &  (not d37) & d37 & "1";
   xh37 <= x37(56 downto 36);
   with d37 select
      wh37 <= xh37 - ds37 when '0',
            xh37 + ds37 when others;
   w37 <= wh37(19 downto 0) & x37(35 downto 0);
   s37 <= s38 & not d37;
   -- Step 36
   d36 <= w37(55);
   x36 <= w37 & "0";
   ds36 <=  "0" & s37 &  (not d36) & d36 & "1";
   xh36 <= x36(56 downto 35);
   with d36 select
      wh36 <= xh36 - ds36 when '0',
            xh36 + ds36 when others;
   w36 <= wh36(20 downto 0) & x36(34 downto 0);
   s36 <= s37 & not d36;
   -- Step 35
   d35 <= w36(55);
   x35 <= w36 & "0";
   ds35 <=  "0" & s36 &  (not d35) & d35 & "1";
   xh35 <= x35(56 downto 34);
   with d35 select
      wh35 <= xh35 - ds35 when '0',
            xh35 + ds35 when others;
   w35 <= wh35(21 downto 0) & x35(33 downto 0);
   s35 <= s36 & not d35;
   -- Step 34
   d34 <= w35(55);
   x34 <= w35 & "0";
   ds34 <=  "0" & s35 &  (not d34) & d34 & "1";
   xh34 <= x34(56 downto 33);
   with d34 select
      wh34 <= xh34 - ds34 when '0',
            xh34 + ds34 when others;
   w34 <= wh34(22 downto 0) & x34(32 downto 0);
   s34 <= s35 & not d34;
   -- Step 33
   d33 <= w34(55);
   x33 <= w34 & "0";
   ds33 <=  "0" & s34 &  (not d33) & d33 & "1";
   xh33 <= x33(56 downto 32);
   with d33 select
      wh33 <= xh33 - ds33 when '0',
            xh33 + ds33 when others;
   w33 <= wh33(23 downto 0) & x33(31 downto 0);
   s33 <= s34 & not d33;
   -- Step 32
   d32 <= w33(55);
   x32 <= w33 & "0";
   ds32 <=  "0" & s33 &  (not d32) & d32 & "1";
   xh32 <= x32(56 downto 31);
   with d32 select
      wh32 <= xh32 - ds32 when '0',
            xh32 + ds32 when others;
   w32 <= wh32(24 downto 0) & x32(30 downto 0);
   s32 <= s33 & not d32;
   -- Step 31
   d31 <= w32(55);
   x31 <= w32 & "0";
   ds31 <=  "0" & s32 &  (not d31) & d31 & "1";
   xh31 <= x31(56 downto 30);
   with d31 select
      wh31 <= xh31 - ds31 when '0',
            xh31 + ds31 when others;
   w31 <= wh31(25 downto 0) & x31(29 downto 0);
   s31 <= s32 & not d31;
   -- Step 30
   d30 <= w31(55);
   x30 <= w31 & "0";
   ds30 <=  "0" & s31 &  (not d30) & d30 & "1";
   xh30 <= x30(56 downto 29);
   with d30 select
      wh30 <= xh30 - ds30 when '0',
            xh30 + ds30 when others;
   w30 <= wh30(26 downto 0) & x30(28 downto 0);
   s30 <= s31 & not d30;
   -- Step 29
   d29 <= w30(55);
   x29 <= w30 & "0";
   ds29 <=  "0" & s30 &  (not d29) & d29 & "1";
   xh29 <= x29(56 downto 28);
   with d29 select
      wh29 <= xh29 - ds29 when '0',
            xh29 + ds29 when others;
   w29 <= wh29(27 downto 0) & x29(27 downto 0);
   s29 <= s30 & not d29;
   -- Step 28
   d28 <= w29(55);
   x28 <= w29 & "0";
   ds28 <=  "0" & s29 &  (not d28) & d28 & "1";
   xh28 <= x28(56 downto 27);
   with d28 select
      wh28 <= xh28 - ds28 when '0',
            xh28 + ds28 when others;
   w28 <= wh28(28 downto 0) & x28(26 downto 0);
   s28 <= s29 & not d28;
   -- Step 27
   d27 <= w28(55);
   x27 <= w28 & "0";
   ds27 <=  "0" & s28 &  (not d27) & d27 & "1";
   xh27 <= x27(56 downto 26);
   with d27 select
      wh27 <= xh27 - ds27 when '0',
            xh27 + ds27 when others;
   w27 <= wh27(29 downto 0) & x27(25 downto 0);
   s27 <= s28 & not d27;
   -- Step 26
   d26 <= w27(55);
   x26 <= w27 & "0";
   ds26 <=  "0" & s27 &  (not d26) & d26 & "1";
   xh26 <= x26(56 downto 25);
   with d26 select
      wh26 <= xh26 - ds26 when '0',
            xh26 + ds26 when others;
   w26 <= wh26(30 downto 0) & x26(24 downto 0);
   s26 <= s27 & not d26;
   -- Step 25
   d25 <= w26(55);
   x25 <= w26 & "0";
   ds25 <=  "0" & s26 &  (not d25) & d25 & "1";
   xh25 <= x25(56 downto 24);
   with d25 select
      wh25 <= xh25 - ds25 when '0',
            xh25 + ds25 when others;
   w25 <= wh25(31 downto 0) & x25(23 downto 0);
   s25 <= s26 & not d25;
   -- Step 24
   d24 <= w25(55);
   x24 <= w25 & "0";
   ds24 <=  "0" & s25 &  (not d24) & d24 & "1";
   xh24 <= x24(56 downto 23);
   with d24 select
      wh24 <= xh24 - ds24 when '0',
            xh24 + ds24 when others;
   w24 <= wh24(32 downto 0) & x24(22 downto 0);
   s24 <= s25 & not d24;
   -- Step 23
   d23 <= w24(55);
   x23 <= w24 & "0";
   ds23 <=  "0" & s24 &  (not d23) & d23 & "1";
   xh23 <= x23(56 downto 22);
   with d23 select
      wh23 <= xh23 - ds23 when '0',
            xh23 + ds23 when others;
   w23 <= wh23(33 downto 0) & x23(21 downto 0);
   s23 <= s24 & not d23;
   -- Step 22
   d22 <= w23(55);
   x22 <= w23 & "0";
   ds22 <=  "0" & s23 &  (not d22) & d22 & "1";
   xh22 <= x22(56 downto 21);
   with d22 select
      wh22 <= xh22 - ds22 when '0',
            xh22 + ds22 when others;
   w22 <= wh22(34 downto 0) & x22(20 downto 0);
   s22 <= s23 & not d22;
   -- Step 21
   d21 <= w22(55);
   x21 <= w22 & "0";
   ds21 <=  "0" & s22 &  (not d21) & d21 & "1";
   xh21 <= x21(56 downto 20);
   with d21 select
      wh21 <= xh21 - ds21 when '0',
            xh21 + ds21 when others;
   w21 <= wh21(35 downto 0) & x21(19 downto 0);
   s21 <= s22 & not d21;
   -- Step 20
   d20 <= w21(55);
   x20 <= w21 & "0";
   ds20 <=  "0" & s21 &  (not d20) & d20 & "1";
   xh20 <= x20(56 downto 19);
   with d20 select
      wh20 <= xh20 - ds20 when '0',
            xh20 + ds20 when others;
   w20 <= wh20(36 downto 0) & x20(18 downto 0);
   s20 <= s21 & not d20;
   -- Step 19
   d19 <= w20(55);
   x19 <= w20 & "0";
   ds19 <=  "0" & s20 &  (not d19) & d19 & "1";
   xh19 <= x19(56 downto 18);
   with d19 select
      wh19 <= xh19 - ds19 when '0',
            xh19 + ds19 when others;
   w19 <= wh19(37 downto 0) & x19(17 downto 0);
   s19 <= s20 & not d19;
   -- Step 18
   d18 <= w19(55);
   x18 <= w19 & "0";
   ds18 <=  "0" & s19 &  (not d18) & d18 & "1";
   xh18 <= x18(56 downto 17);
   with d18 select
      wh18 <= xh18 - ds18 when '0',
            xh18 + ds18 when others;
   w18 <= wh18(38 downto 0) & x18(16 downto 0);
   s18 <= s19 & not d18;
   -- Step 17
   d17 <= w18(55);
   x17 <= w18 & "0";
   ds17 <=  "0" & s18 &  (not d17) & d17 & "1";
   xh17 <= x17(56 downto 16);
   with d17 select
      wh17 <= xh17 - ds17 when '0',
            xh17 + ds17 when others;
   w17 <= wh17(39 downto 0) & x17(15 downto 0);
   s17 <= s18 & not d17;
   -- Step 16
   d16 <= w17(55);
   x16 <= w17 & "0";
   ds16 <=  "0" & s17 &  (not d16) & d16 & "1";
   xh16 <= x16(56 downto 15);
   with d16 select
      wh16 <= xh16 - ds16 when '0',
            xh16 + ds16 when others;
   w16 <= wh16(40 downto 0) & x16(14 downto 0);
   s16 <= s17 & not d16;
   -- Step 15
   d15 <= w16(55);
   x15 <= w16 & "0";
   ds15 <=  "0" & s16 &  (not d15) & d15 & "1";
   xh15 <= x15(56 downto 14);
   with d15 select
      wh15 <= xh15 - ds15 when '0',
            xh15 + ds15 when others;
   w15 <= wh15(41 downto 0) & x15(13 downto 0);
   s15 <= s16 & not d15;
   -- Step 14
   d14 <= w15(55);
   x14 <= w15 & "0";
   ds14 <=  "0" & s15 &  (not d14) & d14 & "1";
   xh14 <= x14(56 downto 13);
   with d14 select
      wh14 <= xh14 - ds14 when '0',
            xh14 + ds14 when others;
   w14 <= wh14(42 downto 0) & x14(12 downto 0);
   s14 <= s15 & not d14;
   -- Step 13
   d13 <= w14(55);
   x13 <= w14 & "0";
   ds13 <=  "0" & s14 &  (not d13) & d13 & "1";
   xh13 <= x13(56 downto 12);
   with d13 select
      wh13 <= xh13 - ds13 when '0',
            xh13 + ds13 when others;
   w13 <= wh13(43 downto 0) & x13(11 downto 0);
   s13 <= s14 & not d13;
   -- Step 12
   d12 <= w13(55);
   x12 <= w13 & "0";
   ds12 <=  "0" & s13 &  (not d12) & d12 & "1";
   xh12 <= x12(56 downto 11);
   with d12 select
      wh12 <= xh12 - ds12 when '0',
            xh12 + ds12 when others;
   w12 <= wh12(44 downto 0) & x12(10 downto 0);
   s12 <= s13 & not d12;
   -- Step 11
   d11 <= w12(55);
   x11 <= w12 & "0";
   ds11 <=  "0" & s12 &  (not d11) & d11 & "1";
   xh11 <= x11(56 downto 10);
   with d11 select
      wh11 <= xh11 - ds11 when '0',
            xh11 + ds11 when others;
   w11 <= wh11(45 downto 0) & x11(9 downto 0);
   s11 <= s12 & not d11;
   -- Step 10
   d10 <= w11(55);
   x10 <= w11 & "0";
   ds10 <=  "0" & s11 &  (not d10) & d10 & "1";
   xh10 <= x10(56 downto 9);
   with d10 select
      wh10 <= xh10 - ds10 when '0',
            xh10 + ds10 when others;
   w10 <= wh10(46 downto 0) & x10(8 downto 0);
   s10 <= s11 & not d10;
   -- Step 9
   d9 <= w10(55);
   x9 <= w10 & "0";
   ds9 <=  "0" & s10 &  (not d9) & d9 & "1";
   xh9 <= x9(56 downto 8);
   with d9 select
      wh9 <= xh9 - ds9 when '0',
            xh9 + ds9 when others;
   w9 <= wh9(47 downto 0) & x9(7 downto 0);
   s9 <= s10 & not d9;
   -- Step 8
   d8 <= w9(55);
   x8 <= w9 & "0";
   ds8 <=  "0" & s9 &  (not d8) & d8 & "1";
   xh8 <= x8(56 downto 7);
   with d8 select
      wh8 <= xh8 - ds8 when '0',
            xh8 + ds8 when others;
   w8 <= wh8(48 downto 0) & x8(6 downto 0);
   s8 <= s9 & not d8;
   -- Step 7
   d7 <= w8(55);
   x7 <= w8 & "0";
   ds7 <=  "0" & s8 &  (not d7) & d7 & "1";
   xh7 <= x7(56 downto 6);
   with d7 select
      wh7 <= xh7 - ds7 when '0',
            xh7 + ds7 when others;
   w7 <= wh7(49 downto 0) & x7(5 downto 0);
   s7 <= s8 & not d7;
   -- Step 6
   d6 <= w7(55);
   x6 <= w7 & "0";
   ds6 <=  "0" & s7 &  (not d6) & d6 & "1";
   xh6 <= x6(56 downto 5);
   with d6 select
      wh6 <= xh6 - ds6 when '0',
            xh6 + ds6 when others;
   w6 <= wh6(50 downto 0) & x6(4 downto 0);
   s6 <= s7 & not d6;
   -- Step 5
   d5 <= w6(55);
   x5 <= w6 & "0";
   ds5 <=  "0" & s6 &  (not d5) & d5 & "1";
   xh5 <= x5(56 downto 4);
   with d5 select
      wh5 <= xh5 - ds5 when '0',
            xh5 + ds5 when others;
   w5 <= wh5(51 downto 0) & x5(3 downto 0);
   s5 <= s6 & not d5;
   -- Step 4
   d4 <= w5(55);
   x4 <= w5 & "0";
   ds4 <=  "0" & s5 &  (not d4) & d4 & "1";
   xh4 <= x4(56 downto 3);
   with d4 select
      wh4 <= xh4 - ds4 when '0',
            xh4 + ds4 when others;
   w4 <= wh4(52 downto 0) & x4(2 downto 0);
   s4 <= s5 & not d4;
   -- Step 3
   d3 <= w4(55);
   x3 <= w4 & "0";
   ds3 <=  "0" & s4 &  (not d3) & d3 & "1";
   xh3 <= x3(56 downto 2);
   with d3 select
      wh3 <= xh3 - ds3 when '0',
            xh3 + ds3 when others;
   w3 <= wh3(53 downto 0) & x3(1 downto 0);
   s3 <= s4 & not d3;
   -- Step 2
   d2 <= w3(55);
   x2 <= w3 & "0";
   ds2 <=  "0" & s3 &  (not d2) & d2 & "1";
   xh2 <= x2(56 downto 1);
   with d2 select
      wh2 <= xh2 - ds2 when '0',
            xh2 + ds2 when others;
   w2 <= wh2(54 downto 0) & x2(0 downto 0);
   s2 <= s3 & not d2;
   -- Step 1
   d1 <= w2(55);
   x1 <= w2 & "0";
   ds1 <=  "0" & s2 &  (not d1) & d1 & "1";
   xh1 <= x1(56 downto 0);
   with d1 select
      wh1 <= xh1 - ds1 when '0',
            xh1 + ds1 when others;
   w1 <= wh1(55 downto 0);
   s1 <= s2 & not d1;
   d0 <= w1(55) ;
   fR <= s1 & not d0 & '1';
   -- normalisation of the result, removing leading 1
   with fR(55) select
      fRn1 <= fR(54 downto 2) & (fR(1) or fR(0)) when '1',
              fR(53 downto 0)                    when others;
              
   expfrac <= "00" & eRn1 & fRn1(53 downto 2) ;
    Guard_Bits <= (fRn1(1) & fRn1(0) & '0');
    rounding : Rounding_Mode_DP
    port map (  EXP_FRAC => expfrac,
          Rounding_Mode => RM,
          Guard_Bits => Guard_Bits,
          Sign => xsR(0),
          OUT_EXP_FRAC => expfracR,
          INEXACT => INEXACT
          );
    fRn2 <= expfracR(51 downto 0);
                 
   --round <= fRn1(1) and (fRn1(2) or fRn1(0)) ; -- round  and (lsb or sticky) : that's RN, tie to even
   --fRn2 <= fRn1(53 downto 2) + ((51 downto 1 => '0') & round); -- rounding sqrt never changes exponents 
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

