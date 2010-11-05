package org.swizframework.utils.logging {
	
	import com.anywebcam.mock.Mock;
	
	import flash.events.Event;

	public class MockSwizLogger extends SwizLogger {
		
		public var mock:Mock;
		
		public function MockSwizLogger(className:String) {
			super(className);
			mock = new Mock(this);
		}

		override public function get category():String {
			return mock.category;
		}
		
		override public function log(level:int, message:String, ...parameters):void {
			mock.log(level, message);
		}
		
		override public function debug(message:String, ...parameters):void {
			mock.debug(message);
		}
		
		override public function fatal(message:String, ...parameters):void {
			mock.fatal(message);
		}
	
		override public function info(message:String, ...parameters):void {
			mock.info(message);
		}
		
		override public function warn(message:String, ...parameters):void {
			mock.warn(message);
		}
		
		override public function error(message:String, ...parameters):void {
			mock.error(message);
		}
		
	}
}