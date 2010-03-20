package example.model {
	
	import flash.events.EventDispatcher;
	
	import mx.logging.ILogger;

	public class MainvViewModel extends EventDispatcher {
		
		[Logger]
		public var logger:ILogger;
		
		[Inject]
		public function setFoo(value:Foo):void {
			logger.info("The logger is available now because [Logger] has a higher priority than [Inject].");
		}
		
		public function MainvViewModel() {
			super();
		}
		
		[PostConstruct]
		public function init():void {
			logger.info("The logger is available now because [Logger] has a higher priority than [PostConstruct].");
		}
		
		public function click():void {
			logger.info("Hello Click!");
		}
		
	}
}