-- SipHash.Entropy
-- A child package that attempts to set the key from an entropy source on the
-- system.
-- This implementation is for systems where no entropy is available.

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

package body SipHash.Entropy
with SPARK_Mode => Off
is

   function System_Entropy_Source return Boolean is
     (False);

   procedure Set_Key_From_System_Entropy is
   begin
      raise Entropy_Unavailable
        with "System entropy not available on this system";
   end Set_Key_From_System_Entropy;

   procedure Set_Key_From_System_Entropy (Success : out Boolean) is
   begin
      Success := False;
   end Set_Key_From_System_Entropy;

end SipHash.Entropy;
