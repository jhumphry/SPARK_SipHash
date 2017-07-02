-- Integer_Storage_IO
-- A re-implementation of Storage_IO for Integers with SPARK_Mode turned on in
-- the specification and off in the body.

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

with System.Storage_Elements;

pragma Warnings (Off, "no procedure exists that can initialize abstract state");
-- The references to the Heap as an Abstract_State of the package are necessary
-- for SPARK GPL 2016 but cause a (non-fatal) warning in SPARK Discovery GPL
-- 2017.

package Integer_Storage_IO
with SPARK_Mode => On,
  Abstract_State => Heap -- This is necessary for SPARK GPL 2016
is

   pragma Warnings (On, "no procedure exists that can initialize abstract state");

   use type System.Storage_Elements.Storage_Offset;

   Buffer_Size : constant System.Storage_Elements.Storage_Count :=
     (Integer'Size + 7) / 8;

   subtype Buffer_Type is
      System.Storage_Elements.Storage_Array(1..Buffer_Size);

   procedure Read (Buffer : in  Buffer_Type; Item : out Integer);

   procedure Write(Buffer : out Buffer_Type; Item : in  Integer)
   with Global => (Input => Heap);

end Integer_Storage_IO;
