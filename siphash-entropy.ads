-- SipHash.Entropy
-- A child package that attempts to set the key from an entropy source on the
-- system. There are various different implementations of this that are selected
-- at compile-time.

generic
package SipHash.Entropy is

   Entropy_Unavailable : exception;

   -- This function indicates whether the program has been compiled with the
   -- possibility to set the SipHash key from system entropy. Note that even
   -- if this returns true it is still possible for Set_Key_From_System_Entropy
   -- to fail, for example if there is an IO error or the system declines to
   -- provide enough entropy.
   function System_Entropy_Available return Boolean;

   -- This procedure will set the SipHash key from a system entropy source,
   -- unless System_Entropy_Available is False, in which case it will raise
   -- No_Entropy_Available.
   procedure Set_Key_From_System_Entropy;

end SipHash.Entropy;
