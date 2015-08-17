-- Example_Hashed_Maps
-- An example of using SipHash with the Ada.Containers.Indefinite_Hashed_Maps

with Ada.Containers, Ada.Containers.Indefinite_Hashed_Maps;

with Ada.Text_IO; use Ada.Text_IO;

with SipHash24, SipHash24.String_Hash, SipHash24.System_Entropy;

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

   if SipHash24.System_Entropy.System_Entropy_Available then
      Put_Line("Setting SipHash key from system entropy source.");
      SipHash24.System_Entropy.Set_Key_From_System_Entropy;
   else
      Put_Line("No system entropy available to set SipHash key. Note that " &
                 "this undermines the hash flooding protection supposed to "&
                 "be provided by SipHash.");
   end if;
   New_Line;

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
