------------------------------------------------------------------------------
--                             G N A T C O L L                              --
--                                                                          --
--                     Copyright (C) 2003-2012, AdaCore                     --
--                                                                          --
-- This library is free software;  you can redistribute it and/or modify it --
-- under terms of the  GNU General Public License  as published by the Free --
-- Software  Foundation;  either version 3,  or (at your  option) any later --
-- version. This library is distributed in the hope that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE.                            --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
------------------------------------------------------------------------------

package body GNATCOLL.Scripts.Python.Gtkada is

   procedure Init_PyGtk_Support
     (Script : access Scripting_Language_Record'Class)
   is
      pragma Unreferenced (Script);
   begin
      null;
   end Init_PyGtk_Support;

   procedure Add_PyWidget_Method
     (Repo   : access Scripts_Repository_Record'Class;
      Class  : Class_Type)
   is
      pragma Unreferenced (Repo, Class);
   begin
      null;
   end Add_PyWidget_Method;

   function From_PyGtk
     (Data : Callback_Data'Class;
      N    : Positive) return Glib.Object.GObject
   is
      pragma Unreferenced (Data, N);
   begin
      return null;
   end From_PyGtk;

end GNATCOLL.Scripts.Python.Gtkada;
