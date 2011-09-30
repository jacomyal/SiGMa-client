package ofnodesandedges.y2011.sigma{
	
	import com.adobe.serialization.json.JSON;
	import com.ofnodesandedges.y2011.core.control.CoreControler;
	import com.ofnodesandedges.y2011.core.data.Graph;
	import com.ofnodesandedges.y2011.core.drawing.GraphDrawer;
	import com.ofnodesandedges.y2011.core.interaction.Glasses;
	import com.ofnodesandedges.y2011.core.interaction.InteractionControler;
	import com.ofnodesandedges.y2011.core.layout.RotationLayout;
	import com.ofnodesandedges.y2011.core.layout.forceAtlas.ForceAtlas;
	import com.ofnodesandedges.y2011.utils.ContentEvent;
	
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.system.Security;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class Initializer extends Sprite{
		
		private var _configPath:String;
		private var _config:Object;
		
		public function Initializer(){}
		
		public function init():void{
			RotationLayout;
			
			Security.allowDomain("*");
			
			// Core initialization:
			CoreControler.init(stage,stage.stageWidth,stage.stageHeight);
			ForceAtlas.initAlgo();
			stage.addEventListener(Event.RESIZE,onResize);
			
			// Load config:
			_config = {};
			
			var configPath:String = stage.loaderInfo.parameters['configPath'];
			configPath = configPath ? configPath : '../data/config.json';
			
			var urlRequest:URLRequest = new URLRequest(configPath);
			var urlLoader:URLLoader = new URLLoader(urlRequest);
			urlLoader.addEventListener(Event.COMPLETE,onLoadingComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR,onLoadingError);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR,onLoadingError);
		}
		
		private function onResize(e:Event):void{
			CoreControler.resize(stage.stageWidth,stage.stageHeight);
		}
		
		private function onLoadingError(e:Event):void{
			displayErrorMessage(e.type);
		}
		
		private function onLoadingComplete(e:Event):void{
			try{
				_config = JSON.decode(URLLoader(e.target).data);
			}catch(e:Error){
				displayErrorMessage("Can't read JSON config file ('"+e.message+"')");
			}
			
			// Init params:
			ParamsManager.initParams(_config['parameters'] ? _config['parameters'] : {});
			ParamsManager.initCallbacks(_config['callbacks'] ? _config['callbacks'] : {});
			
			initSigmaCore();
		}
		
		private function initSigmaCore():void{
			// Initial settings:
			CoreControler.displayNodes = ParamsManager.params['displayNodes'];
			CoreControler.displayEdges = ParamsManager.params['displayEdges'];
			CoreControler.displayLabels = ParamsManager.params['displayLabels'];
			CoreControler.edgeSizes = ParamsManager.params['useEdgeSizes'];
			Graph.defaultEdgeType = ParamsManager.params['defaultEdgeType'];
			
			CoreControler.minDisplaySize = ParamsManager.params['minDisplaySize'];
			CoreControler.maxDisplaySize = ParamsManager.params['maxDisplaySize'];
			CoreControler.minDisplayThickness = ParamsManager.params['minDisplayThickness'];
			CoreControler.maxDisplayThickness = ParamsManager.params['maxDisplayThickness'];
			CoreControler.textThreshold = ParamsManager.params['textThreshold'];
			
			GraphDrawer.setNodesColor(ParamsManager.params['nodesColor']);
			GraphDrawer.setEdgesColor(ParamsManager.params['edgesColor']);
			GraphDrawer.setLabelsColor(ParamsManager.params['labelsColor']);
			
			GraphDrawer.fontName = ParamsManager.params['fontName'];
			
			// Callbacks:
			if(ExternalInterface.available){
				// Sigma methods:
				ExternalInterface.addCallback("deleteGraph",Graph.deleteGraph);
				ExternalInterface.addCallback("pushGraph",SigmaMethods.pushGraph);
				ExternalInterface.addCallback("updateGraph",SigmaMethods.updateGraph);
				ExternalInterface.addCallback("resetGraphPosition",SigmaMethods.resetGraphPosition);
				
				ExternalInterface.addCallback("activateFishEye",function():void{CoreControler.addPostProcessHook(Glasses.fishEyeDisplay);});
				ExternalInterface.addCallback("deactivateFishEye",function():void{CoreControler.removePostProcessHook(Glasses.fishEyeDisplay);});
				ExternalInterface.addCallback("isFishEye",function():Boolean{return CoreControler.hasPostProcessHook(Glasses.fishEyeDisplay);});
				
				ExternalInterface.addCallback("setDisplayEdges",function(value:Boolean):void{CoreControler.displayEdges = value;});
				ExternalInterface.addCallback("getDisplayEdges",function():Boolean{return CoreControler.displayEdges;});
				ExternalInterface.addCallback("setDisplayNodes",function(value:Boolean):void{CoreControler.displayNodes = value;});
				ExternalInterface.addCallback("getDisplayNodes",function():Boolean{return CoreControler.displayNodes;});
				ExternalInterface.addCallback("setDisplayLabels",function(value:Boolean):void{CoreControler.displayLabels = value;});
				ExternalInterface.addCallback("getDisplayLabels",function():Boolean{return CoreControler.displayLabels;});
				ExternalInterface.addCallback("setUseEdgeSizes",function(value:Boolean):void{CoreControler.edgeSizes = value;});
				ExternalInterface.addCallback("getUseEdgeSizes",function():Boolean{return CoreControler.edgeSizes;});
				ExternalInterface.addCallback("setDefaultEdgeType",function(value:int):void{Graph.defaultEdgeType = value;});
				ExternalInterface.addCallback("getDefaultEdgeType",function():int{return Graph.defaultEdgeType;});
				
				ExternalInterface.addCallback("setMinDisplaySize",function(value:Number):void{CoreControler.minDisplaySize = value;});
				ExternalInterface.addCallback("getMinDisplaySize",function():Number{return CoreControler.minDisplaySize;});
				ExternalInterface.addCallback("setMaxDisplaySize",function(value:Number):void{CoreControler.maxDisplaySize = value;});
				ExternalInterface.addCallback("getMaxDisplaySize",function():Number{return CoreControler.maxDisplaySize;});
				ExternalInterface.addCallback("setMinDisplayThickness",function(value:Number):void{CoreControler.minDisplayThickness = value;});
				ExternalInterface.addCallback("getMinDisplayThickness",function():Number{return CoreControler.minDisplayThickness;});
				ExternalInterface.addCallback("setMaxDisplayThickness",function(value:Number):void{CoreControler.maxDisplayThickness = value;});
				ExternalInterface.addCallback("getMaxDisplayThickness",function():Number{return CoreControler.maxDisplayThickness;});
				
				ExternalInterface.addCallback("changeNodesColor",SigmaMethods.setColor);
				ExternalInterface.addCallback("changeNodesSize",SigmaMethods.setSize);
				
				ExternalInterface.addCallback("killForceAtlas",ForceAtlas.killAlgo);
				ExternalInterface.addCallback("initForceAtlas",ForceAtlas.initAlgo);
				
				// External callbacks:
				if(ParamsManager.callbacks['onClickNodes']){
					InteractionControler.addEventListener(InteractionControler.CLICK_NODES,function(e:ContentEvent):void{
						ExternalInterface.call(ParamsManager.callbacks['onClickNodes'],e.content);
					});
				}
				
				if(ParamsManager.callbacks['onOverNodes']){
					InteractionControler.addEventListener(InteractionControler.OVER_NODES,function(e:ContentEvent):void{
						ExternalInterface.call(ParamsManager.callbacks['onOverNodes'],e.content);
					});
				}
				
				// Ready:
				ExternalInterface.call(ParamsManager.callbacks['onReady']);
			}else{
				displayErrorMessage('ExternalInterface is not available.');
			}
		}
		
		private function displayErrorMessage(str:String):void{
			var s:Stage = stage;
			
			s.removeEventListener(Event.RESIZE,onResize);
			CoreControler.kill(true);
			
			while(s.numChildren){ s.removeChildAt(0); }
			
			var tf:TextField = TextField(s.addChild(new TextField()));
			tf.defaultTextFormat = new TextFormat('arial',12);
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = str;
			
			tf.x = s.stageWidth/2-tf.width/2;
			tf.y = s.stageHeight/2-tf.height/2;
			
			s.addEventListener(Event.RESIZE,function(e:Event):void{
				tf.x = s.stageWidth/2-tf.width/2;
				tf.y = s.stageHeight/2-tf.height/2;
			});
		}
	}
}