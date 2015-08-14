-- Test_SipHash
-- a short test program for an Ada implementation of the algorithm described in
-- "SipHash: a fast short-input PRF"
-- by Jean-Philippe Aumasson and Daniel J. Bernstein

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Containers;

with Interfaces, Interfaces.C, Interfaces.C.Strings;
use Interfaces;

with System.Storage_Elements;

with SipHash, SipHash.Discrete;
with SipHash24_c;

procedure Test_SipHash is

   package U64_IO is new Ada.Text_IO.Modular_IO(Interfaces.Unsigned_64);
   use U64_IO;
   package ACH_IO is new Ada.Text_IO.Modular_IO(Ada.Containers.Hash_Type);
   use ACH_IO;

   package Test_SipHash24 is new SipHash(c_rounds => 2,
                                         d_rounds => 4);
   function SipHash24_String is
     new Test_SipHash24.Discrete(T => Character,
                                 T_Index => Positive,
                                 T_Array => String,
                                 Hash_Type => Ada.Containers.Hash_Type);

   -- This matches the test vector setup in the paper.
   K : constant System.Storage_Elements.Storage_Array :=
     (0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15);
   M : constant System.Storage_Elements.Storage_Array :=
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
   Test_String_Result : Ada.Containers.Hash_Type;
begin
   Put_Line("Testing SipHash routines.");
   New_Line;

   Put_Line("Test vector described in Appendix A to the paper " &
           "'SipHash: a fast short-input PRF'");
   Put_Line("by Jean-Philippe Aumasson and Daniel J. Bernstein.");

   Test_SipHash24.SetKey(K);
   Result := Test_SipHash24.SipHash(M);
   Put("Result received from Ada routine: ");
   Put(Result, Base => 16); New_Line;

   Discard := SipHash24_c.C_SipHash24(c_out => C_Output(0)'Access,
                                      c_in => C_M(0)'Access,
                                      inlen => C_M'Length,
                                      k => C_K(0)'Access);
   C_Result := SipHash24_c.U8_Array8_to_U64(C_Output);
   Put("Result received from reference C routine: ");
   Put(C_Result, Base => 16); New_Line;

   Put("Result expected: ");
   Put(Expected_Result, Base => 16); New_Line;
   New_Line;

   Put_Line("Testing hash of: '" & Test_String & "'");
   Test_String_Result := Test_SipHash24.SipHash(Test_String);
   Put("Result received from Ada routine (truncated for use in Ada.Containers): ");
   Put(Test_String_Result, Base => 16); New_Line;
   Test_String_Result := SipHash24_String(Test_String);
   Put("Result received from Ada routine for generic discrete types: ");
   Put(Test_String_Result, Base => 16); New_Line;

   Discard := SipHash24_c.C_SipHash24(c_out => C_Output(0)'Access,
                                      c_in => SipHash24_c.chars_ptr_to_U8_Access(Test_C_String),
                                      inlen => Test_String'Length,
                                      k => C_K(0)'Access);
   C_Result := SipHash24_c.U8_Array8_to_U64(C_Output);
   Put("Result received from reference C routine: ");
   Put(C_Result, Base => 16); New_Line;
   C.Strings.Free(Test_C_String);

end Test_SipHash;
