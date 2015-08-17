-- SipHash.General
-- Implementing SipHash over a general private type

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

-- This generic function will calculate SipHash for any private type of definite
-- size
generic
   type T is private;
   type Hash_Type is mod <>;
function SipHash.General (m : T) return Hash_Type
  with Global => (Input => Initial_Hash_State);
