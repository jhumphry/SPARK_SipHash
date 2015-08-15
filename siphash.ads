-- SipHash
-- an Ada implementation of the algorithm described in
-- "SipHash: a fast short-input PRF"
-- by Jean-Philippe Aumasson and Daniel J. Bernstein

with Interfaces;
with System.Storage_Elements;

generic
   c_rounds, d_rounds : Positive;
   k0 : Interfaces.Unsigned_64 := 16#0706050403020100#;
   k1 : Interfaces.Unsigned_64 := 16#0f0e0d0c0b0a0908#;
package SipHash with
SPARK_Mode,
Abstract_State => (State),
  Initializes => (State)
is

   subtype U64 is Interfaces.Unsigned_64;

   procedure SetKey (k0, k1 : U64)
     with Global => (Output => State);
   -- SetKey changes the key used by the package to generate hash values. It is
   -- particularly useful if you want to avoid dynamic elaboration.

   procedure SetKey (k : System.Storage_Elements.Storage_Array)
     with Pre => (k'Length = 16), Global => (Output => State);
   -- SetKey changes the key used by the package to generate hash values. It is
   -- particularly useful if you want to avoid dynamic elaboration.

   function SipHash (m : System.Storage_Elements.Storage_Array) return U64
     with Global => (Input => State);
   -- This is the full implementation of SipHash, intended to exactly match the
   -- original paper. Ada.Storage_IO can be used to turn private objects into
   -- Storage_Array.

private

   use all type Interfaces.Unsigned_64;

   -- The state array of the SipHash function
   type SipHash_State is array (Integer range 0..3) of U64;

   function Get_Initial_State return SipHash_State
     with Inline, Global => (Input => State);

   subtype SArray is System.Storage_Elements.Storage_Array;
   subtype SArray_8 is System.Storage_Elements.Storage_Array(0..7);

   function SArray8_to_U64_LE (S : in SArray_8) return U64
     with Inline;

   function SArray_Tail_to_U64_LE (S : in SArray; Total_Length : in Natural)
                                   return U64
     with Inline, Pre => (S'Length <= 7);

   procedure SipRound (v : in out SipHash_State) with Inline;

   function SipFinalization (v : in SipHash_State)
                             return U64 with Inline;

end SipHash;
