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

--  This package defines several helper subprograms to easily extract the
--  result of the MI parser in order to test MI.Utils routines.

with MI.Ast;                   use MI.Ast;

with Ada.Text_IO.Text_Streams; use Ada.Text_IO.Text_Streams;

package Test_Helper is

   Helper_Error : exception;
   --  The default exception raise by this compilation unit.

   Test_Exec_Flow_Error : exception;
   --  This is the exception raised on a failed test when calling the
   --  subprogram Test_Helper.Fail.

   Resources : Record_List;
   --  This list holds every resource allocated by this unit so that it can
   --  easily be freed by a single function call.

   procedure Clear_Resources;
   --  Purges every resource allocated in this unit, i.e. frees the above list.

   function MI_Open (File_Name : String) return Stream_Access;
   --  This function opens the MI output file referred by File_Name and returns
   --  a Stream_Access to the content.

   procedure MI_Parse
     (Stream : Stream_Access;
      Result : out Record_List);
   --  This subprogram parse the stream containing MI output and build the
   --  Record_List from it.

   function MI_Get_First_Record (File_Name : String) return MI_Record_Access;
   --  This function calls the three above subprogram to extract the first
   --  record of a MI output expression stored in the file pointed to by
   --  File_Name.

   procedure Fail (Message : String := "");
   --  Raise a Test_Exec_Flow_Error with the given message.

   procedure Expect_Success (Exp : Boolean; Message : String := "");
   --  Raise a Test_Exec_Flow_Error with the given message if Exp is False.

   procedure Expect_Failure (Exp : Boolean; Message : String := "");
   --  Raise a Test_Exec_Flow_Error with the given message if Exp is True.

end Test_Helper;
