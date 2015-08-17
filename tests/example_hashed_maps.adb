-- Example_Hashed_Maps
-- An example of using SipHash with the Ada.Containers.Indefinite_Hashed_Maps

with Ada.Containers, Ada.Containers.Indefinite_Hashed_Maps;

with Ada.Text_IO; use Ada.Text_IO;

with SipHash24, SipHash24.String_Hash;

procedure Example_Hashed_Maps is

   package Maps is
     new Ada.Containers.Indefinite_Hashed_Maps(Key_Type        => String,
                                               Element_Type    => String,
                                               Hash            => SipHash24.String_Hash,
                                               Equivalent_Keys => "=",
                                               "="             => "=");

   subtype Count_Type is Ada.Containers.Count_Type;

   Example_Map : Maps.Map;

begin

   Put_Line("An example of using SipHash with Ada.Containers.Indefinite_Hashed_Maps");
   New_Line;

   -- The key should be set randomly at this point rather than using the default
   -- but we will skip this set for now. Note that with the default key, there
   -- is no additional hash flooding protection from using SipHash over the
   -- implementation default.

   Put_Line("Adding keys foo -> bar, cat -> dog, alice -> bob, England -> London.");
   Example_Map.Insert("foo", "bar");
   Example_Map.Insert("cat", "dog");
   Example_Map.Insert("alice", "bob");
   Example_Map.Insert("England", "London");
   New_Line;

   Put_Line("Length of map : "
            & Count_Type'Image(Example_Map.Length));
   New_Line;

   Put_Line("Now reading out key-element pairs:");
   for I in Example_Map.Iterate loop
      Put_Line(Maps.Key(I) & " -> " & Maps.Element(I));
   end loop;
   New_Line;

end Example_Hashed_Maps;
