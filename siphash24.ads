-- SipHash24
-- An instantiation of SipHash with recommended parameters.
-- The key must be set with SetKey before use, or there will be no protection
-- from hash flooding attacks.

pragma Spark_Mode;

with SipHash;

pragma Elaborate_All(SipHash);

package SipHash24 is new SipHash(c_rounds => 2,
                                 d_rounds => 4,
                                 k0       => 16#0706050403020100#,
                                 k1       => 16#0f0e0d0c0b0a0908#);
