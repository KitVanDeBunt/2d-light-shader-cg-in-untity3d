using UnityEngine;
//using System.Collections;

static class math {
	static public int add(int a,int b){
		return a+b;
	}
	
	static public Vector2 AngleToDirection(float angle){
		float xForce = Mathf.Sin(angle*Mathf.PI/180);
		float yForce = Mathf.Cos(angle*Mathf.PI/180);
		return new Vector2(-xForce,yForce);
	}
}
