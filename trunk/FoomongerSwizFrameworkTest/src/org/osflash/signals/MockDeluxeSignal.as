package org.osflash.signals {
	
	import com.anywebcam.mock.Mock;
	
	public class MockDeluxeSignal implements IPrioritySignal {
		
		public var mock:Mock;
		
		public function MockDeluxeSignal() {
			mock = new Mock(this);
		}
		
		// Not in IDeluxeSignal but in DeluxeSignal for some reason
		public function get valueClasses():Array {
			return mock.valueClasses;
		}
		
		public function get numListeners():uint {
			return mock.numListeners;
		}
		
		public function add(listener:Function):Function {
			return mock.add(listener);
		}
		
		public function addOnce(listener:Function):Function {
			return mock.addOnce(listener);
		}
		
		public function addWithPriority(listener:Function, priority:int = 0):Function {
			return mock.addWithPriority(listener, priority);
		}
		
		public function addOnceWithPriority(listener:Function, priority:int = 0):Function {
			return mock.addOnceWithPriority(listener, priority);
		}
		
		public function remove(listener:Function):Function {
			return mock.remove(listener);
		}
		
	}
}