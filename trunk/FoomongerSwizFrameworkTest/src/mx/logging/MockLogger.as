package mx.logging {
	
	import com.anywebcam.mock.Mock;
	
	import flash.events.Event;

	public class MockLogger implements ILogger {
		
		public var mock:Mock;
		
		public function MockLogger() {
			mock = new Mock(this);
		}

		public function get category():String {
			return mock.category;
		}
		
		public function log(level:int, message:String, ...parameters):void {
			mock.log(level, message);
		}
		
		public function debug(message:String, ...parameters):void {
			mock.debug(message);
		}
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			mock.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function error(message:String, ...parameters):void {
			mock.error(message);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void {
			mock.removeEventListener(type, listener, useCapture);
		}
		
		public function dispatchEvent(event:Event):Boolean {
			return mock.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean {
			return mock.hasEventListener(type);
		}
		
		public function fatal(message:String, ...parameters):void {
			mock.fatal(message);
		}
		
		public function willTrigger(type:String):Boolean {
			return mock.willTrigger(type);
		}
		
		public function info(message:String, ...parameters):void {
			mock.info(message);
		}
		
		public function warn(message:String, ...parameters):void {
			mock.warn(message);
		}
		
	}
}