------------------------------------------------------------------------------
--                                  G P S                                   --
--                                                                          --
--                     Copyright (C) 2011-2012, AdaCore                     --
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

--  This file is a test case for the MI.Utils.Process_Var_List_Children
--  subprogram.

with MI.Ast;         use MI.Ast;
with MI.Utils;       use MI.Utils;

with Test_Helper;    use Test_Helper;
with Ada.Containers; use Ada.Containers;

procedure Process_Var_List_Children_Test is
   Rec_1   : MI_Record_Access :=
               MI_Get_First_Record ("tests/utils/var-list-children-test-1.mi");
   Rec_2   : MI_Record_Access :=
               MI_Get_First_Record ("tests/utils/var-list-children-test-2.mi");
   Var_Obj : Var_Obj_Type;

begin
   Process_Var_List_Children (Result_Record (Rec_1.all), Var_Obj);

   Expect_Success (Var_Obj.Num_Child = 3, "Expected varobj numchild to be 3");
   Expect_Success (Var_Obj.Has_More = 0, "Expected varobj has_more to be 0");
   Expect_Success (Var_Obj_Lists.Length (Var_Obj.Children) = 3,
                   "Expected varobj to have 3 children");

   Clear_Var_Obj (Var_Obj);
   Clear_MI_Record (Rec_1);
   Free_MI_Record (Rec_1);

   Process_Var_List_Children (Result_Record (Rec_2.all), Var_Obj);

   Expect_Success (Var_Obj.Num_Child = 10,
                   "Expected varobj numchild to be 10");
   Expect_Success (Var_Obj.Has_More = 0, "Expected varobj has_more to be 0");
   Expect_Success (Var_Obj_Lists.Length (Var_Obj.Children) = 10,
                   "Expected varobj to have 3 children");

   Clear_Var_Obj (Var_Obj);
   Clear_MI_Record (Rec_2);
   Free_MI_Record (Rec_2);
   Clear_Resources;
end Process_Var_List_Children_Test;
