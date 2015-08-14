-- SipHash
-- an Ada implementation of the algorithm described in
-- "SipHash: a fast short-input PRF"
-- by Jean-Philippe Aumasson and Daniel J. Bernstein

with Ada.Containers;
with Interfaces;
with System.Storage_Elements;

generic
   c_rounds, d_rounds : Positive;
   k0, k1 : Interfaces.Unsigned_64;
package SipHash is

   procedure SetKey (k0, k1 : Interfaces.Unsigned_64);
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

end SipHash;
