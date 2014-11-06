Shader "Custom/2dLight old" {
        Properties {

                //_DistanceRays ("DistanceRays", 2D) = "" {}
                //_MaxDist ("Distence Center", Float) = 2
                //_RayCastRes ("_RayCastRes", Float) = 200
                //_DistCheckRes ("_DistCheckRes", Float) = 200
                //_Color("Color", Color) = (1.0,1.0,1.0,1.0)
                //_LightPower("_LightPower", Range(0.0,10.0)) = 1.0
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
                        int move8bit( int col );
                        int move16bit( int col );
                        int move24bit( int col );
                        float DecodeFloatRGBA2( float4 rgba );
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
                                float angle = angleToPoint(float2(0,0),wcoord);
                                float angleInt = round( angle* _RayCastRes+1)/_RayCastRes;
                                //calculate alowed distance
                                float2 dataPos = float2(angleInt,0);
                                //float4 data = tex2D(_DistanceRays,dataPos);
                                float4 data = tex2D(_DistanceRays,dataPos);
                                float dist = (data.x*0.000255)+(data.y*0.02528)+(data.z*16.71168)+(data.w*4278.190080);
                                //255/1000000 = 0,000255
                                //255 * 256 = 25280
                                //25280/1000000 = 0,02528
                                //255 * 65536 = 16711680
                                //16711680/1000000 = 16,71168
                                //255 * 16777216 = 4278190080
                                //4278190080/1000000 = 4278,190080
                                //int4 distBytes = int4(dataInt.x,move8bit(data.y),move16bit(data.z),move24bit(data.w));
                                //int dist = distBytes.x+distBytes.y+distBytes.z+distBytes.w;
                                float maxDist = (float)dist/10;
                                
                                if (maxDist>distCenter) {
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
                        
                        int move8bit( int col ) {
                                return col * 0x100;
                        }
                        int move16bit( int col ) {
                                return col * 0x10000;
                        }
                        int move24bit( int col ) {
                                return col * 0x1000000;
                        }
                        
                        float DecodeFloatRGBA2( float4 rgba ) {
                                return dot( rgba, float4(1.0, 1/255.0, 1/65025.0, 1/160581375.0) );
                        }
                        
                        float angleToPoint(float2 p1,float2 p2){
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