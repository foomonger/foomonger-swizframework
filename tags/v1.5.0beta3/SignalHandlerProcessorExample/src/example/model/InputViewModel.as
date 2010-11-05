package example.model {
	
	import example.signals.ClearClicked;
	
	import org.osflash.signals.Signal;

	public class InputViewModel {
		
		// Injecting by name
		[Inject("submitClicked")]
		public var submitClicked:Signal;
		
		// Injecting by type
		[Inject]
		public var clearClicked:ClearClicked;
		
		public function InputViewModel() {
			super();
		}
		
		public function submit(message:String):void {
			submitClicked.dispatch(message);
		}
		
		public function clear():void {
			clearClicked.dispatch();
		}
	}
}