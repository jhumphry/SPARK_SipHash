-- HalfSipHash24
-- An instantiation of HalfSipHash with recommended parameters.
-- The key must be set with SetKey before use, or there will be no protection
-- from hash flooding attacks.

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

pragma Spark_Mode;

with HalfSipHash;

pragma Elaborate_All(HalfSipHash);

package HalfSipHash24 is new HalfSipHash(c_rounds => 2,
                                         d_rounds => 4,
                                         k0       => 16#03020100#,
                                         k1       => 16#07060504#);
