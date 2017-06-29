Shader "Unlit/WormHole3"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_SubTex("Texture2", 2D) = "white" {}
		_Mask("Mask", 2D) = "white" {}
		_HoleRadio("Hole Radio", Range(0, 5)) = 0
		_HoleRotation("Hole Rotation", Range(0, 5)) = 0
		_HoleDistortion("Hole Distortion", Range(0, 2)) = 0
		_HoleBrightness("Hole Brightness", Range(0, 2)) = 0.5
		_DirectionSpeed("Direction & Speed", Range(-1, 1)) = 1
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
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
			sampler2D _SubTex;
			float4 _SubTex_ST;
			sampler2D _Mask;
			float4 _Mask_ST;

			float _HoleRadio;
			float _HoleRotation;
			float _HoleDistortion;
			float _HoleBrightness;
			float _DirectionSpeed;

			v2f vert(appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
			//fixed4 col = tex2D(_MainTex, i.uv);
			fixed4 col = 0;
			fixed4 sub = 0;
			fixed4 mask = 0;

			float time = _Time.y;
			float2 p = -1.0 + 2.0 * i.uv.xy;
			float2 uv;
			
			float r = sqrt(dot(p, p)) *_HoleRadio;
	
			
			float a = time + atan2(p.y, p.x) + 0.05*sin(r*(5.0 + 2.0*sin((time * _HoleRotation + 1) / 4.0))) + 5.0*cos((time * _HoleRotation + 1) / 7.0);
			float s = smoothstep(0.0, 0.7, 0.5 + 0.4*cos(7.0*a)*sin(time / 3.0)) * _HoleDistortion;
			uv.x = time + _DirectionSpeed / (r + 0.2*s);
			uv.y = -time + 3.0*a / 3.14;

			float w = (0.5 + 0.5) * r  * r * _HoleBrightness;
			
			col.rgb = tex2D(_MainTex, uv).rgb;
			col.rgb = fixed4(col.xyz * w, 1.0);
			
			sub.rgb = tex2D(_SubTex, i.uv).rgb;
			sub.rgb = fixed4(sub.xyz, 1.0);
			float2 uv2 = i.uv;

			
			/*float s = sin(5 * _Time);
			float c = cos(5 * _Time);
			float2x2 rotationMatrix = float2x2(c, -s, s, c);
			rotationMatrix *= 0.5;
			rotationMatrix += 0.5;
			rotationMatrix = rotationMatrix * 2 - 1;
			uv2.xy = mul(uv2.xy, rotationMatrix);
			uv2.xy += 0.5;*/

			mask = tex2D(_Mask, uv2);
			//col.rgb = sub*(1.0 - abs(w) * 1.5) + col * abs(w);
			
			col = col * (1 + mask);
			
			sub = (sub * (1 - mask)) * abs((sin(time*2.5) + 1.9) * 0.2);

			return (col + sub * 2);
			}
			ENDCG
		}
	}
}