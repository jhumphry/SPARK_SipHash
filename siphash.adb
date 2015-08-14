-- SipHash
-- an Ada implementation of the algorithm described in
-- "SipHash: a fast short-input PRF"
-- by Jean-Philippe Aumasson and Daniel J. Bernstein

with Interfaces;
use all type Interfaces.Unsigned_64;
with System, System.Storage_Elements;
use all type System.Storage_Elements.Storage_Offset;

package body SipHash is

   -- Short names for fundamental machine types
   subtype U64 is Interfaces.Unsigned_64;
   subtype Storage_Element is System.Storage_Elements.Storage_Element;
   subtype SArray is System.Storage_Elements.Storage_Array;
   subtype SArray_8 is System.Storage_Elements.Storage_Array(0..7);

   -- The state array of the SipHash function
   type SipHash_State is array (Integer range 0..3) of U64;

   function SArray8_to_U64_LE (S : in SArray_8) return U64 with Inline;
   function SArray_to_U64_LE (S : in SArray; Total_Length : in Natural)
                              return U64 with Inline;
   procedure SipRound (v : in out SipHash_State) with Inline;
   function SipFinalization (v : in out SipHash_State) return U64 with Inline;

   -- The initial state from the key passed as generic formal parameters is
   -- stored here, so that static elaboration followed by a call of SetKey
   -- can be used in situations where dynamic elaboration might be a problem.
   initial_v : SipHash_State := (k0 xor 16#736f6d6570736575#,
                                 k1 xor 16#646f72616e646f6d#,
                                 k0 xor 16#6c7967656e657261#,
                                 k1 xor 16#7465646279746573#);

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

   function SArray_to_U64_LE (S : in SArray; Total_Length : in Natural)
                              return U64 is
      R : U64 := 0;
   begin
      case S'Length is
         when 0 =>
            null;
         when 1..7 =>
            declare
               Shift : Natural := 0;
            begin
               for I of S loop
                  R := R or Shift_Left(U64(I), Shift);
                  Shift := Shift + 8;
               end loop;
            end;
         when others =>
            raise Program_Error with "Too many bytes passed...";
      end case;
      R := R or Shift_Left(U64(Total_Length mod 256), 56);
      return R;
   end SArray_to_U64_LE;

   --------------
   -- SipRound --
   --------------

   procedure SipRound (v : in out SipHash_State) is
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
   end SipRound;

   ---------------------
   -- SipFinalization --
   ---------------------

   function SipFinalization (v : in out SipHash_State) return U64 is
   begin
      v(2) := v(2) xor 16#ff#;
      for I in 1..d_rounds loop
         SipRound(v);
      end loop;
      return (v(0) xor v(1) xor v(2) xor v(3));
   end SipFinalization;

   ------------
   -- SetKey --
   ------------

   procedure SetKey (k0, k1 : Interfaces.Unsigned_64) is
   begin
      initial_v := (k0 xor 16#736f6d6570736575#,
                    k1 xor 16#646f72616e646f6d#,
                    k0 xor 16#6c7967656e657261#,
                    k1 xor 16#7465646279746573#);
   end SetKey;

   procedure SetKey (k : System.Storage_Elements.Storage_Array) is
      k0, k1 : U64;
   begin
      pragma Assert(Check => k'Length = 16,
                    Message => "Key must be 16 bytes.");
      k0 := SArray8_to_U64_LE(k(k'First..k'First+7));
      k1 := SArray8_to_U64_LE(k(k'First+8..k'Last));
      SetKey(k0, k1);
   end SetKey;

   -------------
   -- SipHash --
   -------------

   function SipHash (Key : String) return Ada.Containers.Hash_Type is
   begin
      --  Generated stub: replace with real body!
      -- pragma Compile_Time_Warning (Standard.True, "SipHash unimplemented");
      raise Program_Error with "Unimplemented function SipHash";
      return SipHash (Key);
   end SipHash;

   -------------
   -- SipHash --
   -------------

   function SipHash (m : System.Storage_Elements.Storage_Array)
      return Interfaces.Unsigned_64
   is
      m_pos : System.Storage_Elements.Storage_Offset := m'First;
      m_i : U64;
      v : SipHash_State := initial_v;
      w : constant Natural := (m'Length / 8) + 1;
      Result : U64;
   begin
      pragma Assert (Check => Storage_Element'Size = 8,
                     Message => "This implementation of SipHash cannot work " &
                       "with Storage_Element'Size /= 8.");

      for I in 1..w-1 loop
         m_i := SArray8_to_U64_LE(m(m_pos..m_pos+7));
         v(3) := v(3) xor m_i;
         for J in 1..c_rounds loop
            SipRound(v);
         end loop;
         v(0) := v(0) xor m_i;
         m_pos := m_pos + 8;
      end loop;

      m_i := SArray_to_U64_LE(m(m_pos..m'Last), m'Length);
      v(3) := v(3) xor m_i;
      for J in 1..c_rounds loop
         SipRound(v);
      end loop;
      v(0) := v(0) xor m_i;

      Result := SipFinalization(v);
      return Result;
   end SipHash;

end SipHash;
