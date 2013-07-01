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

--  This file is a test case for the MI.Utils.Process_Var_Create subprogram.

with MI.Ast;      use MI.Ast;
with MI.Utils;    use MI.Utils;

with Test_Helper; use Test_Helper;

procedure Process_Var_Create_Test is
   Rec      : MI_Record_Access :=
                MI_Get_First_Record ("tests/utils/var-create-test-1.mi");
   Var_Obj  : Var_Obj_Access := Process_Var_Create (Result_Record (Rec.all));

begin
   Expect_Success (Var_Obj.all.Name.all = "var1",
                   "Expected Var_Obj.Name to be `var1'");

   Expect_Success (Var_Obj.all.Num_Child = 10,
                   "Expected Var_Obj.Num_Child to be `10'");

   Expect_Success (Var_Obj.all.Value.all = "[10]",
                   "Expected Var_Obj.Value to be `[10]'");

   Expect_Success (Var_Obj.all.Type_Desc.all = "array (1 .. 10) of integer",
                   ("Expected Var_Obj.Type_Desc to be `array (1 .. 10) of "
                    & "integer'"));

   Expect_Success (Var_Obj.all.Has_More = 0,
                   "Expected Var_Obj.Has_More to be `0'");

   --  Free the resources to satisfy Valgrind.
   Clear_Resources;
   Free_Var_Obj (Var_Obj);
   Clear_MI_Record (Rec);
   Free_MI_Record (Rec);
end Process_Var_Create_Test;
