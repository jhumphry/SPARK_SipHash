-- Half_SipHash24
-- An instantiation of Half_SipHash with recommended parameters.
-- The key must be set with SetKey before use, or there will be no protection
-- from hash flooding attacks.

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

pragma Spark_Mode;

with Half_SipHash;

pragma Elaborate_All(Half_SipHash);

package Half_SipHash24 is new Half_SipHash(c_rounds => 2,
                                           d_rounds => 4,
                                           k0       => 16#03020100#,
                                           k1       => 16#07060504#);
