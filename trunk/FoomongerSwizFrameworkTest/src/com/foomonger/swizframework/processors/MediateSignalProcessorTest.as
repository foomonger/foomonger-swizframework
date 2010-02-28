package com.foomonger.swizframework.processors {
	
	import com.anywebcam.mock.Mock;
	
	import flash.events.EventDispatcher;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	
	import flexunit.framework.TestCase;
	
	import org.osflash.signals.MockDeluxeSignal;
	import org.osflash.signals.MockSignal;
	import org.swizframework.core.Bean;
	import org.swizframework.core.BeanProvider;
	import org.swizframework.core.IBeanProvider;
	import org.swizframework.core.ISwiz;
	import org.swizframework.core.Swiz;
	import org.swizframework.core.SwizConfig;
	import org.swizframework.reflection.BaseMetadataHost;
	import org.swizframework.reflection.BaseMetadataTag;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.MetadataArg;
	import org.swizframework.reflection.TypeDescriptor;
	
	public class MediateSignalProcessorTest extends TestCase {
		
		private static const SIGNAL_BEAN_NAME:String = "signalBean";
		private static const DELUXE_SIGNAL_BEAN_NAME:String = "deluxeSignalBean";
		private static const DECORATED_LISTENER_NAME:String = "listener";
		
		private var swiz:ISwiz;
		private var processor:MediateSignalProcessor;
		private var beanProvider:IBeanProvider;
		private var signalBean:Bean;
		private var deluxeSignalBean:Bean;
		private var decoratedBean:Bean;
		private var signal:MockSignal;
		private var deluxeSignal:MockDeluxeSignal;
		private var decoratedBeanSource:Mock;
		private var listener:Function;
		
		public function MediateSignalProcessorTest(methodName:String=null) {
			super(methodName);
		}
		
		override public function setUp():void {
			signal = new MockSignal();
			deluxeSignal = new MockDeluxeSignal();
			decoratedBeanSource = new Mock();
			decoratedBeanSource.property(DECORATED_LISTENER_NAME)
								.anyNumberOfTimes
								.returns(function():void{});
			listener = decoratedBeanSource[DECORATED_LISTENER_NAME];
			
			signalBean = new Bean(signal, SIGNAL_BEAN_NAME, new TypeDescriptor().fromXML(describeType(signal)));
			signalBean.source = signal;
			deluxeSignalBean = new Bean(deluxeSignal, DELUXE_SIGNAL_BEAN_NAME, new TypeDescriptor().fromXML(describeType(deluxeSignal)));
			decoratedBean = new Bean(decoratedBeanSource, "mock", new TypeDescriptor().fromXML(describeType(decoratedBeanSource)));
			
			beanProvider = new BeanProvider();
			beanProvider.addBean(signalBean);
			beanProvider.addBean(deluxeSignalBean);
			beanProvider.addBean(decoratedBean);
			
			processor = new MediateSignalProcessor();

			swiz = new Swiz(new EventDispatcher(), new SwizConfig(), null, [beanProvider], [processor]);			
			swiz.init();
			
			processor.init(swiz);
		}
				
		public function test_setUpMetadataTag_signal_byBeanName_defaultProperty():void {
			var defaultArg:MetadataArg = new MetadataArg("", SIGNAL_BEAN_NAME);
			var metadataTag:IMetadataTag = createMetadataTag([defaultArg]);
			signal.mock.method("add").once.withArgs(listener);
			processor.setUpMetadataTag(metadataTag, decoratedBean);
			signal.mock.verify();
		}
		
		public function test_setUpMetadataTag_signal_byBeanName_beanProperty():void {
			var beanArg:MetadataArg = new MetadataArg("bean", SIGNAL_BEAN_NAME);
			var metadataTag:IMetadataTag = createMetadataTag([beanArg]);
			signal.mock.method("add").once.withArgs(listener);
			processor.setUpMetadataTag(metadataTag, decoratedBean);
			signal.mock.verify();
		}
		
		public function test_setUpMetadataTag_signal_byBeanType():void {
			var typeArg:MetadataArg = new MetadataArg("type", getQualifiedClassName(signal));
			var metadataTag:IMetadataTag = createMetadataTag([typeArg]);
			signal.mock.method("add").once.withArgs(listener);
			processor.setUpMetadataTag(metadataTag, decoratedBean);
			signal.mock.verify();
		}
		
		public function test_setUpMetadataTag_deluxeSignal_defaultPriority():void {
			var defaultArg:MetadataArg = new MetadataArg("", DELUXE_SIGNAL_BEAN_NAME);
			var metadataTag:IMetadataTag = createMetadataTag([defaultArg]);
			deluxeSignal.mock.method("add").once.withArgs(listener, 0);
			processor.setUpMetadataTag(metadataTag, decoratedBean);
			deluxeSignal.mock.verify();
		}
		
		public function test_setUpMetadataTag_deluxeSignal_priorityArg():void {
			var defaultArg:MetadataArg = new MetadataArg("", DELUXE_SIGNAL_BEAN_NAME);
			var priorityArg:MetadataArg = new MetadataArg("priority", "2");
			var metadataTag:IMetadataTag = createMetadataTag([defaultArg, priorityArg]);
			deluxeSignal.mock.method("add").once.withArgs(listener, int(priorityArg.value));
			processor.setUpMetadataTag(metadataTag, decoratedBean);
			deluxeSignal.mock.verify();
		}
		
		public function test_tearDownMetadataTag_signal_byBeanName_defaultProperty():void {
			var defaultArg:MetadataArg = new MetadataArg("", SIGNAL_BEAN_NAME);
			var metadataTag:IMetadataTag = createMetadataTag([defaultArg]);
			signal.mock.method("remove").once.withArgs(listener);
			processor.tearDownMetadataTag(metadataTag, decoratedBean);
			signal.mock.verify();
		}
				
		public function test_tearDownMetadataTag_signal_byBeanName_beanProperty():void {
			var beanArg:MetadataArg = new MetadataArg("bean", SIGNAL_BEAN_NAME);
			var metadataTag:IMetadataTag = createMetadataTag([beanArg]);
			signal.mock.method("remove").once.withArgs(listener);
			processor.tearDownMetadataTag(metadataTag, decoratedBean);
			signal.mock.verify();
		}
		
		public function test_tearDownMetadataTag_signal_byBeanType():void {
			var typeArg:MetadataArg = new MetadataArg("type", getQualifiedClassName(signal));
			var metadataTag:IMetadataTag = createMetadataTag([typeArg]);
			signal.mock.method("remove").once.withArgs(listener);
			processor.tearDownMetadataTag(metadataTag, decoratedBean);
			signal.mock.verify();
		}
		
		public function test_tearDownMetadataTag_deluxeSignal():void {
			var defaultArg:MetadataArg = new MetadataArg("", DELUXE_SIGNAL_BEAN_NAME);
			var metadataTag:IMetadataTag = createMetadataTag([defaultArg]);
			deluxeSignal.mock.method("remove").once.withArgs(listener);
			processor.tearDownMetadataTag(metadataTag, decoratedBean);
			deluxeSignal.mock.verify();
		}
			
		private function createMetadataTag(args:Array):IMetadataTag {
			var metadataTag:IMetadataTag = new BaseMetadataTag();
			metadataTag.args = args;
			metadataTag.host = new BaseMetadataHost();
			metadataTag.host.name = DECORATED_LISTENER_NAME;
			return metadataTag;
		}
	}
}
