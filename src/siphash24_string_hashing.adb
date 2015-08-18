-- SipHash24_String_Hashing
-- Instantiations of SipHash with recommended parameters for the String types
-- in order to replace Ada.Strings.Hash and friends.

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

pragma Spark_Mode;

with Ada.Characters.Handling, Ada.Wide_Characters.Handling;
with Ada.Wide_Wide_Characters.Handling;
with Ada.Strings.UTF_Encoding.Wide_Wide_Strings;

package body SipHash24_String_Hashing is

   function String_Hash_Case_Insensitive (Key : String)
                                          return Ada.Containers.Hash_Type
   is
     (String_Hash(Ada.Characters.Handling.To_Lower(Key)));

   function Wide_String_Hash_Case_Insensitive (Key : Wide_String)
                                               return Ada.Containers.Hash_Type
   is
     (Wide_String_Hash(Ada.Wide_Characters.Handling.To_Lower(Key)));

   function Wide_Wide_String_Hash_Case_Insensitive (Key : Wide_Wide_String)
                                                    return Ada.Containers.Hash_Type
   is
     (Wide_Wide_String_Hash(Ada.Wide_Wide_Characters.Handling.To_Lower(Key)));

   function UTF_8_String_Hash_Case_Insensitive
     (Key : UTF_8_String)
      return Ada.Containers.Hash_Type is
      Decoded_String : constant Wide_Wide_String
        := Ada.Wide_Wide_Characters.Handling.To_Lower(Ada.Strings.UTF_Encoding.Wide_Wide_Strings.Decode(Key));
   begin
      return Wide_Wide_String_Hash(Decoded_String);
   end UTF_8_String_Hash_Case_Insensitive;

end SipHash24_String_Hashing;
