﻿package com.partkart{
	import flash.geom.Point;
	import flash.display.*;
	
	public class Segment extends Sprite{
		
		public var p1:Point;
		public var p2:Point;
		
		public var active:Boolean = false;
		
		public var linestyle:int = 0;
		
		public function Segment(point1:Point, point2:Point):void{
			p1 = point1;
			p2 = point2;
		}
		
		public function setLineStyle(style:int):void{
			linestyle = style;
			switch(style){
				case 0: // default black line
					graphics.lineStyle(2,0x333333,1,true,LineScaleMode.NONE);
				break;
				case 1: // highlight line
					graphics.lineStyle(3,0xee4500,1,true,LineScaleMode.NONE);
				break;
				case 2: // semi-transparent guide line
					graphics.lineStyle(1, 0x000000, 0.3, false, LineScaleMode.NONE);
				break;
				/*case 3: // transparent collision line
					graphics.lineStyle(16, 0xff0000, 0, false, LineScaleMode.NONE, CapsStyle.ROUND);
				break;*/
				case 3: // green cut line
					graphics.lineStyle(1,0x007700,1,true,LineScaleMode.NONE);
				break;
				case 4: // thick highlighted green cut line
					graphics.lineStyle(2,0x009911,1,true,LineScaleMode.NONE);
				break;
				case 5: // blue biarc line
					graphics.lineStyle(1,0x2266ee,1,true,LineScaleMode.NONE);
				break;
				case 6: // thick hightlighted blue biarc line
					graphics.lineStyle(2,0x3366ff,1,true,LineScaleMode.NONE);
				break;
			}
		}
		
		public function offset(radius:Number):Boolean{
			
			var delta:Point = new Point(p2.x-p1.x,p2.y-p1.y);
			var normal:Point = new Point(-delta.y,delta.x);
			
			normal.normalize(radius);
			p1.x += normal.x; p2.x += normal.x;
			p1.y += normal.y; p2.y += normal.y;
			
			return true;
		}
		
		public function clone():Segment{
			var p1clone:Point = p1.clone();
			var p2clone:Point = p2.clone();
			
			return new Segment(p1clone,p2clone);
		}
		
		// returns the normal direction
		public function getNormal():Point{
			return new Point(-p2.y+p1.y,p2.x-p1.x);
		}
		
		// returns the length of this segment
		public function getLength():Number{
			return Math.sqrt(Math.pow(p2.x-p1.x,2) + Math.pow(p2.y-p1.y,2));
		}
		
		public function getPointFromLength(length:Number):Point{
			var tlength:Number = getLength();
			var t:Number = length/tlength;
			return new Point((1-t)*p1.x + t*p2.x, (1-t)*p1.y + t*p2.y);
		}
		
		public function splitByLength(length:Number):Array{
			if(length == 0){
				return new Array(this);
			}
			var splitpoint:Point = getPointFromLength(length);
			
			var seg1:Segment = new Segment(p1,splitpoint);
			var seg2:Segment = new Segment(splitpoint,p2);
			
			return new Array(seg1,seg2);
		}
	}
}