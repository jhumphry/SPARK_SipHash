-- SipHash.General
-- Implementing SipHash over a general private type

with Ada.Storage_IO, Interfaces;

function SipHash.General (m : T) return Hash_Type is
   package T_Storage is new Ada.Storage_IO(Element_Type => T);
   use T_Storage;
   subtype U64 is Interfaces.Unsigned_64;

   B : Buffer_Type;
   Result : U64;

begin
   Write(B, m);
   Result := SipHash(B);
   return Hash_Type'Mod(Result);
end SipHash.General;
