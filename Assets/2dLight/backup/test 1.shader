Shader "Custom/2dLight" {
	Properties {

		//_DistanceRays ("DistanceRays", 2D) = "" {} 
		//_MaxDist ("Distence Center", Float) = 2
		//_RayCastRes ("_RayCastRes", Float) = 200
		//_DistCheckRes ("_DistCheckRes", Float) = 200
		//_Color("Color", Color) = (1.0,1.0,1.0,1.0)
		//_LightPower("_LightPower", Range(0.0,10.0))  = 1.0
	}
	SubShader {
		
		//Blend OneMinusSrcColor OneMinusSrcColor,srcalpha dstalpha
		Blend one one,srcalpha dstalpha
		//Blend One SrcColor
		//Blend one SrcColor
		
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
			float angleToPoint(float2 p1,float2 p2);
			float angleToPoint2(float2 p1,float2 p2);
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
				float angle = angleToPoint2(float2(0,0),wcoord);
				float angleInt = round( angle* _RayCastRes+1)/_RayCastRes;
				//calculate alowed distance
				float2 dataPos = float2(angleInt,0);
				//float4 data = tex2D(_DistanceRays,dataPos);
				float4 data = tex2D(_DistanceRays,dataPos);
				
				
				
				///float colPosX = (data.x*(_MaxDist))-(_MaxDist/2);
				///float colPosY = (data.y*(_MaxDist))-(_MaxDist/2);
				///float2 colPos = float2(colPosX+colPosX,colPosY+colPosY);
				///float MaxDist = distance(colPos,float2(0,0));
				float MaxDist = (data.w)*_MaxDist;
				
				//float MaxDist = distance(float2(1,1),float2(0,0));
				//float MaxDist = angle/4.0;*2
				//float MaxDist = angleInt/_RayCastRes;
				
				if (MaxDist>distCenter) {
					float colr = 1-(distCenter/_MaxDist);
				//if(dataPos.x>1){
					//color = float4(0.1,0.5,0.5,1.0);
					color = float4(colr,colr,colr,1.0);
				} else {
					color = float4(0.0,0.0,0.0,0.0);
					//color = data;
				}
				
				//color = float4(0.0,0.0,0.0,0.1);
				//color = float4(1.0,0.0,0.0,distCenter);
				//return float4(0.0,0.0,0.0,0.0);
				//color = tex2D(_DistanceRays,wcoord);
				return color*_Color*_LightPower;
			}
			
			float angleToPoint(float2 p1,float2 p2){
				float deltaY = p1.y - p2.y;
				float deltaX = p1.x - p2.x;
				float angle = (atan2(deltaY,deltaX) + 3.14159265359);
				
				if(angle>3.14159265359*0.5){
					
					angle -= (3.14159265359/2);
				}else{
					angle += (3.14159265359*1.5);
				}
				return (angle /(3.14159265359*2));
			}
			
			float angleToPoint2(float2 p1,float2 p2){
				float deltaY = p1.y - p2.y;
				float deltaX = p1.x - p2.x;
				float angle = (atan2(deltaY,deltaX) + 3.14159265359);
				
				float angleScale = (angle/(3.14159265359*2));
				float angleLerp = round(angleScale);
				float dA = -(3.14159265359/2);
				float dB = (3.14159265359*1.5);
				float finalAngle = angle+lerp(dA,dB,angleLerp);
				return ((finalAngle /(3.14159265359*2)));
			}
			ENDCG
		}
	}
}