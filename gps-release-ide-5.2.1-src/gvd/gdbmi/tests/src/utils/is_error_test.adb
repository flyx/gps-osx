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

--  This file implements test cases for the Is_Error subprogram defined in
--  MI.Utils.

with MI.Ast;      use MI.Ast;
with MI.Utils;    use MI.Utils;

with Test_Helper; use Test_Helper;

with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with Ada.Unchecked_Deallocation;

procedure Is_Error_Test is

   procedure Done_Record;
   --  Passes a "done" record, which should result in Is_Error returning False.

   procedure Valid_Error_Record;
   --  Passes an "error" record, which should result in Is_Error returning
   --  True.

   -----------------
   -- Done_Record --
   -----------------

   procedure Done_Record is
      Done : Result_Record := (Token => 13, R_Type => Sync_Result,
                               Class => new String'("done"),
                               Results => Result_Pair_Lists.Empty_List);

      procedure Unchecked_Free is new Ada.Unchecked_Deallocation
        (String, String_Access);

   begin
      Expect_Failure (Is_Error (Done), "`Done' record is not an error-record");
      Unchecked_Free (Done.Class);
   end Done_Record;

   ------------------------
   -- Valid_Error_Record --
   ------------------------

   procedure Valid_Error_Record is
      Error : Result_Record := (Token => 13, R_Type => Sync_Result,
                                Class => new String'("error"),
                                Results => Result_Pair_Lists.Empty_List);

      procedure Unchecked_Free is new Ada.Unchecked_Deallocation
        (String, String_Access);

   begin
      Expect_Success (Is_Error (Error), "`Error' record is an error-record");
      Unchecked_Free (Error.Class);
   end Valid_Error_Record;

begin
   --  Invokes every test cases

   Done_Record;
   Valid_Error_Record;
end Is_Error_Test;
