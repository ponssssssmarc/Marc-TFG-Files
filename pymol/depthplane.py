from pymol import cmd

def depthplane(dist_front=10.0, dist_back=50.0, fog=0.7, fog_start=0.5, bg='white'):
    """
    Simula un depth plane a PyMOL amb plans de clipping i boira.
    - dist_front: distància del pla frontal (clip_front)
    - dist_back: distància del pla posterior (clip_back)
    - fog: densitat de la boira
    - fog_start: inici de la boira
    - bg: color fons ("white" o "black")
    """
    rgb = [0,0,0] if bg=='black' else [1,1,1]
    cmd.set('bg_rgb', rgb)

    # boira / depth cue
    cmd.set('depth_cue',1)
    cmd.set('fog', fog)
    cmd.set('fog_start', fog_start)
    cmd.set('ray_trace_fog', fog)
    cmd.set('ray_trace_fog_start', fog_start)

    # plans de clipping
    cmd.set('clip_front', dist_front)
    cmd.set('clip_back', dist_back)

    print(f"Depth plane aplicat: clip_front={dist_front}, clip_back={dist_back}, fog={fog}, start={fog_start}, bg={bg}")

cmd.extend('depthplane', depthplane)
