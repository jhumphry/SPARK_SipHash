-- SipHash.Entropy
-- A child package that attempts to set the key from an entropy source on the
-- system.
-- This implementation loads bytes from the getrandom() function on Linux. This
-- is easier and more reliable than opening the /dev/urandom file.

-- Copyright (c) 2016, James Humphry - see LICENSE file for details

with Interfaces, Interfaces.C;
use Interfaces;

with System;
with System.Storage_Elements;
use System.Storage_Elements;

package body SipHash.Entropy
with SPARK_Mode => Off
is

   function System_Entropy_Source return Boolean is
     (True);

   function wrap_getrandom (buf : System.Address;
                            buflen : C.size_t;
                            flags : C.unsigned
                           ) return C.int;
   pragma Import (C, wrap_getrandom, "wrap_getrandom");

   procedure Set_Key_From_System_Entropy is

      use type Interfaces.C.int;

      Key : aliased SipHash_Key := (others => 0);
      Result : C.int;
   begin

      Result := wrap_getrandom(buf => Key'Address,
                               buflen => Key'Length,
                               flags  => 0);
      -- Note: flags => 0 implies we do not want non-blocking behaviour. Neither
      -- do we desire the system to block the program until more entropy is
      -- gathered (i.e. we are using '/dev/urandom'-like behaviour rather
      -- than '/dev/random'-like behaviour).

      if Result = -1 then
         raise Entropy_Unavailable
           with "The getrandom syscall returned an error";
      elsif Result /= 16 then
         raise Entropy_Unavailable
           with "The getrandom syscall returned the wrong number of bytes";
      elsif (for all I in Key'First+1..Key'Last => Key(I) = Key(Key'First)) then
         raise Entropy_Unavailable
           with "The getrandom syscall returned a constant buffer, probably due to a fault.";
      end if;

      Set_Key(Key);
   end Set_Key_From_System_Entropy;

   procedure Set_Key_From_System_Entropy (Success : out Boolean) is
   begin
      Set_Key_From_System_Entropy;
      Success := True;
   exception
      when Entropy_Unavailable =>
         Success := False;
   end Set_Key_From_System_Entropy;

end SipHash.Entropy;
