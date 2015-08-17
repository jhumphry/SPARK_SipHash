-- Integer_Storage_IO
-- A re-implementation of Storage_IO for Integers with SPARK_Mode turned on in
-- the specification and off in the body.

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

with Ada.Unchecked_Conversion;

package body Integer_Storage_IO
with SPARK_Mode => Off
is

   type Integer_Access is access all Integer;
   type Storage_Element_Access is access all System.Storage_Elements.Storage_Element;

   function SEA_to_ETA is
     new Ada.Unchecked_Conversion(Source => Storage_Element_Access,
                                  Target => Integer_Access);

   procedure Read (Buffer : in  Buffer_Type; Item : out Integer) is
      B : aliased Buffer_Type := Buffer;
      B_Access : constant Storage_Element_Access := B(1)'Unchecked_Access;
      B_Access_As_ETA : constant Integer_Access := SEA_to_ETA(B_Access);
   begin
      Item := B_Access_As_ETA.all;
   end Read;

   procedure Write(Buffer : out Buffer_Type; Item : in  Integer) is
      B : aliased Buffer_Type;
      B_Access : constant Storage_Element_Access := B(1)'Unchecked_Access;
      B_Access_As_ETA : constant Integer_Access := SEA_to_ETA(B_Access);
   begin
      B_Access_As_ETA.all := Item;
      Buffer := B;
   end Write;

end Integer_Storage_IO;
