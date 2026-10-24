"""
Blender batch render — Mothglass art pack (stylized dream still-life).
Run: Blender --background --python tools/blender_render_mothglass.py
"""
import math
import os
import bpy

OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "art")
os.makedirs(OUT, exist_ok=True)


def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for block in list(bpy.data.meshes):
        bpy.data.meshes.remove(block)
    for block in list(bpy.data.materials):
        bpy.data.materials.remove(block)
    for block in list(bpy.data.lights):
        bpy.data.lights.remove(block)
    for block in list(bpy.data.cameras):
        bpy.data.cameras.remove(block)


def mat(name, color, rough=0.45, metallic=0.0, emit=0.0, alpha=1.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    nt = m.node_tree
    bsdf = nt.nodes.get("Principled BSDF")
    bsdf.inputs["Base Color"].default_value = (*color, 1.0)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metallic
    if "Emission Color" in bsdf.inputs:
        bsdf.inputs["Emission Color"].default_value = (*color, 1.0)
    if "Emission Strength" in bsdf.inputs:
        bsdf.inputs["Emission Strength"].default_value = emit
    if alpha < 1.0:
        bsdf.inputs["Alpha"].default_value = alpha
        m.blend_method = "BLEND"
    return m


def setup_world(cream=(0.92, 0.88, 0.82)):
    world = bpy.data.worlds.new("World")
    bpy.context.scene.world = world
    world.use_nodes = True
    bg = world.node_tree.nodes["Background"]
    bg.inputs[0].default_value = (*cream, 1.0)
    bg.inputs[1].default_value = 0.35


def setup_render(w, h, transparent=True):
    sc = bpy.context.scene
    sc.render.engine = "BLENDER_EEVEE_NEXT"
    sc.render.resolution_x = w
    sc.render.resolution_y = h
    sc.render.resolution_percentage = 100
    sc.render.film_transparent = transparent
    sc.render.image_settings.file_format = "PNG"
    sc.render.image_settings.color_mode = "RGBA"
    sc.render.image_settings.compression = 15
    # Soft look
    ee = sc.eevee
    if hasattr(ee, "use_soft_shadows"):
        ee.use_soft_shadows = True
    if hasattr(ee, "taa_render_samples"):
        ee.taa_render_samples = 64


def add_cam(loc, look_at=(0, 0, 0), ortho=True, ortho_scale=4.0):
    bpy.ops.object.camera_add(location=loc)
    cam = bpy.context.object
    cam.data.type = "ORTHO" if ortho else "PERSP"
    if ortho:
        cam.data.ortho_scale = ortho_scale
    else:
        cam.data.lens = 50
    # Point at target
    direction = (look_at[0] - loc[0], look_at[1] - loc[1], look_at[2] - loc[2])
    # Use track_to constraint
    t = cam.constraints.new(type="TRACK_TO")
    empty = bpy.data.objects.new("LookAt", None)
    bpy.context.collection.objects.link(empty)
    empty.location = look_at
    t.target = empty
    t.track_axis = "TRACK_NEGATIVE_Z"
    t.up_axis = "UP_Y"
    bpy.context.scene.camera = cam
    return cam


def add_light(kind, loc, energy, color=(1, 0.95, 0.85), size=2.0):
    light_data = bpy.data.lights.new(name="L", type=kind)
    light_data.energy = energy
    light_data.color = color
    if kind == "AREA":
        light_data.size = size
    obj = bpy.data.objects.new("LObj", light_data)
    bpy.context.collection.objects.link(obj)
    obj.location = loc
    return obj


def render_to(path):
    bpy.context.scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    print("WROTE", path)


def make_lamp():
    clear_scene()
    setup_world((0.05, 0.05, 0.06))
    setup_render(512, 640, True)
    brass = mat("Brass", (0.55, 0.4, 0.18), rough=0.28, metallic=0.85)
    glass = mat("Glass", (1.0, 0.92, 0.7), rough=0.08, metallic=0.0, emit=1.8, alpha=0.75)
    flame = mat("Flame", (1.0, 0.55, 0.12), rough=0.4, emit=12.0)
    ink = mat("Ink", (0.12, 0.1, 0.09), rough=0.6)

    bpy.ops.mesh.primitive_cylinder_add(radius=0.35, depth=0.55, location=(0, 0, 0.15))
    base = bpy.context.object
    base.data.materials.append(brass)

    bpy.ops.mesh.primitive_cylinder_add(radius=0.22, depth=0.7, location=(0, 0, 0.7))
    stem = bpy.context.object
    stem.data.materials.append(brass)

    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.42, location=(0, 0, 1.25))
    bulb = bpy.context.object
    bulb.scale = (1.0, 1.0, 1.15)
    bpy.ops.object.transform_apply(scale=True)
    bulb.data.materials.append(glass)

    bpy.ops.mesh.primitive_cone_add(radius1=0.12, depth=0.35, location=(0, 0, 1.35))
    fl = bpy.context.object
    fl.data.materials.append(flame)

    bpy.ops.mesh.primitive_torus_add(major_radius=0.38, minor_radius=0.05, location=(0, 0, 1.55))
    ring = bpy.context.object
    ring.data.materials.append(brass)

    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, -0.2))
    plate = bpy.context.object
    plate.scale = (0.55, 0.55, 0.08)
    bpy.ops.object.transform_apply(scale=True)
    plate.data.materials.append(ink)

    add_light("AREA", (1.5, -2.0, 3.0), 80, (1, 0.9, 0.75), 3.0)
    add_light("AREA", (-2.0, 1.5, 2.0), 25, (0.6, 0.7, 1.0), 4.0)
    add_cam((3.2, -3.2, 2.4), look_at=(0, 0, 0.7), ortho=True, ortho_scale=3.2)
    render_to(os.path.join(OUT, "lamp.png"))


