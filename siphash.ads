-- SipHash
-- an Ada implementation of the algorithm described in
-- "SipHash: a fast short-input PRF"
-- by Jean-Philippe Aumasson and Daniel J. Bernstein

with Ada.Containers;
with Interfaces;
with System.Storage_Elements;

generic
   c_rounds, d_rounds : Positive;
   k0 : Interfaces.Unsigned_64 := 16#0706050403020100#;
   k1 : Interfaces.Unsigned_64 := 16#0f0e0d0c0b0a0908#;
package SipHash is

   procedure SetKey (k0, k1 : Interfaces.Unsigned_64);
   -- SetKey changes the key used by the package to generate hash values. It is
   -- particularly useful if you want to avoid dynamic elaboration.

   procedure SetKey (k : System.Storage_Elements.Storage_Array);
   -- SetKey changes the key used by the package to generate hash values. It is
   -- particularly useful if you want to avoid dynamic elaboration.

   function SipHash (Key : String) return Ada.Containers.Hash_Type;
   -- Return the SipHash-c,d of message String Key under the key k0, k1. The
   -- result may be truncated if Ada.Containers.Hash_Type is less than mod
   -- 2**64. The parameter naming is regretable but it matches Ada.Strings.Hash.

   function SipHash (m : System.Storage_Elements.Storage_Array)
                     return Interfaces.Unsigned_64;
   -- This is the full implementation of SipHash, intended to exactly match the
   -- original paper. Ada.Storage_IO can be used to turn private objects into
   -- Storage_Array.

private

   use type Interfaces.Unsigned_64;

   -- The state array of the SipHash function
   type SipHash_State is array (Integer range 0..3) of Interfaces.Unsigned_64;

   -- The initial state from the key passed as generic formal parameters is
   -- stored here, so that static elaboration followed by a call of SetKey
   -- can be used in situations where dynamic elaboration might be a problem.
   initial_v : SipHash_State := (k0 xor 16#736f6d6570736575#,
                                 k1 xor 16#646f72616e646f6d#,
                                 k0 xor 16#6c7967656e657261#,
                                 k1 xor 16#7465646279746573#);

   procedure SipRound (v : in out SipHash_State) with Inline;

   function SipFinalization (v : in out SipHash_State)
                             return Interfaces.Unsigned_64 with Inline;

end SipHash;
