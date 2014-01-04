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

using Nala;

class NalaWatcher.Main : GLib.Object {

	static int main() {

		Nala.WatcherPool pool = new Nala.WatcherPool();

		Nala.Queue queue = new Nala.Queue(3);
		
		Nala.Application xdgmenu = new Nala.Application("/bin/echo", new string[] { "/usr/share/applications"} );
		
		pool.add_watchers(xdgmenu.triggers);
		
		queue.add_application(xdgmenu);
		
		//Nala.Watcher mywatcher = new Nala.Watcher("/tmp");
		//mywatcher.changed.connect(on_change);

		QueueHandler queueh = new QueueHandler(queue);

		queue.processable.connect(on_incoming_queue);
		pool.watcher_changed.connect(queueh.add_to_queue);
		
		new MainLoop().run();
		
		return 0;
	}
	
	class QueueHandler {
		private Nala.Queue queue;
		
		public QueueHandler(Nala.Queue queue) {
			this.queue = queue;
		}
		
		public void add_to_queue(Nala.WatcherPool pool, Nala.Watcher watcher, File trigger, FileMonitorEvent event) {
			stdout.printf("Adding to queue, %s\n", trigger.get_path());
			this.queue.add_to_queue(watcher, trigger, event);
		}
		
	}
	
	static void on_incoming_queue(Nala.Queue queue, Nala.Application[] apps, Array<string> in_queue_path, Array<string> in_queue_trigger, Array<FileMonitorEvent> in_queue_event) {
		stdout.printf("GOT SOMETHING!\n");
		
		foreach(Nala.Application app in apps) {
			stdout.printf(app.path + "\n");
		}
		
	}

}
