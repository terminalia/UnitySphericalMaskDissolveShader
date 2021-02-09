Shader "Mistwork/Spherical Mask"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

        _MaskRadius("Mask Radius", Range(0, 100)) = 0
        _MaskSoftness("Mask Softness", Range(0, 100)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        float _Glossiness;
        float _Metallic;
        float4 _Color;
        float _MaskRadius;
        float _MaskSoftness;

        uniform float4 _PlayerPos;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            //Convert the color texture to grayscale
            float grayscale = (c.r + c.g + c.b) / 3;
            float3 c_gray = (grayscale, grayscale, grayscale);

            //Compute the distance between the player position and the vertices of the dissolving object
            float d = distance(_PlayerPos, IN.worldPos);
            //Compute the effect amount based on the distance of the player relative to the _MaskRadius and compared to _MaskSoftness percentage-wise
            float effectAmount = saturate((d - _MaskRadius) / -_MaskSoftness);
            //Lerp between gray texture to the color texture based on the dissolve amount
            float4 lerpColor = lerp(float4(c_gray, 1), c, effectAmount);

            o.Albedo = lerpColor.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
