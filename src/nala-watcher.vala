using Nala;
/*
pool = WatcherPool()
queue = Queue(30)
xdgmenu = Application("/bin/echo", ["/usr/share/applications"])
pool.add_watcher(xdgmenu.triggers)
queue.add_application(xdgmenu)
*/

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