def make_prop_pillar():
    clear_scene()
    setup_world((0.05, 0.05, 0.06))
    setup_render(256, 512, True)
    stone = mat("Stone", (0.28, 0.24, 0.2), rough=0.55)
    edge = mat("Edge", (0.45, 0.38, 0.3), rough=0.4)
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.35, depth=2.4, location=(0, 0, 1.2))
    col = bpy.context.object
    col.data.materials.append(stone)
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.48, depth=0.18, location=(0, 0, 0.1))
    bpy.context.object.data.materials.append(edge)
    bpy.ops.mesh.primitive_cylinder_add(vertices=12, radius=0.45, depth=0.18, location=(0, 0, 2.3))
    bpy.context.object.data.materials.append(edge)
    add_light("AREA", (2, -3, 4), 90, (1, 0.95, 0.9), 4)
    add_cam((4, -4, 2.0), look_at=(0, 0, 1.2), ortho=True, ortho_scale=3.0)
    render_to(os.path.join(OUT, "prop_pillar.png"))


def make_prop_beam():
    clear_scene()
    setup_world((0.05, 0.05, 0.06))
    setup_render(512, 160, True)
    wood = mat("Wood", (0.38, 0.26, 0.14), rough=0.5)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0))
    b = bpy.context.object
    b.scale = (1.6, 0.22, 0.18)
    bpy.ops.object.transform_apply(scale=True)
    b.data.materials.append(wood)
    add_light("AREA", (2, -3, 3), 70, (1, 0.95, 0.88), 3)
    add_cam((0, -4, 2.5), look_at=(0, 0, 0), ortho=True, ortho_scale=3.6)
    render_to(os.path.join(OUT, "prop_beam.png"))


def make_prop_wedge():
    clear_scene()
    setup_world((0.05, 0.05, 0.06))
    setup_render(320, 320, True)
    clay = mat("Clay", (0.32, 0.28, 0.24), rough=0.48)
    bpy.ops.mesh.primitive_cone_add(vertices=3, radius1=0.9, depth=1.4, location=(0, 0, 0.5))
    w = bpy.context.object
    w.rotation_euler = (math.radians(90), 0, math.radians(180))
    bpy.ops.object.transform_apply(rotation=True)
    w.data.materials.append(clay)
    add_light("AREA", (2, -3, 3), 80, (1, 0.95, 0.9), 3)
    add_cam((3.5, -3.5, 2.2), look_at=(0, 0, 0.4), ortho=True, ortho_scale=2.6)
    render_to(os.path.join(OUT, "prop_wedge.png"))


def make_prop_block():
    clear_scene()
    setup_world((0.05, 0.05, 0.06))
    setup_render(256, 256, True)
    stone = mat("Stone", (0.3, 0.27, 0.23), rough=0.5)
    bpy.ops.mesh.primitive_cube_add(size=1.2, location=(0, 0, 0.6))
    cube = bpy.context.object
    cube.data.materials.append(stone)
    # Soft bevel via modifier
    mod = cube.modifiers.new("Bevel", "BEVEL")
    mod.width = 0.06
    mod.segments = 3
    bpy.ops.object.modifier_apply(modifier="Bevel")
    add_light("AREA", (2, -3, 3), 75, (1, 0.95, 0.9), 3)
    add_cam((3.2, -3.2, 2.4), look_at=(0, 0, 0.6), ortho=True, ortho_scale=2.4)
    render_to(os.path.join(OUT, "prop_block.png"))


def make_prop_wing(side="L"):
    clear_scene()
    setup_world((0.05, 0.05, 0.06))
    setup_render(360, 280, True)
    silk = mat("Silk", (0.22, 0.2, 0.24), rough=0.35)
    # Simple wing from scaled sphere + deform via scale
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.7, location=(0, 0, 0.4))
    w = bpy.context.object
    sx = -1.3 if side == "L" else 1.3
    w.scale = (sx, 0.25, 0.85)
    bpy.ops.object.transform_apply(scale=True)
    w.data.materials.append(silk)
    add_light("AREA", (2, -3, 3), 70, (0.95, 0.9, 1.0), 3)
    add_cam((0, -4, 2.0), look_at=(0, 0, 0.35), ortho=True, ortho_scale=2.8)
    name = "prop_wing_l.png" if side == "L" else "prop_wing_r.png"
    render_to(os.path.join(OUT, name))


