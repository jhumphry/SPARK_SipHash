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

   -- String_Hash is an instantiation of SipHash.Discrete using the default
   -- SipHash parameters (2,4). It is a drop-in replacement for Ada.Strings.Hash
   -- and can be used with the hashed sets and maps in Ada.Containers. Note
   -- that the SipHash key must be set before this is used to provide protection
   -- against hash flooding attacks.
   function String_Hash is
     new SipHash24.Discrete(T => Character,
                            T_Index => Positive,
                            T_Array => String,
                            Hash_Type => Ada.Containers.Hash_Type);

   -- String_Hash_Case_Insensitive is similar to String_Hash but can be used if
   -- keys of different case are considered equivalent.
   function String_Hash_Case_Insensitive (Key : String)
                                          return Ada.Containers.Hash_Type
     with Inline;

   -- Wide_String_Hash is equivalent to String_Hash but accepts Wide_String
   -- values.
   function Wide_String_Hash is
     new SipHash24.Wide_Discrete(T => Wide_Character,
                                 T_Index => Positive,
                                 T_Array => Wide_String,
                                 Hash_Type => Ada.Containers.Hash_Type);

   -- Wide_String_Hash_Case_Insensitive is equivalent to
   -- String_Hash_Case_Insensitive but accepts Wide_String values.
   function Wide_String_Hash_Case_Insensitive (Key : Wide_String)
                                               return Ada.Containers.Hash_Type
     with Inline;

   -- Wide_Wide_String_Hash is equivalent to String_Hash but accepts
   -- Wide_Wide_String values.
   function Wide_Wide_String_Hash is
     new SipHash24.Wide_Wide_Discrete(T => Wide_Wide_Character,
                                      T_Index => Positive,
                                      T_Array => Wide_Wide_String,
                                      Hash_Type => Ada.Containers.Hash_Type);

   -- Wide_Wide_String_Hash_Case_Insensitive is equivalent to
   -- String_Hash_Case_Insensitive but accepts Wide_Wide_String values.
   function Wide_Wide_String_Hash_Case_Insensitive (Key : Wide_Wide_String)
                                                    return Ada.Containers.Hash_Type
     with Inline;

   -- UTF_8_String_Hash is just a renaming of String_Hash as UTF_8_String is
   -- just a subtype of String.
   function UTF_8_String_Hash (Key : UTF_8_String)
                               return Ada.Containers.Hash_Type
                               renames String_Hash;

   -- UTF_8_String_Hash_Case_Insensitive is not just a renaming of
   -- String_Hash_Case_Insensitive. In order to change the case of the string,
   -- the UTF_8_String is decoded into a Wide_Wide_String (i.e. UCS-4 encoding)
   -- and the result is then hashed directly without re-encoding into UTF-8.
   function UTF_8_String_Hash_Case_Insensitive (Key : UTF_8_String)
                                                return Ada.Containers.Hash_Type
     with Inline;

end SipHash24_String_Hashing;
