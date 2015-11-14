-- SipHash.Wide_Wide_Discrete
-- Implementing SipHash over a generic discrete type

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

with Interfaces;
use all type Interfaces.Unsigned_64;

function SipHash.Wide_Wide_Discrete (m : T_Array) return Hash_Type is

   subtype T_Array_2 is T_Array(T_Index'First..T_Index'First+1);

   T_Offset : constant Integer := T'Pos(T'First);

   function T_Array_2_to_U64_LE (S : in T_Array_2) return U64 with Inline;
   function T_Array_Tail_to_U64_LE (S : in T_Array)
                               return U64
     with Inline, Pre => (S'Length = 1);

   function T_Array_2_to_U64_LE (S : in T_Array_2) return U64 is
     (U64(T'Pos(S(S'First)) - T_Offset)
      or Shift_Left(U64(T'Pos(S(S'First+1)) - T_Offset), 32));

   function T_Array_Tail_to_U64_LE (S : in T_Array)
                               return U64 is
     (U64(T'Pos(S(S'First)) - T_Offset));

   m_pos : T_Index'Base := 0;
   m_i : U64;
   v : SipHash_State := Get_Initial_State;
   w : constant Natural := (m'Length / 2) + 1;

begin

   -- This compile-time check is useful for GNAT but in GNATprove it currently
   -- just generates a warning that it can not yet prove them correct.
   pragma Warnings (GNATprove, Off, "Compile_Time_Error");
   pragma Compile_Time_Error ((T'Size > 32),
                              "SipHash.Wide_Wide_Discrete only works for " &
                                "discrete types which fit into four bytes.");
   pragma Warnings (GNATprove, On, "Compile_Time_Error");

   for I in 1..w-1 loop
      pragma Loop_Invariant (m_pos = T_Index'Base(I - 1) * 2);
      m_i := T_Array_2_to_U64_LE(m(m'First + m_pos..m'First + m_pos + 1));
      v(3) := v(3) xor m_i;
      for J in 1..c_rounds loop
         Sip_Round(v);
      end loop;
      v(0) := v(0) xor m_i;
      m_pos := m_pos + 2;
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
end SipHash.Wide_Wide_Discrete;
