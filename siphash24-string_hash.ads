-- SipHash24.String_Hash
-- An instantiation of SipHash with recommended parameters for the String type
-- in order to replace Ada.Strings.Hash.
-- The key must be set with SetKey before use, or there will be no protection
-- from hash flooding attacks.

pragma Spark_Mode;

with Ada.Containers;
with SipHash.Discrete;

pragma Elaborate_All(SipHash.Discrete);

function SipHash24.String_Hash is
     new SipHash24.Discrete(T => Character,
                            T_Index => Positive,
                            T_Array => String,
                            Hash_Type => Ada.Containers.Hash_Type);
