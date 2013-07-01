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

--  This file implements test cases for the Process_Var_Delete subprogram
--  defined in MI.Utils.

with MI.Ast;      use MI.Ast;
with MI.Utils;    use MI.Utils;

with Test_Helper; use Test_Helper;

procedure Process_Var_Delete_Test is

   procedure Error_Record;
   --  Passes a "error" record, which should result in Process_Var_Delete
   --  returning False.

   procedure Var_Delete_Record;
   --  Passes a valid record, which should result in Process_Var_Delete
   --  returning True.

   ------------------
   -- Error_Record --
   ------------------

   procedure Error_Record is
      Error : Result_Record := (Token   => 13, R_Type => Sync_Result,
                                Class   => new String'("error"),
                                Results => Result_Pair_Lists.Empty_List);
      Val   : Natural := Natural'First;
      pragma Unreferenced (Val);

   begin
      Val := Process_Var_Delete (Error);
      Fail ("`Error' record is not a valid result-record");
   exception
      when Utils_Error =>
         Clear_Result_Record (Error);  --  Test is successful.
   end Error_Record;

   -----------------------
   -- Var_Delete_Record --
   -----------------------

   procedure Var_Delete_Record is
      Rec : Result_Record := (Token => 13, R_Type => Sync_Result,
                              Class => new String'("done"),
                              Results => Result_Pair_Lists.Empty_List);
      Val   : Natural := Natural'First;
      pragma Unreferenced (Val);

   begin
      begin
         Val := Process_Var_Delete (Rec);
         Fail ("Invalid result-record: expected Utils_Error exception to be "
               & "raised");
      exception
         when Utils_Error =>
            Rec.Results.Append
              (Result_Pair'(Variable => new String'("ndelete"),
                            Value    => new String_Value'(
                                          Value => new String'("1"))
                                        )
              );

            Expect_Success (Process_Var_Delete (Rec) = 1,
                            "Invalid return: expected value '1'");

            Rec.Results.Append
              (Result_Pair'(Variable => new String'("ndelete"),
                            Value    => new String_Value'(
                                          Value => new String'("2"))
                                        )
              );

            begin
               Val := Process_Var_Delete (Rec);
               Fail ("Invalid result-record: expected Utils_Error exception "
                     & "to be raised");
            exception
               when Utils_Error =>
                  Clear_Result_Record (Rec);  -- Test completed.
               when others =>
                  Fail ("Invalid exception type: excepted Utils_Error");
            end;

         when others =>
            Fail ("Invalid exception type: excepted Utils_Error");
      end;
   end Var_Delete_Record;

begin
   --  Invokes every test cases

   Error_Record;
   Var_Delete_Record;
end Process_Var_Delete_Test;
