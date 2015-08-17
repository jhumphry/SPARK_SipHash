-- SipHash.Discrete
-- Implementing SipHash over a generic discrete type

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

-- This generic function will calculate SipHash over arrays of a discrete type
-- indexed by an integer type, such as the standard String type. The range of
-- values of the discrete type needs to fit in 8 bits.

pragma SPARK_Mode;

generic
   type T is (<>);
   type T_Index is range <>;
   type T_Array is array (T_Index range <>) of T;
   type Hash_Type is mod <>;
function SipHash.Discrete (m : T_Array) return Hash_Type
  with Global => (Input => Initial_Hash_State);