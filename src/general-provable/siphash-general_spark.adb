-- SipHash.General_SPARK
-- Implementing SipHash over a general private type

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

with System.Storage_Elements;

-- Rather than simply writing the object into a buffer and calling the main
-- SipHash routine, this implementation takes advantage of the fact that the
-- padding required is always constant and does not need to be recalculated
-- each time, giving a minor speed increase.

function SipHash.General_SPARK (m : T) return Hash_Type is

   use System.Storage_Elements;

   Padded_Blocks : constant Storage_Count := ((Buffer_Size / 8) + 1);
   Padded_Buffer_Size : constant Storage_Count := Padded_Blocks * 8;

   B : Storage_Array(1..Padded_Buffer_Size) := (others => 0);

   m_pos : Storage_Offset := 1;
   m_i : U64;
   v : SipHash_State := Get_Initial_State;

begin

   -- This compile-time check is useful for GNAT but in GNATprove it currently
   -- just generates a warning that it can not yet prove them correct.
   pragma Warnings (GNATprove, Off, "Compile_Time_Error");
   pragma Compile_Time_Error (Storage_Element'Size /= 8,
                              "This implementation of SipHash cannot work " &
                                "with Storage_Element'Size /= 8.");
   pragma Warnings (GNATprove, On, "Compile_Time_Error");

   Write(Buffer => B(1..Buffer_Size),
         Item => m);

   B(B'Last) := Storage_Element(Buffer_Size mod 256);

   for I in 1..Padded_Blocks loop
      pragma Loop_Invariant (m_pos = (I-1) * 8 + 1);
      m_i := SArray8_to_U64_LE(B(m_pos..m_pos+7));
      v(3) := v(3) xor m_i;
      for J in 1..c_rounds loop
         Sip_Round(v);
      end loop;
      v(0) := v(0) xor m_i;
      m_pos := m_pos + 8;
   end loop;

   return Hash_Type'Mod(Sip_Finalization(v));
end SipHash.General_SPARK;
