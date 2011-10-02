package ofnodesandedges.y2011.sigma.loading{
	
	import ofnodesandedges.y2011.sigma.utils.ColorsManager;
	
	public class LoaderGDF extends FileLoader{
		
		private var _nodeLineStart:Array = ['nodedef>name', 'nodedef> name', 'Nodedef>name', 'Nodedef> name', 'nodedef>"name', 'nodedef> "name', 'Nodedef>"name', 'Nodedef> "name'];
		private var _edgeLineStart:Array = ['edgedef>', 'Edgedef>'];
		
		private var _nodesData:Array;
		private var _edgesData:Array;
		
		private var _nodeIdIndex:int = -1;
		private var _nodeLabelIndex:int = -1;
		private var _nodeXIndex:int = -1;
		private var _nodeYIndex:int = -1;
		private var _nodeSizeIndex:int = -1;
		private var _nodeColorIndex:int = -1;
		
		private var _edgeSourceIndex:int = -1;
		private var _edgeTargetIndex:int = -1;
		
		private var _hasNodeIndexes:Boolean;
		private var _hasEdgeIndexes:Boolean;
		
		private var _nodeAttributes:Object = {};
		private var _edgeAttributes:Object = {};
		
		public function LoaderGDF(){}
		
		protected override function parseFile(data:String):void{
			var line:String;
			var lines:Array = data.replace('\n\r','\n').replace('\r','\n').split("\n");
			
			var nodesCounter:int = 0;
			var edgesCounter:int = 0;
			
			_hasNodeIndexes = false;
			_hasEdgeIndexes = false;
			
			for(var i:int=0;i<lines.length;i++){
				line = lines[i];
				
				if(isNodesFirstLine(line)){
					_hasNodeIndexes = true;
					setNodesData(line);
				}else if(isEdgesFirstLine(line)){
					_hasEdgeIndexes = true;
					setEdgesData(line);
				}else if(_hasEdgeIndexes){
					addEdge(line,edgesCounter);
					edgesCounter ++;
				}else if(_hasNodeIndexes){
					addNode(line,nodesCounter);
					nodesCounter ++;
				}
			}
		}
		
		private function isNodesFirstLine(line:String):Boolean{
			for each(var s:String in _nodeLineStart){
				if (line.indexOf(s)>=0){
					return true;
				}
			}
			
			return false;
		}
		
		private function isEdgesFirstLine(line:String):Boolean{
			for each(var s:String in _edgeLineStart){
				if (line.indexOf(s)>=0){
					return true;
				}
			}
			
			return false;
		}
		
		private function addNode(line:String,counter:int):void{
			var id:String = counter.toString();
			var label:String = null;
			var node:Object = {};
			
			var adaptedLine:String = line.substr(line.indexOf(">")+1);
			adaptedLine = adaptedLine.replace(', ',',').replace(' ,',',');
			
			var array:Array = customSplit(adaptedLine);
			
			var x:Number;
			var y:Number;
			var size:Number = 0;
			var color:uint = 0;
			var hasLocalColor:Boolean = false
			var b:String;
			var g:String;
			var r:String;
			
			var hasX:Boolean = false;
			var hasY:Boolean = false;
			
			var attributes:Object = new Object();
			
			for(var i:int=0;i<array.length;i++){
				switch(i){
					case _nodeIdIndex:
						id = array[i];
						break;
					case _nodeLabelIndex:
						label = clean(array[i]);
						break;
					case _nodeXIndex:
						x = new Number(array[i]);
						hasX = true;
						break;
					case _nodeYIndex:
						y = new Number(array[i]);
						hasY = true;
						break;
					case _nodeSizeIndex:
						size = new Number(array[i]);
						break;
					case _nodeColorIndex:
						if(array[i].split(',').length>2){
							r = clean(array[i].split(',')[0]);
							g = clean(array[i].split(',')[1]);
							b = clean(array[i].split(',')[2]);
							color = ColorsManager.getColor(r,g,b);
							
							hasLocalColor = true;
						}
						break;
					default:
						attributes[_nodesData[i]['key']] = array[i];
						break;
				}
			}
			
			node['label'] = label;
			node['id'] = id;
			
			if(hasX&&hasY){
				node['x'] = x;
				node['y'] = -y;
			}
			
			if(size>0) node['size'] = size;
			
			if(hasLocalColor) node['color'] = color;
			
			for(var key:String in attributes){
				node[key] = attributes[key];
			}
			
			_graph['nodes'].push(node);
		}
		
		private function addEdge(line:String,counter:int):void{
			var adaptedLine:String = line.substr(line.indexOf(">")+1);
			adaptedLine = adaptedLine.replace(', ',',').replace(' ,',',');
			
			var array:Array = customSplit(adaptedLine);
			var edge:Object = {'id':counter.toString()};
			
			for(var i:int=0;i<array.length;i++){
				switch(i){
					case _edgeSourceIndex:
						edge['sourceID'] = array[i];
						break;
					case _edgeTargetIndex:
						edge['targetID'] = array[i];
						break;
					default:
						edge[_edgesData[i]['key']] = array[i];
						break;
				}
			}
			
			if((edge['source']!='')&&(edge['target']!='')){
				_graph['edges'].push(edge);
			}
		}
		
		private function setNodesData(line:String):void{
			_nodesData = [];
			
			var adaptedLine:String = line.substr(line.indexOf(">")+1);
			adaptedLine = adaptedLine.replace(', ',',').replace(' ,',',');
			
			var array:Array = customSplit(adaptedLine);
			var s:String;
			var attTitle:String;
			var attType:String;
			
			for(var i:int = 0;i<array.length;i++){
				s = array[i];
				
				if(s.indexOf(' ')>=0){
					attTitle = s.split(' ')[0];
					attType = s.split(' ')[1];
				}else{
					attTitle = s;
					attType = '';
				}
				
				switch(clean(attType).toLowerCase()){
					case "varchar":
					case "string":
						attType = "string";
						break;
					case "integer":
					case "int":
						attType = "int";
						break;
					case "double":
					case "long":
						attType = "number";
						break;
					default:
						attType = "string";
						break;
				}
				
				_nodesData.push({'key': attTitle, 'type': attType, 'index': i});
				
				switch(clean(attTitle).toLowerCase()){
					case "label":
						_nodeLabelIndex = i;
						break;
					case "color":
						_nodeColorIndex = i;
						break;
					case "x":
						_nodeXIndex = i;
						break;
					case "y":
						_nodeYIndex = i;
						break;
					case "height":
					case "width":
					case "size":
						_nodeSizeIndex = i;
						break;
					case "id":
					case "name":
						_nodeIdIndex = i;
						break;
					default:
						if(i==0){
							_nodeIdIndex = i;
						}
						break;
				}
			}
		}
		
		private function setEdgesData(line:String):void{
			_edgesData = [];
			
			var adaptedLine:String = line.substr(line.indexOf(">")+1);
			adaptedLine = adaptedLine.replace(', ',',').replace(' ,',',');
			
			var array:Array = customSplit(adaptedLine);
			var s:String;
			var attTitle:String;
			var attType:String;
			
			for(var i:int = 0;i<array.length;i++){
				s = array[i];
				
				if(s.indexOf(' ')>=0){
					attTitle = s.split(' ')[0];
					attType = s.split(' ')[1];
				}else{
					attTitle = s;
					attType = '';
				}
				
				switch(clean(attType).toLowerCase()){
					case "varchar":
					case "string":
						attType = "string";
						break;
					case "integer":
					case "int":
						attType = "int";
						break;
					case "double":
					case "long":
						attType = "number";
						break;
					default:
						attType = "string";
						break;
				}
				
				_edgesData.push({'key': attTitle, 'type': attType, 'index': i});
				
				switch(clean(attTitle).toLowerCase()){
					case "node_1":
					case "source":
					case "node1":
						_edgeSourceIndex = i;
						break;
					case "node_2":
					case "target":
					case "node2":
						_edgeTargetIndex = i;
						break;
					default:
						break;
				}
			}
		}
		
		private function customSplit(s:String):Array{
			var res:Array = new Array();
			var containerChar:String;
			var inContainer:Boolean = false;
			var containers:Array = ["'","'",'"','"','(',')','[',']','{','}'];
			
			var element:String = '';
			var char:String;
			
			for(var parser:int=0;parser<s.length;parser++){
				char = s.charAt(parser);
				
				if(inContainer==true){
					if(char==containerChar){
						inContainer = false;
						containerChar = '';
						
						element += char;
					}else{
						element += char;  
					}
				}else{
					if((containers.indexOf(char)>=0)&&(element=='')){
						inContainer = true;
						containerChar = containers[containers.indexOf(char)+1];
						
						element += char;
					}else if(char==','){
						res.push(clean(element));
						element = '';
					}else{
						element += char;  
					}
				}
			}
			
			res.push(clean(element));
			
			return res;
		}
		
		private function clean(s:String):String{
			var res:String = s;
			
			var hasChanged:Boolean = true;
			
			while((hasChanged==true)&&(res.length>1)){
				hasChanged = false;
				if((res.indexOf(' ')==0)||(res.indexOf('"')==0)||(res.indexOf("'")==0)){
					res = res.substr(1);
					hasChanged = true;
				}
				
				if((res.indexOf(' ')==res.length-1)||(res.indexOf('"')==res.length-1)||(res.indexOf("'")==res.length-1)){
					res = res.substr(0,res.length-1);
					hasChanged = true;
				}
			}
			
			return res;
		}
	}
}