-- Example_Hashed_Maps
-- An example of using SipHash with the Ada.Containers.Indefinite_Hashed_Maps

-- Copyright (c) 2015, James Humphry - see LICENSE file for details

with Ada.Containers, Ada.Containers.Indefinite_Hashed_Maps;

with Ada.Text_IO; use Ada.Text_IO;

with Ada.Strings.UTF_Encoding;
use Ada.Strings.UTF_Encoding;

with SipHash24, SipHash24_String_Hashing, SipHash24.System_Entropy;

procedure Example_Hashed_Maps is

   package String_Maps is
     new Ada.Containers.Indefinite_Hashed_Maps(Key_Type        => String,
                                               Element_Type    => String,
                                               Hash            => SipHash24_String_Hashing.String_Hash,
                                               Equivalent_Keys => "=",
                                               "="             => "=");

   package UTF8_Maps is
     new Ada.Containers.Indefinite_Hashed_Maps(Key_Type        => UTF_8_String,
                                               Element_Type    => UTF_8_String,
                                               Hash            => SipHash24_String_Hashing.UTF_8_String_Hash,
                                               Equivalent_Keys => "=",
                                               "="             => "=");

   subtype Count_Type is Ada.Containers.Count_Type;

   Example_Map : String_Maps.Map;
   Example_UTF8_Map : UTF8_Maps.Map;

begin

   Put_Line("An example of using SipHash with Ada.Containers.Indefinite_Hashed_Maps");
   New_Line;

   declare
      Seeded : Boolean;
   begin
      SipHash24.System_Entropy.Set_Key_From_System_Entropy(Seeded);
      if Seeded then
         Put_Line("SipHash key set from system entropy source.");
      else
         Put_Line("No system entropy was available to set SipHash key. Note " &
                    "that this undermines the hash flooding protection "&
                    "supposed to be provided by SipHash.");
      end if;
   end;
   New_Line;

   Put_Line("Using regular string maps.");
   Put_Line("Adding keys foo -> bar, cat -> dog, alice -> bob, UK -> London.");
   Example_Map.Insert("foo", "bar");
   Example_Map.Insert("cat", "dog");
   Example_Map.Insert("alice", "bob");
   Example_Map.Insert("UK", "London");
   New_Line;

   Put_Line("Length of map : "
            & Count_Type'Image(Example_Map.Length));
   New_Line;

   Put_Line("Now reading out key-element pairs:");
   for I in Example_Map.Iterate loop
      Put_Line(String_Maps.Key(I) & " -> " & String_Maps.Element(I));
   end loop;
   New_Line;

   Put_Line("Using UTF8 string maps.");
   Put_Line("Adding keys Türkiye Cumhuriyeti -> Ankara, 中国 -> 北京, UK -> London.");
   Example_UTF8_Map.Insert("Türkiye Cumhuriyeti", "Ankara");
   Example_UTF8_Map.Insert("中国", "北京");
   Example_UTF8_Map.Insert("UK", "London");
   New_Line;

   Put_Line("Retrieving the value for key '中国': "
            & Example_UTF8_Map("中国"));
   New_Line;

   Put_Line("Now reading out key-element pairs:");
   for I in Example_UTF8_Map.Iterate loop
      Put_Line(UTF8_Maps.Key(I) & " -> " & UTF8_Maps.Element(I));
   end loop;
   New_Line;

end Example_Hashed_Maps;
