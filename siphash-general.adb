-- SipHash.General
-- Implementing SipHash over a general private type

with Ada.Storage_IO, Interfaces, System.Storage_Elements;

-- Rather than simply writing the object into a buffer and calling the main
-- SipHash routine, this implementation takes advantage of the fact that the
-- padding required is always constant and does not need to be recalculated
-- each time, giving a minor speed increase.

function SipHash.General (m : T) return Hash_Type is

   package T_Storage is new Ada.Storage_IO(Element_Type => T);

   subtype U64 is Interfaces.Unsigned_64;
   use System.Storage_Elements;

   Padded_Blocks : constant Storage_Count := ((T_Storage.Buffer_Size / 8) + 1);
   Padded_Buffer_Size : constant Storage_Count := Padded_Blocks * 8;

   B : Storage_Array(1..Padded_Buffer_Size);
   Result : U64;

   m_pos : Storage_Offset := 1;
   m_i : U64;
   v : SipHash_State := initial_v;

begin

   pragma Assert (Check => Storage_Element'Size = 8,
                  Message => "This implementation of SipHash cannot work " &
                    "with Storage_Element'Size /= 8.");

   T_Storage.Write(Buffer => B(1..T_Storage.Buffer_Size),
                   Item => m);
   B(T_Storage.Buffer_Size + 1 .. B'Last - 1) := (others => 0);
   B(B'Last) := Storage_Element(T_Storage.Buffer_Size mod 256);

   for I in 1..Padded_Blocks loop
      m_i := SArray8_to_U64_LE(B(m_pos..m_pos+7));
      v(3) := v(3) xor m_i;
      for J in 1..c_rounds loop
         SipRound(v);
      end loop;
      v(0) := v(0) xor m_i;
      m_pos := m_pos + 8;
   end loop;

   Result := SipFinalization(v);

   return Hash_Type'Mod(Result);
end SipHash.General;
