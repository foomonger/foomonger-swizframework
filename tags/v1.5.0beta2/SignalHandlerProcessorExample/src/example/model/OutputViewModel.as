package example.model {
	
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;

	public class OutputViewModel extends EventDispatcher {
		
		[Bindable]
		public var messages:ArrayCollection;
		
		public function OutputViewModel() {
			super();
			messages = new ArrayCollection();
		}
		
		// Handling by name
		[SignalHandler("submitClicked")]
		public function showMessage(message:String):void {
			messages.addItemAt(message, 0);
		}
		
		// Handling by type
		[SignalHandler(type="ClearClicked")]
		public function clearMessages():void {
			messages.removeAll();
		}
		
	}
}