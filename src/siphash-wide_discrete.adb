-- SipHash.Wide_Discrete
-- Implementing SipHash over a generic discrete type

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

with Interfaces;
use all type Interfaces.Unsigned_64;

function SipHash.Wide_Discrete (m : T_Array) return Hash_Type is

   subtype T_Array_4 is T_Array(T_Index'First..T_Index'First+3);

   T_Offset : constant Integer := T'Pos(T'First);

   function T_Array_4_to_U64_LE (S : in T_Array_4) return U64 with Inline;
   function T_Array_Tail_to_U64_LE (S : in T_Array)
                               return U64
     with Inline, Pre => (S'Length <= 3 and then S'Length > 0);

   function T_Array_4_to_U64_LE (S : in T_Array_4) return U64 is
     (U64(T'Pos(S(S'First)) - T_Offset)
      or Shift_Left(U64(T'Pos(S(S'First+1)) - T_Offset), 16)
      or Shift_Left(U64(T'Pos(S(S'First+2)) - T_Offset), 32)
      or Shift_Left(U64(T'Pos(S(S'First+3)) - T_Offset), 48));

   function T_Array_Tail_to_U64_LE (S : in T_Array)
                               return U64 is
      R : U64 := 0;
      Shift : Natural := 0;
      T_I : T;
   begin
      for I in 0..S'Length-1 loop
         pragma Loop_Invariant (Shift = I * 16);
         T_I := S(S'First + T_Index'Base(I));
         R := R or Shift_Left(U64(T'Pos(T_I) - T_Offset), Shift);
         Shift := Shift + 16;
      end loop;
      return R;
   end T_Array_Tail_to_U64_LE;

   m_pos : T_Index'Base := 0;
   m_i : U64;
   v : SipHash_State := Get_Initial_State;
   w : constant Natural := (m'Length / 4) + 1;

begin

   -- This compile-time check is useful for GNAT but in GNATprove it currently
   -- just generates a warning that it can not yet prove them correct.
   pragma Warnings (GNATprove, Off, "Compile_Time_Error");
   pragma Compile_Time_Error ((T'Size > 16),
                              "SipHash.Wide_Discrete only works for discrete " &
                                "types which fit into two bytes.");
   pragma Warnings (GNATprove, On, "Compile_Time_Error");

   for I in 1..w-1 loop
      pragma Loop_Invariant (m_pos = T_Index'Base(I - 1) * 4);
      m_i := T_Array_4_to_U64_LE(m(m'First + m_pos..m'First + m_pos + 3));
      v(3) := v(3) xor m_i;
      for J in 1..c_rounds loop
         Sip_Round(v);
      end loop;
      v(0) := v(0) xor m_i;
      m_pos := m_pos + 4;
   end loop;

   if m_pos < m'Length then
      m_i := T_Array_Tail_to_U64_LE(m(m'First + m_pos .. m'Last));
   else
      m_i := 0;
   end if;
   m_i := m_i or Shift_Left(U64(m'Length mod 256), 56);

   v(3) := v(3) xor m_i;
   for J in 1..c_rounds loop
      Sip_Round(v);
   end loop;
   v(0) := v(0) xor m_i;

   return Hash_Type'Mod(Sip_Finalization(v));
end SipHash.Wide_Discrete;
