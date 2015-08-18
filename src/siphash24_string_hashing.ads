-- SipHash24_String_Hashing
-- Instantiations of SipHash with recommended parameters for the String types
-- in order to replace Ada.Strings.Hash and friends. The key must be set with
-- SetKey before using any of these routines, or there will be no protection
-- from hash flooding attacks.

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

pragma Spark_Mode;

with Ada.Containers;
with Ada.Strings.UTF_Encoding; use Ada.Strings.UTF_Encoding;

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
     with Inline;

   function Wide_String_Hash is
     new SipHash24.Wide_Discrete(T => Wide_Character,
                                 T_Index => Positive,
                                 T_Array => Wide_String,
                                 Hash_Type => Ada.Containers.Hash_Type);

   function Wide_String_Hash_Case_Insensitive (Key : Wide_String)
                                               return Ada.Containers.Hash_Type
     with Inline;

   function Wide_Wide_String_Hash is
     new SipHash24.Wide_Wide_Discrete(T => Wide_Wide_Character,
                                      T_Index => Positive,
                                      T_Array => Wide_Wide_String,
                                      Hash_Type => Ada.Containers.Hash_Type);

   function Wide_Wide_String_Hash_Case_Insensitive (Key : Wide_Wide_String)
                                                    return Ada.Containers.Hash_Type
     with Inline;

   function UTF_8_String_Hash (Key : UTF_8_String)
                               return Ada.Containers.Hash_Type
                               renames String_Hash;

   function UTF_8_String_Hash_Case_Insensitive (Key : UTF_8_String)
                                                return Ada.Containers.Hash_Type
     with Inline;

end SipHash24_String_Hashing;
