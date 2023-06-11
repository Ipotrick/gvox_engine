#pragma once

#define DAXA_ENABLE_SHADER_NO_NAMESPACE 1
#define DAXA_ENABLE_IMAGE_OVERLOADS_BASIC 1
#include <daxa/daxa.inl>
#undef DAXA_ENABLE_SHADER_NO_NAMESPACE
#undef DAXA_ENABLE_IMAGE_OVERLOADS_BASIC

#include <daxa/utils/task_list.inl>

#define CHUNK_SIZE 64

#define PALETTE_REGION_SIZE 8
#define PALETTE_REGION_TOTAL_SIZE (PALETTE_REGION_SIZE * PALETTE_REGION_SIZE * PALETTE_REGION_SIZE)
#define PALETTE_MAX_COMPRESSED_VARIANT_N 367

#if PALETTE_REGION_SIZE != 8
#error Unsupported Palette Region Size
#endif

#define PALETTES_PER_CHUNK_AXIS (CHUNK_SIZE / PALETTE_REGION_SIZE)
#define PALETTES_PER_CHUNK (PALETTES_PER_CHUNK_AXIS * PALETTES_PER_CHUNK_AXIS * PALETTES_PER_CHUNK_AXIS)

#define MAX_CHUNK_UPDATES_PER_FRAME 32

#define MAX_CHUNK_WORK_ITEMS_L0 ((1 << (3)) + 0)
#define MAX_CHUNK_WORK_ITEMS_L1 ((1 << (3 + 9)) + 0)
#define MAX_CHUNK_WORK_ITEMS_L2 MAX_CHUNK_UPDATES_PER_FRAME

#define L2_CHUNK_SIZE CHUNK_SIZE
#define L1_CHUNK_SIZE (L2_CHUNK_SIZE * 8)
#define L0_CHUNK_SIZE (L1_CHUNK_SIZE * 8)

#define CHUNK_FLAGS_ACCEL_GENERATED (1 << 0)
#define CHUNK_FLAGS_WORLD_BRUSH     (1 << 1)
#define CHUNK_FLAGS_USER_BRUSH_A    (1 << 2)
#define CHUNK_FLAGS_USER_BRUSH_B    (1 << 3)
#define CHUNK_FLAGS_BRUSH_MASK      (CHUNK_FLAGS_WORLD_BRUSH | CHUNK_FLAGS_USER_BRUSH_A | CHUNK_FLAGS_USER_BRUSH_B)

#if defined(__cplusplus)
#include <memory>
#include <daxa/utils/pipeline_manager.hpp>
#endif
