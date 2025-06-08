__kernel void vector_scale(__global const float* input, __global float* output, float scale) {
	int id = get_global_id(0);
	output[id] = input[id] * scale;
}