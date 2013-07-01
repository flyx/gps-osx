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

--  This file implements test cases for the Process_Exec_Run subprogram defined
--  in MI.Utils.

with MI.Ast;      use MI.Ast;
with MI.Utils;    use MI.Utils;

with Test_Helper; use Test_Helper;

procedure Process_Exec_Run_Test is

   procedure Done_Record;
   --  Passes a "done" record, which should result in Process_Exec_run
   --  returning False.

   procedure Running_Record;
   --  Passes an "running" record, which should result in Process_Exec_Run
   --  returning True.

   -----------------
   -- Done_Record --
   -----------------

   procedure Done_Record is
      Done : Result_Record := (Token   => 13, R_Type => Sync_Result,
                               Class   => new String'("done"),
                               Results => Result_Pair_Lists.Empty_List);

   begin
      Expect_Failure (Process_Exec_Run (Done), "Should not have returned");
      Fail ("`Done' record is not an error-record");
   exception
      when Utils_Error =>
         Clear_Result_Record (Done);  --  Test was successful.
      when others =>
         Fail ("Unexpected exception");
   end Done_Record;

   --------------------
   -- Running_Record --
   --------------------

   procedure Running_Record is
      Running : Result_Record := (Token   => 13, R_Type => Sync_Result,
                                  Class   => new String'("running"),
                                  Results => Result_Pair_Lists.Empty_List);

   begin
      Expect_Success (Process_Exec_Run (Running),
                      "`Error' record is an error-record");
      Clear_Result_Record (Running);
   end Running_Record;

begin
   --  Invokes every test cases

   Done_Record;
   Running_Record;
end Process_Exec_Run_Test;
