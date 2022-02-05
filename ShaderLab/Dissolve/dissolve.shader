Shader "Unlit/dissolve"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _BlockSize("Block size", int) = 2
        _Alpha("AlphaThreshold", Range(0,1.0)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Cull Off
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
            float _Alpha;
            fixed4 _Color;

            //randomなベクトル生成
            fixed2 random(fixed2 st) {
                st = fixed2(dot(st, fixed2(127.1, 311.7)),
                    dot(st, fixed2(269.5, 183.3)));
                return -1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }


            float perlinNoise(fixed2 uv)
            {
                fixed2 p = floor(uv);
                fixed2 f = frac(uv);
                fixed2 u = f * f * (3.0 - 2.0 * f);

                float v00 = random(p);
                float v10 = random(p + fixed2(1, 0));
                float v01 = random(p + fixed2(0, 1));
                float v11 = random(p + fixed2(1, 1));

                return lerp(lerp(dot(v00, f - fixed2(0, 0)), dot(v10, f - fixed2(1, 0)), u.x),
                    lerp(dot(v01, f - fixed2(0, 1)), dot(v11, f - fixed2(1, 1)), u.x),
                    u.y) + 0.5;
            }

            float fBm(fixed2 st)
            {
                float f = 0;
                fixed2 q = st;

                f += 0.5000 * perlinNoise(q); q = q * 2;
                f += 0.2500 * perlinNoise(q); q = q * 2;
                f += 0.1250 * perlinNoise(q); q = q * 2;
                f += 0.0625 * perlinNoise(q); q = q * 2;

                return f;
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
                float r = fBm(i.uv * _BlockSize);
                //fixed4 col = fixed4(r, r, r, 1.0);
                if (_Alpha < r) {
                     discard;
                }
                return _Color;
            }
            ENDCG
        }
    }
}
