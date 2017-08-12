Shader "Custom/Particle" {
	Properties {
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0

		_PosTex ("position", 2D) = "white" {}
		_NormTex ("normal", 2D) = "white" {}
		_PosTex2 ("position animated", 2D) = "black" {}
		_NormTex2 ("normal animated", 2D) = "black" {}
		_ColTex ("color", 2D) = "white" {}
		_UvTex ("uv", 2D) = "black" {}
	}

	CGINCLUDE
		#include "Assets/CGINC/Quaternion.cginc"
		#define t v.center.w * 4.0

		struct Input {
			float2 uv_MainTex;
			half4 color;
		};

		struct appdata
		{
			float4 vertex : POSITION;
			float3 normal : NORMAL;
			float4 texcoord : TEXCOORD0;
			float4 center : TEXCOORD1;
		};

		sampler2D _PosTex,_NormTex,_PosTex2,_NormTex2,_ColTex,_UvTex;

		void vert (inout appdata v, out Input o) {
			float4 uv = float4(frac(v.texcoord.xy + v.texcoord.zw * 0.333),0,0);
			uv = tex2Dlod(_UvTex, uv);
			uv.w = 0;

			float4 pos0 = tex2Dlod(_PosTex, uv);
			float3 norm0 = tex2Dlod(_NormTex, uv).xyz;
			float4 pos1 = tex2Dlod(_PosTex2, uv);
			float3 norm1 = tex2Dlod(_NormTex2, uv).xyz;
			float4 pos = lerp(pos0, pos1, saturate(t*4-3)*pos1.a);
			float3 normal = lerp(norm0,norm1, saturate(t*4-3)*pos1.a);

			fixed4 color = tex2Dlod(_ColTex, uv);

			float4 toRot = fromToRotation(v.normal, normal);
			float4 wPos = mul(unity_ObjectToWorld, v.vertex);
			wPos.xyz *= pos.w;
			float4 wPos0 = wPos;
			wPos.xyz -= v.center.xyz;
			wPos.xyz = rotateWithQuaternion(wPos.xyz, toRot);
			wPos.xyz += pos.xyz;

			wPos.xyz = lerp(wPos0, wPos, saturate(t));

			v.vertex = mul(unity_WorldToObject, wPos);
			v.normal = lerp(v.normal, normal, saturate(t));

			UNITY_INITIALIZE_OUTPUT(Input,o);
			o.color = color;
		}

		void vertBack (inout appdata v, out Input o) {
			vert(v, o);
			o.color = lerp(o.color, 0, saturate(t));
		}

		half _Glossiness;
		half _Metallic;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
			// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = IN.color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
	ENDCG

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		Cull Back
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard addshadow vertex:vert nolightmap 
		#pragma target 3.0
		ENDCG
		
		Cull Front
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard addshadow vertex:vertBack nolightmap 
		#pragma target 3.0
		ENDCG
	}
	FallBack "Diffuse"
}
