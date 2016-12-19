-- Half SipHash
-- A 32-bit friendly version of SipHash, the algorithm described in
-- "SipHash: a fast short-input PRF"
-- by Jean-Philippe Aumasson and Daniel J. Bernstein

-- Half Siphash was designed by Jean-Philippe Aumasson but is not yet documented
-- in a paper. This implementation is based on the reference code.

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with System;

package body Half_SipHash with
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
   Initial_State : Half_SipHash_State := (k0,
                                          k1,
                                          k0 xor 16#6c796765#,
                                          k1 xor 16#74656462#);

   -----------------------
   -- Get_Initial_State --
   -----------------------

   function Get_Initial_State return Half_SipHash_State is
      (Initial_State);

   -----------------------
   -- SArray4_to_U32_LE --
   -----------------------

   function SArray4_to_U32_LE (S : in SArray_4) return U32 is
     (U32(S(0))
      or Shift_Left(U32(S(1)), 8)
      or Shift_Left(U32(S(2)), 16)
      or Shift_Left(U32(S(3)), 24));

   ---------------------------
   -- SArray_Tail_to_U32_LE --
   ---------------------------

   function SArray_Tail_to_U32_LE (S : in SArray)
                              return U32 is
      R : U32 := 0;
      Shift : Natural := 0;
   begin
      for I in 0..(S'Length-1) loop
         pragma Loop_Invariant (Shift = I * 8);
         R := R or Shift_Left(U32(S(S'First + Storage_Offset(I))), Shift);
         Shift := Shift + 8;
      end loop;
      return R;
   end SArray_Tail_to_U32_LE;

   --------------
   -- SipRound --
   --------------

   procedure Sip_Round (v : in out Half_SipHash_State) is
   begin
      v(0) := v(0) + v(1);
      v(1) := Rotate_Left(v(1), 5);
      v(1) := v(1) xor v(0);
      v(0) := Rotate_Left(v(0), 16);
      v(2) := v(2) + v(3);
      v(3) := Rotate_Left(v(3), 8);
      v(3) := v(3) xor v(2);
      v(0) := v(0) + v(3);
      v(3) := Rotate_Left(v(3), 7);
      v(3) := v(3) xor v(0);
      v(2) := v(2) + v(1);
      v(1) := Rotate_Left(v(1), 13);
      v(1) := v(1) xor v(2);
      v(2) := Rotate_Left(v(2), 16);
   end Sip_Round;

   ---------------------
   -- SipFinalization --
   ---------------------

   function Sip_Finalization (v : in Half_SipHash_State)
                             return U32 is
      vv : Half_SipHash_State := v;
   begin
      vv(2) := vv(2) xor 16#ff#;
      for I in 1..d_rounds loop
         Sip_Round(vv);
      end loop;
      return (vv(1) xor vv(3));
   end Sip_Finalization;

   ------------
   -- SetKey --
   ------------

   procedure Set_Key (k0, k1 : U32) is
   begin
      Initial_State := (k0,
                        k1,
                        k0 xor 16#6c796765#,
                        k1 xor 16#74656462#);
   end Set_Key;

   procedure Set_Key (k : Half_SipHash_Key) is
      k0, k1 : U32;
   begin
      k0 := SArray4_to_U32_LE(k(k'First..k'First+3));
      k1 := SArray4_to_U32_LE(k(k'First+4..k'Last));
      Set_Key(k0, k1);
   end Set_Key;

   ------------------
   -- Half_SipHash --
   ------------------

   function Half_SipHash (m : System.Storage_Elements.Storage_Array)
      return U32
   is
      m_pos : Storage_Offset := 0;
      m_i : U32;
      v : Half_SipHash_State := Initial_State;
      w : constant Storage_Offset := (m'Length / 4) + 1;

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
         pragma Loop_Invariant (m_pos = (I - 1) * 4);
         m_i := SArray4_to_U32_LE(m(m'First + m_pos..m'First + m_pos + 3));
         v(3) := v(3) xor m_i;
         for J in 1..c_rounds loop
            Sip_Round(v);
         end loop;
         v(0) := v(0) xor m_i;
         m_pos := m_pos + 4;
      end loop;

      if m_pos < m'Length then
         m_i := SArray_Tail_to_U32_LE(m(m'First + m_pos .. m'Last));
      else
         m_i := 0;
      end if;
      m_i := m_i or Shift_Left(U32(m'Length mod 256), 24);

      v(3) := v(3) xor m_i;
      for J in 1..c_rounds loop
         Sip_Round(v);
      end loop;
      v(0) := v(0) xor m_i;

      return Sip_Finalization(v);
   end Half_SipHash;

end Half_SipHash;
