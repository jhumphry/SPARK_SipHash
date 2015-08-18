-- SipHash24.System_Entropy
-- An instantiation of SipHash.Entropy to allow the SipHash key to be set from
-- a system entropy source (if possible).

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

pragma Spark_Mode (On);

with SipHash.Entropy;

pragma Elaborate_All(SipHash.Entropy);

package SipHash24.System_Entropy is new SipHash24.Entropy;
