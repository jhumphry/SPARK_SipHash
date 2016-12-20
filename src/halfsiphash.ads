-- HalfSipHash
-- A 32-bit friendly version of SipHash, the algorithm described in
-- "SipHash: a fast short-input PRF"
-- by Jean-Philippe Aumasson and Daniel J. Bernstein

-- Half Siphash was designed by Jean-Philippe Aumasson but is not yet documented
-- in a paper. This implementation is based on the reference code.

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with Interfaces;
with System.Storage_Elements;
use type System.Storage_Elements.Storage_Offset;

generic
   c_rounds, d_rounds : Positive;
   k0 : Interfaces.Unsigned_32 := 16#03020100#;
   k1 : Interfaces.Unsigned_32 := 16#07060504#;
package HalfSipHash with
SPARK_Mode,
Abstract_State => (Initial_Hash_State),
  Initializes => (Initial_Hash_State)
is

   subtype U32 is Interfaces.Unsigned_32;

   subtype HalfSipHash_Key is System.Storage_Elements.Storage_Array(1..8);

   procedure Set_Key (k0, k1 : U32)
     with Global => (Output => Initial_Hash_State);
   -- SetKey changes the key used by the package to generate hash values. It is
   -- particularly useful if you want to avoid dynamic elaboration.

   procedure Set_Key (k : HalfSipHash_Key)
     with Pre => (k'Length = 8), Global => (Output => Initial_Hash_State);
   -- SetKey changes the key used by the package to generate hash values. It is
   -- particularly useful if you want to avoid dynamic elaboration.

   function HalfSipHash (m : System.Storage_Elements.Storage_Array) return U32
     with Pre => (m'Length < System.Storage_Elements.Storage_Offset'Last),
     Global => (Input => Initial_Hash_State);
   -- This is the full implementation of HalfSipHash, intended to exactly
   -- match the reference code. The precondition looks odd, but it is
   -- because Storage_Array is defined with an unconstrained index across
   -- Storage_Offset, which is a signed value. This means that an array from
   -- Storage_Offset'First to Storage_Offset'Last would have too long a length
   -- for calculations to be done in a Storage_Offset variable.

private

   use all type Interfaces.Unsigned_32;

   -- The state array of the SipHash function
   type HalfSipHash_State is array (Integer range 0..3) of U32;

   function Get_Initial_State return HalfSipHash_State
     with Inline, Global => (Input => Initial_Hash_State);

   subtype SArray is System.Storage_Elements.Storage_Array;
   subtype SArray_4 is System.Storage_Elements.Storage_Array(0..3);

   function SArray4_to_U32_LE (S : in SArray_4) return U32
     with Inline;

   function SArray_Tail_to_U32_LE (S : in SArray)
                                   return U32
     with Inline, Pre => (S'Length <= 3 and then S'Length > 0);

   procedure Sip_Round (v : in out HalfSipHash_State) with Inline;

   function Sip_Finalization (v : in HalfSipHash_State)
                             return U32 with Inline;

end HalfSipHash;
