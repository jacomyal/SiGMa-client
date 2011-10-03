package ofnodesandedges.y2011.sigma{
	
	import com.ofnodesandedges.y2011.core.control.CoreControler;
	import com.ofnodesandedges.y2011.core.data.Edge;
	import com.ofnodesandedges.y2011.core.data.Graph;
	import com.ofnodesandedges.y2011.core.data.Node;
	import com.ofnodesandedges.y2011.core.interaction.InteractionControler;
	import com.ofnodesandedges.y2011.core.layout.CircularLayout;
	import com.ofnodesandedges.y2011.utils.ColorUtils;
	import com.ofnodesandedges.y2011.utils.Trace;
	
	import flash.events.Event;
	import flash.external.ExternalInterface;
	
	import ofnodesandedges.y2011.sigma.loading.FileLoader;
	import ofnodesandedges.y2011.sigma.loading.LoaderGDF;
	import ofnodesandedges.y2011.sigma.loading.LoaderGEXF;
	import ofnodesandedges.y2011.sigma.loading.LoaderJSON;
	
	public class SigmaMethods{
		
		// Graph attributes definition:
		public static const VALUES:String = "values";
		
		public static const TYPE:String = "type";
		public static const NUM:String = "Num";
		public static const STR:String = "Str";
		
		public static const COLOR_MIN:String = "colorMin";
		public static const COLOR_MAX:String = "colorMax";
		public static const COLOR_DEF:String = "default";
		
		public static const FILE_LOADERS:Object = {
			"default": LoaderJSON,
			".gexf": LoaderGEXF,
			".gdf": LoaderGDF,
			".json": LoaderJSON
		};
		
		public static var randomScale:Number = 2000;
		
		public static function pushNode(value:Object):Node{
//			if(value==null) throw(new Error('Error: a node is null.'));
//			if(value['id']==undefined) throw(new Error('Error: node without \'id\' attribute.'));
			
			var nodeObject:Object = value;
			var node:Node = new Node(nodeObject['id'],nodeObject['label'] ? nodeObject['label'] : nodeObject['id']);
			
			for(var key:String in nodeObject){
				switch(key){
					case "x": node.x = int(nodeObject[key]); break;
					case "y": node.y = int(nodeObject[key]); break;
					case "shape": node.shape = int(nodeObject[key]); break;
					case "size": node.size = Number(nodeObject[key]); break;
					case "color": node.color = getColor(nodeObject[key]); break;
					default: node.attributes[key] = nodeObject[key];
				}
			}
			
			// Randomize node positions if null:
			if(node.x==0 && node.y==0){
				node.x = Math.random()*randomScale;
				node.y = Math.random()*randomScale;
			}
			
			return node;
		}
		
		public static function pushEdge(value:Object):Edge{
//			if(value==null) throw(new Error('Error: an edge is null.'));
//			if(value['id']==undefined) throw(new Error('Error: an edge without \'id\' attribute.'));
//			if(value['sourceID']==undefined) throw(new Error('Error: an edge without \'sourceID\' attribute.'));
//			if(value['targetID']==undefined) throw(new Error('Error: an edge without \'targetID\' attribute.'));
			
			var edgeObject:Object = value;
			var edge:Edge = new Edge(edgeObject["id"],edgeObject["sourceID"],edgeObject["targetID"]);
			
			for(var key:String in edgeObject){
				switch(key){
					case "weight": edge.weight = Number(edgeObject[key]); break;
					case "type": edge.type = int(edgeObject[key]); break;
					case "label": edge.label = String(edgeObject[key]); break;
					default: edge.attributes[key] = edgeObject[key];
				}
			}
			
			return edge;
		}
		
		public static function resetGraphPosition():void{
			CoreControler.x = 0;
			CoreControler.y = 0;
			CoreControler.ratio = 1;
		}
		
		public static function pushGraph(value:Object):void{
			if(value is String){
				var ext:String = String(value);
				ext = ext.indexOf('.')>=0 ? ext.substring(ext.lastIndexOf('.'),ext.length) : 'default';
				
				var loader:FileLoader = new (FILE_LOADERS[ext] ? FILE_LOADERS[ext] : FILE_LOADERS['default'])();
				loader.addEventListener(FileLoader.FILE_PARSED,function(e:Event):void{
					pushGraph(loader.graph);
				});
				
				loader.openFile(String(value));
			}else{
				var nodes:Object = value["nodes"];
				var edges:Object = value["edges"];
				
				var newNodes:Vector.<Node> = new Vector.<Node>();
				var newEdges:Vector.<Edge> = new Vector.<Edge>();
				
				var node:Object, edge:Object;
				
				// Nodes:
				for each(node in nodes){
					newNodes.push(pushNode(node));
				}
				
				// Edges:
				for each(edge in edges){
					newEdges.push(pushEdge(edge));
				}
				
				Graph.pushGraph(newNodes,newEdges,false);
			}
		}
		
		public static function updateGraph(value:Object):void{
			if(value is String){
				var ext:String = String(value);
				ext = ext.indexOf('.')>=0 ? ext.substring(ext.lastIndexOf('.'),ext.length) : 'default';
				
				var loader:FileLoader = new (FILE_LOADERS[ext] ? FILE_LOADERS[ext] : FILE_LOADERS['default'])();
				loader.addEventListener(FileLoader.FILE_PARSED,function(e:Event):void{
					updateGraph(loader.graph);
				});
				
				loader.openFile(String(value));
			}else{
				var nodes:Object = value["nodes"];
				var edges:Object = value["edges"];
				
				var newNodes:Vector.<Node> = new Vector.<Node>();
				var newEdges:Vector.<Edge> = new Vector.<Edge>();
				
				var node:Object, edge:Object;
				
				// Nodes:
				for each(node in nodes){
					newNodes.push(pushNode(node));
				}
				
				// Edges:
				for each(edge in edges){
					newEdges.push(pushEdge(edge));
				}
				
				Graph.updateGraph(newNodes,newEdges,true);
			}
		}
		
		public static function setColor(field:String,attributes:Object):void{
			var attribute:Object = attributes[field];
			var node:Node;
			
			if(attribute[TYPE]==NUM){
				var colorMin:uint = uint(attribute[COLOR_MIN]);
				var colorMax:uint = uint(attribute[COLOR_MAX]);
				var colorDef:uint = uint(attribute[COLOR_DEF]);
				
				var minValue:Number = Graph.nodes.length ? (Graph.nodes[0].attributes[field] ? Graph.nodes[0].attributes[field] : 0) : 0;
				var maxValue:Number = Graph.nodes.length ? (Graph.nodes[0].attributes[field] ? Graph.nodes[0].attributes[field] : 0) : 0;
				
				for each(node in Graph.nodes){
					minValue = node.attributes[field] ? Math.min(minValue,node.attributes[field]) : minValue;
					maxValue = node.attributes[field] ? Math.max(maxValue,node.attributes[field]) : maxValue;
				}
				
				for each(node in Graph.nodes){
					node.color = node.attributes[field] ? ColorUtils.inBetweenColor(colorMin,colorMax,(node.attributes[field]-minValue)/(maxValue-minValue)) : colorDef;
				}
			}else if(attribute[TYPE]==STR){
				var defaultColor:uint = uint(attribute[COLOR_DEF]);
				var hasGoodValue:Boolean;
				
				for each(node in Graph.nodes){
					hasGoodValue = false;
					
					for(var value:String in attribute[VALUES]){
						if(node.attributes[field]==value){
							node.color = getColor(attribute[VALUES][value]);
							hasGoodValue = true;
							break;
						}
					}
					
					node.color = hasGoodValue ? node.color : defaultColor;
				}
			}
		}
		
		public static function setSize(field:String):void{
			var node:Node;
			
			for each(node in Graph.nodes){
				node.size = node.attributes[field] ? node.attributes[field] : 1;
			}
		}
		
		public static function getColor(s:*):uint{
			if(s is uint) return s;
			
			var res:uint = 0xFFFFFF;
			if(s.length>=3){
				if(s.substr(0,2)=='0x'){
					res = uint(s);
				}else if(s.charAt(0)=='#'){
					var l:int = s.length-1;
					if(l==3){
						res = uint('0x'+s.charAt(1)+s.charAt(1)+s.charAt(2)+s.charAt(2)+s.charAt(3)+s.charAt(3));
					}else{
						res = uint('0x'+s.substr(1,l));
					}
				}else{
					res = uint('0x'+s);
				}
			}
			
			return res;
		}
	}
}