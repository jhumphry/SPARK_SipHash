-- SipHash24_C
-- an Ada specification for the reference C implementation of SipHash

with Interfaces, Interfaces.C;
use Interfaces;

package SipHash24_c is

   subtype U8 is Interfaces.Unsigned_8;
   subtype U64 is Interfaces.Unsigned_64;
   type U8_Array is array (Natural range <>) of aliased U8;
   subtype U8_Array8 is U8_Array(0..7);

   function C_SipHash24
     (c_out : access Interfaces.Unsigned_8;
      c_in : access Interfaces.Unsigned_8;
      inlen : Interfaces.Unsigned_64;
      k : access Interfaces.Unsigned_8) return C.int;
   pragma Import (C, C_SipHash24, "siphash");

   function U8_Array8_to_U64 (c : U8_Array8) return U64 is
     (U64(c(0))
      or Shift_Left(U64(c(1)), 8)
      or Shift_Left(U64(c(2)), 16)
      or Shift_Left(U64(c(3)), 24)
      or Shift_Left(U64(c(4)), 32)
      or Shift_Left(U64(c(5)), 40)
      or Shift_Left(U64(c(6)), 48)
      or Shift_Left(U64(c(7)), 56));

end SipHash24_c;
