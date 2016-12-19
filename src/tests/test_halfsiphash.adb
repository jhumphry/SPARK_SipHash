-- Test_HalfSipHash
-- a short test program for a 32-bit friendly version of SipHash, the algorithm
-- described in "SipHash: a fast short-input PRF"
-- by Jean-Philippe Aumasson and Daniel J. Bernstein

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

with Interfaces, Interfaces.C;
use Interfaces;

with System.Storage_Elements;
use System.Storage_Elements;

with Half_SipHash24;
with SipHash24_c;

procedure Test_HalfSipHash is

   package U32_IO is new Ada.Text_IO.Modular_IO(Interfaces.Unsigned_32);
   use U32_IO;

   K : constant Storage_Array :=
     (0,1,2,3,4,5,6,7);
   M : constant Storage_Array :=
     (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
   Result : Unsigned_32;

   C_K : aliased SipHash24_c.U8_Array(0..7) :=
     (0,1,2,3,4,5,6,7);
   C_M : aliased SipHash24_c.U8_Array(0..14) :=
     (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
   C_Output : aliased SipHash24_c.U8_Array4 := (others => 0);
   C_Result : Unsigned_32;
   Discard : C.int;

   Expected_Result : constant Unsigned_32 := 16#972BFE74#;

begin
   Put_Line("Testing Half_SipHash routines.");
   New_Line;

   Put_Line("Test vector for Half_SipHash");

   Half_SipHash24.Set_Key(K);

   Put("Result received from Ada routine for the test vector: ");
   Put(Half_SipHash24.Half_SipHash(M), Base => 16); New_Line;

   Discard := SipHash24_c.C_HalfSipHash24(c_in => C_M(0)'Access,
                                          inlen => C_M'Length,
                                          k => C_K(0)'Access,
                                          c_out => C_Output(0)'Access,
                                          outlen => 4
                                         );
   C_Result := SipHash24_c.U8_Array4_to_U32(C_Output);
   Put("Result received from reference C routine for the test vector: ");
   Put(C_Result, Base => 16); New_Line;

   Put("Result expected for the test vector: ");
   Put(Expected_Result, Base => 16); New_Line;
   New_Line;

   Put_Line("Testing Ada vs C routine for input lengths from 1 to 2000 bytes.");
   for I in 1..2000 loop
      declare
         M : System.Storage_Elements.Storage_Array(0..Storage_Offset(I-1));
         C_M : aliased SipHash24_c.U8_Array(0..I-1);
      begin
         for J in 0..I-1 loop
            M(Storage_Offset(J)) := Storage_Element(J mod 256);
            C_M(J) := Unsigned_8(J mod 256);
         end loop;
         Result := Half_SipHash24.Half_SipHash(M);
         Discard := SipHash24_c.C_HalfSipHash24(c_in => C_M(0)'Access,
                                                inlen => C_M'Length,
                                                k => C_K(0)'Access,
                                                c_out => C_Output(0)'Access,
                                                outlen => 4
                                               );
         C_Result := SipHash24_c.U8_Array4_to_U32(C_Output);
         if Result /= C_Result then
            Put("Difference in result for: "); Put(I); New_Line;
            Put("Ada code gives: "); Put(Result, Base => 16);
            Put(" C code gives: "); Put(C_Result, Base => 16);
            New_Line;
         end if;
      end;
      if I mod 200 = 0 then
         Put("Tested lengths up to: "); Put(I); New_Line;
      end if;
   end loop;

end Test_HalfSipHash;
