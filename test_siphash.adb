-- Test_SipHash
-- a short test program for an Ada implementation of the algorithm described in
-- "SipHash: a fast short-input PRF"
-- by Jean-Philippe Aumasson and Daniel J. Bernstein

with Ada.Text_IO; use Ada.Text_IO;
with Interfaces;
with System.Storage_Elements;

with SipHash;

procedure Test_SipHash is

   package U64_IO is new Ada.Text_IO.Modular_IO(Interfaces.Unsigned_64);
   use U64_IO;

   -- This matches is the test vector setup in the paper.
   package Test_SipHash is new SipHash(c_rounds => 2,
                               d_rounds => 4,
                               k0 => 16#0706050403020100#,
                               k1 => 16#0f0e0d0c0b0a0908#);
   M : constant System.Storage_Elements.Storage_Array :=
     (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
   R : Interfaces.Unsigned_64;
   Expected_R : constant Interfaces.Unsigned_64 := 16#a129ca6149be45e5#;
begin
   Put_Line("Testing SipHash routine.");
   New_Line;

   Put_Line("Test vector described in Appendix A to the paper " &
           "'SipHash: a fast short-input PRF'");
   Put_Line("by Jean-Philippe Aumasson and Daniel J. Bernstein.");
   R := Test_SipHash.SipHash(M);
   Put("Result received: "); Put(R, Base => 16); New_Line;
   Put("Result expected: "); Put(Expected_R, Base => 16); New_Line;
end Test_SipHash;
