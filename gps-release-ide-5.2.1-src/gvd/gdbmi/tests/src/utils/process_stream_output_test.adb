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

--  This file implements test cases for the Process_Stream_Output subprogram
--  defined in MI.Utils.

with MI.Ast;      use MI.Ast;
with MI.Utils;    use MI.Utils;

with Test_Helper; use Test_Helper;

with Ada.Strings.Unbounded;      use Ada.Strings.Unbounded;
with Ada.Unchecked_Deallocation;

procedure Process_Stream_Output_Test is

   procedure Console_Stream_Record;
   --  Passes a Console type Stream_Output_Record.

   procedure Target_Stream_Record;
   --  Passes a Target type Stream_Output_Record.

   procedure Log_Stream_Record;
   --  Passes a Log type Stream_Output_Record.

   procedure Unchecked_Free is new Ada.Unchecked_Deallocation
     (String, String_Access);
   --  String deallocation procedure.

   ---------------------------
   -- Console_Stream_Record --
   ---------------------------

   procedure Console_Stream_Record is
      Rec : Stream_Output_Record := (Output_Type => Console,
                                     Content     => new String'("done"));
      Str : String_Access := Process_Stream_Output (Rec);
   begin
      Expect_Success (Str.all = "done", "Unexpected content");
      Unchecked_Free (Str);
      Clear_Stream_Output_Record (Rec);
   end Console_Stream_Record;

   --------------------------
   -- Target_Stream_Record --
   --------------------------

   procedure Target_Stream_Record is
      Rec : Stream_Output_Record := (Output_Type => Target,
                                     Content     => new String'("done"));
      Str : String_Access := Process_Stream_Output (Rec);
   begin
      Expect_Success (Str.all = "done", "Unexpected content");
      Unchecked_Free (Str);
      Clear_Stream_Output_Record (Rec);
   end Target_Stream_Record;

   -----------------------
   -- Log_Stream_Record --
   -----------------------

   procedure Log_Stream_Record is
      Rec : Stream_Output_Record := (Output_Type => Log,
                                     Content     => new String'("done"));
      Str : String_Access := Process_Stream_Output (Rec);
   begin
      Expect_Success (Str.all = "done", "Unexpected content");
      Unchecked_Free (Str);
      Clear_Stream_Output_Record (Rec);
   end Log_Stream_Record;

begin
   --  Invokes every test cases

   Console_Stream_Record;
   Target_Stream_Record;
   Log_Stream_Record;
end Process_Stream_Output_Test;
