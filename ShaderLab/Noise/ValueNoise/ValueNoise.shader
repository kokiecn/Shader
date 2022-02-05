Shader "Unlit/ValueNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlockSize("Block size", int) = 2
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
            float _BlockSize;

            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            float noise(fixed2 uv)
            {
                fixed2 p = floor(uv);
                return rand(p);
            }

            float valueNoise(fixed2 uv)
            {
                fixed2 p = floor(uv);
                fixed2 f = frac(uv);

                float v00 = rand(p);
                float v10 = rand(p + fixed2(1, 0));
                float v01 = rand(p + fixed2(0, 1));
                float v11 = rand(p + fixed2(1, 1));

                //interpolation
                fixed2 u = f * f * (3.0 - 2.0 * f);

                float v0010 = lerp(v00, v10, u.x);
                float v0111 = lerp(v01, v11, u.x);
                return lerp(v0010, v0111, u.y);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float r = valueNoise(i.uv * _BlockSize);
                fixed4 col = fixed4(r, r, r, 1.0);
                return col;
            }
            ENDCG
        }
    }
}
