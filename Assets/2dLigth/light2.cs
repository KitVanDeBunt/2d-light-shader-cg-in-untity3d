using UnityEngine;
using System.Collections;
using System;
[ExecuteInEditMode]
public class light2 : MonoBehaviour {

	public int castRes = 200;
	public bool draw;
	public float maxDist = 4;

	private float angleMultiplayer;

	private float curSize;

	//shader
	private Material mat;
	private Texture2D tex;
	private Shader shader1;
	[SerializeField]
	private Color col = Color.white;
	[SerializeField]
	private float power = 1;

	//raycast
	private RaycastHit2D[] rays;
	private Vector2[] hitPoints;
	[SerializeField]
	private LayerMask layer;

	void Start () {
		Resize();

		//make makerial and shader
		shader1 = Shader.Find("Custom/2dLight2");
		//shader1 = Shader.Find("Custom/2dLight old");
		mat = new Material (shader1);
		tex = new Texture2D (castRes, 1, TextureFormat.RGBA32, false);
		renderer.sharedMaterial = mat;
		
		
		rays = new RaycastHit2D[castRes];
		hitPoints = new Vector2[castRes];
		
		mat.SetFloat("_RayCastRes", castRes);
		mat.SetTexture ("_DistanceRays", tex);
		
	}
	void Update () {
		mat.SetFloat("_LightPower", power);
		mat.SetColor("_Color", col);
		mat.SetFloat("_MaxDist", maxDist);
		Resize();

		//transform.localScale = new Vector3(maxDist*2,maxDist*2,0);
		
		
		Vector2 centerV2 = new Vector2 (transform.position.x, transform.position.y);
		V4 ();
		int k;
		int i;
		for (i = 0; i < castRes; i++) {
			float distance = Vector2.Distance (hitPoints [i], centerV2);
			int distanceInt = (int)(distance*10000000);
			Vector2 distObjPos = new Vector2((hitPoints[i].x-centerV2.x+(maxDist))/(maxDist*2),
			                                 ((hitPoints[i].y-centerV2.y)+(maxDist))/(maxDist*2));
			//float dist = distance/maxDist;

			float distPart1 = distance/maxDist;

			int distFloatInInt = distanceInt.GetHashCode();
			byte[] distParts = BitConverter.GetBytes(distFloatInInt);
			byte[] distBytes = new byte[4];
			distBytes[0] = (byte)distFloatInInt;
			distBytes[1] = (byte)(distFloatInInt >> 8);
			distBytes[2] = (byte)(distFloatInInt >> 16);
			distBytes[3] = (byte)(distFloatInInt >> 24);
			float[] distByteScale = new float[4];
			distByteScale[0] = (float)distBytes[0]/255;
			distByteScale[1] = (float)distBytes[1]/255;
			distByteScale[2] = (float)distBytes[2]/255;
			distByteScale[3] = (float)distBytes[3]/255;
			if(false&&i==castRes/2){
				Debug.Log("-----");
				//if(i==0){
				Debug.Log("F: "+distPart1);
				Debug.Log(distFloatInInt);
				//Debug.Log("L: "+distParts.Length);
				//Debug.Log(BitConverter.ToString( distParts));
				Debug.Log("Bytes: "+BitConverter.ToString( distBytes));
				///Debug.Log(distByteScale[0]+" - "+
				///          distByteScale[1]+" - "+
				///          distByteScale[2]+" - "+
				///          distByteScale[3]);
				//new Vector4(0x1, 0x1/0xff, 0x1/0xffff, 0x1/0xffffff);
				float d3= (distByteScale[3]*255*16777216);
				float d2= (distByteScale[2]*255*65536);
				float d1= (distByteScale[1]*255*256);
				float d0= distByteScale[0]*255;
				int di3 = (int)(d3);
				int di2 = (int)(d2);
				int di1 = (int)(d1);
				int di0 = (int)(d0);
				float all= di0+di1+di2+di3;
				Debug.Log(di0+" - "+di1+" - "+di2+" - "+ di3+"\n IN: "+distanceInt+" OUT: "+all);
			}

			tex.SetPixel (i + 1, 1, new Color(distByteScale[0], distByteScale[1], distByteScale[2],distByteScale[3]));
		}
		
		tex.Apply ();
	}

