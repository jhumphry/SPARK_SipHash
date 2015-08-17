-- SipHash24_String_Hash_Case_Insensitive
-- An instantiation of SipHash with recommended parameters for the String
-- type in order to replace Ada.Strings.Hash_Case_Insensitive. Unfortunately
-- this cannot be a child unit of SipHash24 as it is not an instantiation or
-- renaming. The key must be set with SetKey before use, or there will be no
-- protection from hash flooding attacks.

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

with Ada.Containers;

function SipHash24_String_Hash_Case_Insensitive (Key : String)
                                                 return Ada.Containers.Hash_Type
  with Inline;
