Shader "Unlit/Dithering"
{
    Properties
    {
        _SeeThroughColor("SeeThroughColor", Color) = (0.2, 0.7, 0.7, 0.6)
        _BlockSize("BlockSize", float) = 1
    }
    SubShader
    {
        Cull Back

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
                float4 spos     : TEXCOORD1;
            };

            float _BlockSize;

            float isDithered(float2 pos, float alpha) {
                pos *= _ScreenParams.xy / _BlockSize;

                float DITHER_THRESHOLDS[16] =
                {
                    1.0 / 17.0,  9.0 / 17.0,  3.0 / 17.0, 11.0 / 17.0,
                    13.0 / 17.0,  5.0 / 17.0, 15.0 / 17.0,  7.0 / 17.0,
                    4.0 / 17.0, 12.0 / 17.0,  2.0 / 17.0, 10.0 / 17.0,
                    16.0 / 17.0,  8.0 / 17.0, 14.0 / 17.0,  6.0 / 17.0
                };

                int index = (int(pos.x) % 4) * 4 + int(pos.y) % 4;
                return alpha - DITHER_THRESHOLDS[index];
            }

            void ditherClip(float2 pos, float alpha) {
                clip(isDithered(pos, alpha));
            }

            fixed4 _SeeThroughColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.spos = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = _SeeThroughColor;
                ditherClip(i.spos.xy / i.spos.w, col.a);
                return col;
            }
            ENDCG
        }
    }
}