	private void Resize(){
		if(curSize!=maxDist){
			transform.localScale = new Vector3(maxDist*2,maxDist*2,0);
			curSize = maxDist;
		}
	}

	private void V4(){
		int i;
		angleMultiplayer = castRes/360.0f;
		Vector3 center = transform.position;
		center.z = 0;
		Vector2 center2D = new Vector2(center.x,center.y);
		hitPoints[0] = transform.position;
		for (i = 0;i<castRes;i++){
			float angle = (float)i/angleMultiplayer;
			Vector2 direct = math.AngleToDirection(angle);
			direct = new Vector2(direct.x*maxDist,direct.y*maxDist);
			Vector2 colPoint = (center2D+direct);
			RaycastHit2D ray = Physics2D.Linecast(center,colPoint,layer);
			if (ray.collider != null) {
				if (draw) {
					Debug.DrawLine (center, ray.point, Color.red);
				}
				hitPoints [i] = ray.point;
			} else {
				Vector2 point = new Vector2 (direct.x+center.x, direct.y+center.y);
				if (draw) {
					Debug.DrawLine (center, point, Color.green);
				}
				hitPoints [i] = point;
			}
		}
	}

	private void V3(){
		int i;
		angleMultiplayer = castRes/360.0f;
		//Vector3 center = new Vector3(transform.position.x,transform.position.y,0);
		Vector3 center = transform.position;
		center.z = 0;
		//Vector3 point = new Vector3(width/2,height/2,0);
		//Vector3 point2 = new Vector3(-width/2,-height/2,0);
		//Physics2D.Raycast(center,Vector3.up);
		hitPoints[0] = transform.position;
		for (i = 0;i<castRes;i++){
			float angle = (float)i/angleMultiplayer;
			Vector2 direct = math.AngleToDirection(angle);
			direct = new Vector2(direct.x*maxDist,direct.y*maxDist);
			Vector2 colPoint = (new Vector2(center.x,center.y)+direct);
			rays[i] = Physics2D.Linecast(center,colPoint,(1 << LayerMask.NameToLayer("Default")));
			if (rays [i].collider != null) {
				if (draw) {
					Debug.DrawLine (center, rays [i].point, Color.red);
				}
				hitPoints [i] = rays [i].point;
			} else {
				Vector2 direction = math.AngleToDirection (angle);
				Vector2 point = new Vector2 (direction.x*maxDist+center.x, direction.y*maxDist+center.y);
				if (draw) {
					Debug.DrawLine (center, point, Color.green);
				}
				hitPoints [i] = point;
			}
		}
	}

	private void V2(){
		int i;
		angleMultiplayer = castRes/360.0f;
		//Vector3 center = new Vector3(transform.position.x,transform.position.y,0);
		Vector3 center = transform.position;
		center.z = 0;
		//Vector3 point = new Vector3(width/2,height/2,0);
		//Vector3 point2 = new Vector3(-width/2,-height/2,0);
		//Physics2D.Raycast(center,Vector3.up);
		hitPoints[0] = transform.position;
		for (i = 0;i<castRes;i++){
			float angle = (float)i/angleMultiplayer;
			rays[i] = Physics2D.Raycast(center,math.AngleToDirection(angle),maxDist);
			//Debug.Log(rays[i].collider);
			//Debug.Log(rays[i].collider);
			if (rays [i].collider != null) {
				if (draw) {
					Debug.DrawLine (center, rays [i].point, Color.red);
				}
				hitPoints [i] = rays [i].point;
			} else {
				Vector2 direction = math.AngleToDirection (angle);
				Vector2 point = new Vector2 (direction.x*maxDist+center.x, direction.y*maxDist+center.y);
				if (draw) {
					Debug.DrawLine (center, point, Color.green);
				}
				hitPoints [i] = point;
			}
		}
	}
	
	void OnDestroy() {
		tex = null;
		mat = null;
	}
}