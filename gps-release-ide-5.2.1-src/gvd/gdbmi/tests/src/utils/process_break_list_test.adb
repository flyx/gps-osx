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

--  This file is a test case for the MI.Utils.Process_Break_List subprogram.

with MI.Ast;      use MI.Ast;
with MI.Utils;    use MI.Utils;

with Test_Helper; use Test_Helper;
with Ada.Text_IO; use Ada.Text_IO;

procedure Process_Break_List_Test is

   procedure Break_List_Test_1;
   --  Procedure testing the result of the first resource file.

   procedure Break_List_Test_2;
   --  Procedure testing the result of the second resource file.

   -----------------------
   -- Break_List_Test_1 --
   -----------------------

   procedure Break_List_Test_1 is
      FName : constant String := "tests/utils/break-list-test-1.mi";
      Rec   : MI_Record_Access := MI_Get_First_Record (FName);
      Bkpts : Breakpoint_List := Process_Break_List (Result_Record (Rec.all));
      Bkpt  : constant Breakpoint_Type := Breakpoint_Lists.Element
                                             (Breakpoint_Lists.First (Bkpts));

   begin
      Put_Line ("Running test #1: Break_List_Test_1 with file " & FName);

      Expect_Success (Bkpt.Number = 1, "Expected Number attr to be `1'");
      Expect_Success (Bkpt.Type_Desc.all = "breakpoint",
                      "Expected Type_Desc attr to be `breakpoint'");
      Expect_Success (Bkpt.Disp.all = "keep",
                      "Expected Disp attr to be `keep'");
      Expect_Success (Bkpt.Enabled, "Expected Enabled attr to be `True'");
      Expect_Success (Bkpt.Frame.Address.all = "0x08049845",
                      "Expected Address attr to be `0x08049845'");
      Expect_Success (Bkpt.Frame.Function_Name.all = "common",
                      "Expected Function_Name attr to be `common'");

      --  The following path is never evaluated as such. We are only interested
      --  in comparing the two strings.

      Expect_Success (Bkpt.Frame.File_Name.all = "common.adb",
                      "Unexpected File_Name attr");
      Expect_Success (Bkpt.Frame.Line = 5, "Expected Line attr to be `5'");
      Expect_Success (Bkpt.Times = 1, "Expected Times attr to be `1'");
      Expect_Success (Bkpt.Original_Location.all = "common.adb:5",
                      "Unexpected Original_Location attr");

      --  Free the resources to satisfy Valgrind.
      Clear_Breakpoint_List (Bkpts);
      Clear_MI_Record (Rec);
      Free_MI_Record (Rec);
   end Break_List_Test_1;

   -----------------------
   -- Break_List_Test_2 --
   -----------------------

   procedure Break_List_Test_2 is
      FName : constant String := "tests/utils/break-list-test-2.mi";
      Rec   : MI_Record_Access := MI_Get_First_Record (FName);
      Bkpts : Breakpoint_List := Process_Break_List (Result_Record (Rec.all));
      Bkpt0 : constant Breakpoint_Type := Breakpoint_Lists.Element
                                             (Breakpoint_Lists.First (Bkpts));
      Bkpt1 : constant Breakpoint_Type := Breakpoint_Lists.Element
                                           (Breakpoint_Lists.Next
                                             (Breakpoint_Lists.First (Bkpts)));

   begin
      Put_Line ("Running test #1: Break_List_Test_2 with file " & FName);

      --  Testing Bkpt0

      Expect_Success (Bkpt0.Number = 1, "Expected Number attr to be `1'");
      Expect_Success (Bkpt0.Type_Desc.all = "breakpoint",
                      "Expected Type_Desc attr to be `breakpoint'");
      Expect_Success (Bkpt0.Disp.all = "keep",
                      "Expected Disp attr to be `keep'");
      Expect_Success (Bkpt0.Enabled, "Expected Enabled attr to be `True'");
      Expect_Success (Bkpt0.Frame.Address.all = "0x08049845",
                      "Expected Address attr to be `0x08049845'");
      Expect_Success (Bkpt0.Frame.Function_Name.all = "common",
                      "Expected Function_Name attr to be `common'");

      --  The following path is never evaluated as such. We are only interested
      --  in comparing the two strings.

      Expect_Success (Bkpt0.Frame.File_Name.all = "common.adb",
                      "Unexpected File_Name attr");
      Expect_Success (Bkpt0.Frame.Line = 5, "Expected Line attr to be `5'");
      Expect_Success (Bkpt0.Times = 0, "Expected Times attr to be `1'");
      Expect_Success (Bkpt0.Original_Location.all = "common.adb:5",
                      "Unexpected Original_Location attr");

      --  Testing Bkpt1

      Expect_Success (Bkpt1.Number = 2, "Expected Number attr to be `2'");
      Expect_Success (Bkpt1.Type_Desc.all = "breakpoint",
                      "Expected Type_Desc attr to be `breakpoint'");
      Expect_Success (Bkpt1.Disp.all = "keep",
                      "Expected Disp attr to be `keep'");
      Expect_Success (Bkpt1.Enabled, "Expected Enabled attr to be `True'");
      Expect_Success (Bkpt1.Frame.Address.all = "0x08049846",
                      "Expected Address attr to be `0x08049846'");
      Expect_Success (Bkpt1.Frame.Function_Name.all = "common",
                      "Expected Function_Name attr to be `common'");

      --  The following path is never evaluated as such. We are only interested
      --  in comparing the two strings.

      Expect_Success (Bkpt1.Frame.File_Name.all = "common.adb",
                      "Unexpected File_Name attr");
      Expect_Success (Bkpt1.Frame.Line = 6, "Expected Line attr to be `6'");
      Expect_Success (Bkpt1.Times = 0, "Expected Times attr to be `1'");
      Expect_Success (Bkpt1.Original_Location.all = "common.adb:6",
                      "Unexpected Original_Location attr");

      --  Free the resources to satisfy Valgrind.
      Clear_Breakpoint_List (Bkpts);
      Clear_MI_Record (Rec);
      Free_MI_Record (Rec);
   end Break_List_Test_2;

begin
   Break_List_Test_1;
   Break_List_Test_2;

   --  Free the resources to satisfy Valgrind.
   Clear_Resources;
end Process_Break_List_Test;
