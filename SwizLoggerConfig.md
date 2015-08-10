Example [SWF](http://www.foomonger.com/swizframework/SwizLoggerConfigExample/SwizLoggerConfigExample.swf) and [Source](http://www.foomonger.com/swizframework/SwizLoggerConfigExample/srcview/).

SwizLoggerConfig is a helper class that makes it easy to declare logging targets in MXML. If you're creating a non-Flex application then yoou should use SwizLogger directly.

Example:
```
<?xml version="1.0" encoding="utf-8"?>
<mx:Application xmlns:mx="http://www.adobe.com/2006/mxml" 
		xmlns:utils="com.foomonger.swizframework.utils.*"
		xmlns:view="example.view.*"
		xmlns:local="*"
		layout="absolute">
	<mx:Script>
		<![CDATA[
			import mx.logging.LogEventLevel;
		]]>
	</mx:Script>
	<utils:SwizLoggerConfig>
		<mx:TraceTarget 
				includeCategory="true" 
				includeDate="false" 
				includeLevel="true" 
				includeTime="true" 
				level="{LogEventLevel.INFO}"
				filters="*"
				fieldSeparator=" | "/>
	</utils:SwizLoggerConfig>
	<local:SwizLoggerConfigExampleSwiz/>
	<view:MainView/>
</mx:Application>
```