/*
* nala-watcher - file/directory watcher
* Copyright (C) 2014  Eugenio "g7" Paolantonio <me@medesimo.eu>
*
* This library is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This library is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this library; if not, write to the Free Software
* Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
*
*/

namespace Nala {

	public class Application : GLib.Object {
		/**
		 *  An Application object represents a target application which
		 * needs to do things when one of its watched files has been changed.
		*/
		
		public string path { get; set; }
		public string[] triggers { get; set; }
		
		public Application(string path, string[] triggers) {
			/**
			 * Constructs the object.
			 *
			 * path is the application's path.
			 *
			 * triggers is a list of trigger that will then become
			 * self.triggers.
			 *
			 * Note that an application trigger is not automatically added
			 * to the list of watched files.
			 * You need to update your WatcherPool accordingly.
			*/
			 
			this.path = path;
			this.triggers = triggers;
		}
		
	}

}
