package com.foomonger.swizframework.processors {
	
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.utils.describeType;
	
	import flexunit.framework.TestCase;
	
	import org.swizframework.core.Bean;
	import org.swizframework.core.BeanProvider;
	import org.swizframework.core.IBeanProvider;
	import org.swizframework.core.ISwiz;
	import org.swizframework.core.Swiz;
	import org.swizframework.core.SwizConfig;
	import org.swizframework.factories.MetadataHostFactory;
	import org.swizframework.reflection.BaseMetadataTag;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.TypeDescriptor;
	import org.swizframework.utils.logging.SwizLogger;
	
	public class LoggerProcessorTest extends TestCase {
		
		private static const HOST_NAME:String = "logger";
		
		private var swiz:ISwiz;
		private var processor:LoggerProcessor;
		private var beanProvider:IBeanProvider;
		private var decoratedBean:Bean;
		private var decoratedBeanSource:Object;
		private var propertyHostNode:XML;
		
		public function LoggerProcessorTest(methodName:String=null) {
			super(methodName);
			propertyHostNode = <variable name={HOST_NAME} type="org.swizframework.utils.logging::SwizLogger"/>;

		}
		
		override public function setUp():void {
			decoratedBeanSource = new Object();
			decoratedBean = new Bean(decoratedBeanSource, "beanSource", new TypeDescriptor().fromXML(describeType(decoratedBeanSource), ApplicationDomain.currentDomain));
			beanProvider = new BeanProvider();
			beanProvider.addBean(decoratedBean);
			processor = new LoggerProcessor();
			swiz = new Swiz(new EventDispatcher(), new SwizConfig(), null, [beanProvider], [processor]);			
			swiz.init();
			processor.init(swiz);
		}
		
		public function test_setUp_tearDown():void {
			var metadataTag:IMetadataTag = createMetadataTag([], propertyHostNode);
			// Null to start
			assertNull(decoratedBeanSource[HOST_NAME]);
			// Set up
			processor.setUpMetadataTag(metadataTag, decoratedBean);
			// Property should be a SwizLogger
			assertNotNull(decoratedBeanSource[HOST_NAME]);
			assertTrue(decoratedBeanSource[HOST_NAME] is SwizLogger);
			// Tear down
			processor.tearDownMetadataTag(metadataTag, decoratedBean);
			// Now it should be null
			assertNull(decoratedBeanSource[HOST_NAME]);
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