def make_background():
    clear_scene()
    setup_world((0.86, 0.82, 0.74))
    setup_render(1280, 720, False)
    paper = mat("Paper", (0.9, 0.86, 0.78), rough=0.85)
    floor_m = mat("Floor", (0.78, 0.72, 0.62), rough=0.7)
    ink = mat("InkWall", (0.55, 0.48, 0.4), rough=0.65)
    accent = mat("Accent", (0.45, 0.22, 0.24), rough=0.5, emit=0.15)

    # Floor
    bpy.ops.mesh.primitive_plane_add(size=20, location=(0, 0, 0))
    fl = bpy.context.object
    fl.data.materials.append(floor_m)
    # Back wall
    bpy.ops.mesh.primitive_plane_add(size=20, location=(0, 6, 4))
    wall = bpy.context.object
    wall.rotation_euler = (math.radians(90), 0, 0)
    wall.data.materials.append(paper)
    # Side panels
    bpy.ops.mesh.primitive_cube_add(size=1, location=(-6.5, 2, 2.5))
    left = bpy.context.object
    left.scale = (0.3, 5, 4)
    bpy.ops.object.transform_apply(scale=True)
    left.data.materials.append(ink)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(6.5, 2, 2.5))
    right = bpy.context.object
    right.scale = (0.3, 5, 4)
    bpy.ops.object.transform_apply(scale=True)
    right.data.materials.append(ink)
    # Distant arch silhouette
    bpy.ops.mesh.primitive_torus_add(major_radius=2.2, minor_radius=0.25, location=(0, 5.5, 2.8))
    arch = bpy.context.object
    arch.rotation_euler = (math.radians(90), 0, 0)
    arch.data.materials.append(accent)
    # Pedestal
    bpy.ops.mesh.primitive_cylinder_add(radius=1.2, depth=0.35, location=(0, 1.5, 0.15))
    bpy.context.object.data.materials.append(ink)

    add_light("AREA", (0, -4, 8), 120, (1, 0.96, 0.9), 8)
    add_light("AREA", (-5, 2, 5), 40, (0.7, 0.75, 1.0), 5)
    add_light("AREA", (4, 1, 3), 25, (1.0, 0.7, 0.55), 3)
    add_cam((0, -8.5, 4.2), look_at=(0, 2, 2.2), ortho=False)
    bpy.context.scene.camera.data.lens = 32
    bpy.context.scene.world.node_tree.nodes["Background"].inputs[1].default_value = 0.55
    render_to(os.path.join(OUT, "bg_room.png"))


def make_vignette():
    # Simple procedural via compositor would be heavy; use a soft plane render
    clear_scene()
    setup_world((0, 0, 0))
    setup_render(1280, 720, True)
    # Transparent center, dark edges — approximate with large torus? Skip: write via pixels later
    # Render dark frame rings
    m = mat("V", (0.05, 0.04, 0.04), rough=1.0, alpha=0.55)
    bpy.ops.mesh.primitive_plane_add(size=12, location=(0, 0, 0))
    p = bpy.context.object
    p.data.materials.append(m)
    # Punch hole by not using — instead soft dark material full plane with low alpha
    add_cam((0, 0, 5), look_at=(0, 0, 0), ortho=True, ortho_scale=10)
    render_to(os.path.join(OUT, "vignette_raw.png"))


def make_ui_plaque():
    clear_scene()
    setup_world((0.05, 0.05, 0.06))
    setup_render(640, 200, True)
    paper = mat("Paper", (0.93, 0.9, 0.84), rough=0.7)
    edge = mat("Edge", (0.35, 0.28, 0.22), rough=0.45)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0))
    card = bpy.context.object
    card.scale = (2.4, 0.05, 0.7)
    bpy.ops.object.transform_apply(scale=True)
    card.data.materials.append(paper)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, -0.04, 0))
    frame = bpy.context.object
    frame.scale = (2.5, 0.03, 0.78)
    bpy.ops.object.transform_apply(scale=True)
    frame.data.materials.append(edge)
    add_light("AREA", (1, -3, 3), 60, (1, 0.95, 0.9), 3)
    add_cam((0, -4, 1.5), look_at=(0, 0, 0), ortho=True, ortho_scale=5.2)
    render_to(os.path.join(OUT, "ui_plaque.png"))


def main():
    print("=== Mothglass Blender art render ===")
    # Resume remaining if early assets already exist
    need = {
        "bg_room.png": make_background,
        "lamp.png": make_lamp,
        "prop_pillar.png": make_prop_pillar,
        "prop_beam.png": make_prop_beam,
        "prop_wedge.png": make_prop_wedge,
        "prop_block.png": make_prop_block,
        "prop_wing_l.png": lambda: make_prop_wing("L"),
        "prop_wing_r.png": lambda: make_prop_wing("R"),
        "ui_plaque.png": make_ui_plaque,
    }
    for name, fn in need.items():
        path = os.path.join(OUT, name)
        if os.path.isfile(path) and os.path.getsize(path) > 1000:
            print("SKIP", name)
            continue
        fn()
    print("DONE ->", OUT)


if __name__ == "__main__":
    main()
