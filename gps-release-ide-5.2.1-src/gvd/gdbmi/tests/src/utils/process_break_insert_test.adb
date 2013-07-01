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

--  This file is a test case for the MI.Utils.Process_Break_Insert subprogram.

with MI.Ast;      use MI.Ast;
with MI.Utils;    use MI.Utils;

with Test_Helper; use Test_Helper;

procedure Process_Break_Insert_Test is

   Rec  : MI_Record_Access :=
            MI_Get_First_Record ("tests/utils/break-insert-test-1.mi");
   Bkpt : Breakpoint_Type := Process_Break_Insert (Result_Record (Rec.all));

begin
   Expect_Success (Bkpt.Number = 1, "Expected Number attr to be `1'");

   Expect_Success (Bkpt.Type_Desc.all = "breakpoint",
                   "Expected Type_Desc attr to be `breakpoint'");

   Expect_Success (Bkpt.Disp.all = "keep", "Expected Disp attr to be `keep'");

   Expect_Success (Bkpt.Enabled, "Expected Enabled attr to be `True'");

   Expect_Success (Bkpt.Frame.Address.all = "0x08049660",
                   "Expected Address attr to be `0x08049660'");

   Expect_Success (Bkpt.Frame.Function_Name.all = "main",
                   "Expected Function_Name attr to be `main'");

   --  The following path is never evaluated as such. We are only interested in
   --  comparing the two strings.
   Expect_Success (Bkpt.Frame.File_Name.all = "/some/path/to/main.adb",
                   "Unexpected File_Name attr");

   Expect_Success (Bkpt.Frame.File_Fullname.all = "/some/path/to/main.adb",
                   "Unexpected File_Fullname attr");

   Expect_Success (Bkpt.Frame.Line = 5, "Expected Line attr to be `5'");

   Expect_Success (Bkpt.Times = 0, "Expected Times attr to be `0'");

   Expect_Success (Bkpt.Original_Location.all = "main.adb:5",
                   "Unexpected Original_Location attr");

   --  Free the resources to satisfy Valgrind.
   Clear_Resources;
   Clear_Breakpoint (Bkpt);
   Clear_MI_Record (Rec);
   Free_MI_Record (Rec);
end Process_Break_Insert_Test;
