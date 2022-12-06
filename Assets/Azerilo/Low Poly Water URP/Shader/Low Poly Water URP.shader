Shader "Azerilo/Low Poly Water URP"
    {
        Properties
        {
            Vector1_FF85FCED("Smoothness", Range(0, 1)) = 0.5
            Vector1_3868C240("Depth", Float) = 1.5
            Color_C277ACA6("Deep Water Color", Color) = (0.2039216, 0.7058824, 0.8196079, 0.8666667)
            Color_FE83B6F2("Shallow Water Color", Color) = (0.4438857, 0.8962264, 0.7680632, 0.7450981)
            Vector1_72DC4170("Wave Speed", Float) = 1
            Vector1_E7F70192("Wave Frequency", Float) = 41
            Vector1_C5017F27("Wave height", Float) = 4.6
            Color_3931EABE("Foam Color", Color) = (1, 1, 1, 1)
            Vector1_9D907682("Foam Amount", Float) = 6
            Vector1_F9F09DC2("Foam Speed", Float) = 1
            Vector1_C8B2A3C1("Foam Scale", Float) = 200
            Vector1_9A37E012("Foam Cutoff", Float) = 4
            [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Transparent"
                "UniversalMaterialType" = "Lit"
                "Queue"="Transparent"
            }
            Pass
            {
                Name "Universal Forward"
                Tags
                {
                    "LightMode" = "UniversalForward"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
                #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
                #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
                #pragma multi_compile _ _SHADOWS_SOFT
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_FORWARD
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    float4 uv1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    float4 tangentWS;
                    float4 texCoord0;
                    float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    float2 lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    float3 sh;
                    #endif
                    float4 fogFactorAndVertexLight;
                    float4 shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 TangentSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    float4 interp2 : TEXCOORD2;
                    float4 interp3 : TEXCOORD3;
                    float3 interp4 : TEXCOORD4;
                    #if defined(LIGHTMAP_ON)
                    float2 interp5 : TEXCOORD5;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    float3 interp6 : TEXCOORD6;
                    #endif
                    float4 interp7 : TEXCOORD7;
                    float4 interp8 : TEXCOORD8;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyzw =  input.tangentWS;
                    output.interp3.xyzw =  input.texCoord0;
                    output.interp4.xyz =  input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp5.xy =  input.lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp6.xyz =  input.sh;
                    #endif
                    output.interp7.xyzw =  input.fogFactorAndVertexLight;
                    output.interp8.xyzw =  input.shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    output.viewDirectionWS = input.interp4.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.lightmapUV = input.interp5.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp6.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp7.xyzw;
                    output.shadowCoord = input.interp8.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float Vector1_FF85FCED;
                float Vector1_3868C240;
                float4 Color_C277ACA6;
                float4 Color_FE83B6F2;
                float Vector1_72DC4170;
                float Vector1_E7F70192;
                float Vector1_C5017F27;
                float4 Color_3931EABE;
                float Vector1_9D907682;
                float Vector1_F9F09DC2;
                float Vector1_C8B2A3C1;
                float Vector1_9A37E012;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                struct Bindings_depthfade_ad197f998921d45438c2923a057d58fa
                {
                    float4 ScreenPosition;
                };
                
                void SG_depthfade_ad197f998921d45438c2923a057d58fa(float Vector1_5C4B96A6, Bindings_depthfade_ad197f998921d45438c2923a057d58fa IN, out float Output_1)
                {
                    float _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1);
                    float4 _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0 = IN.ScreenPosition;
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_R_1 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[0];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_G_2 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[1];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_B_3 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[2];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[3];
                    float _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2;
                    Unity_Subtract_float(_SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1, _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4, _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2);
                    float _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0 = Vector1_5C4B96A6;
                    float _Divide_911ee1e1202e918899a51b8749d33068_Out_2;
                    Unity_Divide_float(_Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2, _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0, _Divide_911ee1e1202e918899a51b8749d33068_Out_2);
                    float _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                    Unity_Saturate_float(_Divide_911ee1e1202e918899a51b8749d33068_Out_2, _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1);
                    Output_1 = _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
                
                void Unity_DDX_float3(float3 In, out float3 Out)
                {
                    Out = ddx(In);
                }
                
                void Unity_DDY_float3(float3 In, out float3 Out)
                {
                    Out = ddy(In);
                }
                
                void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
                {
                    Out = cross(A, B);
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0 = Vector1_72DC4170;
                    float _Divide_a04606a632dc1280be27255584976b7d_Out_2;
                    Unity_Divide_float(100, _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0, _Divide_a04606a632dc1280be27255584976b7d_Out_2);
                    float _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Divide_a04606a632dc1280be27255584976b7d_Out_2, _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2);
                    float2 _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2.xx), _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3);
                    float _Property_86931d7ca754618ba90f855709fd1158_Out_0 = Vector1_E7F70192;
                    float _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3, _Property_86931d7ca754618ba90f855709fd1158_Out_0, _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2);
                    float _Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0 = Vector1_C5017F27;
                    float _Divide_986b6b134b3636818accb3cbbef198c8_Out_2;
                    Unity_Divide_float(_Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0, 10, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2);
                    float _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2;
                    Unity_Multiply_float(_GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2, _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2);
                    float3 _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2;
                    Unity_Multiply_float((_Multiply_74100bafb098b482a96ac7aae9daf502_Out_2.xxx), IN.ObjectSpaceNormal, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2);
                    float3 _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2, _Add_4658daf37d98598f815235b0814f543d_Out_2);
                    description.Position = _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 NormalTS;
                    float3 Emission;
                    float Metallic;
                    float Smoothness;
                    float Occlusion;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_428392b895d75588a789fa5e287344b7_Out_0 = Color_FE83B6F2;
                    float4 _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0 = Color_C277ACA6;
                    float _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1);
                    float _Multiply_285fae212657458aab12f18322e1cb55_Out_2;
                    Unity_Multiply_float(_SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1, _ProjectionParams.z, _Multiply_285fae212657458aab12f18322e1cb55_Out_2);
                    float4 _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0 = IN.ScreenPosition;
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_R_1 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[0];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_G_2 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[1];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_B_3 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[2];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[3];
                    float _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0 = Vector1_3868C240;
                    float _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2;
                    Unity_Add_float(_Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4, _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2);
                    float _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2;
                    Unity_Subtract_float(_Multiply_285fae212657458aab12f18322e1cb55_Out_2, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2, _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2);
                    float _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3;
                    Unity_Clamp_float(_Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2, 0, 1, _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3);
                    float4 _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3;
                    Unity_Lerp_float4(_Property_428392b895d75588a789fa5e287344b7_Out_0, _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0, (_Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3.xxxx), _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3);
                    float4 _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0 = Color_3931EABE;
                    float _Property_34238cd90bbe988da24e1813dab2cd84_Out_0 = Vector1_9D907682;
                    Bindings_depthfade_ad197f998921d45438c2923a057d58fa _depthfade_1c444d766e4743c3acfdf1e5dd412e0c;
                    _depthfade_1c444d766e4743c3acfdf1e5dd412e0c.ScreenPosition = IN.ScreenPosition;
                    float _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1;
                    SG_depthfade_ad197f998921d45438c2923a057d58fa(_Property_34238cd90bbe988da24e1813dab2cd84_Out_0, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1);
                    float _Property_769ea1a0d0064584904edd20953794c0_Out_0 = Vector1_9A37E012;
                    float _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2;
                    Unity_Multiply_float(_depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1, _Property_769ea1a0d0064584904edd20953794c0_Out_0, _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2);
                    float _Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0 = Vector1_F9F09DC2;
                    float _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0 = Vector1_C8B2A3C1;
                    float _Divide_263822ede7aca782aaa923328ca71b31_Out_2;
                    Unity_Divide_float(_Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0, _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0, _Divide_263822ede7aca782aaa923328ca71b31_Out_2);
                    float _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Divide_263822ede7aca782aaa923328ca71b31_Out_2, _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2);
                    float2 _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2.xx), _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3);
                    float _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0 = Vector1_C8B2A3C1;
                    float _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3, _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2);
                    float _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2;
                    Unity_Step_float(_Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2, _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2);
                    float4 _Property_f429294e25120d848a0b88be0496b643_Out_0 = Color_3931EABE;
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_R_1 = _Property_f429294e25120d848a0b88be0496b643_Out_0[0];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_G_2 = _Property_f429294e25120d848a0b88be0496b643_Out_0[1];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_B_3 = _Property_f429294e25120d848a0b88be0496b643_Out_0[2];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4 = _Property_f429294e25120d848a0b88be0496b643_Out_0[3];
                    float _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2;
                    Unity_Multiply_float(_Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2, _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4, _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2);
                    float4 _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3;
                    Unity_Lerp_float4(_Lerp_5b013f099edf5785970f814b97e8df7b_Out_3, _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0, (_Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2.xxxx), _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3);
                    float3 _DDX_a7d600399dc07881b908a3a53583516f_Out_1;
                    Unity_DDX_float3(IN.WorldSpacePosition, _DDX_a7d600399dc07881b908a3a53583516f_Out_1);
                    float3 _DDY_28e176db7b2f3e83922081808777141e_Out_1;
                    Unity_DDY_float3(IN.WorldSpacePosition, _DDY_28e176db7b2f3e83922081808777141e_Out_1);
                    float3 _CrossProduct_be87980cfa67218b90c9a60413ab291c_Out_2;
                    Unity_CrossProduct_float(_DDX_a7d600399dc07881b908a3a53583516f_Out_1, _DDY_28e176db7b2f3e83922081808777141e_Out_1, _CrossProduct_be87980cfa67218b90c9a60413ab291c_Out_2);
                    float3 _Normalize_3253518d6b72628faf87de91eb464d94_Out_1;
                    Unity_Normalize_float3(_CrossProduct_be87980cfa67218b90c9a60413ab291c_Out_2, _Normalize_3253518d6b72628faf87de91eb464d94_Out_1);
                    float _Property_86d066cb5a7bf58f8d9583c0b62bd6b2_Out_0 = Vector1_FF85FCED;
                    float _Split_58f416024fe7fb8090af221026c86100_R_1 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[0];
                    float _Split_58f416024fe7fb8090af221026c86100_G_2 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[1];
                    float _Split_58f416024fe7fb8090af221026c86100_B_3 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[2];
                    float _Split_58f416024fe7fb8090af221026c86100_A_4 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[3];
                    surface.BaseColor = (_Lerp_0c7ea3049416da86bae08da697b4c022_Out_3.xyz);
                    surface.NormalTS = _Normalize_3253518d6b72628faf87de91eb464d94_Out_1;
                    surface.Emission = float3(0, 0, 0);
                    surface.Metallic = 0;
                    surface.Smoothness = _Property_86d066cb5a7bf58f8d9583c0b62bd6b2_Out_0;
                    surface.Occlusion = 1;
                    surface.Alpha = _Split_58f416024fe7fb8090af221026c86100_A_4;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.uv0 =                         input.uv0;
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                    output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "GBuffer"
                Tags
                {
                    "LightMode" = "UniversalGBuffer"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
                #pragma multi_compile _ _SHADOWS_SOFT
                #pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
                #pragma multi_compile _ _GBUFFER_NORMALS_OCT
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_GBUFFER
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    float4 uv1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    float4 tangentWS;
                    float4 texCoord0;
                    float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    float2 lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    float3 sh;
                    #endif
                    float4 fogFactorAndVertexLight;
                    float4 shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 TangentSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    float4 interp2 : TEXCOORD2;
                    float4 interp3 : TEXCOORD3;
                    float3 interp4 : TEXCOORD4;
                    #if defined(LIGHTMAP_ON)
                    float2 interp5 : TEXCOORD5;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    float3 interp6 : TEXCOORD6;
                    #endif
                    float4 interp7 : TEXCOORD7;
                    float4 interp8 : TEXCOORD8;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyzw =  input.tangentWS;
                    output.interp3.xyzw =  input.texCoord0;
                    output.interp4.xyz =  input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp5.xy =  input.lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp6.xyz =  input.sh;
                    #endif
                    output.interp7.xyzw =  input.fogFactorAndVertexLight;
                    output.interp8.xyzw =  input.shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    output.viewDirectionWS = input.interp4.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.lightmapUV = input.interp5.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp6.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp7.xyzw;
                    output.shadowCoord = input.interp8.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float Vector1_FF85FCED;
                float Vector1_3868C240;
                float4 Color_C277ACA6;
                float4 Color_FE83B6F2;
                float Vector1_72DC4170;
                float Vector1_E7F70192;
                float Vector1_C5017F27;
                float4 Color_3931EABE;
                float Vector1_9D907682;
                float Vector1_F9F09DC2;
                float Vector1_C8B2A3C1;
                float Vector1_9A37E012;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                struct Bindings_depthfade_ad197f998921d45438c2923a057d58fa
                {
                    float4 ScreenPosition;
                };
                
                void SG_depthfade_ad197f998921d45438c2923a057d58fa(float Vector1_5C4B96A6, Bindings_depthfade_ad197f998921d45438c2923a057d58fa IN, out float Output_1)
                {
                    float _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1);
                    float4 _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0 = IN.ScreenPosition;
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_R_1 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[0];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_G_2 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[1];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_B_3 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[2];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[3];
                    float _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2;
                    Unity_Subtract_float(_SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1, _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4, _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2);
                    float _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0 = Vector1_5C4B96A6;
                    float _Divide_911ee1e1202e918899a51b8749d33068_Out_2;
                    Unity_Divide_float(_Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2, _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0, _Divide_911ee1e1202e918899a51b8749d33068_Out_2);
                    float _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                    Unity_Saturate_float(_Divide_911ee1e1202e918899a51b8749d33068_Out_2, _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1);
                    Output_1 = _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
                
                void Unity_DDX_float3(float3 In, out float3 Out)
                {
                    Out = ddx(In);
                }
                
                void Unity_DDY_float3(float3 In, out float3 Out)
                {
                    Out = ddy(In);
                }
                
                void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
                {
                    Out = cross(A, B);
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0 = Vector1_72DC4170;
                    float _Divide_a04606a632dc1280be27255584976b7d_Out_2;
                    Unity_Divide_float(100, _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0, _Divide_a04606a632dc1280be27255584976b7d_Out_2);
                    float _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Divide_a04606a632dc1280be27255584976b7d_Out_2, _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2);
                    float2 _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2.xx), _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3);
                    float _Property_86931d7ca754618ba90f855709fd1158_Out_0 = Vector1_E7F70192;
                    float _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3, _Property_86931d7ca754618ba90f855709fd1158_Out_0, _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2);
                    float _Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0 = Vector1_C5017F27;
                    float _Divide_986b6b134b3636818accb3cbbef198c8_Out_2;
                    Unity_Divide_float(_Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0, 10, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2);
                    float _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2;
                    Unity_Multiply_float(_GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2, _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2);
                    float3 _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2;
                    Unity_Multiply_float((_Multiply_74100bafb098b482a96ac7aae9daf502_Out_2.xxx), IN.ObjectSpaceNormal, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2);
                    float3 _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2, _Add_4658daf37d98598f815235b0814f543d_Out_2);
                    description.Position = _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 NormalTS;
                    float3 Emission;
                    float Metallic;
                    float Smoothness;
                    float Occlusion;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_428392b895d75588a789fa5e287344b7_Out_0 = Color_FE83B6F2;
                    float4 _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0 = Color_C277ACA6;
                    float _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1);
                    float _Multiply_285fae212657458aab12f18322e1cb55_Out_2;
                    Unity_Multiply_float(_SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1, _ProjectionParams.z, _Multiply_285fae212657458aab12f18322e1cb55_Out_2);
                    float4 _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0 = IN.ScreenPosition;
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_R_1 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[0];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_G_2 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[1];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_B_3 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[2];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[3];
                    float _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0 = Vector1_3868C240;
                    float _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2;
                    Unity_Add_float(_Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4, _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2);
                    float _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2;
                    Unity_Subtract_float(_Multiply_285fae212657458aab12f18322e1cb55_Out_2, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2, _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2);
                    float _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3;
                    Unity_Clamp_float(_Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2, 0, 1, _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3);
                    float4 _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3;
                    Unity_Lerp_float4(_Property_428392b895d75588a789fa5e287344b7_Out_0, _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0, (_Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3.xxxx), _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3);
                    float4 _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0 = Color_3931EABE;
                    float _Property_34238cd90bbe988da24e1813dab2cd84_Out_0 = Vector1_9D907682;
                    Bindings_depthfade_ad197f998921d45438c2923a057d58fa _depthfade_1c444d766e4743c3acfdf1e5dd412e0c;
                    _depthfade_1c444d766e4743c3acfdf1e5dd412e0c.ScreenPosition = IN.ScreenPosition;
                    float _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1;
                    SG_depthfade_ad197f998921d45438c2923a057d58fa(_Property_34238cd90bbe988da24e1813dab2cd84_Out_0, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1);
                    float _Property_769ea1a0d0064584904edd20953794c0_Out_0 = Vector1_9A37E012;
                    float _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2;
                    Unity_Multiply_float(_depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1, _Property_769ea1a0d0064584904edd20953794c0_Out_0, _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2);
                    float _Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0 = Vector1_F9F09DC2;
                    float _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0 = Vector1_C8B2A3C1;
                    float _Divide_263822ede7aca782aaa923328ca71b31_Out_2;
                    Unity_Divide_float(_Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0, _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0, _Divide_263822ede7aca782aaa923328ca71b31_Out_2);
                    float _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Divide_263822ede7aca782aaa923328ca71b31_Out_2, _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2);
                    float2 _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2.xx), _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3);
                    float _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0 = Vector1_C8B2A3C1;
                    float _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3, _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2);
                    float _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2;
                    Unity_Step_float(_Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2, _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2);
                    float4 _Property_f429294e25120d848a0b88be0496b643_Out_0 = Color_3931EABE;
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_R_1 = _Property_f429294e25120d848a0b88be0496b643_Out_0[0];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_G_2 = _Property_f429294e25120d848a0b88be0496b643_Out_0[1];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_B_3 = _Property_f429294e25120d848a0b88be0496b643_Out_0[2];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4 = _Property_f429294e25120d848a0b88be0496b643_Out_0[3];
                    float _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2;
                    Unity_Multiply_float(_Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2, _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4, _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2);
                    float4 _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3;
                    Unity_Lerp_float4(_Lerp_5b013f099edf5785970f814b97e8df7b_Out_3, _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0, (_Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2.xxxx), _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3);
                    float3 _DDX_a7d600399dc07881b908a3a53583516f_Out_1;
                    Unity_DDX_float3(IN.WorldSpacePosition, _DDX_a7d600399dc07881b908a3a53583516f_Out_1);
                    float3 _DDY_28e176db7b2f3e83922081808777141e_Out_1;
                    Unity_DDY_float3(IN.WorldSpacePosition, _DDY_28e176db7b2f3e83922081808777141e_Out_1);
                    float3 _CrossProduct_be87980cfa67218b90c9a60413ab291c_Out_2;
                    Unity_CrossProduct_float(_DDX_a7d600399dc07881b908a3a53583516f_Out_1, _DDY_28e176db7b2f3e83922081808777141e_Out_1, _CrossProduct_be87980cfa67218b90c9a60413ab291c_Out_2);
                    float3 _Normalize_3253518d6b72628faf87de91eb464d94_Out_1;
                    Unity_Normalize_float3(_CrossProduct_be87980cfa67218b90c9a60413ab291c_Out_2, _Normalize_3253518d6b72628faf87de91eb464d94_Out_1);
                    float _Property_86d066cb5a7bf58f8d9583c0b62bd6b2_Out_0 = Vector1_FF85FCED;
                    float _Split_58f416024fe7fb8090af221026c86100_R_1 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[0];
                    float _Split_58f416024fe7fb8090af221026c86100_G_2 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[1];
                    float _Split_58f416024fe7fb8090af221026c86100_B_3 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[2];
                    float _Split_58f416024fe7fb8090af221026c86100_A_4 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[3];
                    surface.BaseColor = (_Lerp_0c7ea3049416da86bae08da697b4c022_Out_3.xyz);
                    surface.NormalTS = _Normalize_3253518d6b72628faf87de91eb464d94_Out_1;
                    surface.Emission = float3(0, 0, 0);
                    surface.Metallic = 0;
                    surface.Smoothness = _Property_86d066cb5a7bf58f8d9583c0b62bd6b2_Out_0;
                    surface.Occlusion = 1;
                    surface.Alpha = _Split_58f416024fe7fb8090af221026c86100_A_4;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.uv0 =                         input.uv0;
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                    output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityGBuffer.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRGBufferPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite On
                ColorMask 0
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_SHADOWCASTER
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float4 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.texCoord0 = input.interp1.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float Vector1_FF85FCED;
                float Vector1_3868C240;
                float4 Color_C277ACA6;
                float4 Color_FE83B6F2;
                float Vector1_72DC4170;
                float Vector1_E7F70192;
                float Vector1_C5017F27;
                float4 Color_3931EABE;
                float Vector1_9D907682;
                float Vector1_F9F09DC2;
                float Vector1_C8B2A3C1;
                float Vector1_9A37E012;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                struct Bindings_depthfade_ad197f998921d45438c2923a057d58fa
                {
                    float4 ScreenPosition;
                };
                
                void SG_depthfade_ad197f998921d45438c2923a057d58fa(float Vector1_5C4B96A6, Bindings_depthfade_ad197f998921d45438c2923a057d58fa IN, out float Output_1)
                {
                    float _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1);
                    float4 _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0 = IN.ScreenPosition;
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_R_1 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[0];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_G_2 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[1];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_B_3 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[2];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[3];
                    float _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2;
                    Unity_Subtract_float(_SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1, _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4, _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2);
                    float _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0 = Vector1_5C4B96A6;
                    float _Divide_911ee1e1202e918899a51b8749d33068_Out_2;
                    Unity_Divide_float(_Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2, _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0, _Divide_911ee1e1202e918899a51b8749d33068_Out_2);
                    float _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                    Unity_Saturate_float(_Divide_911ee1e1202e918899a51b8749d33068_Out_2, _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1);
                    Output_1 = _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0 = Vector1_72DC4170;
                    float _Divide_a04606a632dc1280be27255584976b7d_Out_2;
                    Unity_Divide_float(100, _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0, _Divide_a04606a632dc1280be27255584976b7d_Out_2);
                    float _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Divide_a04606a632dc1280be27255584976b7d_Out_2, _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2);
                    float2 _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2.xx), _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3);
                    float _Property_86931d7ca754618ba90f855709fd1158_Out_0 = Vector1_E7F70192;
                    float _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3, _Property_86931d7ca754618ba90f855709fd1158_Out_0, _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2);
                    float _Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0 = Vector1_C5017F27;
                    float _Divide_986b6b134b3636818accb3cbbef198c8_Out_2;
                    Unity_Divide_float(_Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0, 10, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2);
                    float _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2;
                    Unity_Multiply_float(_GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2, _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2);
                    float3 _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2;
                    Unity_Multiply_float((_Multiply_74100bafb098b482a96ac7aae9daf502_Out_2.xxx), IN.ObjectSpaceNormal, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2);
                    float3 _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2, _Add_4658daf37d98598f815235b0814f543d_Out_2);
                    description.Position = _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_428392b895d75588a789fa5e287344b7_Out_0 = Color_FE83B6F2;
                    float4 _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0 = Color_C277ACA6;
                    float _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1);
                    float _Multiply_285fae212657458aab12f18322e1cb55_Out_2;
                    Unity_Multiply_float(_SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1, _ProjectionParams.z, _Multiply_285fae212657458aab12f18322e1cb55_Out_2);
                    float4 _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0 = IN.ScreenPosition;
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_R_1 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[0];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_G_2 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[1];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_B_3 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[2];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[3];
                    float _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0 = Vector1_3868C240;
                    float _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2;
                    Unity_Add_float(_Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4, _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2);
                    float _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2;
                    Unity_Subtract_float(_Multiply_285fae212657458aab12f18322e1cb55_Out_2, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2, _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2);
                    float _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3;
                    Unity_Clamp_float(_Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2, 0, 1, _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3);
                    float4 _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3;
                    Unity_Lerp_float4(_Property_428392b895d75588a789fa5e287344b7_Out_0, _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0, (_Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3.xxxx), _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3);
                    float4 _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0 = Color_3931EABE;
                    float _Property_34238cd90bbe988da24e1813dab2cd84_Out_0 = Vector1_9D907682;
                    Bindings_depthfade_ad197f998921d45438c2923a057d58fa _depthfade_1c444d766e4743c3acfdf1e5dd412e0c;
                    _depthfade_1c444d766e4743c3acfdf1e5dd412e0c.ScreenPosition = IN.ScreenPosition;
                    float _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1;
                    SG_depthfade_ad197f998921d45438c2923a057d58fa(_Property_34238cd90bbe988da24e1813dab2cd84_Out_0, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1);
                    float _Property_769ea1a0d0064584904edd20953794c0_Out_0 = Vector1_9A37E012;
                    float _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2;
                    Unity_Multiply_float(_depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1, _Property_769ea1a0d0064584904edd20953794c0_Out_0, _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2);
                    float _Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0 = Vector1_F9F09DC2;
                    float _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0 = Vector1_C8B2A3C1;
                    float _Divide_263822ede7aca782aaa923328ca71b31_Out_2;
                    Unity_Divide_float(_Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0, _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0, _Divide_263822ede7aca782aaa923328ca71b31_Out_2);
                    float _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Divide_263822ede7aca782aaa923328ca71b31_Out_2, _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2);
                    float2 _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2.xx), _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3);
                    float _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0 = Vector1_C8B2A3C1;
                    float _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3, _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2);
                    float _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2;
                    Unity_Step_float(_Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2, _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2);
                    float4 _Property_f429294e25120d848a0b88be0496b643_Out_0 = Color_3931EABE;
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_R_1 = _Property_f429294e25120d848a0b88be0496b643_Out_0[0];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_G_2 = _Property_f429294e25120d848a0b88be0496b643_Out_0[1];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_B_3 = _Property_f429294e25120d848a0b88be0496b643_Out_0[2];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4 = _Property_f429294e25120d848a0b88be0496b643_Out_0[3];
                    float _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2;
                    Unity_Multiply_float(_Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2, _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4, _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2);
                    float4 _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3;
                    Unity_Lerp_float4(_Lerp_5b013f099edf5785970f814b97e8df7b_Out_3, _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0, (_Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2.xxxx), _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3);
                    float _Split_58f416024fe7fb8090af221026c86100_R_1 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[0];
                    float _Split_58f416024fe7fb8090af221026c86100_G_2 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[1];
                    float _Split_58f416024fe7fb8090af221026c86100_B_3 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[2];
                    float _Split_58f416024fe7fb8090af221026c86100_A_4 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[3];
                    surface.Alpha = _Split_58f416024fe7fb8090af221026c86100_A_4;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.uv0 =                         input.uv0;
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "DepthOnly"
                Tags
                {
                    "LightMode" = "DepthOnly"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite On
                ColorMask 0
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_DEPTHONLY
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float4 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.texCoord0 = input.interp1.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float Vector1_FF85FCED;
                float Vector1_3868C240;
                float4 Color_C277ACA6;
                float4 Color_FE83B6F2;
                float Vector1_72DC4170;
                float Vector1_E7F70192;
                float Vector1_C5017F27;
                float4 Color_3931EABE;
                float Vector1_9D907682;
                float Vector1_F9F09DC2;
                float Vector1_C8B2A3C1;
                float Vector1_9A37E012;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                struct Bindings_depthfade_ad197f998921d45438c2923a057d58fa
                {
                    float4 ScreenPosition;
                };
                
                void SG_depthfade_ad197f998921d45438c2923a057d58fa(float Vector1_5C4B96A6, Bindings_depthfade_ad197f998921d45438c2923a057d58fa IN, out float Output_1)
                {
                    float _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1);
                    float4 _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0 = IN.ScreenPosition;
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_R_1 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[0];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_G_2 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[1];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_B_3 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[2];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[3];
                    float _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2;
                    Unity_Subtract_float(_SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1, _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4, _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2);
                    float _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0 = Vector1_5C4B96A6;
                    float _Divide_911ee1e1202e918899a51b8749d33068_Out_2;
                    Unity_Divide_float(_Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2, _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0, _Divide_911ee1e1202e918899a51b8749d33068_Out_2);
                    float _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                    Unity_Saturate_float(_Divide_911ee1e1202e918899a51b8749d33068_Out_2, _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1);
                    Output_1 = _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0 = Vector1_72DC4170;
                    float _Divide_a04606a632dc1280be27255584976b7d_Out_2;
                    Unity_Divide_float(100, _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0, _Divide_a04606a632dc1280be27255584976b7d_Out_2);
                    float _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Divide_a04606a632dc1280be27255584976b7d_Out_2, _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2);
                    float2 _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2.xx), _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3);
                    float _Property_86931d7ca754618ba90f855709fd1158_Out_0 = Vector1_E7F70192;
                    float _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3, _Property_86931d7ca754618ba90f855709fd1158_Out_0, _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2);
                    float _Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0 = Vector1_C5017F27;
                    float _Divide_986b6b134b3636818accb3cbbef198c8_Out_2;
                    Unity_Divide_float(_Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0, 10, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2);
                    float _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2;
                    Unity_Multiply_float(_GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2, _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2);
                    float3 _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2;
                    Unity_Multiply_float((_Multiply_74100bafb098b482a96ac7aae9daf502_Out_2.xxx), IN.ObjectSpaceNormal, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2);
                    float3 _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2, _Add_4658daf37d98598f815235b0814f543d_Out_2);
                    description.Position = _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_428392b895d75588a789fa5e287344b7_Out_0 = Color_FE83B6F2;
                    float4 _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0 = Color_C277ACA6;
                    float _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1);
                    float _Multiply_285fae212657458aab12f18322e1cb55_Out_2;
                    Unity_Multiply_float(_SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1, _ProjectionParams.z, _Multiply_285fae212657458aab12f18322e1cb55_Out_2);
                    float4 _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0 = IN.ScreenPosition;
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_R_1 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[0];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_G_2 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[1];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_B_3 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[2];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[3];
                    float _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0 = Vector1_3868C240;
                    float _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2;
                    Unity_Add_float(_Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4, _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2);
                    float _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2;
                    Unity_Subtract_float(_Multiply_285fae212657458aab12f18322e1cb55_Out_2, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2, _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2);
                    float _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3;
                    Unity_Clamp_float(_Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2, 0, 1, _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3);
                    float4 _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3;
                    Unity_Lerp_float4(_Property_428392b895d75588a789fa5e287344b7_Out_0, _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0, (_Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3.xxxx), _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3);
                    float4 _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0 = Color_3931EABE;
                    float _Property_34238cd90bbe988da24e1813dab2cd84_Out_0 = Vector1_9D907682;
                    Bindings_depthfade_ad197f998921d45438c2923a057d58fa _depthfade_1c444d766e4743c3acfdf1e5dd412e0c;
                    _depthfade_1c444d766e4743c3acfdf1e5dd412e0c.ScreenPosition = IN.ScreenPosition;
                    float _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1;
                    SG_depthfade_ad197f998921d45438c2923a057d58fa(_Property_34238cd90bbe988da24e1813dab2cd84_Out_0, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1);
                    float _Property_769ea1a0d0064584904edd20953794c0_Out_0 = Vector1_9A37E012;
                    float _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2;
                    Unity_Multiply_float(_depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1, _Property_769ea1a0d0064584904edd20953794c0_Out_0, _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2);
                    float _Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0 = Vector1_F9F09DC2;
                    float _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0 = Vector1_C8B2A3C1;
                    float _Divide_263822ede7aca782aaa923328ca71b31_Out_2;
                    Unity_Divide_float(_Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0, _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0, _Divide_263822ede7aca782aaa923328ca71b31_Out_2);
                    float _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Divide_263822ede7aca782aaa923328ca71b31_Out_2, _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2);
                    float2 _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2.xx), _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3);
                    float _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0 = Vector1_C8B2A3C1;
                    float _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3, _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2);
                    float _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2;
                    Unity_Step_float(_Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2, _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2);
                    float4 _Property_f429294e25120d848a0b88be0496b643_Out_0 = Color_3931EABE;
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_R_1 = _Property_f429294e25120d848a0b88be0496b643_Out_0[0];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_G_2 = _Property_f429294e25120d848a0b88be0496b643_Out_0[1];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_B_3 = _Property_f429294e25120d848a0b88be0496b643_Out_0[2];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4 = _Property_f429294e25120d848a0b88be0496b643_Out_0[3];
                    float _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2;
                    Unity_Multiply_float(_Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2, _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4, _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2);
                    float4 _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3;
                    Unity_Lerp_float4(_Lerp_5b013f099edf5785970f814b97e8df7b_Out_3, _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0, (_Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2.xxxx), _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3);
                    float _Split_58f416024fe7fb8090af221026c86100_R_1 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[0];
                    float _Split_58f416024fe7fb8090af221026c86100_G_2 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[1];
                    float _Split_58f416024fe7fb8090af221026c86100_B_3 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[2];
                    float _Split_58f416024fe7fb8090af221026c86100_A_4 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[3];
                    surface.Alpha = _Split_58f416024fe7fb8090af221026c86100_A_4;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.uv0 =                         input.uv0;
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "DepthNormals"
                Tags
                {
                    "LightMode" = "DepthNormals"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite On
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile _ DOTS_INSTANCING_ON
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    float4 uv1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    float4 tangentWS;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 TangentSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    float4 interp2 : TEXCOORD2;
                    float4 interp3 : TEXCOORD3;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyzw =  input.tangentWS;
                    output.interp3.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float Vector1_FF85FCED;
                float Vector1_3868C240;
                float4 Color_C277ACA6;
                float4 Color_FE83B6F2;
                float Vector1_72DC4170;
                float Vector1_E7F70192;
                float Vector1_C5017F27;
                float4 Color_3931EABE;
                float Vector1_9D907682;
                float Vector1_F9F09DC2;
                float Vector1_C8B2A3C1;
                float Vector1_9A37E012;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_DDX_float3(float3 In, out float3 Out)
                {
                    Out = ddx(In);
                }
                
                void Unity_DDY_float3(float3 In, out float3 Out)
                {
                    Out = ddy(In);
                }
                
                void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
                {
                    Out = cross(A, B);
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                struct Bindings_depthfade_ad197f998921d45438c2923a057d58fa
                {
                    float4 ScreenPosition;
                };
                
                void SG_depthfade_ad197f998921d45438c2923a057d58fa(float Vector1_5C4B96A6, Bindings_depthfade_ad197f998921d45438c2923a057d58fa IN, out float Output_1)
                {
                    float _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1);
                    float4 _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0 = IN.ScreenPosition;
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_R_1 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[0];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_G_2 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[1];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_B_3 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[2];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[3];
                    float _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2;
                    Unity_Subtract_float(_SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1, _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4, _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2);
                    float _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0 = Vector1_5C4B96A6;
                    float _Divide_911ee1e1202e918899a51b8749d33068_Out_2;
                    Unity_Divide_float(_Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2, _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0, _Divide_911ee1e1202e918899a51b8749d33068_Out_2);
                    float _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                    Unity_Saturate_float(_Divide_911ee1e1202e918899a51b8749d33068_Out_2, _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1);
                    Output_1 = _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0 = Vector1_72DC4170;
                    float _Divide_a04606a632dc1280be27255584976b7d_Out_2;
                    Unity_Divide_float(100, _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0, _Divide_a04606a632dc1280be27255584976b7d_Out_2);
                    float _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Divide_a04606a632dc1280be27255584976b7d_Out_2, _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2);
                    float2 _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2.xx), _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3);
                    float _Property_86931d7ca754618ba90f855709fd1158_Out_0 = Vector1_E7F70192;
                    float _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3, _Property_86931d7ca754618ba90f855709fd1158_Out_0, _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2);
                    float _Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0 = Vector1_C5017F27;
                    float _Divide_986b6b134b3636818accb3cbbef198c8_Out_2;
                    Unity_Divide_float(_Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0, 10, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2);
                    float _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2;
                    Unity_Multiply_float(_GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2, _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2);
                    float3 _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2;
                    Unity_Multiply_float((_Multiply_74100bafb098b482a96ac7aae9daf502_Out_2.xxx), IN.ObjectSpaceNormal, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2);
                    float3 _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2, _Add_4658daf37d98598f815235b0814f543d_Out_2);
                    description.Position = _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 NormalTS;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float3 _DDX_a7d600399dc07881b908a3a53583516f_Out_1;
                    Unity_DDX_float3(IN.WorldSpacePosition, _DDX_a7d600399dc07881b908a3a53583516f_Out_1);
                    float3 _DDY_28e176db7b2f3e83922081808777141e_Out_1;
                    Unity_DDY_float3(IN.WorldSpacePosition, _DDY_28e176db7b2f3e83922081808777141e_Out_1);
                    float3 _CrossProduct_be87980cfa67218b90c9a60413ab291c_Out_2;
                    Unity_CrossProduct_float(_DDX_a7d600399dc07881b908a3a53583516f_Out_1, _DDY_28e176db7b2f3e83922081808777141e_Out_1, _CrossProduct_be87980cfa67218b90c9a60413ab291c_Out_2);
                    float3 _Normalize_3253518d6b72628faf87de91eb464d94_Out_1;
                    Unity_Normalize_float3(_CrossProduct_be87980cfa67218b90c9a60413ab291c_Out_2, _Normalize_3253518d6b72628faf87de91eb464d94_Out_1);
                    float4 _Property_428392b895d75588a789fa5e287344b7_Out_0 = Color_FE83B6F2;
                    float4 _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0 = Color_C277ACA6;
                    float _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1);
                    float _Multiply_285fae212657458aab12f18322e1cb55_Out_2;
                    Unity_Multiply_float(_SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1, _ProjectionParams.z, _Multiply_285fae212657458aab12f18322e1cb55_Out_2);
                    float4 _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0 = IN.ScreenPosition;
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_R_1 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[0];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_G_2 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[1];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_B_3 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[2];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[3];
                    float _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0 = Vector1_3868C240;
                    float _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2;
                    Unity_Add_float(_Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4, _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2);
                    float _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2;
                    Unity_Subtract_float(_Multiply_285fae212657458aab12f18322e1cb55_Out_2, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2, _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2);
                    float _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3;
                    Unity_Clamp_float(_Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2, 0, 1, _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3);
                    float4 _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3;
                    Unity_Lerp_float4(_Property_428392b895d75588a789fa5e287344b7_Out_0, _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0, (_Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3.xxxx), _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3);
                    float4 _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0 = Color_3931EABE;
                    float _Property_34238cd90bbe988da24e1813dab2cd84_Out_0 = Vector1_9D907682;
                    Bindings_depthfade_ad197f998921d45438c2923a057d58fa _depthfade_1c444d766e4743c3acfdf1e5dd412e0c;
                    _depthfade_1c444d766e4743c3acfdf1e5dd412e0c.ScreenPosition = IN.ScreenPosition;
                    float _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1;
                    SG_depthfade_ad197f998921d45438c2923a057d58fa(_Property_34238cd90bbe988da24e1813dab2cd84_Out_0, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1);
                    float _Property_769ea1a0d0064584904edd20953794c0_Out_0 = Vector1_9A37E012;
                    float _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2;
                    Unity_Multiply_float(_depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1, _Property_769ea1a0d0064584904edd20953794c0_Out_0, _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2);
                    float _Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0 = Vector1_F9F09DC2;
                    float _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0 = Vector1_C8B2A3C1;
                    float _Divide_263822ede7aca782aaa923328ca71b31_Out_2;
                    Unity_Divide_float(_Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0, _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0, _Divide_263822ede7aca782aaa923328ca71b31_Out_2);
                    float _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Divide_263822ede7aca782aaa923328ca71b31_Out_2, _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2);
                    float2 _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2.xx), _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3);
                    float _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0 = Vector1_C8B2A3C1;
                    float _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3, _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2);
                    float _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2;
                    Unity_Step_float(_Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2, _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2);
                    float4 _Property_f429294e25120d848a0b88be0496b643_Out_0 = Color_3931EABE;
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_R_1 = _Property_f429294e25120d848a0b88be0496b643_Out_0[0];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_G_2 = _Property_f429294e25120d848a0b88be0496b643_Out_0[1];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_B_3 = _Property_f429294e25120d848a0b88be0496b643_Out_0[2];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4 = _Property_f429294e25120d848a0b88be0496b643_Out_0[3];
                    float _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2;
                    Unity_Multiply_float(_Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2, _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4, _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2);
                    float4 _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3;
                    Unity_Lerp_float4(_Lerp_5b013f099edf5785970f814b97e8df7b_Out_3, _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0, (_Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2.xxxx), _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3);
                    float _Split_58f416024fe7fb8090af221026c86100_R_1 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[0];
                    float _Split_58f416024fe7fb8090af221026c86100_G_2 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[1];
                    float _Split_58f416024fe7fb8090af221026c86100_B_3 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[2];
                    float _Split_58f416024fe7fb8090af221026c86100_A_4 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[3];
                    surface.NormalTS = _Normalize_3253518d6b72628faf87de91eb464d94_Out_1;
                    surface.Alpha = _Split_58f416024fe7fb8090af221026c86100_A_4;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.uv0 =                         input.uv0;
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                    output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "Meta"
                Tags
                {
                    "LightMode" = "Meta"
                }
    
                // Render State
                Cull Off
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_META
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    float4 uv1 : TEXCOORD1;
                    float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float4 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.texCoord0 = input.interp1.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float Vector1_FF85FCED;
                float Vector1_3868C240;
                float4 Color_C277ACA6;
                float4 Color_FE83B6F2;
                float Vector1_72DC4170;
                float Vector1_E7F70192;
                float Vector1_C5017F27;
                float4 Color_3931EABE;
                float Vector1_9D907682;
                float Vector1_F9F09DC2;
                float Vector1_C8B2A3C1;
                float Vector1_9A37E012;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                struct Bindings_depthfade_ad197f998921d45438c2923a057d58fa
                {
                    float4 ScreenPosition;
                };
                
                void SG_depthfade_ad197f998921d45438c2923a057d58fa(float Vector1_5C4B96A6, Bindings_depthfade_ad197f998921d45438c2923a057d58fa IN, out float Output_1)
                {
                    float _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1);
                    float4 _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0 = IN.ScreenPosition;
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_R_1 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[0];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_G_2 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[1];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_B_3 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[2];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[3];
                    float _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2;
                    Unity_Subtract_float(_SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1, _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4, _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2);
                    float _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0 = Vector1_5C4B96A6;
                    float _Divide_911ee1e1202e918899a51b8749d33068_Out_2;
                    Unity_Divide_float(_Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2, _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0, _Divide_911ee1e1202e918899a51b8749d33068_Out_2);
                    float _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                    Unity_Saturate_float(_Divide_911ee1e1202e918899a51b8749d33068_Out_2, _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1);
                    Output_1 = _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0 = Vector1_72DC4170;
                    float _Divide_a04606a632dc1280be27255584976b7d_Out_2;
                    Unity_Divide_float(100, _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0, _Divide_a04606a632dc1280be27255584976b7d_Out_2);
                    float _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Divide_a04606a632dc1280be27255584976b7d_Out_2, _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2);
                    float2 _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2.xx), _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3);
                    float _Property_86931d7ca754618ba90f855709fd1158_Out_0 = Vector1_E7F70192;
                    float _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3, _Property_86931d7ca754618ba90f855709fd1158_Out_0, _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2);
                    float _Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0 = Vector1_C5017F27;
                    float _Divide_986b6b134b3636818accb3cbbef198c8_Out_2;
                    Unity_Divide_float(_Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0, 10, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2);
                    float _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2;
                    Unity_Multiply_float(_GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2, _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2);
                    float3 _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2;
                    Unity_Multiply_float((_Multiply_74100bafb098b482a96ac7aae9daf502_Out_2.xxx), IN.ObjectSpaceNormal, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2);
                    float3 _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2, _Add_4658daf37d98598f815235b0814f543d_Out_2);
                    description.Position = _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 Emission;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_428392b895d75588a789fa5e287344b7_Out_0 = Color_FE83B6F2;
                    float4 _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0 = Color_C277ACA6;
                    float _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1);
                    float _Multiply_285fae212657458aab12f18322e1cb55_Out_2;
                    Unity_Multiply_float(_SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1, _ProjectionParams.z, _Multiply_285fae212657458aab12f18322e1cb55_Out_2);
                    float4 _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0 = IN.ScreenPosition;
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_R_1 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[0];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_G_2 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[1];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_B_3 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[2];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[3];
                    float _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0 = Vector1_3868C240;
                    float _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2;
                    Unity_Add_float(_Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4, _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2);
                    float _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2;
                    Unity_Subtract_float(_Multiply_285fae212657458aab12f18322e1cb55_Out_2, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2, _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2);
                    float _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3;
                    Unity_Clamp_float(_Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2, 0, 1, _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3);
                    float4 _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3;
                    Unity_Lerp_float4(_Property_428392b895d75588a789fa5e287344b7_Out_0, _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0, (_Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3.xxxx), _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3);
                    float4 _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0 = Color_3931EABE;
                    float _Property_34238cd90bbe988da24e1813dab2cd84_Out_0 = Vector1_9D907682;
                    Bindings_depthfade_ad197f998921d45438c2923a057d58fa _depthfade_1c444d766e4743c3acfdf1e5dd412e0c;
                    _depthfade_1c444d766e4743c3acfdf1e5dd412e0c.ScreenPosition = IN.ScreenPosition;
                    float _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1;
                    SG_depthfade_ad197f998921d45438c2923a057d58fa(_Property_34238cd90bbe988da24e1813dab2cd84_Out_0, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1);
                    float _Property_769ea1a0d0064584904edd20953794c0_Out_0 = Vector1_9A37E012;
                    float _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2;
                    Unity_Multiply_float(_depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1, _Property_769ea1a0d0064584904edd20953794c0_Out_0, _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2);
                    float _Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0 = Vector1_F9F09DC2;
                    float _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0 = Vector1_C8B2A3C1;
                    float _Divide_263822ede7aca782aaa923328ca71b31_Out_2;
                    Unity_Divide_float(_Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0, _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0, _Divide_263822ede7aca782aaa923328ca71b31_Out_2);
                    float _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Divide_263822ede7aca782aaa923328ca71b31_Out_2, _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2);
                    float2 _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2.xx), _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3);
                    float _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0 = Vector1_C8B2A3C1;
                    float _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3, _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2);
                    float _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2;
                    Unity_Step_float(_Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2, _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2);
                    float4 _Property_f429294e25120d848a0b88be0496b643_Out_0 = Color_3931EABE;
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_R_1 = _Property_f429294e25120d848a0b88be0496b643_Out_0[0];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_G_2 = _Property_f429294e25120d848a0b88be0496b643_Out_0[1];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_B_3 = _Property_f429294e25120d848a0b88be0496b643_Out_0[2];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4 = _Property_f429294e25120d848a0b88be0496b643_Out_0[3];
                    float _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2;
                    Unity_Multiply_float(_Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2, _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4, _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2);
                    float4 _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3;
                    Unity_Lerp_float4(_Lerp_5b013f099edf5785970f814b97e8df7b_Out_3, _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0, (_Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2.xxxx), _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3);
                    float _Split_58f416024fe7fb8090af221026c86100_R_1 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[0];
                    float _Split_58f416024fe7fb8090af221026c86100_G_2 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[1];
                    float _Split_58f416024fe7fb8090af221026c86100_B_3 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[2];
                    float _Split_58f416024fe7fb8090af221026c86100_A_4 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[3];
                    surface.BaseColor = (_Lerp_0c7ea3049416da86bae08da697b4c022_Out_3.xyz);
                    surface.Emission = float3(0, 0, 0);
                    surface.Alpha = _Split_58f416024fe7fb8090af221026c86100_A_4;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.uv0 =                         input.uv0;
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                // Name: <None>
                Tags
                {
                    "LightMode" = "Universal2D"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 4.5
                #pragma exclude_renderers gles gles3 glcore
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_2D
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float4 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.texCoord0 = input.interp1.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float Vector1_FF85FCED;
                float Vector1_3868C240;
                float4 Color_C277ACA6;
                float4 Color_FE83B6F2;
                float Vector1_72DC4170;
                float Vector1_E7F70192;
                float Vector1_C5017F27;
                float4 Color_3931EABE;
                float Vector1_9D907682;
                float Vector1_F9F09DC2;
                float Vector1_C8B2A3C1;
                float Vector1_9A37E012;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                struct Bindings_depthfade_ad197f998921d45438c2923a057d58fa
                {
                    float4 ScreenPosition;
                };
                
                void SG_depthfade_ad197f998921d45438c2923a057d58fa(float Vector1_5C4B96A6, Bindings_depthfade_ad197f998921d45438c2923a057d58fa IN, out float Output_1)
                {
                    float _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1);
                    float4 _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0 = IN.ScreenPosition;
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_R_1 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[0];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_G_2 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[1];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_B_3 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[2];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[3];
                    float _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2;
                    Unity_Subtract_float(_SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1, _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4, _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2);
                    float _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0 = Vector1_5C4B96A6;
                    float _Divide_911ee1e1202e918899a51b8749d33068_Out_2;
                    Unity_Divide_float(_Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2, _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0, _Divide_911ee1e1202e918899a51b8749d33068_Out_2);
                    float _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                    Unity_Saturate_float(_Divide_911ee1e1202e918899a51b8749d33068_Out_2, _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1);
                    Output_1 = _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0 = Vector1_72DC4170;
                    float _Divide_a04606a632dc1280be27255584976b7d_Out_2;
                    Unity_Divide_float(100, _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0, _Divide_a04606a632dc1280be27255584976b7d_Out_2);
                    float _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Divide_a04606a632dc1280be27255584976b7d_Out_2, _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2);
                    float2 _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2.xx), _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3);
                    float _Property_86931d7ca754618ba90f855709fd1158_Out_0 = Vector1_E7F70192;
                    float _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3, _Property_86931d7ca754618ba90f855709fd1158_Out_0, _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2);
                    float _Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0 = Vector1_C5017F27;
                    float _Divide_986b6b134b3636818accb3cbbef198c8_Out_2;
                    Unity_Divide_float(_Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0, 10, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2);
                    float _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2;
                    Unity_Multiply_float(_GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2, _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2);
                    float3 _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2;
                    Unity_Multiply_float((_Multiply_74100bafb098b482a96ac7aae9daf502_Out_2.xxx), IN.ObjectSpaceNormal, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2);
                    float3 _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2, _Add_4658daf37d98598f815235b0814f543d_Out_2);
                    description.Position = _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_428392b895d75588a789fa5e287344b7_Out_0 = Color_FE83B6F2;
                    float4 _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0 = Color_C277ACA6;
                    float _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1);
                    float _Multiply_285fae212657458aab12f18322e1cb55_Out_2;
                    Unity_Multiply_float(_SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1, _ProjectionParams.z, _Multiply_285fae212657458aab12f18322e1cb55_Out_2);
                    float4 _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0 = IN.ScreenPosition;
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_R_1 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[0];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_G_2 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[1];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_B_3 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[2];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[3];
                    float _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0 = Vector1_3868C240;
                    float _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2;
                    Unity_Add_float(_Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4, _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2);
                    float _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2;
                    Unity_Subtract_float(_Multiply_285fae212657458aab12f18322e1cb55_Out_2, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2, _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2);
                    float _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3;
                    Unity_Clamp_float(_Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2, 0, 1, _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3);
                    float4 _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3;
                    Unity_Lerp_float4(_Property_428392b895d75588a789fa5e287344b7_Out_0, _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0, (_Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3.xxxx), _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3);
                    float4 _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0 = Color_3931EABE;
                    float _Property_34238cd90bbe988da24e1813dab2cd84_Out_0 = Vector1_9D907682;
                    Bindings_depthfade_ad197f998921d45438c2923a057d58fa _depthfade_1c444d766e4743c3acfdf1e5dd412e0c;
                    _depthfade_1c444d766e4743c3acfdf1e5dd412e0c.ScreenPosition = IN.ScreenPosition;
                    float _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1;
                    SG_depthfade_ad197f998921d45438c2923a057d58fa(_Property_34238cd90bbe988da24e1813dab2cd84_Out_0, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1);
                    float _Property_769ea1a0d0064584904edd20953794c0_Out_0 = Vector1_9A37E012;
                    float _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2;
                    Unity_Multiply_float(_depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1, _Property_769ea1a0d0064584904edd20953794c0_Out_0, _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2);
                    float _Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0 = Vector1_F9F09DC2;
                    float _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0 = Vector1_C8B2A3C1;
                    float _Divide_263822ede7aca782aaa923328ca71b31_Out_2;
                    Unity_Divide_float(_Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0, _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0, _Divide_263822ede7aca782aaa923328ca71b31_Out_2);
                    float _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Divide_263822ede7aca782aaa923328ca71b31_Out_2, _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2);
                    float2 _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2.xx), _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3);
                    float _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0 = Vector1_C8B2A3C1;
                    float _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3, _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2);
                    float _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2;
                    Unity_Step_float(_Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2, _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2);
                    float4 _Property_f429294e25120d848a0b88be0496b643_Out_0 = Color_3931EABE;
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_R_1 = _Property_f429294e25120d848a0b88be0496b643_Out_0[0];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_G_2 = _Property_f429294e25120d848a0b88be0496b643_Out_0[1];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_B_3 = _Property_f429294e25120d848a0b88be0496b643_Out_0[2];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4 = _Property_f429294e25120d848a0b88be0496b643_Out_0[3];
                    float _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2;
                    Unity_Multiply_float(_Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2, _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4, _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2);
                    float4 _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3;
                    Unity_Lerp_float4(_Lerp_5b013f099edf5785970f814b97e8df7b_Out_3, _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0, (_Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2.xxxx), _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3);
                    float _Split_58f416024fe7fb8090af221026c86100_R_1 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[0];
                    float _Split_58f416024fe7fb8090af221026c86100_G_2 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[1];
                    float _Split_58f416024fe7fb8090af221026c86100_B_3 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[2];
                    float _Split_58f416024fe7fb8090af221026c86100_A_4 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[3];
                    surface.BaseColor = (_Lerp_0c7ea3049416da86bae08da697b4c022_Out_3.xyz);
                    surface.Alpha = _Split_58f416024fe7fb8090af221026c86100_A_4;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.uv0 =                         input.uv0;
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
    
                ENDHLSL
            }
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Transparent"
                "UniversalMaterialType" = "Lit"
                "Queue"="Transparent"
            }
            Pass
            {
                Name "Universal Forward"
                Tags
                {
                    "LightMode" = "UniversalForward"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma multi_compile_fog
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                #pragma multi_compile _ _SCREEN_SPACE_OCCLUSION
                #pragma multi_compile _ LIGHTMAP_ON
                #pragma multi_compile _ DIRLIGHTMAP_COMBINED
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
                #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
                #pragma multi_compile _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS _ADDITIONAL_OFF
                #pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
                #pragma multi_compile _ _SHADOWS_SOFT
                #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
                #pragma multi_compile _ SHADOWS_SHADOWMASK
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define VARYINGS_NEED_VIEWDIRECTION_WS
                #define VARYINGS_NEED_FOG_AND_VERTEX_LIGHT
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_FORWARD
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    float4 uv1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    float4 tangentWS;
                    float4 texCoord0;
                    float3 viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    float2 lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    float3 sh;
                    #endif
                    float4 fogFactorAndVertexLight;
                    float4 shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 TangentSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    float4 interp2 : TEXCOORD2;
                    float4 interp3 : TEXCOORD3;
                    float3 interp4 : TEXCOORD4;
                    #if defined(LIGHTMAP_ON)
                    float2 interp5 : TEXCOORD5;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    float3 interp6 : TEXCOORD6;
                    #endif
                    float4 interp7 : TEXCOORD7;
                    float4 interp8 : TEXCOORD8;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyzw =  input.tangentWS;
                    output.interp3.xyzw =  input.texCoord0;
                    output.interp4.xyz =  input.viewDirectionWS;
                    #if defined(LIGHTMAP_ON)
                    output.interp5.xy =  input.lightmapUV;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.interp6.xyz =  input.sh;
                    #endif
                    output.interp7.xyzw =  input.fogFactorAndVertexLight;
                    output.interp8.xyzw =  input.shadowCoord;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    output.viewDirectionWS = input.interp4.xyz;
                    #if defined(LIGHTMAP_ON)
                    output.lightmapUV = input.interp5.xy;
                    #endif
                    #if !defined(LIGHTMAP_ON)
                    output.sh = input.interp6.xyz;
                    #endif
                    output.fogFactorAndVertexLight = input.interp7.xyzw;
                    output.shadowCoord = input.interp8.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float Vector1_FF85FCED;
                float Vector1_3868C240;
                float4 Color_C277ACA6;
                float4 Color_FE83B6F2;
                float Vector1_72DC4170;
                float Vector1_E7F70192;
                float Vector1_C5017F27;
                float4 Color_3931EABE;
                float Vector1_9D907682;
                float Vector1_F9F09DC2;
                float Vector1_C8B2A3C1;
                float Vector1_9A37E012;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                struct Bindings_depthfade_ad197f998921d45438c2923a057d58fa
                {
                    float4 ScreenPosition;
                };
                
                void SG_depthfade_ad197f998921d45438c2923a057d58fa(float Vector1_5C4B96A6, Bindings_depthfade_ad197f998921d45438c2923a057d58fa IN, out float Output_1)
                {
                    float _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1);
                    float4 _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0 = IN.ScreenPosition;
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_R_1 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[0];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_G_2 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[1];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_B_3 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[2];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[3];
                    float _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2;
                    Unity_Subtract_float(_SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1, _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4, _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2);
                    float _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0 = Vector1_5C4B96A6;
                    float _Divide_911ee1e1202e918899a51b8749d33068_Out_2;
                    Unity_Divide_float(_Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2, _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0, _Divide_911ee1e1202e918899a51b8749d33068_Out_2);
                    float _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                    Unity_Saturate_float(_Divide_911ee1e1202e918899a51b8749d33068_Out_2, _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1);
                    Output_1 = _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
                
                void Unity_DDX_float3(float3 In, out float3 Out)
                {
                    Out = ddx(In);
                }
                
                void Unity_DDY_float3(float3 In, out float3 Out)
                {
                    Out = ddy(In);
                }
                
                void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
                {
                    Out = cross(A, B);
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0 = Vector1_72DC4170;
                    float _Divide_a04606a632dc1280be27255584976b7d_Out_2;
                    Unity_Divide_float(100, _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0, _Divide_a04606a632dc1280be27255584976b7d_Out_2);
                    float _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Divide_a04606a632dc1280be27255584976b7d_Out_2, _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2);
                    float2 _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2.xx), _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3);
                    float _Property_86931d7ca754618ba90f855709fd1158_Out_0 = Vector1_E7F70192;
                    float _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3, _Property_86931d7ca754618ba90f855709fd1158_Out_0, _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2);
                    float _Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0 = Vector1_C5017F27;
                    float _Divide_986b6b134b3636818accb3cbbef198c8_Out_2;
                    Unity_Divide_float(_Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0, 10, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2);
                    float _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2;
                    Unity_Multiply_float(_GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2, _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2);
                    float3 _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2;
                    Unity_Multiply_float((_Multiply_74100bafb098b482a96ac7aae9daf502_Out_2.xxx), IN.ObjectSpaceNormal, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2);
                    float3 _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2, _Add_4658daf37d98598f815235b0814f543d_Out_2);
                    description.Position = _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 NormalTS;
                    float3 Emission;
                    float Metallic;
                    float Smoothness;
                    float Occlusion;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_428392b895d75588a789fa5e287344b7_Out_0 = Color_FE83B6F2;
                    float4 _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0 = Color_C277ACA6;
                    float _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1);
                    float _Multiply_285fae212657458aab12f18322e1cb55_Out_2;
                    Unity_Multiply_float(_SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1, _ProjectionParams.z, _Multiply_285fae212657458aab12f18322e1cb55_Out_2);
                    float4 _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0 = IN.ScreenPosition;
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_R_1 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[0];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_G_2 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[1];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_B_3 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[2];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[3];
                    float _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0 = Vector1_3868C240;
                    float _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2;
                    Unity_Add_float(_Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4, _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2);
                    float _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2;
                    Unity_Subtract_float(_Multiply_285fae212657458aab12f18322e1cb55_Out_2, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2, _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2);
                    float _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3;
                    Unity_Clamp_float(_Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2, 0, 1, _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3);
                    float4 _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3;
                    Unity_Lerp_float4(_Property_428392b895d75588a789fa5e287344b7_Out_0, _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0, (_Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3.xxxx), _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3);
                    float4 _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0 = Color_3931EABE;
                    float _Property_34238cd90bbe988da24e1813dab2cd84_Out_0 = Vector1_9D907682;
                    Bindings_depthfade_ad197f998921d45438c2923a057d58fa _depthfade_1c444d766e4743c3acfdf1e5dd412e0c;
                    _depthfade_1c444d766e4743c3acfdf1e5dd412e0c.ScreenPosition = IN.ScreenPosition;
                    float _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1;
                    SG_depthfade_ad197f998921d45438c2923a057d58fa(_Property_34238cd90bbe988da24e1813dab2cd84_Out_0, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1);
                    float _Property_769ea1a0d0064584904edd20953794c0_Out_0 = Vector1_9A37E012;
                    float _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2;
                    Unity_Multiply_float(_depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1, _Property_769ea1a0d0064584904edd20953794c0_Out_0, _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2);
                    float _Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0 = Vector1_F9F09DC2;
                    float _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0 = Vector1_C8B2A3C1;
                    float _Divide_263822ede7aca782aaa923328ca71b31_Out_2;
                    Unity_Divide_float(_Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0, _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0, _Divide_263822ede7aca782aaa923328ca71b31_Out_2);
                    float _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Divide_263822ede7aca782aaa923328ca71b31_Out_2, _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2);
                    float2 _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2.xx), _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3);
                    float _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0 = Vector1_C8B2A3C1;
                    float _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3, _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2);
                    float _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2;
                    Unity_Step_float(_Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2, _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2);
                    float4 _Property_f429294e25120d848a0b88be0496b643_Out_0 = Color_3931EABE;
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_R_1 = _Property_f429294e25120d848a0b88be0496b643_Out_0[0];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_G_2 = _Property_f429294e25120d848a0b88be0496b643_Out_0[1];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_B_3 = _Property_f429294e25120d848a0b88be0496b643_Out_0[2];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4 = _Property_f429294e25120d848a0b88be0496b643_Out_0[3];
                    float _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2;
                    Unity_Multiply_float(_Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2, _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4, _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2);
                    float4 _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3;
                    Unity_Lerp_float4(_Lerp_5b013f099edf5785970f814b97e8df7b_Out_3, _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0, (_Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2.xxxx), _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3);
                    float3 _DDX_a7d600399dc07881b908a3a53583516f_Out_1;
                    Unity_DDX_float3(IN.WorldSpacePosition, _DDX_a7d600399dc07881b908a3a53583516f_Out_1);
                    float3 _DDY_28e176db7b2f3e83922081808777141e_Out_1;
                    Unity_DDY_float3(IN.WorldSpacePosition, _DDY_28e176db7b2f3e83922081808777141e_Out_1);
                    float3 _CrossProduct_be87980cfa67218b90c9a60413ab291c_Out_2;
                    Unity_CrossProduct_float(_DDX_a7d600399dc07881b908a3a53583516f_Out_1, _DDY_28e176db7b2f3e83922081808777141e_Out_1, _CrossProduct_be87980cfa67218b90c9a60413ab291c_Out_2);
                    float3 _Normalize_3253518d6b72628faf87de91eb464d94_Out_1;
                    Unity_Normalize_float3(_CrossProduct_be87980cfa67218b90c9a60413ab291c_Out_2, _Normalize_3253518d6b72628faf87de91eb464d94_Out_1);
                    float _Property_86d066cb5a7bf58f8d9583c0b62bd6b2_Out_0 = Vector1_FF85FCED;
                    float _Split_58f416024fe7fb8090af221026c86100_R_1 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[0];
                    float _Split_58f416024fe7fb8090af221026c86100_G_2 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[1];
                    float _Split_58f416024fe7fb8090af221026c86100_B_3 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[2];
                    float _Split_58f416024fe7fb8090af221026c86100_A_4 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[3];
                    surface.BaseColor = (_Lerp_0c7ea3049416da86bae08da697b4c022_Out_3.xyz);
                    surface.NormalTS = _Normalize_3253518d6b72628faf87de91eb464d94_Out_1;
                    surface.Emission = float3(0, 0, 0);
                    surface.Metallic = 0;
                    surface.Smoothness = _Property_86d066cb5a7bf58f8d9583c0b62bd6b2_Out_0;
                    surface.Occlusion = 1;
                    surface.Alpha = _Split_58f416024fe7fb8090af221026c86100_A_4;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.uv0 =                         input.uv0;
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                    output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBRForwardPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite On
                ColorMask 0
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_SHADOWCASTER
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float4 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.texCoord0 = input.interp1.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float Vector1_FF85FCED;
                float Vector1_3868C240;
                float4 Color_C277ACA6;
                float4 Color_FE83B6F2;
                float Vector1_72DC4170;
                float Vector1_E7F70192;
                float Vector1_C5017F27;
                float4 Color_3931EABE;
                float Vector1_9D907682;
                float Vector1_F9F09DC2;
                float Vector1_C8B2A3C1;
                float Vector1_9A37E012;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                struct Bindings_depthfade_ad197f998921d45438c2923a057d58fa
                {
                    float4 ScreenPosition;
                };
                
                void SG_depthfade_ad197f998921d45438c2923a057d58fa(float Vector1_5C4B96A6, Bindings_depthfade_ad197f998921d45438c2923a057d58fa IN, out float Output_1)
                {
                    float _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1);
                    float4 _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0 = IN.ScreenPosition;
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_R_1 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[0];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_G_2 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[1];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_B_3 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[2];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[3];
                    float _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2;
                    Unity_Subtract_float(_SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1, _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4, _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2);
                    float _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0 = Vector1_5C4B96A6;
                    float _Divide_911ee1e1202e918899a51b8749d33068_Out_2;
                    Unity_Divide_float(_Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2, _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0, _Divide_911ee1e1202e918899a51b8749d33068_Out_2);
                    float _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                    Unity_Saturate_float(_Divide_911ee1e1202e918899a51b8749d33068_Out_2, _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1);
                    Output_1 = _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0 = Vector1_72DC4170;
                    float _Divide_a04606a632dc1280be27255584976b7d_Out_2;
                    Unity_Divide_float(100, _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0, _Divide_a04606a632dc1280be27255584976b7d_Out_2);
                    float _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Divide_a04606a632dc1280be27255584976b7d_Out_2, _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2);
                    float2 _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2.xx), _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3);
                    float _Property_86931d7ca754618ba90f855709fd1158_Out_0 = Vector1_E7F70192;
                    float _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3, _Property_86931d7ca754618ba90f855709fd1158_Out_0, _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2);
                    float _Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0 = Vector1_C5017F27;
                    float _Divide_986b6b134b3636818accb3cbbef198c8_Out_2;
                    Unity_Divide_float(_Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0, 10, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2);
                    float _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2;
                    Unity_Multiply_float(_GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2, _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2);
                    float3 _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2;
                    Unity_Multiply_float((_Multiply_74100bafb098b482a96ac7aae9daf502_Out_2.xxx), IN.ObjectSpaceNormal, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2);
                    float3 _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2, _Add_4658daf37d98598f815235b0814f543d_Out_2);
                    description.Position = _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_428392b895d75588a789fa5e287344b7_Out_0 = Color_FE83B6F2;
                    float4 _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0 = Color_C277ACA6;
                    float _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1);
                    float _Multiply_285fae212657458aab12f18322e1cb55_Out_2;
                    Unity_Multiply_float(_SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1, _ProjectionParams.z, _Multiply_285fae212657458aab12f18322e1cb55_Out_2);
                    float4 _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0 = IN.ScreenPosition;
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_R_1 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[0];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_G_2 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[1];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_B_3 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[2];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[3];
                    float _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0 = Vector1_3868C240;
                    float _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2;
                    Unity_Add_float(_Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4, _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2);
                    float _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2;
                    Unity_Subtract_float(_Multiply_285fae212657458aab12f18322e1cb55_Out_2, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2, _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2);
                    float _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3;
                    Unity_Clamp_float(_Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2, 0, 1, _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3);
                    float4 _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3;
                    Unity_Lerp_float4(_Property_428392b895d75588a789fa5e287344b7_Out_0, _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0, (_Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3.xxxx), _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3);
                    float4 _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0 = Color_3931EABE;
                    float _Property_34238cd90bbe988da24e1813dab2cd84_Out_0 = Vector1_9D907682;
                    Bindings_depthfade_ad197f998921d45438c2923a057d58fa _depthfade_1c444d766e4743c3acfdf1e5dd412e0c;
                    _depthfade_1c444d766e4743c3acfdf1e5dd412e0c.ScreenPosition = IN.ScreenPosition;
                    float _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1;
                    SG_depthfade_ad197f998921d45438c2923a057d58fa(_Property_34238cd90bbe988da24e1813dab2cd84_Out_0, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1);
                    float _Property_769ea1a0d0064584904edd20953794c0_Out_0 = Vector1_9A37E012;
                    float _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2;
                    Unity_Multiply_float(_depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1, _Property_769ea1a0d0064584904edd20953794c0_Out_0, _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2);
                    float _Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0 = Vector1_F9F09DC2;
                    float _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0 = Vector1_C8B2A3C1;
                    float _Divide_263822ede7aca782aaa923328ca71b31_Out_2;
                    Unity_Divide_float(_Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0, _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0, _Divide_263822ede7aca782aaa923328ca71b31_Out_2);
                    float _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Divide_263822ede7aca782aaa923328ca71b31_Out_2, _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2);
                    float2 _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2.xx), _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3);
                    float _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0 = Vector1_C8B2A3C1;
                    float _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3, _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2);
                    float _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2;
                    Unity_Step_float(_Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2, _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2);
                    float4 _Property_f429294e25120d848a0b88be0496b643_Out_0 = Color_3931EABE;
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_R_1 = _Property_f429294e25120d848a0b88be0496b643_Out_0[0];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_G_2 = _Property_f429294e25120d848a0b88be0496b643_Out_0[1];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_B_3 = _Property_f429294e25120d848a0b88be0496b643_Out_0[2];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4 = _Property_f429294e25120d848a0b88be0496b643_Out_0[3];
                    float _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2;
                    Unity_Multiply_float(_Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2, _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4, _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2);
                    float4 _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3;
                    Unity_Lerp_float4(_Lerp_5b013f099edf5785970f814b97e8df7b_Out_3, _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0, (_Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2.xxxx), _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3);
                    float _Split_58f416024fe7fb8090af221026c86100_R_1 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[0];
                    float _Split_58f416024fe7fb8090af221026c86100_G_2 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[1];
                    float _Split_58f416024fe7fb8090af221026c86100_B_3 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[2];
                    float _Split_58f416024fe7fb8090af221026c86100_A_4 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[3];
                    surface.Alpha = _Split_58f416024fe7fb8090af221026c86100_A_4;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.uv0 =                         input.uv0;
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "DepthOnly"
                Tags
                {
                    "LightMode" = "DepthOnly"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite On
                ColorMask 0
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_DEPTHONLY
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float4 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.texCoord0 = input.interp1.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float Vector1_FF85FCED;
                float Vector1_3868C240;
                float4 Color_C277ACA6;
                float4 Color_FE83B6F2;
                float Vector1_72DC4170;
                float Vector1_E7F70192;
                float Vector1_C5017F27;
                float4 Color_3931EABE;
                float Vector1_9D907682;
                float Vector1_F9F09DC2;
                float Vector1_C8B2A3C1;
                float Vector1_9A37E012;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                struct Bindings_depthfade_ad197f998921d45438c2923a057d58fa
                {
                    float4 ScreenPosition;
                };
                
                void SG_depthfade_ad197f998921d45438c2923a057d58fa(float Vector1_5C4B96A6, Bindings_depthfade_ad197f998921d45438c2923a057d58fa IN, out float Output_1)
                {
                    float _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1);
                    float4 _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0 = IN.ScreenPosition;
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_R_1 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[0];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_G_2 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[1];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_B_3 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[2];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[3];
                    float _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2;
                    Unity_Subtract_float(_SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1, _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4, _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2);
                    float _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0 = Vector1_5C4B96A6;
                    float _Divide_911ee1e1202e918899a51b8749d33068_Out_2;
                    Unity_Divide_float(_Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2, _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0, _Divide_911ee1e1202e918899a51b8749d33068_Out_2);
                    float _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                    Unity_Saturate_float(_Divide_911ee1e1202e918899a51b8749d33068_Out_2, _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1);
                    Output_1 = _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0 = Vector1_72DC4170;
                    float _Divide_a04606a632dc1280be27255584976b7d_Out_2;
                    Unity_Divide_float(100, _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0, _Divide_a04606a632dc1280be27255584976b7d_Out_2);
                    float _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Divide_a04606a632dc1280be27255584976b7d_Out_2, _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2);
                    float2 _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2.xx), _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3);
                    float _Property_86931d7ca754618ba90f855709fd1158_Out_0 = Vector1_E7F70192;
                    float _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3, _Property_86931d7ca754618ba90f855709fd1158_Out_0, _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2);
                    float _Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0 = Vector1_C5017F27;
                    float _Divide_986b6b134b3636818accb3cbbef198c8_Out_2;
                    Unity_Divide_float(_Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0, 10, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2);
                    float _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2;
                    Unity_Multiply_float(_GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2, _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2);
                    float3 _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2;
                    Unity_Multiply_float((_Multiply_74100bafb098b482a96ac7aae9daf502_Out_2.xxx), IN.ObjectSpaceNormal, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2);
                    float3 _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2, _Add_4658daf37d98598f815235b0814f543d_Out_2);
                    description.Position = _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_428392b895d75588a789fa5e287344b7_Out_0 = Color_FE83B6F2;
                    float4 _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0 = Color_C277ACA6;
                    float _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1);
                    float _Multiply_285fae212657458aab12f18322e1cb55_Out_2;
                    Unity_Multiply_float(_SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1, _ProjectionParams.z, _Multiply_285fae212657458aab12f18322e1cb55_Out_2);
                    float4 _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0 = IN.ScreenPosition;
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_R_1 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[0];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_G_2 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[1];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_B_3 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[2];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[3];
                    float _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0 = Vector1_3868C240;
                    float _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2;
                    Unity_Add_float(_Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4, _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2);
                    float _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2;
                    Unity_Subtract_float(_Multiply_285fae212657458aab12f18322e1cb55_Out_2, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2, _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2);
                    float _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3;
                    Unity_Clamp_float(_Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2, 0, 1, _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3);
                    float4 _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3;
                    Unity_Lerp_float4(_Property_428392b895d75588a789fa5e287344b7_Out_0, _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0, (_Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3.xxxx), _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3);
                    float4 _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0 = Color_3931EABE;
                    float _Property_34238cd90bbe988da24e1813dab2cd84_Out_0 = Vector1_9D907682;
                    Bindings_depthfade_ad197f998921d45438c2923a057d58fa _depthfade_1c444d766e4743c3acfdf1e5dd412e0c;
                    _depthfade_1c444d766e4743c3acfdf1e5dd412e0c.ScreenPosition = IN.ScreenPosition;
                    float _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1;
                    SG_depthfade_ad197f998921d45438c2923a057d58fa(_Property_34238cd90bbe988da24e1813dab2cd84_Out_0, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1);
                    float _Property_769ea1a0d0064584904edd20953794c0_Out_0 = Vector1_9A37E012;
                    float _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2;
                    Unity_Multiply_float(_depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1, _Property_769ea1a0d0064584904edd20953794c0_Out_0, _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2);
                    float _Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0 = Vector1_F9F09DC2;
                    float _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0 = Vector1_C8B2A3C1;
                    float _Divide_263822ede7aca782aaa923328ca71b31_Out_2;
                    Unity_Divide_float(_Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0, _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0, _Divide_263822ede7aca782aaa923328ca71b31_Out_2);
                    float _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Divide_263822ede7aca782aaa923328ca71b31_Out_2, _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2);
                    float2 _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2.xx), _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3);
                    float _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0 = Vector1_C8B2A3C1;
                    float _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3, _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2);
                    float _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2;
                    Unity_Step_float(_Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2, _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2);
                    float4 _Property_f429294e25120d848a0b88be0496b643_Out_0 = Color_3931EABE;
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_R_1 = _Property_f429294e25120d848a0b88be0496b643_Out_0[0];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_G_2 = _Property_f429294e25120d848a0b88be0496b643_Out_0[1];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_B_3 = _Property_f429294e25120d848a0b88be0496b643_Out_0[2];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4 = _Property_f429294e25120d848a0b88be0496b643_Out_0[3];
                    float _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2;
                    Unity_Multiply_float(_Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2, _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4, _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2);
                    float4 _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3;
                    Unity_Lerp_float4(_Lerp_5b013f099edf5785970f814b97e8df7b_Out_3, _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0, (_Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2.xxxx), _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3);
                    float _Split_58f416024fe7fb8090af221026c86100_R_1 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[0];
                    float _Split_58f416024fe7fb8090af221026c86100_G_2 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[1];
                    float _Split_58f416024fe7fb8090af221026c86100_B_3 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[2];
                    float _Split_58f416024fe7fb8090af221026c86100_A_4 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[3];
                    surface.Alpha = _Split_58f416024fe7fb8090af221026c86100_A_4;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.uv0 =                         input.uv0;
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "DepthNormals"
                Tags
                {
                    "LightMode" = "DepthNormals"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite On
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_NORMAL_WS
                #define VARYINGS_NEED_TANGENT_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    float4 uv1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float3 normalWS;
                    float4 tangentWS;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 TangentSpaceNormal;
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float3 interp1 : TEXCOORD1;
                    float4 interp2 : TEXCOORD2;
                    float4 interp3 : TEXCOORD3;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyz =  input.normalWS;
                    output.interp2.xyzw =  input.tangentWS;
                    output.interp3.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.normalWS = input.interp1.xyz;
                    output.tangentWS = input.interp2.xyzw;
                    output.texCoord0 = input.interp3.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float Vector1_FF85FCED;
                float Vector1_3868C240;
                float4 Color_C277ACA6;
                float4 Color_FE83B6F2;
                float Vector1_72DC4170;
                float Vector1_E7F70192;
                float Vector1_C5017F27;
                float4 Color_3931EABE;
                float Vector1_9D907682;
                float Vector1_F9F09DC2;
                float Vector1_C8B2A3C1;
                float Vector1_9A37E012;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_DDX_float3(float3 In, out float3 Out)
                {
                    Out = ddx(In);
                }
                
                void Unity_DDY_float3(float3 In, out float3 Out)
                {
                    Out = ddy(In);
                }
                
                void Unity_CrossProduct_float(float3 A, float3 B, out float3 Out)
                {
                    Out = cross(A, B);
                }
                
                void Unity_Normalize_float3(float3 In, out float3 Out)
                {
                    Out = normalize(In);
                }
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                struct Bindings_depthfade_ad197f998921d45438c2923a057d58fa
                {
                    float4 ScreenPosition;
                };
                
                void SG_depthfade_ad197f998921d45438c2923a057d58fa(float Vector1_5C4B96A6, Bindings_depthfade_ad197f998921d45438c2923a057d58fa IN, out float Output_1)
                {
                    float _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1);
                    float4 _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0 = IN.ScreenPosition;
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_R_1 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[0];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_G_2 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[1];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_B_3 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[2];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[3];
                    float _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2;
                    Unity_Subtract_float(_SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1, _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4, _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2);
                    float _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0 = Vector1_5C4B96A6;
                    float _Divide_911ee1e1202e918899a51b8749d33068_Out_2;
                    Unity_Divide_float(_Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2, _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0, _Divide_911ee1e1202e918899a51b8749d33068_Out_2);
                    float _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                    Unity_Saturate_float(_Divide_911ee1e1202e918899a51b8749d33068_Out_2, _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1);
                    Output_1 = _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0 = Vector1_72DC4170;
                    float _Divide_a04606a632dc1280be27255584976b7d_Out_2;
                    Unity_Divide_float(100, _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0, _Divide_a04606a632dc1280be27255584976b7d_Out_2);
                    float _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Divide_a04606a632dc1280be27255584976b7d_Out_2, _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2);
                    float2 _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2.xx), _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3);
                    float _Property_86931d7ca754618ba90f855709fd1158_Out_0 = Vector1_E7F70192;
                    float _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3, _Property_86931d7ca754618ba90f855709fd1158_Out_0, _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2);
                    float _Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0 = Vector1_C5017F27;
                    float _Divide_986b6b134b3636818accb3cbbef198c8_Out_2;
                    Unity_Divide_float(_Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0, 10, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2);
                    float _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2;
                    Unity_Multiply_float(_GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2, _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2);
                    float3 _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2;
                    Unity_Multiply_float((_Multiply_74100bafb098b482a96ac7aae9daf502_Out_2.xxx), IN.ObjectSpaceNormal, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2);
                    float3 _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2, _Add_4658daf37d98598f815235b0814f543d_Out_2);
                    description.Position = _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 NormalTS;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float3 _DDX_a7d600399dc07881b908a3a53583516f_Out_1;
                    Unity_DDX_float3(IN.WorldSpacePosition, _DDX_a7d600399dc07881b908a3a53583516f_Out_1);
                    float3 _DDY_28e176db7b2f3e83922081808777141e_Out_1;
                    Unity_DDY_float3(IN.WorldSpacePosition, _DDY_28e176db7b2f3e83922081808777141e_Out_1);
                    float3 _CrossProduct_be87980cfa67218b90c9a60413ab291c_Out_2;
                    Unity_CrossProduct_float(_DDX_a7d600399dc07881b908a3a53583516f_Out_1, _DDY_28e176db7b2f3e83922081808777141e_Out_1, _CrossProduct_be87980cfa67218b90c9a60413ab291c_Out_2);
                    float3 _Normalize_3253518d6b72628faf87de91eb464d94_Out_1;
                    Unity_Normalize_float3(_CrossProduct_be87980cfa67218b90c9a60413ab291c_Out_2, _Normalize_3253518d6b72628faf87de91eb464d94_Out_1);
                    float4 _Property_428392b895d75588a789fa5e287344b7_Out_0 = Color_FE83B6F2;
                    float4 _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0 = Color_C277ACA6;
                    float _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1);
                    float _Multiply_285fae212657458aab12f18322e1cb55_Out_2;
                    Unity_Multiply_float(_SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1, _ProjectionParams.z, _Multiply_285fae212657458aab12f18322e1cb55_Out_2);
                    float4 _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0 = IN.ScreenPosition;
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_R_1 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[0];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_G_2 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[1];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_B_3 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[2];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[3];
                    float _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0 = Vector1_3868C240;
                    float _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2;
                    Unity_Add_float(_Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4, _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2);
                    float _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2;
                    Unity_Subtract_float(_Multiply_285fae212657458aab12f18322e1cb55_Out_2, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2, _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2);
                    float _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3;
                    Unity_Clamp_float(_Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2, 0, 1, _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3);
                    float4 _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3;
                    Unity_Lerp_float4(_Property_428392b895d75588a789fa5e287344b7_Out_0, _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0, (_Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3.xxxx), _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3);
                    float4 _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0 = Color_3931EABE;
                    float _Property_34238cd90bbe988da24e1813dab2cd84_Out_0 = Vector1_9D907682;
                    Bindings_depthfade_ad197f998921d45438c2923a057d58fa _depthfade_1c444d766e4743c3acfdf1e5dd412e0c;
                    _depthfade_1c444d766e4743c3acfdf1e5dd412e0c.ScreenPosition = IN.ScreenPosition;
                    float _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1;
                    SG_depthfade_ad197f998921d45438c2923a057d58fa(_Property_34238cd90bbe988da24e1813dab2cd84_Out_0, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1);
                    float _Property_769ea1a0d0064584904edd20953794c0_Out_0 = Vector1_9A37E012;
                    float _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2;
                    Unity_Multiply_float(_depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1, _Property_769ea1a0d0064584904edd20953794c0_Out_0, _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2);
                    float _Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0 = Vector1_F9F09DC2;
                    float _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0 = Vector1_C8B2A3C1;
                    float _Divide_263822ede7aca782aaa923328ca71b31_Out_2;
                    Unity_Divide_float(_Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0, _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0, _Divide_263822ede7aca782aaa923328ca71b31_Out_2);
                    float _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Divide_263822ede7aca782aaa923328ca71b31_Out_2, _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2);
                    float2 _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2.xx), _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3);
                    float _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0 = Vector1_C8B2A3C1;
                    float _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3, _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2);
                    float _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2;
                    Unity_Step_float(_Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2, _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2);
                    float4 _Property_f429294e25120d848a0b88be0496b643_Out_0 = Color_3931EABE;
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_R_1 = _Property_f429294e25120d848a0b88be0496b643_Out_0[0];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_G_2 = _Property_f429294e25120d848a0b88be0496b643_Out_0[1];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_B_3 = _Property_f429294e25120d848a0b88be0496b643_Out_0[2];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4 = _Property_f429294e25120d848a0b88be0496b643_Out_0[3];
                    float _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2;
                    Unity_Multiply_float(_Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2, _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4, _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2);
                    float4 _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3;
                    Unity_Lerp_float4(_Lerp_5b013f099edf5785970f814b97e8df7b_Out_3, _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0, (_Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2.xxxx), _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3);
                    float _Split_58f416024fe7fb8090af221026c86100_R_1 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[0];
                    float _Split_58f416024fe7fb8090af221026c86100_G_2 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[1];
                    float _Split_58f416024fe7fb8090af221026c86100_B_3 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[2];
                    float _Split_58f416024fe7fb8090af221026c86100_A_4 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[3];
                    surface.NormalTS = _Normalize_3253518d6b72628faf87de91eb464d94_Out_1;
                    surface.Alpha = _Split_58f416024fe7fb8090af221026c86100_A_4;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.uv0 =                         input.uv0;
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                    output.TangentSpaceNormal =          float3(0.0f, 0.0f, 1.0f);
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                Name "Meta"
                Tags
                {
                    "LightMode" = "Meta"
                }
    
                // Render State
                Cull Off
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                #pragma shader_feature _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define ATTRIBUTES_NEED_TEXCOORD1
                #define ATTRIBUTES_NEED_TEXCOORD2
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_META
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/MetaInput.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    float4 uv1 : TEXCOORD1;
                    float4 uv2 : TEXCOORD2;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float4 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.texCoord0 = input.interp1.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float Vector1_FF85FCED;
                float Vector1_3868C240;
                float4 Color_C277ACA6;
                float4 Color_FE83B6F2;
                float Vector1_72DC4170;
                float Vector1_E7F70192;
                float Vector1_C5017F27;
                float4 Color_3931EABE;
                float Vector1_9D907682;
                float Vector1_F9F09DC2;
                float Vector1_C8B2A3C1;
                float Vector1_9A37E012;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                struct Bindings_depthfade_ad197f998921d45438c2923a057d58fa
                {
                    float4 ScreenPosition;
                };
                
                void SG_depthfade_ad197f998921d45438c2923a057d58fa(float Vector1_5C4B96A6, Bindings_depthfade_ad197f998921d45438c2923a057d58fa IN, out float Output_1)
                {
                    float _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1);
                    float4 _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0 = IN.ScreenPosition;
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_R_1 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[0];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_G_2 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[1];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_B_3 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[2];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[3];
                    float _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2;
                    Unity_Subtract_float(_SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1, _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4, _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2);
                    float _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0 = Vector1_5C4B96A6;
                    float _Divide_911ee1e1202e918899a51b8749d33068_Out_2;
                    Unity_Divide_float(_Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2, _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0, _Divide_911ee1e1202e918899a51b8749d33068_Out_2);
                    float _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                    Unity_Saturate_float(_Divide_911ee1e1202e918899a51b8749d33068_Out_2, _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1);
                    Output_1 = _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0 = Vector1_72DC4170;
                    float _Divide_a04606a632dc1280be27255584976b7d_Out_2;
                    Unity_Divide_float(100, _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0, _Divide_a04606a632dc1280be27255584976b7d_Out_2);
                    float _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Divide_a04606a632dc1280be27255584976b7d_Out_2, _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2);
                    float2 _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2.xx), _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3);
                    float _Property_86931d7ca754618ba90f855709fd1158_Out_0 = Vector1_E7F70192;
                    float _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3, _Property_86931d7ca754618ba90f855709fd1158_Out_0, _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2);
                    float _Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0 = Vector1_C5017F27;
                    float _Divide_986b6b134b3636818accb3cbbef198c8_Out_2;
                    Unity_Divide_float(_Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0, 10, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2);
                    float _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2;
                    Unity_Multiply_float(_GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2, _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2);
                    float3 _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2;
                    Unity_Multiply_float((_Multiply_74100bafb098b482a96ac7aae9daf502_Out_2.xxx), IN.ObjectSpaceNormal, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2);
                    float3 _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2, _Add_4658daf37d98598f815235b0814f543d_Out_2);
                    description.Position = _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float3 Emission;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_428392b895d75588a789fa5e287344b7_Out_0 = Color_FE83B6F2;
                    float4 _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0 = Color_C277ACA6;
                    float _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1);
                    float _Multiply_285fae212657458aab12f18322e1cb55_Out_2;
                    Unity_Multiply_float(_SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1, _ProjectionParams.z, _Multiply_285fae212657458aab12f18322e1cb55_Out_2);
                    float4 _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0 = IN.ScreenPosition;
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_R_1 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[0];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_G_2 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[1];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_B_3 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[2];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[3];
                    float _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0 = Vector1_3868C240;
                    float _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2;
                    Unity_Add_float(_Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4, _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2);
                    float _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2;
                    Unity_Subtract_float(_Multiply_285fae212657458aab12f18322e1cb55_Out_2, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2, _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2);
                    float _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3;
                    Unity_Clamp_float(_Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2, 0, 1, _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3);
                    float4 _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3;
                    Unity_Lerp_float4(_Property_428392b895d75588a789fa5e287344b7_Out_0, _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0, (_Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3.xxxx), _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3);
                    float4 _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0 = Color_3931EABE;
                    float _Property_34238cd90bbe988da24e1813dab2cd84_Out_0 = Vector1_9D907682;
                    Bindings_depthfade_ad197f998921d45438c2923a057d58fa _depthfade_1c444d766e4743c3acfdf1e5dd412e0c;
                    _depthfade_1c444d766e4743c3acfdf1e5dd412e0c.ScreenPosition = IN.ScreenPosition;
                    float _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1;
                    SG_depthfade_ad197f998921d45438c2923a057d58fa(_Property_34238cd90bbe988da24e1813dab2cd84_Out_0, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1);
                    float _Property_769ea1a0d0064584904edd20953794c0_Out_0 = Vector1_9A37E012;
                    float _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2;
                    Unity_Multiply_float(_depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1, _Property_769ea1a0d0064584904edd20953794c0_Out_0, _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2);
                    float _Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0 = Vector1_F9F09DC2;
                    float _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0 = Vector1_C8B2A3C1;
                    float _Divide_263822ede7aca782aaa923328ca71b31_Out_2;
                    Unity_Divide_float(_Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0, _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0, _Divide_263822ede7aca782aaa923328ca71b31_Out_2);
                    float _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Divide_263822ede7aca782aaa923328ca71b31_Out_2, _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2);
                    float2 _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2.xx), _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3);
                    float _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0 = Vector1_C8B2A3C1;
                    float _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3, _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2);
                    float _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2;
                    Unity_Step_float(_Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2, _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2);
                    float4 _Property_f429294e25120d848a0b88be0496b643_Out_0 = Color_3931EABE;
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_R_1 = _Property_f429294e25120d848a0b88be0496b643_Out_0[0];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_G_2 = _Property_f429294e25120d848a0b88be0496b643_Out_0[1];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_B_3 = _Property_f429294e25120d848a0b88be0496b643_Out_0[2];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4 = _Property_f429294e25120d848a0b88be0496b643_Out_0[3];
                    float _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2;
                    Unity_Multiply_float(_Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2, _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4, _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2);
                    float4 _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3;
                    Unity_Lerp_float4(_Lerp_5b013f099edf5785970f814b97e8df7b_Out_3, _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0, (_Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2.xxxx), _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3);
                    float _Split_58f416024fe7fb8090af221026c86100_R_1 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[0];
                    float _Split_58f416024fe7fb8090af221026c86100_G_2 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[1];
                    float _Split_58f416024fe7fb8090af221026c86100_B_3 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[2];
                    float _Split_58f416024fe7fb8090af221026c86100_A_4 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[3];
                    surface.BaseColor = (_Lerp_0c7ea3049416da86bae08da697b4c022_Out_3.xyz);
                    surface.Emission = float3(0, 0, 0);
                    surface.Alpha = _Split_58f416024fe7fb8090af221026c86100_A_4;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.uv0 =                         input.uv0;
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/LightingMetaPass.hlsl"
    
                ENDHLSL
            }
            Pass
            {
                // Name: <None>
                Tags
                {
                    "LightMode" = "Universal2D"
                }
    
                // Render State
                Cull Off
                Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
                ZTest LEqual
                ZWrite Off
    
                // Debug
                // <None>
    
                // --------------------------------------------------
                // Pass
    
                HLSLPROGRAM
    
                // Pragmas
                #pragma target 2.0
                #pragma only_renderers gles gles3 glcore
                #pragma multi_compile_instancing
                #pragma vertex vert
                #pragma fragment frag
    
                // DotsInstancingOptions: <None>
                // HybridV1InjectedBuiltinProperties: <None>
    
                // Keywords
                // PassKeywords: <None>
                // GraphKeywords: <None>
    
                // Defines
                #define _SURFACE_TYPE_TRANSPARENT 1
                #define _NORMALMAP 1
                #define _NORMAL_DROPOFF_TS 1
                #define ATTRIBUTES_NEED_NORMAL
                #define ATTRIBUTES_NEED_TANGENT
                #define ATTRIBUTES_NEED_TEXCOORD0
                #define VARYINGS_NEED_POSITION_WS
                #define VARYINGS_NEED_TEXCOORD0
                #define FEATURES_GRAPH_VERTEX
                /* WARNING: $splice Could not find named fragment 'PassInstancing' */
                #define SHADERPASS SHADERPASS_2D
                #define REQUIRE_DEPTH_TEXTURE
                /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
    
                // Includes
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
                #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
    
                // --------------------------------------------------
                // Structs and Packing
    
                struct Attributes
                {
                    float3 positionOS : POSITION;
                    float3 normalOS : NORMAL;
                    float4 tangentOS : TANGENT;
                    float4 uv0 : TEXCOORD0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : INSTANCEID_SEMANTIC;
                    #endif
                };
                struct Varyings
                {
                    float4 positionCS : SV_POSITION;
                    float3 positionWS;
                    float4 texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
                struct SurfaceDescriptionInputs
                {
                    float3 WorldSpacePosition;
                    float4 ScreenPosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct VertexDescriptionInputs
                {
                    float3 ObjectSpaceNormal;
                    float3 ObjectSpaceTangent;
                    float3 ObjectSpacePosition;
                    float4 uv0;
                    float3 TimeParameters;
                };
                struct PackedVaryings
                {
                    float4 positionCS : SV_POSITION;
                    float3 interp0 : TEXCOORD0;
                    float4 interp1 : TEXCOORD1;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    uint instanceID : CUSTOM_INSTANCE_ID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                    #endif
                };
    
                PackedVaryings PackVaryings (Varyings input)
                {
                    PackedVaryings output;
                    output.positionCS = input.positionCS;
                    output.interp0.xyz =  input.positionWS;
                    output.interp1.xyzw =  input.texCoord0;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
                Varyings UnpackVaryings (PackedVaryings input)
                {
                    Varyings output;
                    output.positionCS = input.positionCS;
                    output.positionWS = input.interp0.xyz;
                    output.texCoord0 = input.interp1.xyzw;
                    #if UNITY_ANY_INSTANCING_ENABLED
                    output.instanceID = input.instanceID;
                    #endif
                    #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                    output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                    #endif
                    #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                    output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                    #endif
                    #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                    output.cullFace = input.cullFace;
                    #endif
                    return output;
                }
    
                // --------------------------------------------------
                // Graph
    
                // Graph Properties
                CBUFFER_START(UnityPerMaterial)
                float Vector1_FF85FCED;
                float Vector1_3868C240;
                float4 Color_C277ACA6;
                float4 Color_FE83B6F2;
                float Vector1_72DC4170;
                float Vector1_E7F70192;
                float Vector1_C5017F27;
                float4 Color_3931EABE;
                float Vector1_9D907682;
                float Vector1_F9F09DC2;
                float Vector1_C8B2A3C1;
                float Vector1_9A37E012;
                CBUFFER_END
                
                // Object and Global properties
    
                // Graph Functions
                
                void Unity_Divide_float(float A, float B, out float Out)
                {
                    Out = A / B;
                }
                
                void Unity_TilingAndOffset_float(float2 UV, float2 Tiling, float2 Offset, out float2 Out)
                {
                    Out = UV * Tiling + Offset;
                }
                
                
                float2 Unity_GradientNoise_Dir_float(float2 p)
                {
                    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
                    p = p % 289;
                    // need full precision, otherwise half overflows when p > 1
                    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
                    x = (34 * x + 1) * x % 289;
                    x = frac(x / 41) * 2 - 1;
                    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
                }
                
                void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
                { 
                    float2 p = UV * Scale;
                    float2 ip = floor(p);
                    float2 fp = frac(p);
                    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
                    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
                    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
                    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
                    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
                }
                
                void Unity_Multiply_float(float A, float B, out float Out)
                {
                    Out = A * B;
                }
                
                void Unity_Multiply_float(float3 A, float3 B, out float3 Out)
                {
                    Out = A * B;
                }
                
                void Unity_Add_float3(float3 A, float3 B, out float3 Out)
                {
                    Out = A + B;
                }
                
                void Unity_SceneDepth_Linear01_float(float4 UV, out float Out)
                {
                    Out = Linear01Depth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Add_float(float A, float B, out float Out)
                {
                    Out = A + B;
                }
                
                void Unity_Subtract_float(float A, float B, out float Out)
                {
                    Out = A - B;
                }
                
                void Unity_Clamp_float(float In, float Min, float Max, out float Out)
                {
                    Out = clamp(In, Min, Max);
                }
                
                void Unity_Lerp_float4(float4 A, float4 B, float4 T, out float4 Out)
                {
                    Out = lerp(A, B, T);
                }
                
                void Unity_SceneDepth_Eye_float(float4 UV, out float Out)
                {
                    Out = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH(UV.xy), _ZBufferParams);
                }
                
                void Unity_Saturate_float(float In, out float Out)
                {
                    Out = saturate(In);
                }
                
                struct Bindings_depthfade_ad197f998921d45438c2923a057d58fa
                {
                    float4 ScreenPosition;
                };
                
                void SG_depthfade_ad197f998921d45438c2923a057d58fa(float Vector1_5C4B96A6, Bindings_depthfade_ad197f998921d45438c2923a057d58fa IN, out float Output_1)
                {
                    float _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1;
                    Unity_SceneDepth_Eye_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1);
                    float4 _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0 = IN.ScreenPosition;
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_R_1 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[0];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_G_2 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[1];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_B_3 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[2];
                    float _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4 = _ScreenPosition_a3f759a6e5a3298287353330fb9ac67b_Out_0[3];
                    float _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2;
                    Unity_Subtract_float(_SceneDepth_012d55ed5e337882ba189656aaa9806e_Out_1, _Split_00af0a80cf190c8dbac26f1c9bd29d10_A_4, _Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2);
                    float _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0 = Vector1_5C4B96A6;
                    float _Divide_911ee1e1202e918899a51b8749d33068_Out_2;
                    Unity_Divide_float(_Subtract_bff97afa03f6cf84b0fa4692ef45f6ae_Out_2, _Property_c8da11bdf2cad1859e4d5fe95818c056_Out_0, _Divide_911ee1e1202e918899a51b8749d33068_Out_2);
                    float _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                    Unity_Saturate_float(_Divide_911ee1e1202e918899a51b8749d33068_Out_2, _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1);
                    Output_1 = _Saturate_bc5e13f1c52dd8839d83ada5e314caa9_Out_1;
                }
                
                void Unity_Step_float(float Edge, float In, out float Out)
                {
                    Out = step(Edge, In);
                }
    
                // Graph Vertex
                struct VertexDescription
                {
                    float3 Position;
                    float3 Normal;
                    float3 Tangent;
                };
                
                VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
                {
                    VertexDescription description = (VertexDescription)0;
                    float _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0 = Vector1_72DC4170;
                    float _Divide_a04606a632dc1280be27255584976b7d_Out_2;
                    Unity_Divide_float(100, _Property_c0fb5ca7bf0b0f87b1694e5a5fc6af20_Out_0, _Divide_a04606a632dc1280be27255584976b7d_Out_2);
                    float _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2;
                    Unity_Divide_float(IN.TimeParameters.x, _Divide_a04606a632dc1280be27255584976b7d_Out_2, _Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2);
                    float2 _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Divide_7f9b6811bfa35b8a8798f10ef9fbabb0_Out_2.xx), _TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3);
                    float _Property_86931d7ca754618ba90f855709fd1158_Out_0 = Vector1_E7F70192;
                    float _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_38e8160ce048328db27133ec9aab2d05_Out_3, _Property_86931d7ca754618ba90f855709fd1158_Out_0, _GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2);
                    float _Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0 = Vector1_C5017F27;
                    float _Divide_986b6b134b3636818accb3cbbef198c8_Out_2;
                    Unity_Divide_float(_Property_c7161fa63d15618eb7f6e2da30faddd4_Out_0, 10, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2);
                    float _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2;
                    Unity_Multiply_float(_GradientNoise_545f9dbaf90f348bacbf6ff57b963be0_Out_2, _Divide_986b6b134b3636818accb3cbbef198c8_Out_2, _Multiply_74100bafb098b482a96ac7aae9daf502_Out_2);
                    float3 _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2;
                    Unity_Multiply_float((_Multiply_74100bafb098b482a96ac7aae9daf502_Out_2.xxx), IN.ObjectSpaceNormal, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2);
                    float3 _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    Unity_Add_float3(IN.ObjectSpacePosition, _Multiply_07494529e80d7c83ac79dcd29f5fa37d_Out_2, _Add_4658daf37d98598f815235b0814f543d_Out_2);
                    description.Position = _Add_4658daf37d98598f815235b0814f543d_Out_2;
                    description.Normal = IN.ObjectSpaceNormal;
                    description.Tangent = IN.ObjectSpaceTangent;
                    return description;
                }
    
                // Graph Pixel
                struct SurfaceDescription
                {
                    float3 BaseColor;
                    float Alpha;
                };
                
                SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
                {
                    SurfaceDescription surface = (SurfaceDescription)0;
                    float4 _Property_428392b895d75588a789fa5e287344b7_Out_0 = Color_FE83B6F2;
                    float4 _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0 = Color_C277ACA6;
                    float _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1;
                    Unity_SceneDepth_Linear01_float(float4(IN.ScreenPosition.xy / IN.ScreenPosition.w, 0, 0), _SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1);
                    float _Multiply_285fae212657458aab12f18322e1cb55_Out_2;
                    Unity_Multiply_float(_SceneDepth_1dec3b72c9113e84ac7025e55c90adc7_Out_1, _ProjectionParams.z, _Multiply_285fae212657458aab12f18322e1cb55_Out_2);
                    float4 _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0 = IN.ScreenPosition;
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_R_1 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[0];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_G_2 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[1];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_B_3 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[2];
                    float _Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4 = _ScreenPosition_fca2cc8562dfbc8a9bc2369ddf384828_Out_0[3];
                    float _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0 = Vector1_3868C240;
                    float _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2;
                    Unity_Add_float(_Split_8c2f80c3ef23708d87c4c21edc436fb6_A_4, _Property_4ee5188667602e8abd23d6e09da7b6fd_Out_0, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2);
                    float _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2;
                    Unity_Subtract_float(_Multiply_285fae212657458aab12f18322e1cb55_Out_2, _Add_b59f2632bfe2d189b0b6d9cb15a93e72_Out_2, _Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2);
                    float _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3;
                    Unity_Clamp_float(_Subtract_6c162d26f43bdc86a05bf17a61260e69_Out_2, 0, 1, _Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3);
                    float4 _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3;
                    Unity_Lerp_float4(_Property_428392b895d75588a789fa5e287344b7_Out_0, _Property_c187721d6d9f328297c7d2acaf06c25b_Out_0, (_Clamp_e6bd4c784f15ab8d9efbe73db41e5a79_Out_3.xxxx), _Lerp_5b013f099edf5785970f814b97e8df7b_Out_3);
                    float4 _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0 = Color_3931EABE;
                    float _Property_34238cd90bbe988da24e1813dab2cd84_Out_0 = Vector1_9D907682;
                    Bindings_depthfade_ad197f998921d45438c2923a057d58fa _depthfade_1c444d766e4743c3acfdf1e5dd412e0c;
                    _depthfade_1c444d766e4743c3acfdf1e5dd412e0c.ScreenPosition = IN.ScreenPosition;
                    float _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1;
                    SG_depthfade_ad197f998921d45438c2923a057d58fa(_Property_34238cd90bbe988da24e1813dab2cd84_Out_0, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c, _depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1);
                    float _Property_769ea1a0d0064584904edd20953794c0_Out_0 = Vector1_9A37E012;
                    float _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2;
                    Unity_Multiply_float(_depthfade_1c444d766e4743c3acfdf1e5dd412e0c_Output_1, _Property_769ea1a0d0064584904edd20953794c0_Out_0, _Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2);
                    float _Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0 = Vector1_F9F09DC2;
                    float _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0 = Vector1_C8B2A3C1;
                    float _Divide_263822ede7aca782aaa923328ca71b31_Out_2;
                    Unity_Divide_float(_Property_57fe735ab67e528eb6bcd97476dc7a82_Out_0, _Property_6310a100d75c8a87acec7e33e636ad8e_Out_0, _Divide_263822ede7aca782aaa923328ca71b31_Out_2);
                    float _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2;
                    Unity_Multiply_float(IN.TimeParameters.x, _Divide_263822ede7aca782aaa923328ca71b31_Out_2, _Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2);
                    float2 _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3;
                    Unity_TilingAndOffset_float(IN.uv0.xy, float2 (1, 1), (_Multiply_54979ed3f14d7f848e00fff2aa15d61f_Out_2.xx), _TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3);
                    float _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0 = Vector1_C8B2A3C1;
                    float _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2;
                    Unity_GradientNoise_float(_TilingAndOffset_c3d8e9b1cff123838c02178974225a38_Out_3, _Property_d7ab6dbb46eb1e85bc4e0b10914f4100_Out_0, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2);
                    float _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2;
                    Unity_Step_float(_Multiply_c89eeda5e0e4be8cbbbdda0b72de7651_Out_2, _GradientNoise_89079e1c731ae18cad20885c66113791_Out_2, _Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2);
                    float4 _Property_f429294e25120d848a0b88be0496b643_Out_0 = Color_3931EABE;
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_R_1 = _Property_f429294e25120d848a0b88be0496b643_Out_0[0];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_G_2 = _Property_f429294e25120d848a0b88be0496b643_Out_0[1];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_B_3 = _Property_f429294e25120d848a0b88be0496b643_Out_0[2];
                    float _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4 = _Property_f429294e25120d848a0b88be0496b643_Out_0[3];
                    float _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2;
                    Unity_Multiply_float(_Step_1867ba2ab9ce3a87b5ef41efc308f716_Out_2, _Split_2b5c9e345e2de1899433a0cc9c38ede3_A_4, _Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2);
                    float4 _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3;
                    Unity_Lerp_float4(_Lerp_5b013f099edf5785970f814b97e8df7b_Out_3, _Property_7363d38a7d68528cbcb385ca74971fdb_Out_0, (_Multiply_8c4821e1b9135d8aafcd2e0d8b155557_Out_2.xxxx), _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3);
                    float _Split_58f416024fe7fb8090af221026c86100_R_1 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[0];
                    float _Split_58f416024fe7fb8090af221026c86100_G_2 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[1];
                    float _Split_58f416024fe7fb8090af221026c86100_B_3 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[2];
                    float _Split_58f416024fe7fb8090af221026c86100_A_4 = _Lerp_0c7ea3049416da86bae08da697b4c022_Out_3[3];
                    surface.BaseColor = (_Lerp_0c7ea3049416da86bae08da697b4c022_Out_3.xyz);
                    surface.Alpha = _Split_58f416024fe7fb8090af221026c86100_A_4;
                    return surface;
                }
    
                // --------------------------------------------------
                // Build Graph Inputs
    
                VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
                {
                    VertexDescriptionInputs output;
                    ZERO_INITIALIZE(VertexDescriptionInputs, output);
                
                    output.ObjectSpaceNormal =           input.normalOS;
                    output.ObjectSpaceTangent =          input.tangentOS;
                    output.ObjectSpacePosition =         input.positionOS;
                    output.uv0 =                         input.uv0;
                    output.TimeParameters =              _TimeParameters.xyz;
                
                    return output;
                }
                
                SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
                {
                    SurfaceDescriptionInputs output;
                    ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
                
                
                
                
                
                    output.WorldSpacePosition =          input.positionWS;
                    output.ScreenPosition =              ComputeScreenPos(TransformWorldToHClip(input.positionWS), _ProjectionParams.x);
                    output.uv0 =                         input.texCoord0;
                    output.TimeParameters =              _TimeParameters.xyz; // This is mainly for LW as HD overwrite this value
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
                #else
                #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                #endif
                #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
                
                    return output;
                }
                
    
                // --------------------------------------------------
                // Main
    
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
                #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/PBR2DPass.hlsl"
    
                ENDHLSL
            }
        }
    }
