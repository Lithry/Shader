Shader "Unlit/WormHole"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
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


				float time = _Time.y;
				float2 p = -1.0 + 2.0 * i.uv.xy / _ScreenParams.xy;
				float2 uv;
				p.x += 0.5*sin(time*0.71);
				p.y += 0.5*cos(time*1.64);
				float r = sqrt(dot(p, p));
				float a = time + atan2(p.y, p.x) + 0.1*sin(r*(5.0 + 2.0*sin(time / 4.0))) + 5.0*cos(time / 7.0);
				float s = smoothstep(0.0, 0.7, 0.5 + 0.4*cos(7.0*a)*sin(time / 3.0));
				uv.x = time + 0.9 / (r + .2*s);
				uv.y = -time + sin(time / 2.575) + 3.0*a / 3.1416;
				float w = (0.5 + 0.5*s)*r*r;
				col.rgb = tex2D(_MainTex, i.uv).rgb;
				col.x *= 1.0 + 0.5*sin(0.5*time);
				col.y *= 1.0 + 0.5*cos(0.7*time);
				col.z *= 1.0 + 0.5*sin(1.1*time + 1.5);
				col.xyz = fixed4(col.xyz * w, 1.0);
				return col;
			}
			ENDCG
		}
	}
}
