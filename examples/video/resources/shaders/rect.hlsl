struct VS_INPUT {
    float2 pos : POSITION;
};
struct VS_OUTPUT {
    float4 pos : SV_POSITION;
};

VS_OUTPUT vs_main(VS_INPUT input) {
    VS_OUTPUT output;
    output.pos = float4(input.pos, 0.0, 1.0);
    return output;
}

float4 ps_main(VS_OUTPUT input) : SV_TARGET {
    return float4(0.4, 0.6, 0.2, 1.0);
}