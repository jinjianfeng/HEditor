package core.panels.node
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import core.panels.base.NumStrInput;
	
	import rawui.UI_StuffItem;
	
	public class StuffItem extends UI_StuffItem
	{
		private var press:Boolean;
		private var pos:Point = new Point();
		private var dragLeft:Boolean = true;
		private var endX:Number;

		private var zeroX:Number;

		private var max:NumStrInput;

		private var lines:LevelLines;

		private var step:Number;
		public function StuffItem()
		{
			super();
		}
		protected override function constructFromXML(xml:XML):void
		{
			super.constructFromXML(xml);
			
//			m_dragStart.addEventListener(MouseEvent.MOUSE_DOWN,down);
//			m_dragEnd.addEventListener(MouseEvent.MOUSE_DOWN,down);
			m_beziBg.addEventListener(MouseEvent.MOUSE_DOWN,down);
			m_beziStart.addEventListener(MouseEvent.MOUSE_DOWN,down);
			m_beziEnd.addEventListener(MouseEvent.MOUSE_DOWN,down);
			this.addEventListener(MouseEvent.MOUSE_UP,up);
			this.addEventListener(MouseEvent.RELEASE_OUTSIDE,up);
			this.addEventListener(MouseEvent.MOUSE_MOVE,move);
			zeroX = m_bezi.x;
			max = m_max as NumStrInput;
			max.toFixedNum = 0;
			max.addBtn(m_addMax,m_subMax);
			lines = new LevelLines();
			m_lines.x = m_bezi.x;
			m_lines.y = m_bezi.y;
			m_lines.setNativeObject(lines);
		}
		
		protected function move(e:Event):void
		{
			if(!press){
				return;
			}
			pos = this.globalToLocal(HEditor.ins.stage.mouseX,HEditor.ins.stage.mouseY);
			changeBeziBox();
		}
		
		public function changeBeziBox():void
		{
			var b:BeziContainer = m_bezi as BeziContainer;
			if(pos.x < zeroX){
				pos.x = zeroX;//限制左越界
			}
			var rightBound:Number = m_beziBg.x + m_beziBg.width;
			if(dragLeft){
				rightBound -= 10;
			}
			if(pos.x > rightBound){
				pos.x = rightBound;//限制右越界
			}
			if(dragLeft){
				endX = isNaN(endX)?(m_beziBg.width+m_beziBg.x):endX;
				b.x = pos.x;
				b.width = endX - b.x;//修改左延展
			}else{
				b.width = pos.x-b.x;//修改右延展
			}
			if(b.width<10){
				b.width = 10;//最小宽度
			}
			b.onSizeChange();
		}
		public function drawLines(num:int):Number{
			m_lines.x = m_bezi.x;
			m_lines.y = m_bezi.y;
			var b:BeziContainer = m_bezi as BeziContainer;
			step = lines.setSize(b.width,b.height,num);
			b.step = step;
			return step;
		}
		protected function up(e:MouseEvent):void
		{
			press = false;
		}
		
		protected function down(e:MouseEvent):void
		{
			var b:BeziContainer = m_bezi as BeziContainer;
			pos = this.globalToLocal(HEditor.ins.stage.mouseX,HEditor.ins.stage.mouseY);
			press = true;
			dragLeft = !(pos.x>(b.x+2));
			endX = b.x+b.width;
		}
		
		public function getNumAtLevel(level:int,maxLevel:int):int
		{
			var b:BeziContainer = m_bezi as BeziContainer;
			if(!b.points || b.points.length!=maxLevel){
				b.draw(true,maxLevel);
			}
			var points:Array = b.points;
			if(points){
				var hh:Number = b.height;
				try
				{
					var n:Number = ((hh-points[level-1].y)/hh);
				}
				catch(e:Error) 
				{
					trace(e.message);
				}
				var out:int = Math.round(n*max.value);
				return out;
			}
			return 1;
		}
	}
}