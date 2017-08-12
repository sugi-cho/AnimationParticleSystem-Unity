Shader "Generator/mesh Info texture Animated"
{
	Properties
	{
		_PosTex("position texture", 2D) = "black"{}
		_NmlTex("normal texture", 2D) = "white"{}
		_DT ("delta time", float) = 0
		_Length ("animation length", Float) = 1
		[Toggle(ANIM_LOOP)] _Loop("loop", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100 ZTest Always Cull Off

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile ___ ANIM_LOOP
			
			#include "UnityCG.cginc"

			#define ts _PosTex_TexelSize

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
			};

			struct v2f
			{
				float3 vPos : TEXCOORD0;
				float3 vNorm : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			struct pOut
			{
				float4 VertexPosition : SV_Target0;
				float4 VertexNormal : SV_Target1;
			};

			sampler2D _PosTex, _NmlTex;
			float4 _PosTex_TexelSize;
			float _Length, _DT;
			
			v2f vert (appdata v, uint vid : SV_VertexID)
			{
				float t = (_Time.y - _DT) / _Length;
#if ANIM_LOOP
				t = fmod(t, 1.0);
#else
				t = saturate(t);
#endif

				float x = (vid + 0.5) * ts.x;
				float y = t;
				float4 vPos = tex2Dlod(_PosTex, float4(x, y, 0, 0));
				float3 vNorm = tex2Dlod(_NmlTex, float4(x, y, 0, 0));
				v.uv2.y = 1.0-v.uv2.y;
				
				v2f o;
				//use uv2 generated for light-map
				o.vertex = float4(v.uv2*2.0-1.0,0.0,1.0);
				o.vPos = vPos;
				o.vNorm = vNorm;
				return o;
			}
			
			pOut frag (v2f i)
			{
				pOut o;
				o.VertexPosition = float4(i.vPos,1.0);
				o.VertexNormal = float4(i.vNorm,1.0);
				return o;
			}
			ENDCG
		}
	}
}
