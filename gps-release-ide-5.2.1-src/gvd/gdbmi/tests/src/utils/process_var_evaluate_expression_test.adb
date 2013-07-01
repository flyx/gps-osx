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

--  This file implements test cases for the Process_Var_Evaluate_Expression
--  subprogram defined in MI.Utils.

with MI.Ast;      use MI.Ast;
with MI.Utils;    use MI.Utils;

with Test_Helper; use Test_Helper;

procedure Process_Var_Evaluate_Expression_Test is

   procedure Error_Record;
   --  Passes a "error" record, which should result in Process_Var_Assign
   --  raising exception.

   procedure Var_Evaluate_Expression_Record;
   --  Passes a valid record, which should result in Process_Var_Assign
   --  completing quietly.

   ------------------
   -- Error_Record --
   ------------------

   procedure Error_Record is
      Error : Result_Record := (Token   => 13, R_Type => Sync_Result,
                                Class   => new String'("error"),
                                Results => Result_Pair_Lists.Empty_List);
      Var_Obj : Var_Obj_Type;

   begin
      Process_Var_Evaluate_Expression (Error, Var_Obj);
      Fail ("`Error' record is not a valid result-record");
   exception
      when Utils_Error =>
         Clear_Result_Record (Error);  --  Test is successful.
         Clear_Var_Obj (Var_Obj);
   end Error_Record;

   -----------------------
   -- Var_Evaluate_Expression_Record --
   -----------------------

   procedure Var_Evaluate_Expression_Record is
      Rec      : MI_Record_Access :=
                   MI_Get_First_Record ("tests/utils/"
                                        & "var-evaluate-expression-test-1.mi");
      Var_Obj : Var_Obj_Type;

   begin
      begin
         Process_Var_Evaluate_Expression (Result_Record (Rec.all), Var_Obj);
         Clear_MI_Record (Rec);
         Free_MI_Record (Rec);
         Clear_Var_Obj (Var_Obj);
      exception
         when Utils_Error =>
            Fail ("Invalid result-record: unexpected Utils_Error");
      end;
   end Var_Evaluate_Expression_Record;

begin
   --  Invokes every test cases

   Error_Record;
   Var_Evaluate_Expression_Record;
end Process_Var_Evaluate_Expression_Test;
