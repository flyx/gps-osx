with Dynamic_Arrays;
with Ada.Text_IO; use Ada.Text_IO;

procedure Test_Arrays is
   type My_Data is new Integer;
   package Data_Arrays is new Dynamic_Arrays
     (Data                    => My_Data,
      Table_Multiplier        => 2,
      Table_Minimum_Increment => 10,
      Table_Initial_Size      => 5);
   use Data_Arrays;

   procedure Assert (Data1 : Index_Type; Data2 : Integer; Msg : String);

   procedure Assert (Data1 : Index_Type; Data2 : Integer; Msg : String) is
   begin
      if Integer (Data1) /= Data2 then
         Put_Line ("--- Failed: " & Msg);
         Put_Line ("Expected:" & Data2'Img);
         Put_Line ("Got:     " & Data1'Img);
      end if;
   end Assert;

   Arr : Instance;
begin
   for J in My_Data'(1) .. 10_000 loop
      Append (Arr, J);
   end loop;

   Assert (Length (Arr), 10_000, "Incorrect number of elements");

   Remove (Arr, Item => 5_000);
   Assert (Length (Arr), 9_999,  "Incorrect size after remove");

   Free (Arr);
   Assert (Length (Arr), 0, "Incorrect size after free");
end Test_Arrays;
