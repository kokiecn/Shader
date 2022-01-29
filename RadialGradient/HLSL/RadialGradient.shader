Shader "Unlit/Radial gradient"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MinThreshold("Min Distance Threshold", Float) = 1
        _MaxThreshold("Max Distance Threshold", Float) = 10
        _FarColor("Far Color", Color) = (0,0,0,1)
        _NearColor("Near Color", Color) = (0,0,0,1)
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
                float3 vertex_world :TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _MinThreshold;
            float _MaxThreshold;
            fixed4 _FarColor;
            fixed4 _NearColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.vertex_world = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                float dst = length(i.vertex_world);
                float fadeLevel = (dst - _MinThreshold) / (_MaxThreshold - _MinThreshold);
                fadeLevel = clamp(fadeLevel, 0, 1);

                return col * _NearColor * (1 - fadeLevel) + _FarColor * fadeLevel;
            }
            ENDCG
        }
    }
}
