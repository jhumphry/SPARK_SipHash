-- SipHash.General_SPARK
-- Implementing SipHash over a general private type

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

with Integer_Storage_IO;

-- This generic function will calculate SipHash for any private type of definite
-- size
generic
   type T is private;
   type Hash_Type is mod <>;
   Buffer_Size : System.Storage_Elements.Storage_Count;
   with procedure Write(Buffer : out System.Storage_Elements.Storage_Array;
                        Item : in T);
function SipHash.General_SPARK (m : T) return Hash_Type
  with Global => (Input => (Initial_Hash_State, Integer_Storage_IO.Heap));

-- gnatprove insists on a Global referencing a Integer_Storage_IO.Heap
-- abstract state, even though this is supposed to be generic and not tied
-- to Integer_Storage_IO.
