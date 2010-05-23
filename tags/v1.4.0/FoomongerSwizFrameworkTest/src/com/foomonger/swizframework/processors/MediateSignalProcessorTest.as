package com.foomonger.swizframework.processors {
	
	import com.anywebcam.mock.Mock;
	
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;
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
	import org.swizframework.factories.MetadataHostFactory;
	import org.swizframework.reflection.BaseMetadataTag;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.MetadataArg;
	import org.swizframework.reflection.TypeDescriptor;
	import org.swizframework.utils.logging.MockSwizLogger;
	
	public class MediateSignalProcessorTest extends TestCase {
		
		private static const SIGNAL_BEAN_NAME:String = "signalBean";
		private static const DELUXE_SIGNAL_BEAN_NAME:String = "deluxeSignalBean";
		private static const NON_SIGNAL_BEAN_NAME:String = "nonSignalBean";
		private static const DECORATED_LISTENER_NAME:String = "listener";
		private static const SIGNAL_CLASS_PACKAGE:String = "org.osflash.signals";
		private static const SIGNAL_CLASS_NAME:String = "MockSignal";
		
		private var swiz:ISwiz;
		private var processor:MediateSignalProcessor;
		private var beanProvider:IBeanProvider;
		private var signalBean:Bean;
		private var deluxeSignalBean:Bean;
		private var nonSignalBean:Bean;
		private var decoratedBean:Bean;
		private var signal:MockSignal;
		private var deluxeSignal:MockDeluxeSignal;
		private var decoratedBeanSource:Mock;
		private var listener:Function;
		private var listenerHostNode:XML;
		
		public function MediateSignalProcessorTest(methodName:String=null) {
			super(methodName);
			listenerHostNode = <method name={DECORATED_LISTENER_NAME} returnType="void"/>;
		}
		
		override public function setUp():void {
			signal = new MockSignal();
			deluxeSignal = new MockDeluxeSignal();
			decoratedBeanSource = new Mock();
			decoratedBeanSource.property(DECORATED_LISTENER_NAME)
								.anyNumberOfTimes
								.returns(function():void{});
			listener = decoratedBeanSource[DECORATED_LISTENER_NAME];
			
			signalBean = new Bean(signal, SIGNAL_BEAN_NAME, new TypeDescriptor().fromXML(describeType(signal), ApplicationDomain.currentDomain));
			signalBean.source = signal;
			deluxeSignalBean = new Bean(deluxeSignal, DELUXE_SIGNAL_BEAN_NAME, new TypeDescriptor().fromXML(describeType(deluxeSignal), ApplicationDomain.currentDomain));
			var obj:Object = new Object();
			nonSignalBean = new Bean(obj, NON_SIGNAL_BEAN_NAME, new TypeDescriptor().fromXML(describeType(obj), ApplicationDomain.currentDomain));
			decoratedBean = new Bean(decoratedBeanSource, "mock", new TypeDescriptor().fromXML(describeType(decoratedBeanSource), ApplicationDomain.currentDomain));
			
			beanProvider = new BeanProvider();
			beanProvider.addBean(signalBean);
			beanProvider.addBean(deluxeSignalBean);
			beanProvider.addBean(nonSignalBean);
			beanProvider.addBean(decoratedBean);
			
			processor = new MediateSignalProcessor();

			swiz = new Swiz(new EventDispatcher(), new SwizConfig(), null, [beanProvider], [processor]);			
			swiz.init();
			
			processor.init(swiz);
		}
		
		public function test_setUpMetadataTag_beanNotFoundError():void {
			var defaultArg:MetadataArg = new MetadataArg("", "thisBeanDoesntExist");
			var metadataTag:IMetadataTag = createMetadataTag([defaultArg], listenerHostNode);
			signal.mock.method("add").never;
			var logger:MockSwizLogger = new MockSwizLogger("mock");
			logger.mock.method("error").withAnyArgs.once;
			processor.logger = logger;
			processor.setUpMetadataTag(metadataTag, decoratedBean);
			logger.mock.verify();
			signal.mock.verify();
		}
		
		public function test_setUpMetadataTag_nonSignalBeanError():void {
			var defaultArg:MetadataArg = new MetadataArg("", NON_SIGNAL_BEAN_NAME);
			var metadataTag:IMetadataTag = createMetadataTag([defaultArg], listenerHostNode);
			signal.mock.method("add").never;
			var logger:MockSwizLogger = new MockSwizLogger("mock");
			logger.mock.method("error").withAnyArgs.once;
			processor.logger = logger;
			processor.setUpMetadataTag(metadataTag, decoratedBean);
			logger.mock.verify();
			signal.mock.verify();
		}
				
		public function test_setUpMetadataTag_signal_byBeanName_defaultProperty():void {
			var defaultArg:MetadataArg = new MetadataArg("", SIGNAL_BEAN_NAME);
			var metadataTag:IMetadataTag = createMetadataTag([defaultArg], listenerHostNode);
			signal.mock.property("valueClasses").returns([]);
			signal.mock.method("add").once.withArgs(listener);
			processor.setUpMetadataTag(metadataTag, decoratedBean);
			signal.mock.verify();
		}
		
		public function test_setUpMetadataTag_signal_byBeanName_beanProperty():void {
			var beanArg:MetadataArg = new MetadataArg("bean", SIGNAL_BEAN_NAME);
			var metadataTag:IMetadataTag = createMetadataTag([beanArg], listenerHostNode);
			signal.mock.property("valueClasses").returns([]);
			signal.mock.method("add").once.withArgs(listener);
			processor.setUpMetadataTag(metadataTag, decoratedBean);
			signal.mock.verify();
		}
		
		public function test_setUpMetadataTag_signal_byBeanType():void {
			var typeArg:MetadataArg = new MetadataArg("type", getQualifiedClassName(signal));
			var metadataTag:IMetadataTag = createMetadataTag([typeArg], listenerHostNode);
			signal.mock.property("valueClasses").returns([]);
			signal.mock.method("add").once.withArgs(listener);
			processor.setUpMetadataTag(metadataTag, decoratedBean);
			signal.mock.verify();
		}
		
		public function test_setUpMetadataTag_deluxeSignal_defaultPriority():void {
			var defaultArg:MetadataArg = new MetadataArg("", DELUXE_SIGNAL_BEAN_NAME);
			var metadataTag:IMetadataTag = createMetadataTag([defaultArg], listenerHostNode);
			deluxeSignal.mock.property("valueClasses").returns([]);
			deluxeSignal.mock.method("add").once.withArgs(listener, 0);
			processor.setUpMetadataTag(metadataTag, decoratedBean);
			deluxeSignal.mock.verify();
		}
		
		public function test_setUpMetadataTag_deluxeSignal_priorityArg():void {
			var defaultArg:MetadataArg = new MetadataArg("", DELUXE_SIGNAL_BEAN_NAME);
			var priorityArg:MetadataArg = new MetadataArg("priority", "2");
			var metadataTag:IMetadataTag = createMetadataTag([defaultArg, priorityArg], listenerHostNode);
			deluxeSignal.mock.property("valueClasses").returns([]);
			deluxeSignal.mock.method("add").once.withArgs(listener, int(priorityArg.value));
			processor.setUpMetadataTag(metadataTag, decoratedBean);
			deluxeSignal.mock.verify();
		}
		
		public function test_tearDownMetadataTag_signal_byBeanName_defaultProperty():void {
			var defaultArg:MetadataArg = new MetadataArg("", SIGNAL_BEAN_NAME);
			var metadataTag:IMetadataTag = createMetadataTag([defaultArg], listenerHostNode);
			signal.mock.method("remove").once.withArgs(listener);
			processor.tearDownMetadataTag(metadataTag, decoratedBean);
			signal.mock.verify();
		}
				
		public function test_tearDownMetadataTag_signal_byBeanName_beanProperty():void {
			var beanArg:MetadataArg = new MetadataArg("bean", SIGNAL_BEAN_NAME);
			var metadataTag:IMetadataTag = createMetadataTag([beanArg], listenerHostNode);
			signal.mock.method("remove").once.withArgs(listener);
			processor.tearDownMetadataTag(metadataTag, decoratedBean);
			signal.mock.verify();
		}
		
		public function test_tearDownMetadataTag_signal_byBeanType():void {
			var typeArg:MetadataArg = new MetadataArg("type", getQualifiedClassName(signal));
			var metadataTag:IMetadataTag = createMetadataTag([typeArg], listenerHostNode);
			signal.mock.method("remove").once.withArgs(listener);
			processor.tearDownMetadataTag(metadataTag, decoratedBean);
			signal.mock.verify();
		}
		
		public function test_tearDownMetadataTag_deluxeSignal():void {
			var defaultArg:MetadataArg = new MetadataArg("", DELUXE_SIGNAL_BEAN_NAME);
			var metadataTag:IMetadataTag = createMetadataTag([defaultArg], listenerHostNode);
			deluxeSignal.mock.method("remove").once.withArgs(listener);
			processor.tearDownMetadataTag(metadataTag, decoratedBean);
			deluxeSignal.mock.verify();
		}
		
		public function test_setUpMetadataTag_beanNotFound():void {
			var defaultArg:MetadataArg = new MetadataArg("", "nonExistantBeanName");
			var metadataTag:IMetadataTag = createMetadataTag([defaultArg], listenerHostNode);
			signal.mock.property("valueClasses").returns([]);
			signal.mock.method("add").never;
			processor.setUpMetadataTag(metadataTag, decoratedBean);
			signal.mock.verify();
		}
		
		public function test_setUpMetadataTag_signal_byBeanType_signalPackages():void {
			var typeArg:MetadataArg = new MetadataArg("type", SIGNAL_CLASS_NAME);
			var metadataTag:IMetadataTag = createMetadataTag([typeArg], listenerHostNode);
			signal.mock.property("valueClasses").returns([]);
			signal.mock.method("add").once.withArgs(listener);
			processor.signalPackages = SIGNAL_CLASS_PACKAGE;
			processor.setUpMetadataTag(metadataTag, decoratedBean);
			signal.mock.verify();
		}

		public function test_setUpMetadataTag_argumentLengthValidation():void {
			var defaultArg:MetadataArg = new MetadataArg("", SIGNAL_BEAN_NAME);
			var invalidListenerHostNode:XML = <method name="listener" returnType="void">
												<parameter index="1" type="String" optional="false"/>
												<parameter index="2" type="String" optional="false"/>
											</method>;
			var metadataTag:IMetadataTag = createMetadataTag([defaultArg], invalidListenerHostNode);
			signal.mock.property("valueClasses").returns([String]);
			signal.mock.method("add").never;
			var logger:MockSwizLogger = new MockSwizLogger("mock");
			logger.mock.method("error").withAnyArgs.once;
			processor.logger = logger;
	 		processor.setUpMetadataTag(metadataTag, decoratedBean);
			logger.mock.verify();
			signal.mock.verify();
		}
		
		public function test_setUpMetadataTag_argumentTypeValidation_loose():void {
			var defaultArg:MetadataArg = new MetadataArg("", SIGNAL_BEAN_NAME);
			var invalidListenerHostNode:XML = <method name="listener" returnType="void">
												<parameter index="1" type="String" optional="false"/>
												<parameter index="2" type="Boolean" optional="false"/>
											</method>;
			var metadataTag:IMetadataTag = createMetadataTag([defaultArg], invalidListenerHostNode);
			signal.mock.property("valueClasses").returns([String, String]);
			signal.mock.method("add").once.withArgs(listener); // Passing listener isn't fully accurate but doesn't matter here
	 		processor.setUpMetadataTag(metadataTag, decoratedBean);
			signal.mock.verify();
		}
		
		public function test_setUpMetadataTag_argumentTypeValidation_strict():void {
			var defaultArg:MetadataArg = new MetadataArg("", SIGNAL_BEAN_NAME);
			var invalidListenerHostNode:XML = <method name="listener" returnType="void">
												<parameter index="1" type="String" optional="false"/>
												<parameter index="2" type="Boolean" optional="false"/>
											</method>;
			var metadataTag:IMetadataTag = createMetadataTag([defaultArg], invalidListenerHostNode);
			signal.mock.property("valueClasses").returns([String, String]);
			signal.mock.method("add").never;
			processor.strictArgumentTypes = true;
			var logger:MockSwizLogger = new MockSwizLogger("mock");
			logger.mock.method("error").withAnyArgs.once;
	 		processor.logger = logger;
	 		processor.setUpMetadataTag(metadataTag, decoratedBean);
			logger.mock.verify();
			signal.mock.verify();
		}
		
		public function test_set_signalPackages():void {
			processor.signalPackages = "a.b.c";
			assertEquals(1, processor.signalPackages.length);
			assertEquals("a.b.c", processor.signalPackages[0]);
			
			processor.signalPackages = ["a.b.c", "d.e.f"];
			assertEquals(2, processor.signalPackages.length);
			assertEquals("a.b.c", processor.signalPackages[0]);
			assertEquals("d.e.f", processor.signalPackages[1]);
			
			processor.signalPackages = "a.b.c, d.e.f";
			assertEquals(2, processor.signalPackages.length);
			assertEquals("a.b.c", processor.signalPackages[0]);
			assertEquals("d.e.f", processor.signalPackages[1]);
		}
				
		private function createMetadataTag(args:Array, hostNode:XML):IMetadataTag {
			var metadataTag:IMetadataTag = new BaseMetadataTag();
			metadataTag.args = args;
			var factory:MetadataHostFactory = new MetadataHostFactory(ApplicationDomain.currentDomain);
			metadataTag.host = factory.getMetadataHost(hostNode);
			return metadataTag;
		}
	}
}
