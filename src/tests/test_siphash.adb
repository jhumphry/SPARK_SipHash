-- Test_SipHash
-- a short test program for an Ada implementation of the algorithm described in
-- "SipHash: a fast short-input PRF"
-- by Jean-Philippe Aumasson and Daniel J. Bernstein

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Containers;

with Interfaces, Interfaces.C, Interfaces.C.Strings;
use Interfaces;

with System.Storage_Elements;
use System.Storage_Elements;

with SipHash24, SipHash24_String_Hashing, SipHash.General;
with SipHash24_c;

procedure Test_SipHash is

   package U64_IO is new Ada.Text_IO.Modular_IO(Interfaces.Unsigned_64);
   use U64_IO;
   package ACH_IO is new Ada.Text_IO.Modular_IO(Ada.Containers.Hash_Type);
   use ACH_IO;

   -- This matches the test vector setup in the paper.
   K : constant Storage_Array :=
     (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);
   M : constant Storage_Array :=
     (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
   Result : Unsigned_64;

   C_K : aliased SipHash24_c.U8_Array(0..15) :=
     (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);
   C_M : aliased SipHash24_c.U8_Array(0..14) :=
     (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14);
   C_Output : aliased SipHash24_c.U8_Array8 := (others => 0);
   C_Result : Unsigned_64;
   Discard : C.int;

   Expected_Result : constant Unsigned_64 := 16#a129ca6149be45e5#;

   -- Testing use on strings
   Test_String : constant String := "Lorem ipsum dolor sit amet.";
   Test_C_String : C.Strings.chars_ptr := C.Strings.New_String(Test_String);

   -- Testing use on an example record type.
   type Example_Type is
      record
         Flag : Boolean;
         Counter : Natural;
      end record;

   function SipHash24_Example_Type is
     new SipHash24.General(T => Example_Type,
                           Hash_Type => Unsigned_64);

   Example_Value : Example_Type := (Flag => True, Counter => 3);

begin
   Put_Line("Testing SipHash routines.");
   New_Line;

   Put_Line("Test vector described in Appendix A to the paper " &
           "'SipHash: a fast short-input PRF'");
   Put_Line("by Jean-Philippe Aumasson and Daniel J. Bernstein.");

   SipHash24.Set_Key(K);

   Put("Result received from Ada routine for the test vector: ");
   Put(SipHash24.SipHash(M), Base => 16); New_Line;

   Discard := SipHash24_c.C_SipHash24(c_out => C_Output(0)'Access,
                                      c_in => C_M(0)'Access,
                                      inlen => C_M'Length,
                                      k => C_K(0)'Access);
   C_Result := SipHash24_c.U8_Array8_to_U64(C_Output);
   Put("Result received from reference C routine for the test vector: ");
   Put(C_Result, Base => 16); New_Line;

   Put("Result expected for the test vector: ");
   Put(Expected_Result, Base => 16); New_Line;
   New_Line;

   Put_Line("Testing hash of a string value: '" & Test_String & "'");
   Put("Result received from Ada routine (truncated for use in Ada.Containers): ");
   Put(SipHash24_String_Hashing.String_Hash(Test_String), Base => 16); New_Line;

   Discard := SipHash24_c.C_SipHash24(c_out => C_Output(0)'Access,
                                      c_in => SipHash24_c.chars_ptr_to_U8_Access(Test_C_String),
                                      inlen => Test_String'Length,
                                      k => C_K(0)'Access);
   C_Result := SipHash24_c.U8_Array8_to_U64(C_Output);
   Put("Result received from reference C routine: ");
   Put(C_Result, Base => 16); New_Line;
   C.Strings.Free(Test_C_String);
   New_Line;

   Put_Line("Testing hash of a small record type (Flag => true, Counter => 3).");
   Put("Result received from Ada routine: ");
   Put(SipHash24_Example_Type(Example_Value), Base => 16); New_Line;
   Put_Line("Incrementing counter and re-hashing.");
   Example_Value.Counter := Example_Value.Counter + 1;
   Put("Result received from Ada routine: ");
   Put(SipHash24_Example_Type(Example_Value), Base => 16); New_Line;
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
         Result := SipHash24.SipHash(M);
         Discard := SipHash24_c.C_SipHash24(c_out => C_Output(0)'Access,
                                            c_in => C_M(0)'Access,
                                            inlen => Unsigned_64(I),
                                            k => C_K(0)'Access);
         C_Result := SipHash24_c.U8_Array8_to_U64(C_Output);
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

end Test_SipHash;
