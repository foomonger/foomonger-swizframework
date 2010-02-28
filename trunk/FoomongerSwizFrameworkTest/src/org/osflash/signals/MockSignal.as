package org.osflash.signals {
	
	import com.anywebcam.mock.Mock;
	
	public class MockSignal implements ISignal {
		
		public var mock:Mock;
	
		public function MockSignal() {
			mock = new Mock(this);
		}

		public function get valueClasses():Array {
			return mock.valueClasses;
		}
		
		public function get numListeners():uint {
			return mock.numListeners;
		}
		
		public function add(listener:Function):void {
			mock.add(listener);
		}
		
		public function addOnce(listener:Function):void {
			mock.addOnce(listener);
		}
		
		public function remove(listener:Function):void {
			mock.remove(listener);
		}
		
		public function removeAll():void {
			mock.remoeAll();
		}
		
	}
}