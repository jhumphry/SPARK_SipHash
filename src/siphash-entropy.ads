-- SipHash.Entropy
-- A child package that attempts to set the key from an entropy source on the
-- system. There are various different implementations of this that are selected
-- at compile-time.

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

generic
package SipHash.Entropy
with SPARK_Mode => On
is

   Entropy_Unavailable : exception;

   -- This function indicates whether the program has been compiled with the
   -- possibility to set the SipHash key from system entropy. Note that even
   -- if this returns true it is still possible for Set_Key_From_System_Entropy
   -- to fail, for example if there is an IO error or the system declines to
   -- provide enough entropy.
   function System_Entropy_Source return Boolean;

   -- This procedure will set the SipHash key from a system entropy source,
   -- unless System_Entropy_Source is False or the system returns insufficient
   -- data, in which case it will raise No_Entropy_Available.
   procedure Set_Key_From_System_Entropy
     with Global => (Output => Initial_Hash_State);

   -- This procedure will set the SipHash key from a system entropy source,
   -- returning a boolean to indicate if it was successful. Failure can be
   -- caused by having no entropy source compiled into the library, or by an
   -- inability to retrieve sufficient data from the system.
   -- It would be nice to make this a function, but functions with side effects
   -- are not permitted by SPARK.
   procedure Set_Key_From_System_Entropy (Success : out Boolean)
     with Global => (Output => Initial_Hash_State);

end SipHash.Entropy;
