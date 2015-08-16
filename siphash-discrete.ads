-- SipHash.Discrete
-- Implementing SipHash over a generic discrete type

-- This generic function will calculate SipHash over arrays of a discrete type
-- indexed by an integer type, such as the standard String type. The range of
-- values of the discrete type needs to fit in 8 bits.
generic
   type T is (<>);
   type T_Index is range <>;
   type T_Array is array (T_Index range <>) of T;
   type Hash_Type is mod <>;
function SipHash.Discrete (m : T_Array) return Hash_Type
  with SPARK_Mode,
  Global => (Input => Initial_Hash_State);
