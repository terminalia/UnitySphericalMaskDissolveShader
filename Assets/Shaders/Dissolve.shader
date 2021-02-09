Shader "Mistwork/Dissolve"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _DissolveTex("Dissolve Texture", 2D) = "white" {}
        _DissolveAmount("Dissolve Amount", Range(0, 1)) = 0
        _BurnSize("Burn Size", Range(0, 1)) = 0.03
        _BurnColor("Burn Color", Color) = (1, 1, 1, 1)

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _DissolveTex;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_DissolveTex;
        };

        float _Glossiness;
        float _Metallic;
        float4 _Color;
        float _DissolveAmount;
        float _BurnSize;
        float4 _BurnColor;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            //Sample the _DissolveTex values. We use this value to discard pixels. _DissolveAmount adjust the amount of dissolve effect  
            float dissolve_value = tex2D(_DissolveTex, IN.uv_DissolveTex).r - _DissolveAmount;
            //Discard the pixel if dissolve_value is < 0
            clip(dissolve_value);

            //Show the burn area only if _BurnSize is > than dissolve value
            float burnAmount = step(dissolve_value, _BurnSize);
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
            o.Emission = _BurnColor * burnAmount;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
