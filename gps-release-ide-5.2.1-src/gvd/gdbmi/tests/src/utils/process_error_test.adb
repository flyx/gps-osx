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

--  This file implements test cases for the Process_Error subprogram defined in
--  MI.Utils.

with MI.Ast;      use MI.Ast;
with MI.Utils;    use MI.Utils;

with Test_Helper; use Test_Helper;

with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with Ada.Unchecked_Deallocation;

procedure Process_Error_Test is

   procedure Done_Record;
   --  Passes a "done" record, which should result in Process_Error returning
   --  null.

   procedure Valid_Error_Record;
   --  Passes an "error" record, which should result in Process_Error returning
   --  the errpr message content.

   procedure Free_String is new Ada.Unchecked_Deallocation
     (String, String_Access);
   --  String deallocation procedure.

   -----------------
   -- Done_Record --
   -----------------

   procedure Done_Record is
      Done : Result_Record := (Token   => 13, R_Type => Sync_Result,
                               Class   => new String'("done"),
                               Results => Result_Pair_Lists.Empty_List);
      Str  : String_Access := null;

   begin
      Str := Process_Error (Done);
      Fail ("`Done' record is not an error-record");
   exception
      when Utils_Error =>
         Free_String (Str);  --  Test was successful.
         Clear_Result_Record (Done);
      when others =>
         Fail ("Unexpected exception");
   end Done_Record;

   ------------------------
   -- Valid_Error_Record --
   ------------------------

   procedure Valid_Error_Record is
      Error : Result_Record := (Token   => 13, R_Type => Sync_Result,
                                Class   => new String'("error"),
                                Results => Result_Pair_Lists.Empty_List);
      Str   : String_Access := null;

   begin
      begin
         Str := Process_Error (Error);

         if Str /= null then
            Fail ("Invalid error-record: expected Utils_Error exception to be "
                  & "raised");
         end if;
      exception
         when Utils_Error =>
            Free_String (Str);

            Error.Results.Append (Result_Pair'(Variable => new String'("msg"),
                                               Value => new String_Value'(
                                                Value => new String'("Error")))
                                 );

            Str := Process_Error (Error);

            if Str = null or else Str.all /= "Error" then
               Fail ("Invalid return: expected string 'Error'");
            end if;

            Free_String (Str);

            Error.Results.Append (Result_Pair'(Variable => new String'("msg"),
                                               Value => new String_Value'(
                                                Value => new String'("Error")))
                                 );
            begin
               Str := Process_Error (Error);

               if Str /= null then
                  Fail ("Invalid error-record: expected Utils_Error exception "
                        & "to be raised");
               end if;
            exception
               when Utils_Error =>
                  Clear_Result_Record (Error);  -- Test completed.
                  Free_String (Str);
               when others =>
                  Fail ("Invalid exception type: excepted Utils_Error");
            end;

         when others =>
            Fail ("Invalid exception type: excepted Utils_Error");
      end;
   end Valid_Error_Record;

begin
   --  Invokes every test cases

   Done_Record;
   Valid_Error_Record;
end Process_Error_Test;
