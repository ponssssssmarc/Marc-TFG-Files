from pymol import cmd

def depthcue(fog=0.7, fog_start=0.5, bg='white'):
    cmd.bg_color(bg)
    cmd.set('depth_cue', 1)
    cmd.set('fog', fog)
    cmd.set('fog_start', fog_start)
    cmd.set('ray_trace_fog', fog)
    cmd.set('ray_trace_fog_start', fog_start)
    print(f"Depth cue activat (fog={fog}, start={fog_start}, bg={bg})")

cmd.extend('depthcue', depthcue)
