#pragma once

#define GEN_SCL 1
#define BLOCK_OFFSET float3(300, 0, 110)

#define GROUND_LEVEL 0
#define WATER_LEVEL (184 - GROUND_LEVEL)
#define MIN_WATER_LEVEL (WATER_LEVEL + 10)
#define LAVA_LEVEL (348 - GROUND_LEVEL)

#define VISUALIZE_BIOMES 0
#define DO_DETAILED_GEN 1
#define INJECT_STRUCTURES 1