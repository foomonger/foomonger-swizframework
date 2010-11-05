/*
Copyright 2010 Samuel Ahn

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

package com.foomonger.swizframework.processors {

	import flash.system.ApplicationDomain;
	
	import org.osflash.signals.IPrioritySignal;
	import org.osflash.signals.ISignal;
	import org.swizframework.core.Bean;
	import org.swizframework.processors.BaseMetadataProcessor;
	import org.swizframework.processors.ProcessorPriority;
	import org.swizframework.reflection.BaseMetadataTag;
	import org.swizframework.reflection.IMetadataTag;
	import org.swizframework.reflection.MetadataArg;
	import org.swizframework.reflection.MetadataHostMethod;
	import org.swizframework.reflection.MethodParameter;
	import org.swizframework.utils.logging.SwizLogger;

	/**
	 * SignalHandlerProcessor is the Signal version of EventHandlerProcessor. 
	 * After defining Signal Beans, decorate Signal listener methods with the 
	 * [SignalHandler] metadata tag and set a bean name ("name" property) or 
	 * type ("type" property) which is useful when subclassing Signals. 
	 * "name" is the default property. You may also use the "priority" property 
	 * for DeluxeSignals. 
	 */ 
	public class SignalHandlerProcessor extends BaseMetadataProcessor {

		protected static const SIGNAL_HANDLER:String = "SignalHandler";
		
		protected static const WILDCARD_PACKAGE:RegExp = /\A(.*)(\.\**)\Z/;
		
		internal var logger:SwizLogger = SwizLogger.getLogger(this);
		
		protected var _signalPackages:Array = [];

		public var strictArgumentTypes:Boolean = false;
	
		public function get signalPackages():Array {
			return _signalPackages;
		}
				
		public function set signalPackages(value:*):void {
			_signalPackages = parsePackageValue(value);
		}
		
		override public function get priority():int {
			return ProcessorPriority.EVENT_HANDLER - 1;
		}
 
		public function SignalHandlerProcessor() {
			super([SIGNAL_HANDLER]);
		}
 
		override public function setUpMetadataTag(metadataTag:IMetadataTag, bean:Bean):void {
			var signalBean:Bean = getSignalBean(metadataTag);
			
			if (signalBean == null) {
				logger.error("[SignalHandlerProcessor] Bean not found for tag {0}", (metadataTag as BaseMetadataTag).asTag);
				return;
			}
			if (!(signalBean.source is ISignal) && !(signalBean.source is IPrioritySignal)) {
				logger.error("[SignalHandlerProcessor] Bean source is not a Signal for tag {0}", (metadataTag as BaseMetadataTag).asTag);
				return;
			}
			var hostParameters:Array = (metadataTag.host as MetadataHostMethod).parameters;
			var signalValueClasses:Array = (signalBean.source["valueClasses"] as Array)
											? signalBean.source["valueClasses"] as Array
											: [];
			
			if (!isValidHostArguments(hostParameters, signalValueClasses)) {
				logger.error("[SignalHandlerProcessor] Invalid Signal listener arguments. {0}.{1}()", String(bean.source), metadataTag.host.name);
				return;
			}
			
			var listener:Function = bean.source[metadataTag.host.name];
			
			if (signalBean.source is ISignal) {
				if (signalBean.source is IPrioritySignal) {
					var prioritySignal:IPrioritySignal = signalBean.source as IPrioritySignal;
					var priorityArg:MetadataArg = metadataTag.getArg("priority");
					var priority:int = priorityArg ? int(priorityArg.value) : 0; 
					prioritySignal.addWithPriority(listener, priority);
				} else {
					var signal:ISignal = signalBean.source as ISignal;
					signal.add(listener);
				}
			}
		}
						
		override public function tearDownMetadataTag(metadataTag:IMetadataTag, bean:Bean):void {
			var signalBean:Bean = getSignalBean(metadataTag);
			
			if (signalBean) {
				var listener:Function = bean.source[metadataTag.host.name];
				
				if (signalBean.source is ISignal) {
					var signal:ISignal = signalBean.source as ISignal;
					signal.remove(listener);
				} else if (signalBean.source is IPrioritySignal) {
					var deluxeSignal:IPrioritySignal = signalBean.source as IPrioritySignal; 
					deluxeSignal.remove(listener);
				}
			}
		}
 
		protected function getSignalBean(metadataTag:IMetadataTag):Bean {
			var signalBean:Bean;
			
			// First find Bean by name
			var beanName:String;
			var defaultArg:MetadataArg = metadataTag.getArg("");
			if (defaultArg) {
				beanName = defaultArg.value;
			} else {
				var nameArg:MetadataArg = metadataTag.getArg("name");
				if (nameArg) {
					beanName = nameArg.value;
				}
			}
			if (beanName) {
				signalBean = beanFactory.getBeanByName(beanName)
			}
			
			// If not found by Name, then find by Type
			if (signalBean == null) {
				var typeArg:MetadataArg = metadataTag.getArg("type");
				if (typeArg) {
					var type:Class;
					if (signalPackages.length > 0) {
						type = findClassDefinition(swiz.domain, typeArg.value, signalPackages);
					} else {
						type = getClassDefinition(swiz.domain, typeArg.value) as Class;
					}
					if (type) {
						signalBean = beanFactory.getBeanByType(type);
					}
				}
			}

			return signalBean;
		}
		
		protected function isValidHostArguments(hostParameters:Array, signalValueClasses:Array):Boolean {
			// Compare lengths
			if (hostParameters.length != signalValueClasses.length) {
				return false;
			}
			// If strict mode, then check types
			if (strictArgumentTypes) {
				hostParameters.sortOn("index", Array.NUMERIC);
				var ilen:int = signalValueClasses.length;
				var hostParameter:MethodParameter;
				var signalValueClass:Class;
				for (var i:int = 0; i < ilen; i++) {
					signalValueClass = signalValueClasses[i] as Class;
					hostParameter = hostParameters[i] as MethodParameter;
					// It would be nice if this accounted for interface implementations
					if (signalValueClass != hostParameter.type) {
						return false;
					}
				}
			}
			
			return true;
		}
		
		/*
		Parser method copied from SwizConfig so that logic is consitent with eventPackages.
		*/
		
		protected static function parsePackageValue(value:*):Array {
			if (value == null) {
				return [];
			} else if (value is Array) {
				return parsePackageNames(value as Array);
			} else if (value is String) {
				return parsePackageNames(value.replace( /\ /g, "" ).split( "," ));
			} else {
				throw new Error("Package specified using unknown type. Supported types are Array or String.");
			}
		}

		protected static function parsePackageNames( packageNames:Array):Array {
			var parsedPackageNames:Array = [];
			
			for each(var packageName:String in packageNames) {
				parsedPackageNames.push(parsePackageName(packageName));
			}
			
			return parsedPackageNames;
		}
		
		protected static function parsePackageName(packageName:String):String {
			var match:Object = WILDCARD_PACKAGE.exec(packageName);
			if (match) {
				return match[1];
			}
			return packageName;
		}
		
		/*
		Lookup logic copied from ClassConstant.
		*/
		protected static function findClassDefinition(domain:ApplicationDomain, className:String, packageNames:Array):Class {
			for each (var packageName:String in packageNames) {
				var definition:Class = getClassDefinition(domain, packageName + "." + className);
				if (definition != null) {
					return definition;
				}
			}
			
			return null;
		}
		
		protected static function getClassDefinition(domain:ApplicationDomain, name:String):Class {
			try {
				return domain.getDefinition( name ) as Class;
			} catch( e:ReferenceError ) {}
			
			return null;
		}
	}
}