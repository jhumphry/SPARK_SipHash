-- SipHash.Entropy
-- A child package that attempts to set the key from an entropy source on the
-- system.
-- This implementation loads bytes from /dev/urandom on Linux/Unix-like systems.

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

with Ada.Streams, Ada.Streams.Stream_IO;
use Ada.Streams;
with System.Storage_Elements;
use System.Storage_Elements;

package body SipHash.Entropy
with SPARK_Mode => Off
is

   pragma Compile_Time_Error (Storage_Element'Size > Stream_Element'Size,
                              "Cannot read entropy from /dev/urandom due to "&
                                "mis-matched Storage_Element'Size and "&
                                "Stream_Element'Size");

   function System_Entropy_Source return Boolean is
     (True);

   procedure Set_Key_From_System_Entropy is
      use Ada.Streams.Stream_IO;

      Key : SipHash_Key;
      Buffer : Stream_Element_Array(1..16);
      Last : Stream_Element_Offset;

      Dev_Urandom : File_Type;
   begin
      begin
         Open(File => Dev_Urandom,
              Mode => In_File,
              Name => "/dev/urandom");
         Read(File => Dev_Urandom,
              Item => Buffer,
              Last => Last);
      exception
         when others =>
            raise Entropy_Unavailable
              with "IO error when reading /dev/urandom.";
      end;

      if Last /= 16 then
         raise Entropy_Unavailable
           with "Insufficient entropy read from /dev/urandom.";
      end if;

      for I in Key'Range loop
         Key(I) := Storage_Element'Mod(Buffer(Stream_Element_Offset(I)));
      end loop;

      Set_Key(Key);

   end Set_Key_From_System_Entropy;

end SipHash.Entropy;
