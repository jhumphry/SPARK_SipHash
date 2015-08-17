-- SipHash24.System_Entropy
-- An instantiation of SipHash.Entropy to allow the SipHash key to be set from
-- a system entropy source (if possible).

pragma Spark_Mode (Off);

with SipHash.Entropy;

package SipHash24.System_Entropy is new SipHash24.Entropy;
