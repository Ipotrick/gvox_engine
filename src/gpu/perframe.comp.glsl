
#include <utils/player.glsl>
#include <utils/voxel_world.glsl>
#include <utils/voxel_malloc.glsl>
#include <utils/trace.glsl>

#define SETTINGS deref(settings)
#define INPUT deref(gpu_input)
#define BRUSH_STATE deref(globals).brush_state
#define THREAD_POOL deref(globals).chunk_thread_pool_state
layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;
void main() {
    player_perframe(settings, gpu_input, globals);
    voxel_world_perframe(settings, gpu_input, globals);

    {
        f32vec2 frame_dim = INPUT.frame_dim;
        f32vec2 inv_frame_dim = f32vec2(1.0) / frame_dim;
        f32 aspect = frame_dim.x * inv_frame_dim.y;
        f32vec2 uv = (deref(gpu_input).mouse.pos * inv_frame_dim - 0.5) * f32vec2(2 * aspect, 2);
        f32vec3 ray_pos = create_view_pos(deref(globals).player);
        f32vec3 cam_pos = ray_pos;
        f32vec3 ray_dir = create_view_dir(deref(globals).player, uv);
        u32vec3 chunk_n = u32vec3(1u << SETTINGS.log2_chunks_per_axis);
        trace(voxel_malloc_global_allocator, voxel_chunks, chunk_n, ray_pos, ray_dir);

        if (BRUSH_STATE.is_editing == 0) {
            BRUSH_STATE.initial_ray = ray_pos - cam_pos;
        }

        BRUSH_STATE.prev_pos = BRUSH_STATE.pos;
        BRUSH_STATE.pos = length(BRUSH_STATE.initial_ray) * ray_dir + cam_pos;

        if (INPUT.actions[GAME_ACTION_BRUSH_A] != 0) {
            // if (BRUSH_STATE.is_editing == 0)
            {
                ChunkWorkItem brush_work_item;
                brush_work_item.i = u32vec3(0);
                brush_work_item.brush_id = CHUNK_STAGE_USER_BRUSH_A;
                zero_work_item_children(brush_work_item);
                queue_root_work_item(globals, brush_work_item);
            }
            BRUSH_STATE.is_editing = 1;
        } else if (INPUT.actions[GAME_ACTION_BRUSH_B] != 0) {
            // if (BRUSH_STATE.is_editing == 0)
            {
                ChunkWorkItem brush_work_item;
                brush_work_item.i = u32vec3(0);
                brush_work_item.brush_id = CHUNK_STAGE_USER_BRUSH_B;
                zero_work_item_children(brush_work_item);
                queue_root_work_item(globals, brush_work_item);
            }
            BRUSH_STATE.is_editing = 1;
        } else {
            BRUSH_STATE.is_editing = 0;
        }
    }

    deref(gpu_output[INPUT.fif_index]).player_pos = deref(globals).player.pos;

#if USE_OLD_ALLOC
    deref(gpu_output[INPUT.fif_index]).heap_size = deref(voxel_malloc_global_allocator).offset;
#else
    deref(gpu_output[INPUT.fif_index]).heap_size =
        (deref(voxel_malloc_global_allocator).page_count -
         deref(voxel_malloc_global_allocator).available_pages_stack_size) *
        VOXEL_MALLOC_PAGE_SIZE_U32S;

    // Debug - reset the allocator
    // deref(voxel_malloc_global_allocator).page_count = 0;
    // deref(voxel_malloc_global_allocator).available_pages_stack_size = 0;
    // deref(voxel_malloc_global_allocator).released_pages_stack_size = 0;
#endif

    THREAD_POOL.queue_index = 1 - THREAD_POOL.queue_index;

    THREAD_POOL.total_jobs_ran = THREAD_POOL.work_items_l0_uncompleted + THREAD_POOL.work_items_l1_uncompleted;

    deref(gpu_output[INPUT.fif_index]).job_counters_packed = 0;
    deref(gpu_output[INPUT.fif_index]).total_jobs_ran = THREAD_POOL.total_jobs_ran;

    // clang-format off
    THREAD_POOL.work_items_l0_queued      = THREAD_POOL.work_items_l0_uncompleted;
    THREAD_POOL.work_items_l0_completed   = 0;
    THREAD_POOL.work_items_l0_uncompleted = 0;

    THREAD_POOL.work_items_l1_queued      = THREAD_POOL.work_items_l1_uncompleted;
    THREAD_POOL.work_items_l1_completed   = 0;
    THREAD_POOL.work_items_l1_uncompleted = 0;
    // clang-format on

    voxel_malloc_perframe(
        gpu_input,
        voxel_malloc_global_allocator);
}
#undef INPUT
#undef SETTINGS
