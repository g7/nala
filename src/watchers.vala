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

	public class WatcherPool : GLib.Object {
		/**
		 * A pool which handles multiple watchers.
		*/
		
		// "watcher-changed" signal
		public signal void watcher_changed (Watcher watcher, File trigger, FileMonitorEvent event);

		private Gee.HashMap<string, Watcher> watchers = new Gee.HashMap<string, Watcher>();
		
		public void add_watchers(string[] paths) {
			/**
			 * Creates a new Watcher and adds it to this.watchers.
			*/
			
			foreach(string path in paths) {
				Watcher _watcher = new Watcher(path);
				_watcher.changed.connect(
					(watcher, trigger, event) => {
						watcher_changed (watcher, trigger, event);
					}
				);
				
				this.watchers.set(path, _watcher);
			}
		}
		
	}

	public class Watcher : GLib.Object {
		/**
		 * A Watcher is that cool thingy which watches your file/directory to
		 * get any modifications happening there.
		*/
		
		// "changed" signal
		public signal void changed (File trigger, FileMonitorEvent event);
		
		public string path { get; set; }
		
		private File file_object;
		private FileMonitor file_monitor;
		
		public Watcher(string path) {
			/**
			 * Initializes watcher.
			 *
			 * path is the path to watch.
			*/
			
			this.path = path;
			this.file_object = File.new_for_path(this.path);
			try {
				this.file_monitor = this.file_object.monitor(FileMonitorFlags.NONE, null);
				
				this.file_monitor.changed.connect(
					(trigger, wtf, event) => {
						if ((event == FileMonitorEvent.CHANGED) ||
							(event == FileMonitorEvent.CREATED) ||
							(event == FileMonitorEvent.DELETED) ||
							(event == FileMonitorEvent.MOVED)) {
							changed (trigger, event);
						}
					}
				);
			} catch (Error e) {
				stderr.printf("ERROR: Unable to create watcher for %s\n", path);
			}
		}
	}

}
