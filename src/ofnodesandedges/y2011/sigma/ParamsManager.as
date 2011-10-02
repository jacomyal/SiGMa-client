package ofnodesandedges.y2011.sigma{
	import com.ofnodesandedges.y2011.core.drawing.EdgeDrawer;
	
	public class ParamsManager{
		
		private static var _params:Object;
		private static var _callbacks:Object;
		
		public static function initParams(obj:Object):void{
			// Default params:
			_params = {
				// BOOLEANS:
				'displayEdges': true,
				'displayNodes': true,
				'displayLabels': true,
				'useEdgeSizes': true,
				// NUMBERS:
				'minDisplaySize': 2,
				'maxDisplaySize': 6,
				'minDisplayThickness': 0.1,
				'maxDisplayThickness': 0.5,
				'textThreshold': 3.5,
				// COLORS:
				'nodesColor': 0xaaaaaa,
				'edgesColor': 0x888888,
				'labelsColor': 0x444444,
				// STRINGS:
				'fontName': 'Helvetica'
			};
			
			for(var key:String in obj){
				switch(key){
					// BOOLEANS:
					case 'displayEdges':
					case 'displayNodes':
					case 'displayLabels':
					case 'useEdgeSizes':
						_params[key] = Boolean(obj[key]);
						break;
					// NUMBERS:
					case 'minDisplaySize':
					case 'maxDisplaySize':
					case 'minDisplayThickness':
					case 'maxDisplayThickness':
					case 'textThreshold':
						_params[key] = Number(obj[key]);
						break;
					// COLORS:
					case 'nodesColor':
					case 'edgesColor':
					case 'labelsColor':
						_params[key] = SigmaMethods.getColor(obj[key]);
						break;
					// STRINGS:
					case 'defaultEdgeType':
						switch(obj[key].toString().toLowerCase()){
							case 'none':
							case '0':
								_params[key] = EdgeDrawer.NONE;
								break;
							case 'line':
							case '1':
								_params[key] = EdgeDrawer.LINE;
								break;
							case 'curve':
							case '2':
								_params[key] = EdgeDrawer.CURVE;
								break;
							case 'arrow':
							case '3':
								_params[key] = EdgeDrawer.ARROW;
								break;
						}
					default:
						_params[key] = obj[key];
				}
			}
			
		}
		
		public static function initCallbacks(obj:Object):void{
			// Default params:
			_callbacks = {
				'onReady': '',
				'onClickNodes': '',
				'onOverNodes': ''
			};
			
			for(var key:String in obj){
				_callbacks[key] = obj[key];
			}
			
		}

		public static function get params():Object{
			return _params;
		}
		
		public static function get callbacks():Object{
			return _callbacks;
		}

	}
}