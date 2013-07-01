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

with MI.Lexer;    use MI.Lexer;
with MI.Parser;   use MI.Parser;

with Ada.Text_IO; use Ada.Text_IO;

package body Test_Helper is

   ---------------------
   -- Clear_Resources --
   ---------------------

   procedure Clear_Resources is
   begin
      Clear_Record_List (Resources);
   end Clear_Resources;

   -------------
   -- MI_Open --
   -------------

   function MI_Open (File_Name : String) return Stream_Access
   is
      File         : File_Type;
   begin
      Open (File, In_File, File_Name);
      return Stream (File);
   end MI_Open;

   --------------
   -- MI_Parse --
   --------------

   procedure MI_Parse
     (Stream : Stream_Access;
      Result : out Record_List)
   is
      Tokens : Token_List;
   begin
      Tokens := Build_Tokens (Stream);
      Build_Records (Tokens, Result);
   end MI_Parse;

   -------------------------
   -- MI_Get_First_Record --
   -------------------------

   function MI_Get_First_Record (File_Name : String) return MI_Record_Access
   is
      Stream   : constant Stream_Access := MI_Open (File_Name);
      Rec_List : Record_List;
      Iterator : Record_Lists.Cursor;
      Rec      : MI_Record_Access;

   begin
      MI_Parse (Stream, Rec_List);
      Iterator := Record_Lists.First (Rec_List);

      if not Record_Lists.Has_Element (Iterator) then
         raise Helper_Error with "no MI_Record found";
      end if;

      Rec := Record_Lists.Element (Iterator);

      loop
         Iterator := Record_Lists.Next (Iterator);
         exit when not Record_Lists.Has_Element (Iterator);
         Resources.Append (Record_Lists.Element (Iterator));
      end loop;

      return Rec;
   end MI_Get_First_Record;

   ----------
   -- Fail --
   ----------

   procedure Fail (Message : String := "") is
   begin
      raise Test_Exec_Flow_Error with Message;
   end Fail;

   --------------------
   -- Expect_Success --
   --------------------

   procedure Expect_Success (Exp : Boolean; Message : String := "") is
   begin
      if Exp = False then
         Fail (Message);
      end if;
   end Expect_Success;

   --------------------
   -- Expect_Failure --
   --------------------

   procedure Expect_Failure (Exp : Boolean; Message : String := "") is
   begin
      if Exp then
         Fail (Message);
      end if;
   end Expect_Failure;

end Test_Helper;
