// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/LensFlare" {
	Properties{
		_Color("Flare Color", Color) = (1,1,1,0)
		_MainTex("Texture", 2D) = "white" {}
	}
		SubShader{
		//Tags{ "LightMode" = "ForwardBase" }
		// make sure that all uniforms are correctly set
		Tags{ "Queue" = "Transparent" "RenderType" = "Transparent"}
		// draw after all opaque geometry has been drawn
		//Tags{ "Queue" = "AlphaTest" }
		//Tags{ "Queue" = "Overlay" }
		// Last of Last

		Pass{
			ZWrite Off // don't write to depth buffer 
			// in order not to occlude other objects

			Blend SrcAlpha OneMinusSrcAlpha // use alpha blending

			CGPROGRAM

			#pragma vertex vert 
			#pragma fragment frag
			#include "UnityCG.cginc"

			uniform float4 _LightColor0;
			// color of light source (from "Lighting.cginc")

			uniform float4 _Color; // define shader property for shaders

			struct appdata
			{
				
				float4 vertex : POSITION;       //local vertex position
				float2 uv : TEXCOORD0;			//uv coordinates
				float3 normal : NORMAL;         //normal direction
				float4 tangent : TANGENT;       //tangent direction    
			
				
			};
			
			struct v2f {
				float4 posScreen : SV_POSITION;
				float4 posWorld : TEXCOORD3;
				float2 uv : TEXCOORD0;
				float3 normalDir : TEXCOORD4;
				float3 tangentDir : TEXCOORD5;
			};

			sampler2D _MainTex;

			v2f vert(appdata v)
			{
				v2f o;
				
				/*float3 lightDirection;
					if (0.0 == _WorldSpaceLightPos0.w) // directional light?
					{
						lightDirection = normalize(_WorldSpaceLightPos0.xyz);
					}
				
				float3 worldPosition = mul(_Object2World, v.vertex);
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.normalDir = UnityObjectToWorldNormal(v.normal);
				o.posWorld = mul(_Object2World, v.vertex);
				o.posScreen = mul(UNITY_MATRIX_MVP, v.vertex);*/



				o.uv = v.uv;
				o.normalDir = -UnityObjectToWorldNormal(v.normal);
				o.tangentDir = -normalize(mul(unity_ObjectToWorld, half4(v.tangent.xyz, 0.0)).xyz);
				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.posScreen = UnityObjectToClipPos(v.vertex);





				return o;

			}

			fixed4 frag(v2f i) : SV_Target
			{
				//i.viewDir = UNITY_MATRIX_IT_MV[2].xyz;
				fixed4 col = tex2D(_MainTex, i.uv);

				return col;
			}

			ENDCG
		}
	}
		FallBack "Diffuse"
}