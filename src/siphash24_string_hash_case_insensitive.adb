-- SipHash24_String_Hash_Case_Insensitive
-- An instantiation of SipHash with recommended parameters for the String type
-- in order to replace Ada.Strings.Hash_Case_Insensitive.
-- The key must be set with SetKey before use, or there will be no protection
-- from hash flooding attacks.

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

with Ada.Characters.Handling;

with SipHash24.String_Hash;

function SipHash24_String_Hash_Case_Insensitive (Key : String)
                                                 return Ada.Containers.Hash_Type
is
begin
   return SipHash24.String_Hash(Ada.Characters.Handling.To_Lower(Key));
end SipHash24_String_Hash_Case_Insensitive;
