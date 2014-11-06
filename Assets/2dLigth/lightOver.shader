Shader "Custom/2dLight2" {
	Properties {
		//uncomment to make visable in unity editor
		
		//_DistanceRays ("DistanceRays", 2D) = "" {} 
		//_MaxDist ("Distence Center", Float) = 2
		//_RayCastRes ("_RayCastRes", Float) = 200
		//_DistCheckRes ("_DistCheckRes", Float) = 200
		//_Color("Color", Color) = (1.0,1.0,1.0,1.0)
		//_LightPower("_LightPower", Range(0.0,10.0))  = 1.0
	}
	SubShader {
		
		//Blend OneMinusSrcColor OneMinusSrcColor,srcalpha dstalpha
		//Blend One SrcColor
		//Blend one SrcColor
		Blend one one,srcalpha dstalpha
		
		
		//Blend SrcAlpha One
		//ZWrite Off
		Tags { //"LightMode" = "ForwardBase"
				//"Queue" = "Transparent"
				}
		//ColorMask RGB
		Pass {
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			float pointsToAngle(float2 p1,float2 p2);
			uniform float _MaxDist;
			uniform float _RayCastRes;
			uniform float _DistCheckRes;
			uniform sampler2D _DistanceRays;
			uniform float4 _Color;
			uniform float _LightPower;

			#include "UnityCG.cginc"
			
			// structs
			struct vertexInput {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct vertOut {
				float4 pos:SV_POSITION;
				float4 scrPos : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
			};
			
			///------Vertex function
			vertOut vert(vertexInput v) {
				vertOut o;
				o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
				o.scrPos = ComputeScreenPos(o.pos);
				//o.posWorld = mul(_Object2World,v.vertex);
				o.posWorld = v.vertex;
				return o;
			}
			///------Fragment function
			fixed4 frag(vertOut i) : COLOR0 {
				float2 wcoord = (i.posWorld.xy/i.posWorld.w);
				float4 color;
				
				float distCenter = distance(float2(0,0),wcoord);
				
				//float wx = wcoord.x;
				//float wy = wcoord.y;
				//if (fmod(wx,2.0)<_MaxDist&&fmod(wx,2.0)>-_MaxDist) {
				
				//calculate angle
				float angle = pointsToAngle(float2(0,0),wcoord);
				float angleReal = (angle* _RayCastRes+1)/_RayCastRes;
				float angleScale = (float)round( angle* _RayCastRes+1)/_RayCastRes;
				float2 dataPos = float2(angleScale,0);
				
				fixed bo =  step( angleScale , angleReal );// if angle scale is bigger than real angle 0 else 1
				float angle2 = ((angle+(((bo*2)-1)/_RayCastRes)));
			
				//if(angle2>0){
				//	angle2 -=1;
				//}else if (angle2 <0){
				//	angle2 +=1;
				//}
				fixed ang2A = step(angle2,(0+(1/_RayCastRes))); // if angle is bigger return 0
				fixed ang2B = step(angle2,(1-(1/_RayCastRes))); // if angle is smaller return 0
				angle2 = angle2 +(ang2A)-(ang2B);
				
				float angleScale2 = (float)round( angle2* _RayCastRes+1)/_RayCastRes;//(angleScale+((bo*2)));
				float2 dataPos2 = float2(angleScale2,0);
				//float2 dataPos2 = float2((dataPos.x+(1/_RayCastRes)),0);
				
				//calculate alowed distance
				
				//float4 data = tex2D(_DistanceRays,dataPos);
				float4 data = tex2D(_DistanceRays,dataPos);
				float4 data2 = tex2D(_DistanceRays,dataPos2);
				float dist = (data.x*0.000255)+(data.y*0.02528)+(data.z*16.71168)+(data.w*4278.190080);
				float dist2 = (data2.x*0.000255)+(data2.y*0.02528)+(data2.z*16.71168)+(data2.w*4278.190080);
				//255/1000000 = 0,000255
				//255 * 256 = 25280
				//25280/1000000 = 0,02528
				//255 * 65536 = 16711680
				//16711680/1000000 = 16,71168
				//255 * 16777216 = 4278190080
				//4278190080/1000000 = 4278,190080
				float lerpAng = (angleReal-angleScale)*((bo*2)-1)*_RayCastRes;
				float distfinal = lerp(dist,dist2,lerpAng);//lerpAng
				float maxDist = distfinal/10;
				//maxDist = lerpAng;
				//maxDist = ((bo*2)+1);
				//maxDist = lerpAng;
				
				if (maxDist>distCenter) {
					
					float colr = 1-(distCenter/_MaxDist);
					color = float4(colr,colr,colr,1.0);
				} else {
					//shadow
					color = float4(0.0,0.0,0.0,0.0);
				}
				return color*_Color*_LightPower;
			}
			
			float pointsToAngle(float2 p1,float2 p2){
				float angle = atan2(p1.y - p2.y,p1.x - p2.x)+3.14159265359 ;
				float angleScale = angle/6.28318530718;
				fixed angleRound = round(angleScale);
				//-0.5 = -0.5pi/2pi 
				//0.75 =  1.5pi/2pi = 4.71238898038/6.28318530718
				float finalAngle = angleScale+lerp(-0.25,0.75,angleRound);
				return finalAngle;
			}
			ENDCG
		}
	}
}