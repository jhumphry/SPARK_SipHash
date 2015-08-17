-- SipHash24.Integer_Hash
-- An instantiation of SipHash for the Integer type. Not much use other than as
-- a base for running gnatprove

pragma Spark_Mode;

with Ada.Containers;
with SipHash.General_SPARK;
with Integer_Storage_IO;

pragma Elaborate_All(SipHash.General_SPARK);

function SipHash24.Integer_Hash is
     new SipHash24.General_SPARK(T => Integer,
                                 Hash_Type => Ada.Containers.Hash_Type,
                                 Buffer_Size => Integer_Storage_IO.Buffer_Size,
                                 Write => Integer_Storage_IO.Write);
