Shader "Mistwork/Spherical Mask Dissolve"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
        _MaskRadius("Mask Radius", Range(0, 100)) = 0
        _MaskSoftness("Mask Softness", Range(0, 100)) = 0
        _DissolveTex("Dissolve Texture", 2D) = "white" {}
        _BurnSize("Burn Size", Range(0, 2)) = 0.03
        _BurnColor("Burn Color", Color) = (1, 1, 1, 1)
        _BurnAnimSpeed("Burn Animation Speed", Float) = 0.1
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
            float3 worldPos;
        };

        float _Glossiness;
        float _Metallic;
        float4 _Color;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        uniform float4 _PlayerPos;
        float _MaskRadius;
        float _MaskSoftness;
        float _BurnSize;
        float4 _BurnColor;
        float _BurnAnimSpeed;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

            //Compute the distance between the player position and the vertices of the dissolving object
            float d = distance(_PlayerPos, IN.worldPos);
            //Compute the dissolve amount based on the distance of the player relative to the _MaskRadius and compared to _MaskSoftness percentage-wise
            float dissolveAmount = saturate((d - _MaskRadius) / -_MaskSoftness);
            //Compute the dissolve values from _DissolveTex
            float dissolveFromTex = tex2D(_DissolveTex, IN.uv_DissolveTex + _Time.y * _BurnAnimSpeed).r;
            //Use dissolveAmount to adjust dissolve effect based on the distance from the player
            float dissolve = dissolveAmount - dissolveFromTex;
            //Discard pixels that are < 0
            clip(dissolve);
            
            //Show the burn area only if _BurnSize is > than dissolve value
            float burnAmount = step(dissolve, _BurnSize);

            o.Albedo = c.rgb;
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
            //Show _BurnColor as Emit color
            o.Emission = _BurnColor * burnAmount;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
