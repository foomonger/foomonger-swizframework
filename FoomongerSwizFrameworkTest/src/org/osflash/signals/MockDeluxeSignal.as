package org.osflash.signals {
	
	import com.anywebcam.mock.Mock;
	
	public class MockDeluxeSignal implements IDeluxeSignal {
		
		public var mock:Mock;
		
		public function MockDeluxeSignal() {
		}
		
		public function get numListeners():uint {
			return mock.numListeners;
		}
		
		public function add(listener:Function, priority:int = 0):void {
			mock.add(listener, priority);
		}
		
		public function addOnce(listener:Function, priority:int = 0):void {
			mock.addOnce(listener, priority);
		}
		
		public function remove(listener:Function):void {
			mock.remove(listener);
		}
		
		public function removeAll():void {
			mock.removeAll();
		}
		
	}
}