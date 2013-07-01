------------------------------------------------------------------------------
--                                  G P S                                   --
--                                                                          --
--                     Copyright (C) 2000-2012, AdaCore                     --
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

with GNAT.Command_Line; use GNAT.Command_Line;
with GNAT.Directory_Operations; use GNAT.Directory_Operations;
with GNAT.OS_Lib;
with GNATCOLL.Traces;
with Ada.Exceptions;    use Ada.Exceptions;
with Ada.Strings.Fixed; use Ada.Strings.Fixed;
with Ada.Text_IO;       use Ada.Text_IO;
with GNAT.Strings;      use GNAT.Strings;
with GNATCOLL.Projects; use GNATCOLL.Projects;
with GNATCOLL.VFS;      use GNATCOLL.VFS;

procedure Testsuite is
   Use_Error : exception;

   Tree         : Project_Tree_Access := new Project_Tree;
   Env          : Project_Environment_Access;

   procedure Help;
   --  Display the help message

   procedure Load_Error (Msg : String);
   pragma Unreferenced (Load_Error);
   --  Display an error reported by the project manager

   function Get_Argument_Advanced return String;
   --  Return the next argument on the command line, or raises Use_Error if
   --  there is none.

   function Parse_Project (Name : String) return Project_Type;
   --  Parse the project, and outputs any possible error directly on standard
   --  output.
   --  If Append is False, then the current tree is first deleted.

   procedure Test_Normalize;
   --  Test the normalization of project files (NORM command)

   procedure Add_Single;
   --  Test the addition of a new attribute with a single value (SINGLE
   --  command)

   procedure Add_List;
   --  Test the addition of a new attribute with a list value (LIST
   --  command)

   procedure Add_With;
   --  Add a new dependency between two project files (WITH command)

   procedure Remove_With;
   --  Remove a dependency between two project files (REMOVE_WITH command)

   procedure Add_Var;
   --  Add a new scenario variable to the project (VAR command)

   procedure Rename;
   --  Rename a project (RENAME command)

   procedure Rename_Var;
   --  Rename an external variable (RENAME_VAR command)

   procedure Add_Value;
   --  Add new values for a variable (VALUE command)

   procedure Rename_Value;
   --  Rename one of the possible values for a variable (MODIFY command)

   procedure Delete_Attribute;
   --  Remove an attribute from the current scenario (DELETE_ATTR command)

   procedure Set_Environment (Definition : String);
   --  Set a new environment variable based on the definition.
   --  Definition must be of the form "name=value"

   procedure Delete_Var;
   --  Remove one of the scenario variables (DELETE_VAR command)

   procedure Remove_Value;
   --  Remove on of the value of the variable (REMOVE_VALUE command);
   --  If the value is the last possible one for the variable, the variable
   --  itself is removed.

   procedure Pretty (Project : Project_Type);
   --  Pretty print project and its imported projects;

   procedure Report_Error2 (Line : String);
   --  Print an error message while processing a project

   function Get_Scenario_Variable (Name : String) return Scenario_Variable;
   --  Search the variable Name in Project or its imported projects

   ----------
   -- Help --
   ----------

   procedure Help is
   begin
      Put_Line ("Syntax: testsuite [switches] [command] [args...]");
      New_Line;
      Put_Line ("where switches is one of");
      Put_Line ("  -Dname=value");
      Put_Line ("      set the environment variable name to value.");
      Put_Line ("  -root=project");
      Put_Line ("      define the root of the project tree, that should");
      Put_Line ("      be used for instance to find scenario variables.");
      New_Line;
      Put_Line ("and command is one of");
      Put_Line ("------ Projects ------");
      Put_Line ("  NORM file.gpr");
      Put_Line ("      normalize the file, and outputs the result.");
      Put_Line ("  WITH file.gpr [file2.gpr file3.gpr ...]");
      Put_Line ("      add new depencies in file.");
      Put_Line ("  REMOVE_WITH file.gpr file2.gpr");
      Put_Line ("      Remove a dependency from file");
      Put_Line ("  RENAME file.gpr root_project.gpr new_name");
      Put_Line ("      rename a project, in the project tree of root_project");
      Put_Line ("      prints out the modified project and the modified root");
      New_Line;
      Put_Line ("------ Attributes ------");
      Put_Line ("  SINGLE file.gpr [INDEX=idx_name] [pkg#]attr_name "
                & "attr_value");
      Put_Line ("      add an attribute with a single value to the");
      Put_Line ("      normalized project.");
      Put_Line ("      If pkg_name is specified, then the attribute is added");
      Put_Line ("      in that package.");
      Put_Line ("      If idx_name is specified, then a specific index is");
      Put_Line ("      used for the index.");
      Put_Line ("  LIST file.gpr [INDEX=idx_name] [pkg#]attr_name "
                & "[value1 value2...]");
      Put_Line ("      add an attribute with a list value to the");
      Put_Line ("      normalized project.");
      Put_Line ("  DELETE_ATTR file.gpr [pkg#]attr_name "
                & "[INDEX=idx_name]");
      Put_Line ("      Remove an attribute in the current scenario, ie fall");
      Put_Line ("      back to the default value");
      New_Line;
      Put_Line ("------ Variables ------");
      Put_Line ("  ADD_VAR file.gpr external_var list_of_values...");
      Put_Line ("      add a new scenario variable to the project");
      Put_Line ("  RENAME_VAR file.gpr ext_var_name new_name");
      Put_Line ("      Rename an external variable.");
      Put_Line ("  DELETE_VAR file.gpr ext_var_name keep_choice direct_ref");
      Put_Line ("      Remove a scenario variable. The resulting project");
      Put_Line ("      behaves as the old one when the value was keep_choice");
      Put_Line ("      If direct_ref is True, then all direct references to");
      Put_Line ("      ext_var_name are also removed.");
      Put_Line ("  MODIFY file.gpr ext_var_name old_value new_value");
      Put_Line ("      Rename one of the possible value for ext_var_name");
      Put_Line ("  VALUE file.gpr ext_var_name [value1 value2 ...]");
      Put_Line ("      Add new possible values for var_name.");
      Put_Line ("  REMOVE_VALUE file.gpr ext_var_name value");
      Put_Line ("      Remove one of the possible values for ext_var_name");
      Put_Line ("      Removing the last possible value deletes the variable");
      GNAT.OS_Lib.OS_Exit (1);
   end Help;

   ---------------------------
   -- Get_Argument_Advanced --
   ---------------------------

   function Get_Argument_Advanced return String is
      S : constant String := Get_Argument;
   begin
      if S'Length = 0 then
         raise Use_Error;
      end if;
      return S;
   end Get_Argument_Advanced;

   -------------------
   -- Report_Error2 --
   -------------------

   procedure Report_Error2 (Line : String) is
   begin
      Put_Line ("Process error: " & Line);
   end Report_Error2;

   ------------
   -- Pretty --
   ------------

   procedure Pretty (Project : Project_Type) is
      Printer : Pretty_Printer;
      Iter : Project_Iterator := Start (Project, True);
   begin
      --  Process the project just to test we still have a valid tree.
      --  However, we do not pass these currently, since there are some
      --  duplicate sources, duplicate directories, undefined external
      --  references,...
      --  Prj.Proc.Process
      --    (Processed_Project, Project, Report_Error'Unrestricted_Access);

      while Current (Iter) /= No_Project loop
         --  Normalize (Registry.Tree.Data, Current (Iter));
         Printer.Put (Current (Iter));
         Next (Iter);
      end loop;
   end Pretty;

   ----------------
   -- Load_Error --
   ----------------

   procedure Load_Error (Msg : String) is
   begin
      Put_Line (Msg);
   end Load_Error;

   -------------------
   -- Parse_Project --
   -------------------

   function Parse_Project (Name : String) return Project_Type is
      Project : Project_Type := No_Project;
   begin
      --  We used to call Load_Or_Find on the project_registry, which would
      --  in turn call Internal_Load. This did not compute the project view.
      --  However, if we try not to compute the view now, we get incorrect
      --  results.
      if File_Extension (Name) /= ".gpr" then
         Project := Tree.Project_From_Name (Name);
         if Project = No_Project then
            Tree.Load (Create (+Name & ".gpr"), Env => Env,
                       Recompute_View => True);
            Project := Tree.Root_Project;
         end if;

      else
         Project := Tree.Project_From_Name (Base_Name (Name, ".gpr"));
         if Project = No_Project then
            Tree.Load (Create (+Name), Env => Env,
                       Recompute_View => True);
            Project := Tree.Root_Project;
         end if;
      end if;

      pragma Assert (Project /= No_Project);

      return Project;
   end Parse_Project;

   --------------------
   -- Test_Normalize --
   --------------------

   procedure Test_Normalize is
      Project_Name : constant String := Get_Argument_Advanced;
      Project : Project_Type;
      Var     : Scenario_Variable;
      pragma Unreferenced (Var);
   begin
      Project := Parse_Project (Project_Name);

      --  Any modification, just to force the normalization
      Var := Project.Create_Scenario_Variable ("foo", "foo_t", "foo");
      Tree.Delete_Scenario_Variable ("foo", "");

      Pretty (Project);

   exception
      when E : others =>
         Put_Line (Exception_Information (E));
   end Test_Normalize;

   ----------------
   -- Add_Single --
   ----------------

   procedure Add_Single is
      Project_Name : constant String := Get_Argument_Advanced;
      Arg2         : GNAT.Strings.String_Access :=
         new String'(Get_Argument_Advanced);
      Var_Name     : GNAT.Strings.String_Access;
      Project      : Project_Type;
      Idx_Name     : GNAT.Strings.String_Access;
   begin
      if Arg2'Length > 6
        and then Arg2 (Arg2'First .. Arg2'First + 5) = "INDEX="
      then
         Idx_Name := new String'(Arg2 (Arg2'First + 6 .. Arg2'Last));
         Free (Arg2);
         Arg2 := new String'(Get_Argument_Advanced);
      else
         Idx_Name := new String'("");
      end if;

      Var_Name := Arg2;

      declare
         Value : constant String := Get_Argument_Advanced;
         Sep   : constant Natural := Index (Var_Name.all, "#");
         Attr  : constant String := Var_Name (Sep + 1 .. Var_Name'Last);
         Pkg   : constant String := Var_Name (Var_Name'First .. Sep - 1);

      begin
         Project := Parse_Project (Project_Name);
         Project.Set_Attribute
           (Scenario  => Tree.Scenario_Variables,
            Attribute => Build (Pkg, Attr),
            Value     => Value,
            Index     => Idx_Name.all);
         Pretty (Project);
      end;

      Free (Idx_Name);
      Free (Var_Name);
   end Add_Single;

   --------------
   -- Add_List --
   --------------

   procedure Add_List is
      Project_Name : constant String := Get_Argument_Advanced;
      Arg2         : String_Access := new String'(Get_Argument_Advanced);
      Var_Name     : String_Access;
      Project      : Project_Type;
      Args         : String_List (1 .. 100);
      Last_Args    : Natural := Args'First - 1;
      Idx_Name     : String_Access;
   begin
      if Arg2'Length > 6
        and then Arg2 (Arg2'First .. Arg2'First + 5) = "INDEX="
      then
         Idx_Name := new String'(Arg2 (Arg2'First + 6 .. Arg2'Last));
         Free (Arg2);
         Arg2 := new String'(Get_Argument_Advanced);
      else
         Idx_Name := new String'("");
      end if;

      Var_Name := Arg2;

      Project := Parse_Project (Project_Name);

      loop
         declare
            Value : constant String := Get_Argument;
         begin
            exit when Value'Length = 0
              or else Last_Args = Args'Last;
            Last_Args := Last_Args + 1;
            Args (Last_Args) := new String'(Value);
         end;
      end loop;

      declare
         Sep   : constant Natural := Index (Var_Name.all, "#");
         Attr  : constant String := Var_Name (Sep + 1 .. Var_Name'Last);
         Pkg   : constant String := Var_Name (Var_Name'First .. Sep - 1);
      begin
         Project.Set_Attribute
           (Scenario  => Tree.Scenario_Variables,
            Attribute => Build (Pkg, Attr),
            Values    => Args (1 .. Last_Args),
            Index     => Idx_Name.all);
      end;

      Pretty (Project);

      Free (Idx_Name);
      Free (Var_Name);
   end Add_List;

   ---------------------
   -- Set_Environment --
   ---------------------

   procedure Set_Environment (Definition : String) is
      Equal_Sign_Index : constant Natural := Index (Definition, "=");
      Var : Scenario_Variable;
   begin
      if Equal_Sign_Index = 0 then
         raise Use_Error;
      end if;

      Var := Tree.Scenario_Variables
        (Definition (Definition'First .. Equal_Sign_Index - 1));
      Set_Value (Var, Definition (Equal_Sign_Index + 1 .. Definition'Last));
      Tree.Change_Environment ((1 => Var));
   end Set_Environment;

   --------------
   -- Add_With --
   --------------

   procedure Add_With is
      Original : constant String := Get_Argument_Advanced;
      Original_Project : Project_Type;
      Success : Boolean := True;
   begin
      Original_Project := Parse_Project (Original);

      loop
         declare
            Dep : constant String := Get_Argument;
         begin
            exit when Dep'Length = 0;
            Success := Success
              and then Tree.Add_Imported_Project
              (Original_Project,
               Create (+GNAT.OS_Lib.Normalize_Pathname (Dep)),
               Errors => Report_Error2'Unrestricted_Access,
               Use_Relative_Path => False) = GNATCOLL.Projects.Success;
         end;
      end loop;

      if Success then
         Pretty (Original_Project);
      end if;
   end Add_With;

   -----------------
   -- Remove_With --
   -----------------

   procedure Remove_With is
      Original : constant String := Get_Argument_Advanced;
      Project  : Project_Type;
      Imported : Project_Type;
   begin
      Project := Parse_Project (Original);

      if Project = No_Project then
         Put_Line ("Could not parse project " & Original);
         return;
      end if;

      loop
         declare
            Dep : constant String := Get_Argument;
         begin
            exit when Dep'Length = 0;

            Imported := Tree.Project_From_Name (Dep);
            Project.Remove_Imported_Project (Imported);
         end;
      end loop;

      Pretty (Project);
   end Remove_With;

   -------------
   -- Add_Var --
   -------------

   procedure Add_Var is
      Project_Name : constant String := Get_Argument_Advanced;
      Ext_Var_Name : constant String := Get_Argument_Advanced;
      Var_Name     : String          := Ext_Var_Name;
      Project      : Project_Type;
      Var          : Scenario_Variable;
   begin
      Project := Parse_Project (Project_Name);

      --  Cleanup the name
      for J in Var_Name'Range loop
         if Var_Name (J) = ' ' then
            Var_Name (J) := '_';
         end if;
      end loop;

      Var := Project.Create_Scenario_Variable
        (Name          => Var_Name,
         Type_Name     => Var_Name & "_Type",
         External_Name => Ext_Var_Name);

      loop
         declare
            Value : constant String := Get_Argument;
         begin
            exit when Value'Length = 0;
            Tree.Add_Values
              (Var, Values => (1 => new String'(Value)));
         end;
      end loop;

      Pretty (Project);
   end Add_Var;

   ------------
   -- Rename --
   ------------

   procedure Rename is
      Project_Name  : constant String := Get_Argument_Advanced;
      Root_Name     : constant String := Get_Argument_Advanced;
      New_Name      : constant String := Get_Argument_Advanced;
      Project, Root : Project_Type;
   begin
      Root    := Parse_Project (Root_Name);
      Project := Parse_Project (Project_Name);
      Project.Rename_And_Move (New_Name, GNATCOLL.VFS.No_File);
      Pretty (Root);
   end Rename;

   ---------------
   -- Add_Value --
   ---------------

   procedure Add_Value is
      Project_Name : constant String := Get_Argument_Advanced;
      Ext_Var_Name : constant String := Get_Argument_Advanced;
      Project      : Project_Type;

      Values : GNAT.Strings.String_List (1 .. 100);
      Last_Values : Natural := Values'First - 1;

   begin
      Project := Parse_Project (Project_Name);

      loop
         declare
            Value : constant String := Get_Argument;
         begin
            exit when Value'Length = 0
              or else Last_Values = Values'Last;

            Last_Values := Last_Values + 1;
            Values (Last_Values) := new String'(Value);
         end;
      end loop;

      Tree.Add_Values
        (Get_Scenario_Variable (Ext_Var_Name),
         Values (Values'First .. Last_Values));

      Pretty (Project);
   end Add_Value;

   ----------------------
   -- Delete_Attribute --
   ----------------------

   procedure Delete_Attribute is
      Project_Name : constant String := Get_Argument_Advanced;
      Var_Name     : String_Access := new String'(Get_Argument_Advanced);
      Idx_Id       : String_Access;
      Project      : Project_Type;
      Sep   : constant Natural := Index (Var_Name.all, "#");
      Attr  : constant String := Var_Name (Sep + 1 .. Var_Name'Last);
      Pkg   : constant String := Var_Name (Var_Name'First .. Sep - 1);
   begin
      declare
         Idx_Name : constant String := Get_Argument;
      begin
         if Idx_Name'Length /= 0
           and then Idx_Name'Length > 6
           and then Idx_Name (Idx_Name'First .. Idx_Name'First + 5) = "INDEX="
         then
            Idx_Id := new String'
              (Idx_Name (Idx_Name'First + 6 .. Idx_Name'Last));
         else
            Idx_Id := new String'("");
         end if;
      end;

      Project := Parse_Project (Project_Name);

      Delete_Attribute
        (Project,
         Scenario  => Tree.Scenario_Variables,
         Attribute => Attribute_Pkg_String'(Build (Pkg, Attr)),
         Index     => Idx_Id.all);

      Pretty (Project);

      Free (Idx_Id);
      Free (Var_Name);
   end Delete_Attribute;

   ---------------------------
   -- Get_Scenario_Variable --
   ---------------------------

   function Get_Scenario_Variable (Name : String) return Scenario_Variable is
      Vars : constant Scenario_Variable_Array :=
         Tree.Scenario_Variables;
   begin
      for V in Vars'Range loop
         if External_Name (Vars (V)) = Name then
            return Vars (V);
         end if;
      end loop;
      return No_Variable;
   end Get_Scenario_Variable;

   ----------------
   -- Rename_Var --
   ----------------

   procedure Rename_Var is
      Project_Name  : constant String := Get_Argument_Advanced;
      Ext_Var_Name  : constant String := Get_Argument_Advanced;
      New_Name      : constant String := Get_Argument_Advanced;
      Project       : constant Project_Type := Parse_Project (Project_Name);
      Var           : Scenario_Variable := Get_Scenario_Variable
        (Ext_Var_Name);
   begin
      Tree.Change_External_Name (Var, New_Name);
      Pretty (Project);
   end Rename_Var;

   ----------------
   -- Delete_Var --
   ----------------

   procedure Delete_Var is
      Project_Name : constant String := Get_Argument_Advanced;
      Ext_Var_Name : constant String := Get_Argument_Advanced;
      Keep_Choice  : constant String := Get_Argument_Advanced;
      Direct_Ref   : constant Boolean :=
        Boolean'Value (Get_Argument_Advanced);
      Project      : Project_Type;
   begin
      Project := Parse_Project (Project_Name);
      Tree.Delete_Scenario_Variable
        (Ext_Var_Name, Keep_Choice, Direct_Ref);
      Pretty (Project);
   end Delete_Var;

   ------------------
   -- Rename_Value --
   ------------------

   procedure Rename_Value is
      Project_Name : constant String := Get_Argument_Advanced;
      Ext_Var_Name : constant String := Get_Argument_Advanced;
      Old_Value    : constant String := Get_Argument_Advanced;
      New_Value    : constant String := Get_Argument_Advanced;
      Project      : Project_Type;
   begin
      Project := Parse_Project (Project_Name);
      Tree.Rename_Value (Ext_Var_Name, Old_Value, New_Value);
      Pretty (Project);
   end Rename_Value;

   ------------------
   -- Remove_Value --
   ------------------

   procedure Remove_Value is
      Project_Name : constant String := Get_Argument_Advanced;
      Ext_Var_Name : constant String := Get_Argument_Advanced;
      Value        : constant String := Get_Argument_Advanced;
      Project      : Project_Type;
   begin
      Project := Parse_Project (Project_Name);

      Tree.Remove_Value (Ext_Var_Name, Value);

      Pretty (Project);
   end Remove_Value;

begin
   GNATCOLL.Traces.Parse_Config_File (Create_From_Base (".gnatdebug"));
   Initialize (Env);
   Tree.Load_Empty_Project (Env => Env);

   loop
      case Getopt ("D: root:") is
         when 'D' =>
            Set_Environment (GNAT.Command_Line.Parameter);

         when 'r' =>
            declare
               Root_Name : constant String := Parameter;
               Root_Project : Project_Type;
               pragma Unreferenced (Root_Project);
            begin
               Root_Project := Parse_Project (Root_Name);
            end;

         when others =>
            exit;
      end case;
   end loop;

   declare
      Command : constant String := Get_Argument;
   begin
      if Command = "NORM" then
         Test_Normalize;

      elsif Command = "SINGLE" then
         Add_Single;

      elsif Command = "WITH" then
         Add_With;

      elsif Command = "ADD_VAR" then
         Add_Var;

      elsif Command = "RENAME" then
         Rename;

      elsif Command = "LIST" then
         Add_List;

      elsif Command = "VALUE" then
         Add_Value;

      elsif Command = "RENAME_VAR" then
         Rename_Var;

      elsif Command = "DELETE_ATTR" then
         Delete_Attribute;

      elsif Command = "DELETE_VAR" then
         Delete_Var;

      elsif Command = "MODIFY" then
         Rename_Value;

      elsif Command = "REMOVE_VALUE" then
         Remove_Value;

      elsif Command = "REMOVE_WITH" then
         Remove_With;

      else
         Put_Line ("Unknown command: " & Command);
         Help;
      end if;
   end;

   Tree.Unload;
   Free (Env);
   Free (Tree);
   GNATCOLL.Projects.Finalize;

exception
   when E : Use_Error =>
      Put_Line ("Unexpected exception:");
      Put_Line (Exception_Information (E));
      Help;
end Testsuite;
