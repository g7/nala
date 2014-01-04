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

	public class Queue : GLib.Object {
		/**
		 * Handles the rebuild queue. 
		 *
		 * How the Queue works:
		 * - An Application(), added via self.add_application(), is linked
		 *   on every trigger it requires.
		 * - When something occours, self.add_to_queue() needs to be called.
		 *   This may be done by connecting the "watcher-changed" signal of the
		 *   WatcherPool or the "changed" signal of the Watcher to a dummy
		 *   method which calls the appropriate queue's add_to_queue().
		 * - self.add_to_queue() takes note of the event and sets a timeout of
		 *   3 seconds (default, can be changed when constructing the class using
		 *   the wait_time argument) before telling listeners to do the things
		 *   they want.
		 * - If another event happens BEFORE the 3 seconds timeout, the timeout
		 *   is resetted.
		 *   This *may* be an issue if you want to work on directories like /tmp,
		 *   so you need to set the wait_time to 0 in that case.
		 * - If after the timeout everything is good, the object automatically
		 *   merges reported events (e.g. handling a 'changed' event when
		 *   a file has been deleted later has no sense) and fires the
		 *   "processable" signal.
		*/
		
		private class ApplicationArrayWrapper {
			// Really, is this needed to put an array into an HashMap?!
			public Array<Application> array = new Array<Application>();
		}

		// "processable" signal
		public signal void processable (Application[] apps, Array<string> in_queue_path, Array<string> in_queue_trigger, Array<FileMonitorEvent> in_queue_event);

		public uint wait_time { get; set; default=3; }
		
		private Gee.HashMap<string, ApplicationArrayWrapper> triggers = new Gee.HashMap<string, ApplicationArrayWrapper>();
		private uint timeout;
		
		private Array<string> in_queue_path = new Array<string>();
		private Array<string> in_queue_trigger = new Array<string>();
		private Array<FileMonitorEvent> in_queue_event = new Array<FileMonitorEvent>();
		
		public Queue(int? wait_time) {
			/**
			 * Initializes the Queue object.
			 * 
			 * wait_time is the time (in seconds) the Queue should wait
			 * before emit the processable signals.
			*/
			
			if ((wait_time != null) && (wait_time > 0)) {
				this.wait_time = wait_time;
			}
		}
		
		public void add_application(Application app) {
			/**
			 * Adds an Application.
			*/
			
			foreach(string trigger in app.triggers) {
				if (!(trigger in this.triggers.keys)) {
					this.triggers[trigger] = new ApplicationArrayWrapper();
				}
				
				//Array<Application> trg = this.triggers[trigger].array;
				this.triggers[trigger].array.append_val(app);
			}
		}
		
		private bool _processable() {
			/**
			 * When this method is fired, we are almost ready to hand-off
			 * the current Queue to the listeners of the 'processable' signal.
			*/
						
			// Get application list to process
			Application[] apps = new Application[0];
			for (int i = 0; i < this.in_queue_path.length; i++) {
				string item = this.in_queue_path.index(i);
				if (item in this.triggers.keys) {
					// item[0] is watcher's path
					for (int j = 0; j < this.triggers[item].array.length; j++) {
						Application app = this.triggers[item].array.index(j);
						if (!(app in apps)) {
							apps += app;
						}
					}
				}
			}
			
			processable (apps, this.in_queue_path, this.in_queue_trigger, this.in_queue_event);
			
			// Cleanup things
			this.in_queue_path.remove_range(0, this.in_queue_path.length);
			this.in_queue_trigger.remove_range(0, this.in_queue_trigger.length);
			this.in_queue_event.remove_range(0, this.in_queue_event.length);
			

			this.timeout = 0;
			
			return false;
			
			
		}

		public void add_to_queue(Watcher watcher, File trigger, FileMonitorEvent event) {
			/**
			 * Adds a trigger to the queue.
			*/			
			
			if (this.timeout > 0) {
				// An existing timeout is there, we need to delete it...
				GLib.Source.remove(this.timeout);
			}
			
			string trigger_path = trigger.get_path();
			
			if (!(watcher.path in this.triggers.keys)) {
				// We do not need to touch this
				return;
			}
			
			/*
			 * The behaviour here is a bit changed if we compare with
			 * the python implementation. This is mainly because this is
			 * my first thing I do in vala and really I'm not expert with
			 * this language. But I'm learning ;)
			*/
			this.in_queue_path.append_val(watcher.path);
			this.in_queue_trigger.append_val(trigger_path);
			this.in_queue_event.append_val(event);
			this.timeout = GLib.Timeout.add_seconds(this.wait_time, this._processable);
		}
		
	}

}
