-- SipHash
-- an Ada implementation of the algorithm described in
-- "SipHash: a fast short-input PRF"
-- by Jean-Philippe Aumasson and Daniel J. Bernstein

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

with System;

package body SipHash with
SPARK_Mode,
Refined_State => (Initial_Hash_State => Initial_State)
is

   -- Short names for fundamental machine types
   subtype Storage_Offset is System.Storage_Elements.Storage_Offset;

   -- The initial state from the key passed as generic formal parameters is
   -- stored here, so that static elaboration followed by a call of SetKey
   -- can be used in situations where dynamic elaboration might be a problem.

   -- This could really be in the private part of the package, but SPARK GPL
   -- 2015 doesn't seem to like Part_Of in the private part of a package,
   -- regardless of what the SPARK RM says...
   Initial_State : SipHash_State := (k0 xor 16#736f6d6570736575#,
                                     k1 xor 16#646f72616e646f6d#,
                                     k0 xor 16#6c7967656e657261#,
                                     k1 xor 16#7465646279746573#);

   -----------------------
   -- Get_Initial_State --
   -----------------------

   function Get_Initial_State return SipHash_State is
      (Initial_State);

   -----------------------
   -- SArray8_to_U64_LE --
   -----------------------

   function SArray8_to_U64_LE (S : in SArray_8) return U64 is
     (U64(S(0))
      or Shift_Left(U64(S(1)), 8)
      or Shift_Left(U64(S(2)), 16)
      or Shift_Left(U64(S(3)), 24)
      or Shift_Left(U64(S(4)), 32)
      or Shift_Left(U64(S(5)), 40)
      or Shift_Left(U64(S(6)), 48)
      or Shift_Left(U64(S(7)), 56));

   ----------------------
   -- SArray_to_U64_LE --
   ----------------------

   function SArray_Tail_to_U64_LE (S : in SArray)
                              return U64 is
      R : U64 := 0;
      Shift : Natural := 0;
   begin
      for I in 0..(S'Length-1) loop
         pragma Loop_Invariant (Shift = I * 8);
         R := R or Shift_Left(U64(S(S'First + Storage_Offset(I))), Shift);
         Shift := Shift + 8;
      end loop;
      return R;
   end SArray_Tail_to_U64_LE;

   --------------
   -- SipRound --
   --------------

   procedure Sip_Round (v : in out SipHash_State) is
   begin
      v(0) := v(0) + v(1);
      v(2) := v(2) + v(3);
      v(1) := Rotate_Left(v(1), 13);
      v(3) := Rotate_Left(v(3), 16);
      v(1) := v(1) xor v(0);
      v(3) := v(3) xor v(2);
      v(0) := Rotate_Left(v(0), 32);

      v(2) := v(2) + v(1);
      v(0) := v(0) + v(3);
      v(1) := Rotate_Left(v(1), 17);
      v(3) := Rotate_Left(v(3), 21);
      v(1) := v(1) xor v(2);
      v(3) := v(3) xor v(0);
      v(2) := Rotate_Left(v(2), 32);
   end Sip_Round;

   ---------------------
   -- SipFinalization --
   ---------------------

   function Sip_Finalization (v : in SipHash_State)
                             return U64 is
      vv : SipHash_State := v;
   begin
      vv(2) := vv(2) xor 16#ff#;
      for I in 1..d_rounds loop
         Sip_Round(vv);
      end loop;
      return (vv(0) xor vv(1) xor vv(2) xor vv(3));
   end Sip_Finalization;

   ------------
   -- SetKey --
   ------------

   procedure Set_Key (k0, k1 : U64) is
   begin
      Initial_State := (k0 xor 16#736f6d6570736575#,
                        k1 xor 16#646f72616e646f6d#,
                        k0 xor 16#6c7967656e657261#,
                        k1 xor 16#7465646279746573#);
   end Set_Key;

   procedure Set_Key (k : SipHash_Key) is
      k0, k1 : U64;
   begin
      k0 := SArray8_to_U64_LE(k(k'First..k'First+7));
      k1 := SArray8_to_U64_LE(k(k'First+8..k'Last));
      Set_Key(k0, k1);
   end Set_Key;

   -------------
   -- SipHash --
   -------------

   function SipHash (m : System.Storage_Elements.Storage_Array)
      return U64
   is
      m_pos : Storage_Offset := 0;
      m_i : U64;
      v : SipHash_State := Initial_State;
      w : constant Storage_Offset := (m'Length / 8) + 1;

   begin

      -- This compile-time check is useful for GNAT but in GNATprove it
      -- currently just generates a warning that it can not yet prove
      -- them correct.
      pragma Warnings (GNATprove, Off, "Compile_Time_Error");
      pragma Compile_Time_Error (System.Storage_Elements.Storage_Element'Size /= 8,
                                 "This implementation of SipHash cannot work " &
                                   "with Storage_Element'Size /= 8.");
      pragma Warnings (GNATprove, On, "Compile_Time_Error");

      for I in 1..w-1 loop
         pragma Loop_Invariant (m_pos = (I - 1) * 8);
         m_i := SArray8_to_U64_LE(m(m'First + m_pos..m'First + m_pos + 7));
         v(3) := v(3) xor m_i;
         for J in 1..c_rounds loop
            Sip_Round(v);
         end loop;
         v(0) := v(0) xor m_i;
         m_pos := m_pos + 8;
      end loop;

      if m_pos < m'Length then
         m_i := SArray_Tail_to_U64_LE(m(m'First + m_pos .. m'Last));
      else
         m_i := 0;
      end if;
      m_i := m_i or Shift_Left(U64(m'Length mod 256), 56);

      v(3) := v(3) xor m_i;
      for J in 1..c_rounds loop
         Sip_Round(v);
      end loop;
      v(0) := v(0) xor m_i;

      return Sip_Finalization(v);
   end SipHash;

end SipHash;
