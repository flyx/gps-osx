------------------------------------------------------------------------------
--                                  G P S                                   --
--                                                                          --
--                     Copyright (C) 2010-2012, AdaCore                     --
--                                                                          --
-- This is free software;  you can redistribute it  and/or modify it  under --
-- terms of the  GNU General Public License as published  by the Free Soft- --
-- ware  Foundation;  either version 3,  or (at your option) any later ver- --
-- sion.  This software is distributed in the hope  that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public --
-- License for  more details.  You should have  received  a copy of the GNU --
-- General  Public  License  distributed  with  this  software;   see  file --
-- COPYING3.  If not, go to http://www.gnu.org/licenses for a complete copy --
-- of the license.                                                          --
------------------------------------------------------------------------------

--  Command-line tester for the template project system.

with Ada.Containers;        use Ada.Containers;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;           use Ada.Text_IO;

with GNATCOLL.VFS;          use GNATCOLL.VFS;

with Project_Templates;     use Project_Templates;

procedure Main is

   Errors    : Unbounded_String;

   use Project_Templates_List;
   Templates : List;
   C         : Cursor;
   T         : Project_Template;

   use type Ada.Containers.Count_Type;

   Dir       : Virtual_File;

begin
   --  Read the "templates" dir

   Read_Templates_Dir
     (Dir       => Create (+"templates"),
      Errors    => Errors,
      Templates => Templates);

   if Errors /= Null_Unbounded_String then
      Put_Line (To_String (Errors));
      return;
   end if;

   if Templates.Length = 0 then
      Put_Line ("No template found.");
      return;
   end if;

   --  Install all found templates in the "output" directory

   C := Templates.First;

   while Has_Element (C) loop
      T := Element (C);

      Errors := Null_Unbounded_String;

      Instantiate_Template
        (Template    => T,
         Target_Dir  =>
           Create_From_Dir (Create ("output"), +To_String (T.Label)),
         Assignments => Default_Assignments (T.Variables),
         Errors      => Errors);

      if Errors /= Null_Unbounded_String then
         Put_Line (To_String (Errors));
         return;
      end if;

      Next (C);
   end loop;
end Main;
