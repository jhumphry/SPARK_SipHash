-- SipHash.Discrete
-- Implementing SipHash over a generic discrete type

with Interfaces;
use all type Interfaces.Unsigned_64;

function SipHash.Discrete (m : T_Array) return Hash_Type is

   subtype T_Array_8 is T_Array(T_Index'First..T_Index'First+7);

   T_Offset : constant Integer := T'Pos(T'First);

   function T_Array_8_to_U64_LE (S : in T_Array_8) return U64 with Inline;
   function T_Array_Tail_to_U64_LE (S : in T_Array; Total_Length : in Natural)
                               return U64
     with Inline, Pre => (S'Length <= 7);

   function T_Array_8_to_U64_LE (S : in T_Array_8) return U64 is
     (U64(T'Pos(S(S'First)) - T_Offset)
      or Shift_Left(U64(T'Pos(S(S'First+1)) - T_Offset), 8)
      or Shift_Left(U64(T'Pos(S(S'First+2)) - T_Offset), 16)
      or Shift_Left(U64(T'Pos(S(S'First+3)) - T_Offset), 24)
      or Shift_Left(U64(T'Pos(S(S'First+4)) - T_Offset), 32)
      or Shift_Left(U64(T'Pos(S(S'First+5)) - T_Offset), 40)
      or Shift_Left(U64(T'Pos(S(S'First+6)) - T_Offset), 48)
      or Shift_Left(U64(T'Pos(S(S'First+7)) - T_Offset), 56));

   function T_Array_Tail_to_U64_LE (S : in T_Array; Total_Length : in Natural)
                               return U64 is
      R : U64 := 0;
      Shift : Natural := 0;
   begin
      for I of S loop
         R := R or Shift_Left(U64(T'Pos(I) - T_Offset), Shift);
         Shift := Shift + 8;
      end loop;
      R := R or Shift_Left(U64(Total_Length mod 256), 56);
      return R;
   end T_Array_Tail_to_U64_LE;

   m_pos : T_Index := m'First;
   m_i : U64;
   v : SipHash_State := Initial_State;
   w : constant Natural := (m'Length / 8) + 1;
   Result : U64;
begin

   pragma Assert(Check => ((T'Pos(T'Last) - T_Offset) < 256),
                 Message => "SipHash.Discrete only works for discrete types " &
                   "which fit into one byte.");

   for I in 1..w-1 loop
      m_i := T_Array_8_to_U64_LE(m(m_pos..m_pos+7));
      v(3) := v(3) xor m_i;
      for J in 1..c_rounds loop
         SipRound(v);
      end loop;
      v(0) := v(0) xor m_i;
      m_pos := m_pos + 8;
   end loop;

   m_i := T_Array_Tail_to_U64_LE(m(m_pos..m'Last), m'Length);
   v(3) := v(3) xor m_i;
   for J in 1..c_rounds loop
      SipRound(v);
   end loop;
   v(0) := v(0) xor m_i;

   Result := SipFinalization(v);
   return Hash_Type'Mod(Result);
end SipHash.Discrete;
