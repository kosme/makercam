﻿package com.partkart{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class CircularArc extends ArcSegment{
		
		public var center:Point;
		public var radius:Number;
		
		public function CircularArc(point1:Point, point2:Point, c:Point, r:Number):void{
			
			center = c;
			radius = r;
			
			var theta1:Number = Math.atan2(point1.y-center.y,point1.x-center.x);
			var theta2:Number = Math.atan2(point2.y-center.y,point2.x-center.x);
			
			var dtheta1:Number = ((theta2 - theta1)*180)/Math.PI;
			var dtheta2:Number = (((Math.PI-theta2) + theta1)*180)/Math.PI;
			
			if(dtheta1 > 360){
				dtheta1 -= 360;
			}
			else if(dtheta1 < -360){
				dtheta1 += 360;
			}
			
			if(dtheta2 > 360){
				dtheta2 -= 360;
			}
			else if(dtheta2 < -360){
				dtheta2 += 360;
			}
			
			var dtheta:Number;
			
			if(Math.abs(dtheta1) <= Math.abs(dtheta2)){
				dtheta = dtheta1;	
			}
			else{
				dtheta = dtheta2;
			}
			
			var large:Boolean = false;
			
			// calculate which side of the segment the center lies on
			var m:Number = (center.x - point1.x) * (point2.y - point1.y) - (point2.x - point1.x) * (center.y - point1.y);
			
			if(((m > 0 && r < 0) || (m < 0 && r > 0)) && Math.abs(m) > Global.tolerance){
				large = true;
			}
			
			large = false;
			
			if(Math.abs(dtheta) < 0.000001 || Math.abs(dtheta + 180) < 0.00000001 || Math.abs(dtheta - 180) < 0.0000001){
				dtheta = 0;
			}
			
			var sweep:Boolean = false;
			
			if(dtheta > 0){
				sweep = true;
			}
			
			if(dtheta == 0 && r < 0){
				sweep = true;
			}
			else if(dtheta == 0 && r > 0){
				sweep = false;
			}
			//large = true;
			//sweep = !sweep;
			//trace("dtheta: ", dtheta);
			
			super(point1,point2,Math.abs(r),Math.abs(r),0,large,sweep);
		}
		
		public override function offset(r:Number):Boolean{
			var newradius:Number = radius + r;
			
			// inverted offsets (offsets that pass through the arc center) are VALID
			// they must be preserved to maintain the integrity of the overall offset
			var inverse:Boolean = false;
			if(newradius/Math.abs(newradius) != radius/Math.abs(radius)){
				inverse = true;					   
			}
			
			radius = newradius;
			
			rx = radius;
			ry = radius;
			
			var r1:Point = new Point(p1.x - center.x,p1.y - center.y);
			var r2:Point = new Point(p2.x - center.x,p2.y - center.y);
			
			if(inverse){
				r1.normalize(-Math.abs(radius));
				r2.normalize(-Math.abs(radius));
			}
			else{
				r1.normalize(Math.abs(radius));
				r2.normalize(Math.abs(radius));
			}
			
			p1.x = center.x + r1.x;
			p1.y = center.y + r1.y;
			
			p2.x = center.x + r2.x;
			p2.y = center.y + r2.y;
			
			return true;
		}
		
		public function arcclone():CircularArc{
			var p1clone:Point = p1.clone();
			var p2clone:Point = p2.clone();
			
			var centerclone:Point = center.clone();
			
			return new CircularArc(p1clone,p2clone,centerclone,radius);
		}
		
		public override function getLength():Number{
			var radians:Number = Global.getAngle(new Point(p1.x-center.x,p1.y-center.y), new Point(p2.x-center.x, p2.y-center.y));
			var length:Number = radians*radius;
			
			return Math.abs(length);
		}
		
		public function onArc(p:Point):Boolean{
			
			var norm1:Point;
			var norm2:Point;
			
			var normpoint:Point;
			
			normpoint = new Point(p.x - center.x, p.y - center.y);
			
			norm1 = new Point(p1.x - center.x, p1.y - center.y);
			norm2 = new Point(p2.x - center.x, p2.y - center.y);
			
			var angle1:Number = Global.getAngle(norm1,normpoint);
			var angle2:Number = Global.getAngle(norm1,norm2);
			
			var pi:Number = Math.PI;
			
			if(angle1 == 0 || angle2 == 0){
				return false;
			}
			else if(Math.PI - Math.abs(angle2) < 0.0000000001){
				// things get a bit hairy with the angle method when the normals are exactly opposite. In this case we simply key on the circle winding direction and point position
				var m = (p.x - p1.x) * (p2.y - p1.y) - (p2.x - p1.x) * (p.y - p1.y);
				
				if((m > 0 && radius < 0) || (m < 0 && radius > 0)){
					return true;
				}
				else{
					return false;
				}
			}
			else if((angle2 > 0 && angle1 > 0 && angle1 < angle2) || (angle2 < 0 && angle1 < 0 && angle1 > angle2)){
				return true;
			}
			
			//trace(cross1, cross2);
			return false;
		}
		
		// similar to the getbounds function, this function returns a bounding rectangle
		// however it uses exact geometry rather than pixel approximation
		// note that the returned rectangle is in right-hand coordinates (x,y values represent lower-left corner of box)
		public function getExactBounds():Rectangle{
			var minx:Number = Math.min(p1.x,p2.x);
			var miny:Number = Math.min(p1.y,p2.y);
			
			var maxx:Number = Math.max(p1.x, p2.x);
			var maxy:Number = Math.max(p1.y, p2.y);
			
			if(onArc(new Point(center.x+Math.abs(radius), center.y))){
				maxx = center.x + Math.abs(radius);
			}
			if(onArc(new Point(center.x-Math.abs(radius), center.y))){
				minx = center.x - Math.abs(radius);
			}
			if(onArc(new Point(center.x, center.y+Math.abs(radius)))){
				maxy = center.y + Math.abs(radius);
			}
			if(onArc(new Point(center.x, center.y-Math.abs(radius)))){
				miny = center.y - Math.abs(radius);
			}
			
			return new Rectangle(minx,miny,maxx-minx,maxy-miny);
		}
		
		// returns a point that is distance "length" from p1 along the arc
		public override function getPointFromLength(length:Number):Point{
			var norm1:Point = new Point(p1.x-center.x,p1.y-center.y);
			var norm2:Point = new Point(p2.x-center.x,p2.y-center.y);
			
			var angle:Number = Global.getAngle(norm1, norm2);
			
			/*if(angle < 0){
				l = -l;
			}*/
			
			var theta:Number = length/Math.abs(radius);
			
			if(angle < 0){
				theta = -theta;
			}
			
			theta += Math.atan2(norm1.y,norm1.x);
			
			var dx:Number = Math.abs(radius)*Math.cos(theta);
			var dy:Number = Math.abs(radius)*Math.sin(theta);
			
			return new Point(center.x+dx, center.y+dy);
		}
		
		// splits the arc at the point that is distance "length" from p1 along the arc
		// returns two arcs as an array
		public override function splitByLength(length:Number):Array{
			if(length == 0){
				return new Array(this);
			}
			var splitpoint:Point = getPointFromLength(length);
			
			var arc1:CircularArc = new CircularArc(p1,splitpoint,center.clone(),radius);
			var arc2:CircularArc = new CircularArc(splitpoint,p2,center.clone(),radius);
			
			return new Array(arc1, arc2);
		}
		
		// returns a linearized version of this arc, with deviation no more than the given tolerance
		// not useful for now, but may come in handy later (?)
		/*public function linearize(tol:Number):Array{
			var dtheta:Number = Math.sqrt(tol/Math.abs(radius*2));
			var angle:Number = Global.getAngle(new Point(p1.x-center.x,p1.y-center.y), new Point(p2.x-center.x, p2.y-center.y));
			
			var divisions:Number = angle/dtheta;
			
			if(divisions < 0){
				dtheta = -dtheta;
				divisions = -divisions;
			}
			
			divisions = Math.ceil(divisions);
			var increment:Number = angle/divisions;
			
			var segments:Array = new Array();
			var current:Number = Math.atan2(p1.y-center.y,p1.x-center.x);
			
			var i:int = 0;
			
			var prev:Point = p1.clone();
			
			while(i < divisions){
				i++;
				var next:Point = new Point(radius*Math.cos(current+i*increment)+center.x,radius*Math.sin(current+i*increment)+center.y);
				var segment:Segment = new Segment(prev, next);
				prev = next;
				segments.push(segment);
			}
			
			return segments;
		}
		
		public function getAverage():Point{
			var segments:Array = linearize(Global.tolerance);
			var ax:Number = segments[0].x;
			var ay:Number = segments[0].y;
			for(var i:int=1; i<segments.length; i++){
				ax += (segments[i].x-ax)/(i+1);
				ay += (segments[i].y-ax)/(i+1);
			}
			
			return new Point(ax,ay);
		}*/
	}
}