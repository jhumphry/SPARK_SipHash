-- SipHash24_String_Hashing
-- Instantiations of SipHash with recommended parameters for the String types
-- in order to replace Ada.Strings.Hash and friends. The key must be set with
-- SetKey before using any of these routines, or there will be no protection
-- from hash flooding attacks.

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

pragma Spark_Mode;

with Ada.Characters.Handling, Ada.Wide_Characters.Handling;
with Ada.Wide_Wide_Characters.Handling, Ada.Containers;

with SipHash24;
with SipHash.Discrete, SipHash.Wide_Discrete, SipHash.Wide_Wide_Discrete;

pragma Elaborate_All(SipHash.Discrete,
                     SipHash.Wide_Discrete,
                     SipHash.Wide_Wide_Discrete);

package SipHash24_String_Hashing is

   function String_Hash is
     new SipHash24.Discrete(T => Character,
                            T_Index => Positive,
                            T_Array => String,
                            Hash_Type => Ada.Containers.Hash_Type);

   function String_Hash_Case_Insensitive (Key : String)
                                          return Ada.Containers.Hash_Type
   is
     (String_Hash(Ada.Characters.Handling.To_Lower(Key)))
   with Inline;

   function Wide_String_Hash is
     new SipHash24.Wide_Discrete(T => Wide_Character,
                                 T_Index => Positive,
                                 T_Array => Wide_String,
                                 Hash_Type => Ada.Containers.Hash_Type);

   function Wide_String_Hash_Case_Insensitive (Key : Wide_String)
                                               return Ada.Containers.Hash_Type
   is
     (Wide_String_Hash(Ada.Wide_Characters.Handling.To_Lower(Key)))
   with Inline;

   function Wide_Wide_String_Hash is
     new SipHash24.Wide_Wide_Discrete(T => Wide_Wide_Character,
                                      T_Index => Positive,
                                      T_Array => Wide_Wide_String,
                                      Hash_Type => Ada.Containers.Hash_Type);

   function Wide_Wide_String_Hash_Case_Insensitive (Key : Wide_Wide_String)
                                                    return Ada.Containers.Hash_Type
   is
     (Wide_Wide_String_Hash(Ada.Wide_Wide_Characters.Handling.To_Lower(Key)))
   with Inline;

end SipHash24_String_Hashing;
