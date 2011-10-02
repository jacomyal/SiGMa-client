package ofnodesandedges.y2011.sigma.loading{
	
	import com.ofnodesandedges.y2011.core.data.Graph;
	
	import ofnodesandedges.y2011.sigma.utils.ColorsManager;
	
	public class LoaderGEXF extends FileLoader{
		
		private var _nodeAttributes:Object;
		private var _edgeAttributes:Object;
		
		public function LoaderGEXF(){}
		
		protected override function parseFile(data:String):void{
			_nodeAttributes = {};
			_edgeAttributes = {};
			
			var xml:XML = new XML(data);
			
			var xmlRoot:XMLList = xml.elements();
			var xmlMeta:XMLList;
			var xmlGraph:XMLList;
			var xmlGraphAttributes:XMLList;
			var xmlNodes:XMLList;
			var xmlEdges:XMLList;
			var xmlNodesAttributes:XMLList;
			var xmlEdgesAttributes:XMLList;
			
			var xmlCursor:XML;
			
			// Parse at depth:=1:
			for(var i:int=0;i<xmlRoot.length();i++){
				if(xmlRoot[i].name().localName=='meta'){
					xmlMeta = xmlRoot[i].children();
				}else if(xmlRoot[i].name().localName=='graph'){
					xmlGraph = xmlRoot[i].children();
					xmlGraphAttributes = xmlRoot[i].attributes();
				}
			}
			
			// Parse graph attributes for the background:
			for(i=0;i<xmlGraphAttributes.length();i++){
				if(xmlGraphAttributes[i].name().localName=='defaultedgetype'){
					Graph.defaultEdgeType = xmlGraphAttributes[i].valueOf();
				}
			}
			
			// Parse at depth:=2:
			for(i=0;i<xmlGraph.length();i++){
				if((xmlGraph[i].name().localName=='attributes')&&(xmlGraph[i].attribute("class")=='node')){
					xmlNodesAttributes = xmlGraph[i].children();
				}else if((xmlGraph[i].name().localName=='attributes')&&(xmlGraph[i].attribute("class")=='edge')){
					xmlEdgesAttributes = xmlGraph[i].children();
				}else if(xmlGraph[i].name().localName=='nodes'){
					xmlNodes = xmlGraph[i].children();
				}else if(xmlGraph[i].name().localName=='edges'){
					xmlEdges = xmlGraph[i].children();
				}
			}
			
			// Now we can easily parse all metadata...
			if(xmlMeta!=null){
				for each(xmlCursor in xmlMeta){
					Graph.metaData[xmlCursor.name().localName] = xmlCursor.text();
				}
			}
			
			// ..., node attributes...
			var attId:String;
			var attTitle:String;
			var attType:String;
			var attDefault:*;
			
			if(xmlNodesAttributes!=null){
				var nodeAttributesCounter:int = 0;
				for each(xmlCursor in xmlNodesAttributes){
					if(xmlCursor.name().localName=="attribute"){
						attId = (xmlCursor.@id!=undefined) ? xmlCursor.@id : null;
						attTitle = (xmlCursor.@title!=undefined) ? xmlCursor.@title : null;
						attType = (xmlCursor.@type!=undefined) ? xmlCursor.@type : "String";
						attDefault = null;
						
						for each(xmlSubCursor in xmlCursor.children()){
							// Position:
							if(xmlSubCursor.name().localName=='default'){
								attDefault = getDefaultVar(xmlSubCursor.text(),attType);
							}
						}
						
						if((attId!=null)&&(attTitle!=null)){
							_nodeAttributes[attId] = {'label': attTitle, 'type': attType, 'default': attDefault};
							nodeAttributesCounter++;
						}
					}
				}
			}
			
			// ..., edge attributes...
			if(xmlEdgesAttributes!=null){
				var edgeAttributesCounter:int = 0;
				for each(xmlCursor in xmlEdgesAttributes){
					if(xmlCursor.name().localName=="attribute"){
						attId = (xmlCursor.@id!=undefined) ? xmlCursor.@id : null;
						attTitle = (xmlCursor.@title!=undefined) ? xmlCursor.@title : null;
						attId = (xmlCursor.@type!=undefined) ? xmlCursor.@type : "String";
						attDefault = null;
						
						for each(xmlSubCursor in xmlCursor.children()){
							// Position:
							if(xmlSubCursor.name().localName=='default'){
								attDefault = getDefaultVar(xmlSubCursor.text(),attType);
							}
						}
						
						if((attId!=null)&&(attTitle!=null)){
							_edgeAttributes[attId] = {'label': attTitle, 'type': attType, 'default': attDefault};
							edgeAttributesCounter++;
						}
					}
				}
			}
			
			// ..., nodes...
			var nodesCounter:int = 0;
			var node:Object;
			var xmlSubCursor:XML;
			var xmlNodesAttributesValues:XMLList;
			
			var x:Number;
			var y:Number;
			
			var size:Number;
			var shape:String;
			var b:String;
			var g:String;
			var r:String;
			
			var id:String;
			var label:String;
			
			for each(xmlCursor in xmlNodes){
				label = (xmlCursor.@label!=undefined) ? xmlCursor.@label : null;
				id = (xmlCursor.@id!=undefined) ? xmlCursor.@id : nodesCounter.toString();
				
				node = {'id':id,'label':label};
				
				xmlNodesAttributesValues = null;
				
				for each(xmlSubCursor in xmlCursor.children()){
					// Position:
					if(xmlSubCursor.name().localName=='position'){
						if((xmlSubCursor.attribute("x")!=undefined)&&
						   (xmlSubCursor.attribute("y")!=undefined)){
							x = new Number(xmlSubCursor.attribute("x"));
							y = new Number(xmlSubCursor.attribute("y"));
							
							node['x'] = x;
							node['y'] = -y;
						}
					}
					
					// Color:
					if(xmlSubCursor.name().localName=='color'){
						if((xmlSubCursor.attribute("b")!=undefined)&&
						   (xmlSubCursor.attribute("g")!=undefined)&&
						   (xmlSubCursor.attribute("r")!=undefined)){
							r = xmlSubCursor.attribute("r");
							g = xmlSubCursor.attribute("g");
							b = xmlSubCursor.attribute("b");
							
							node['color'] = ColorsManager.getColor(r,g,b);
						}
					}
					
					// Size:
					if(xmlSubCursor.name().localName=='size'){
						if(xmlSubCursor.@value!=undefined){
							size = new Number(xmlSubCursor.@value);
							node['size'] = size;
						}
					}
					
					// Shape:
					if(xmlSubCursor.name().localName=='shape'){
						if(xmlSubCursor.@value!=undefined){
							shape = xmlSubCursor.@value;
							node['shape'] = shape;
						}
					}
					
					// Old format attributes container, see below:
					if(xmlSubCursor.name().localName=='attvalues'){
						xmlNodesAttributesValues = xmlSubCursor.children();
					}
					
					// New format attributes:
					if(xmlSubCursor.name().localName=='attvalue'){
						if((xmlSubCursor.attribute("for")!=undefined)&&(xmlSubCursor.@value!=undefined)){
							node[xmlSubCursor.attribute("for")] = xmlSubCursor.@value;
						}else if((xmlSubCursor.@id!=undefined)&&(xmlSubCursor.@value!=undefined)){
							node[xmlSubCursor.@id] = xmlSubCursor.@value;
						}
					}
				}
				
				// Old format attributes:
				for each(xmlSubCursor in xmlNodesAttributesValues){
					if(xmlSubCursor.name().localName=='attvalue'){
						if((xmlSubCursor.attribute("for")!=undefined)&&(xmlSubCursor.@value!=undefined)){
							node[xmlSubCursor.attribute("for")] = xmlSubCursor.@value;
						}else if((xmlSubCursor.@id!=undefined)&&(xmlSubCursor.@value!=undefined)){
							node[xmlSubCursor.@id] = xmlSubCursor.@value;
						}
					}
				}
				
				_graph['nodes'].push(node);
				nodesCounter++;
			}
			
			// ... and edges:
			var edge:Object;
			var edgesCounter:int = 0;
			var xmlEdgesAttributesValues:XMLList;
			
			for each(xmlCursor in xmlEdges){
				edge = {'id': edgesCounter.toString()};
				
				if(xmlCursor.@source!=xmlCursor.@target){
					xmlEdgesAttributesValues = new XMLList();
					
					for each(xmlSubCursor in xmlCursor.children()){
						if(xmlSubCursor.name().localName=='attvalues'){
							xmlEdgesAttributesValues = xmlSubCursor.children();
						}
					}
					
					for each(xmlSubCursor in xmlEdgesAttributesValues){
						if(xmlSubCursor.name().localName=='attvalue'){
							if((xmlSubCursor.attribute("for")!=undefined)&&(xmlSubCursor.@value!=undefined)){
								edge[xmlSubCursor.attribute("for")] = xmlSubCursor.@value;
							}else if((xmlSubCursor.@id!=undefined)&&(xmlSubCursor.@value!=undefined)){
								edge[xmlSubCursor.@id] = xmlSubCursor.@value;
							}
						}
					}
					
					if(xmlCursor.@target){
						edge['sourceID'] = xmlCursor.@source;
						edge['targetID'] = xmlCursor.@target;
						_graph['edges'].push(edge);
					}
					
					edgesCounter++;
				}
			}
		}
		
		private function getDefaultVar(defaultValue:String,type:String):*{
			var res:*;
			
			switch(type.toLowerCase()){
				case 'float':
				case 'long':
				case 'double':
					res = new Number(defaultValue);
					break;
				case 'int':
				case 'integer':
					res = new int(defaultValue);
					break;
				default:
					res = defaultValue;
					break;
			}
			
			return res;
		}
		
	}
}