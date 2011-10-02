package ofnodesandedges.y2011.sigma.loading{
	
	import com.adobe.serialization.json.JSON;
	
	import flash.events.Event;
	
	public class LoaderJSON extends FileLoader{
		
		public function LoaderJSON(){}
		
		protected override function parseFile(data:String):void{
			JSON.decode(data);
		}
	}
}