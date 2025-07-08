struct VS_INPUT {
    float2 pos : POSITION;
    float2 uv  : TEXCOORD0;
};
struct VS_OUTPUT {
    float4 pos : SV_POSITION;
    float2 uv  : TEXCOORD0;
};

VS_OUTPUT vs_main(VS_INPUT input) {
    VS_OUTPUT output;
    output.pos = float4(input.pos, 0.0, 1.0);
    output.uv = input.uv;
    return output;
}

Texture2D fontTex : register(t0);
SamplerState fontSampler : register(s0);

float4 ps_main(VS_OUTPUT input) : SV_TARGET {
    float4 color = fontTex.Sample(fontSampler, input.uv);
    if (dot(color.rgb, float3(1.0, 1.0, 1.0)) <= 0.1) {
        discard;
        return float4(0.4, 0.6, 0.2, 1.0);
    }
    return color;
}