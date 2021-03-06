-- SipHash
-- an Ada implementation of the algorithm described in
-- "SipHash: a fast short-input PRF"
-- by Jean-Philippe Aumasson and Daniel J. Bernstein

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

with Interfaces;
with System.Storage_Elements;
use type System.Storage_Elements.Storage_Offset;

generic
   c_rounds, d_rounds : Positive;
   k0 : Interfaces.Unsigned_64 := 16#0706050403020100#;
   k1 : Interfaces.Unsigned_64 := 16#0f0e0d0c0b0a0908#;
package SipHash with
SPARK_Mode,
Abstract_State => (Initial_Hash_State),
  Initializes => (Initial_Hash_State)
is

   subtype U64 is Interfaces.Unsigned_64;

   subtype SipHash_Key is System.Storage_Elements.Storage_Array(1..16);

   procedure Set_Key (k0, k1 : U64)
     with Global => (Output => Initial_Hash_State);
   -- SetKey changes the key used by the package to generate hash values. It is
   -- particularly useful if you want to avoid dynamic elaboration.

   procedure Set_Key (k : SipHash_Key)
     with Pre => (k'Length = 16), Global => (Output => Initial_Hash_State);
   -- SetKey changes the key used by the package to generate hash values. It is
   -- particularly useful if you want to avoid dynamic elaboration.

   function SipHash (m : System.Storage_Elements.Storage_Array) return U64
     with Pre => (if m'First <= 0 then
                    (Long_Long_Integer (m'Last) < Long_Long_Integer'Last +
                         Long_Long_Integer (m'First))
                 ),
     Global => (Input => Initial_Hash_State);
   -- This is the full implementation of SipHash, intended to exactly match
   -- the original paper. The precondition looks odd, but it is because
   -- Storage_Array is defined with an unconstrained index across
   -- Storage_Offset, which is a signed value. This means that an array from
   -- Storage_Offset'First to Storage_Offset'Last would have too long a length
   -- for calculations to be done in a Storage_Offset variable.

private

   use all type Interfaces.Unsigned_64;

   -- The state array of the SipHash function
   type SipHash_State is array (Integer range 0..3) of U64;

   function Get_Initial_State return SipHash_State
     with Inline, Global => (Input => Initial_Hash_State);

   subtype SArray is System.Storage_Elements.Storage_Array;
   subtype SArray_8 is System.Storage_Elements.Storage_Array(0..7);

   function SArray8_to_U64_LE (S : in SArray_8) return U64
     with Inline;

   function SArray_Tail_to_U64_LE (S : in SArray)
                                   return U64
     with Inline,
     Pre => (if S'First <= 0 then
               (
                (Long_Long_Integer (S'Last) < Long_Long_Integer'Last +
                  Long_Long_Integer (S'First))
                and then
                  S'Length in 1..7
               )
                 else
                   S'Length in 1..7
            );

   procedure Sip_Round (v : in out SipHash_State) with Inline;

   function Sip_Finalization (v : in SipHash_State)
                             return U64 with Inline;

end SipHash;
