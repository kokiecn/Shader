Shader "Unlit/RimLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1,1,1,1)
        _RimColor("RimColor", Color) = (1,1,1,1)
        _RimPower("RimPower", float) = 0.0
        _Alpha("Alpha", Range(0,1.0)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100
        

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 viewDir : TEXCOORD1;
                float3 normalDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            fixed4 _MainTex_ST;
            fixed4 _Color;
            fixed4 _RimColor;
            half _RimPower;
            half _Alpha;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normalDir = normalize(UnityObjectToWorldNormal(v.normal));
                o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex).xyz);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                half rim = 1.0 - abs(dot(i.viewDir, i.normalDir));
                fixed3 emission = _RimColor.rgb * pow(rim, _RimPower);
                col.rgb += emission;
                half alpha = clamp(rim * _Alpha, 0.05, 1.0);
                col = fixed4(col.rgb, alpha);
                return col;
            }
            ENDCG
        }
    }
}
