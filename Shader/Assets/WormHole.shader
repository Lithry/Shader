Shader "Unlit/WormHole"
{
	Properties
	{
		_MainTex ("Texture1", 2D) = "white" {}
		_SubTex("Texture2", 2D) = "white" {}
		_Hole("Hole", Range(0, 5)) = 0
		_Direction("Direction", Range(-1, 1)) = 0
		_HoleDistance("Hole Distance", Range(-3, 3)) = 0
		_HoleDistortion("Hole Distortion", Range(0, 2)) = 0
		_HoleBrightness("Hole Brightness", Range(0, 25)) = 0.5
		_HoleIntensity("Hole Intensity", Range (50, 0)) = 1
		_MoveIntensityX ("Move Intensity on X", Range(0, 1)) = 0.5
		_MoveIntensityY("Move Intensity on Y", Range(0, 1)) = 0.5
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _SubTex;
			float4 _SubTex_ST;
			float _MoveIntensityX;
			float _MoveIntensityY;
			float _Hole;
			float _Direction;
			float _HoleDistance;
			float _HoleDistortion;
			float _HoleBrightness;
			float _HoleIntensity;
			
			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				//fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 col = 0;
				fixed4 sub = 0;

				float time = _Time.y;
				float2 p = -1.0 + 2.0 * i.uv.xy;
				float2 uv;
				p.x += 0.5*sin(time*0.71) * _MoveIntensityX;
				p.y += 0.5*cos(time*1.64) * _MoveIntensityY;
				float r = sqrt(dot(p, p)) * _HoleDistance;
				float a = time + atan2(p.y, p.x) + 0.1*sin(r*(5.0 + 2.0*sin(time / 4.0))) + 5.0*cos(time / 7.0);
				float s = smoothstep(0.0, 0.7, 0.5 + 0.4*cos(7.0*a)*sin(time / 3.0)) * _HoleDistortion;
				uv.x = time + 0.9 / (r + 0.2*s);
				uv.y = -time + sin(time / 2.575) + 3.0*a / 3.1416;
				float w = (0.5 + 0.5*s)*r;//*((_HoleIntensity)) * _HoleBrightness);
				//w = w*r*r;
				float w2 = (3 * 0.5 + 0.5);
				col.rgb = tex2D(_MainTex, uv).rgb;
				sub.rgb = tex2D(_SubTex, i.uv).rgb;
				sub.rgb = sub.rgb * w;
				//float r2 = ()
				col.rgb = fixed4(col.rgb * sub.rgb * (r * _Direction) , 1.0);
				
				return col;
			}
			ENDCG
		}
	}
}
