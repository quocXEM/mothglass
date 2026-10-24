"""
Mothglass PRO art pass — denser geometry, EEVEE bloom, richer materials.
"""
import math
import os
import bpy

OUT = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "assets", "art")
os.makedirs(OUT, exist_ok=True)


def clear():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)
    for coll in (bpy.data.meshes, bpy.data.materials, bpy.data.lights, bpy.data.cameras, bpy.data.curves):
        for b in list(coll):
            coll.remove(b)


def mat(name, color, rough=0.4, metallic=0.0, emit=0.0, alpha=1.0, sss=0.0):
    m = bpy.data.materials.new(name)
    m.use_nodes = True
    bsdf = m.node_tree.nodes["Principled BSDF"]
    bsdf.inputs["Base Color"].default_value = (*color, 1)
    bsdf.inputs["Roughness"].default_value = rough
    bsdf.inputs["Metallic"].default_value = metallic
    if "Emission Color" in bsdf.inputs:
        bsdf.inputs["Emission Color"].default_value = (*color, 1)
    if "Emission Strength" in bsdf.inputs:
        bsdf.inputs["Emission Strength"].default_value = emit
    if "Subsurface Weight" in bsdf.inputs and sss > 0:
        bsdf.inputs["Subsurface Weight"].default_value = sss
    if alpha < 1:
        bsdf.inputs["Alpha"].default_value = alpha
        m.blend_method = "BLEND"
    return m


def setup_render(w, h, transparent=True, samples=128):
    sc = bpy.context.scene
    sc.render.engine = "BLENDER_EEVEE_NEXT"
    sc.render.resolution_x = w
    sc.render.resolution_y = h
    sc.render.film_transparent = transparent
    sc.render.image_settings.file_format = "PNG"
    sc.render.image_settings.color_mode = "RGBA"
    sc.view_settings.view_transform = "Filmic"
    sc.view_settings.look = "Medium High Contrast"
    ee = sc.eevee
    if hasattr(ee, "taa_render_samples"):
        ee.taa_render_samples = samples
    if hasattr(ee, "use_bloom"):
        ee.use_bloom = True
        ee.bloom_intensity = 0.12
        ee.bloom_radius = 4.5
    # World
    wld = bpy.data.worlds.new("W")
    sc.world = wld
    wld.use_nodes = True
    bg = wld.node_tree.nodes["Background"]
    bg.inputs[0].default_value = (0.04, 0.035, 0.04, 1)
    bg.inputs[1].default_value = 0.2


def cam(loc, look, ortho=False, scale=5.0, lens=35):
    bpy.ops.object.camera_add(location=loc)
    c = bpy.context.object
    if ortho:
        c.data.type = "ORTHO"
        c.data.ortho_scale = scale
    else:
        c.data.lens = lens
    empty = bpy.data.objects.new("T", None)
    bpy.context.collection.objects.link(empty)
    empty.location = look
    t = c.constraints.new("TRACK_TO")
    t.target = empty
    t.track_axis = "TRACK_NEGATIVE_Z"
    t.up_axis = "UP_Y"
    bpy.context.scene.camera = c
    return c


def light(kind, loc, energy, color=(1, 0.95, 0.88), size=3.0):
    d = bpy.data.lights.new("L", kind)
    d.energy = energy
    d.color = color
    if kind == "AREA":
        d.size = size
    o = bpy.data.objects.new("Lo", d)
    bpy.context.collection.objects.link(o)
    o.location = loc
    return o


def save(name):
    path = os.path.join(OUT, name)
    bpy.context.scene.render.filepath = path
    bpy.ops.render.render(write_still=True)
    print("WROTE", path)


def add_column(x, y, z, h=3.5, r=0.28, m=None):
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=r, depth=h, location=(x, y, z + h * 0.5))
    col = bpy.context.object
    if m:
        col.data.materials.append(m)
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=r * 1.35, depth=0.18, location=(x, y, z + 0.09))
    if m:
        bpy.context.object.data.materials.append(m)
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=r * 1.3, depth=0.18, location=(x, y, z + h - 0.05))
    if m:
        bpy.context.object.data.materials.append(m)


def render_background():
    clear()
    setup_render(1600, 900, False, 96)
    bpy.context.scene.world.node_tree.nodes["Background"].inputs[0].default_value = (0.72, 0.68, 0.62, 1)
    bpy.context.scene.world.node_tree.nodes["Background"].inputs[1].default_value = 0.45

    plaster = mat("Plaster", (0.82, 0.78, 0.7), rough=0.78)
    stone = mat("Stone", (0.42, 0.36, 0.3), rough=0.55)
    dark = mat("Dark", (0.18, 0.15, 0.14), rough=0.6)
    rose = mat("Rose", (0.55, 0.28, 0.3), rough=0.45, emit=0.08)
    gold = mat("Gold", (0.62, 0.48, 0.22), rough=0.3, metallic=0.7)

    # Floor with tiles feel
    bpy.ops.mesh.primitive_plane_add(size=24, location=(0, 0, 0))
    fl = bpy.context.object
    fl.data.materials.append(mat("Floor", (0.7, 0.64, 0.55), rough=0.72))

    # Back wall panels
    for i, x in enumerate([-6, -2, 2, 6]):
        bpy.ops.mesh.primitive_cube_add(size=1, location=(x, 7.2, 3.2))
        p = bpy.context.object
        p.scale = (1.7, 0.25, 3.4)
        bpy.ops.object.transform_apply(scale=True)
        p.data.materials.append(plaster if i % 2 == 0 else stone)

    # Side colonnade
    for x in (-7.5, 7.5):
        for y in (1.5, 3.5, 5.5):
            add_column(x, y, 0, h=4.2, r=0.32, m=dark)

    # Central stepped plinth
    for i, (s, z) in enumerate([(3.2, 0.15), (2.4, 0.4), (1.6, 0.65)]):
        bpy.ops.mesh.primitive_cylinder_add(vertices=32, radius=s, depth=0.28, location=(0, 2.2, z))
        bpy.context.object.data.materials.append(stone if i < 2 else dark)

    # Floating rings (dream motif)
    for i, (r, z) in enumerate([(2.8, 3.4), (2.0, 4.2), (1.3, 4.9)]):
        bpy.ops.mesh.primitive_torus_add(major_radius=r, minor_radius=0.08, location=(0, 5.0, z))
        t = bpy.context.object
        t.rotation_euler = (math.radians(90), 0, math.radians(i * 12))
        t.data.materials.append(rose if i != 1 else gold)

    # Suspended shards
    for i in range(7):
        a = i * TAU / 7
        bpy.ops.mesh.primitive_cone_add(vertices=4, radius1=0.18, depth=0.7,
                                       location=(math.cos(a) * 3.5, 4.0, 2.2 + (i % 3) * 0.4))
        sh = bpy.context.object
        sh.rotation_euler = (math.radians(20), a, math.radians(30))
        sh.data.materials.append(dark)

    # Soft fog volume-ish: large translucent planes
    mist = mat("Mist", (0.85, 0.8, 0.75), rough=1.0, alpha=0.08)
    bpy.ops.mesh.primitive_plane_add(size=18, location=(0, 3, 2.5))
    mp = bpy.context.object
    mp.rotation_euler = (math.radians(90), 0, 0)
    mp.data.materials.append(mist)

    light("AREA", (0, -6, 9), 250, (1.0, 0.95, 0.88), 10)
    light("AREA", (-6, 2, 5), 60, (0.55, 0.65, 1.0), 6)
    light("AREA", (5, 1, 3.5), 45, (1.0, 0.55, 0.4), 4)
    light("POINT", (0, 5, 4.5), 80, (1.0, 0.7, 0.75))
    cam((0, -9.5, 4.8), (0, 3, 2.8), ortho=False, lens=28)
    save("bg_room.png")


TAU = math.tau


def render_lamp():
    clear()
    setup_render(640, 800, True, 96)
    brass = mat("Brass", (0.72, 0.52, 0.22), rough=0.22, metallic=0.92)
    glass = mat("Glass", (1.0, 0.93, 0.75), rough=0.05, emit=2.5, alpha=0.7, sss=0.3)
    flame = mat("Flame", (1.0, 0.6, 0.2), rough=0.35, emit=18)
    ink = mat("Ink", (0.1, 0.08, 0.07), rough=0.55)
    cord = mat("Cord", (0.25, 0.2, 0.15), rough=0.6)

    # Ornate base
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=0.55, depth=0.12, location=(0, 0, 0.06))
    bpy.context.object.data.materials.append(ink)
    bpy.ops.mesh.primitive_cylinder_add(vertices=24, radius=0.4, depth=0.35, location=(0, 0, 0.3))
    bpy.context.object.data.materials.append(brass)
    # Fluted stem
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.16, depth=0.9, location=(0, 0, 0.9))
    stem = bpy.context.object
    stem.data.materials.append(brass)
    mod = stem.modifiers.new("Bevel", "BEVEL")
    mod.width = 0.02
    mod.segments = 2
    bpy.ops.object.modifier_apply(modifier="Bevel")
    # Globe
    bpy.ops.mesh.primitive_uv_sphere_add(segments=32, ring_count=16, radius=0.48, location=(0, 0, 1.55))
    g = bpy.context.object
    g.scale = (1, 1, 1.15)
    bpy.ops.object.transform_apply(scale=True)
    g.data.materials.append(glass)
    # Inner flame
    bpy.ops.mesh.primitive_cone_add(vertices=12, radius1=0.1, depth=0.32, location=(0, 0, 1.55))
    bpy.context.object.data.materials.append(flame)
    # Top crown
    bpy.ops.mesh.primitive_torus_add(major_radius=0.42, minor_radius=0.045, location=(0, 0, 1.95))
    bpy.context.object.data.materials.append(brass)
    bpy.ops.mesh.primitive_torus_add(major_radius=0.28, minor_radius=0.03, location=(0, 0, 2.15))
    bpy.context.object.data.materials.append(brass)
    # Handle arc
    bpy.ops.mesh.primitive_torus_add(major_radius=0.35, minor_radius=0.035, location=(0.35, 0, 1.35))
    h = bpy.context.object
    h.rotation_euler = (0, math.radians(90), 0)
    h.scale = (1, 1, 0.55)
    bpy.ops.object.transform_apply(scale=True)
    h.data.materials.append(brass)

    light("AREA", (2.5, -3, 4), 120, (1, 0.92, 0.8), 3)
    light("AREA", (-2, 2, 2), 30, (0.5, 0.6, 1), 4)
    light("POINT", (0, 0, 1.55), 40, (1, 0.7, 0.3))
    cam((3.6, -3.6, 2.6), (0, 0, 1.1), ortho=True, scale=3.4)
    save("lamp.png")


def render_pillar():
    clear()
    setup_render(320, 640, True, 64)
    stone = mat("S", (0.34, 0.3, 0.26), rough=0.48)
    trim = mat("T", (0.55, 0.45, 0.3), rough=0.35, metallic=0.4)
    bpy.ops.mesh.primitive_cylinder_add(vertices=20, radius=0.38, depth=2.6, location=(0, 0, 1.3))
    c = bpy.context.object
    c.data.materials.append(stone)
    for z, r in [(0.12, 0.55), (2.5, 0.52)]:
        bpy.ops.mesh.primitive_cylinder_add(vertices=20, radius=r, depth=0.2, location=(0, 0, z))
        bpy.context.object.data.materials.append(trim)
    # Relief rings
    for z in (0.7, 1.3, 1.9):
        bpy.ops.mesh.primitive_torus_add(major_radius=0.4, minor_radius=0.03, location=(0, 0, z))
        bpy.context.object.data.materials.append(trim)
    light("AREA", (2.5, -3, 4), 100, (1, 0.95, 0.9), 3)
    cam((4, -4, 2.2), (0, 0, 1.3), ortho=True, scale=3.2)
    save("prop_pillar.png")


def render_beam():
    clear()
    setup_render(640, 180, True, 64)
    wood = mat("W", (0.45, 0.3, 0.16), rough=0.42)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0))
    b = bpy.context.object
    b.scale = (1.9, 0.28, 0.2)
    bpy.ops.object.transform_apply(scale=True)
    b.data.materials.append(wood)
    mod = b.modifiers.new("Bevel", "BEVEL")
    mod.width = 0.03
    mod.segments = 3
    bpy.ops.object.modifier_apply(modifier="Bevel")
    light("AREA", (2, -3, 3), 80, (1, 0.95, 0.88), 3)
    cam((0, -4, 2.2), (0, 0, 0), ortho=True, scale=4.2)
    save("prop_beam.png")


def render_block():
    clear()
    setup_render(320, 320, True, 64)
    stone = mat("S", (0.36, 0.32, 0.28), rough=0.5)
    bpy.ops.mesh.primitive_cube_add(size=1.3, location=(0, 0, 0.65))
    c = bpy.context.object
    c.data.materials.append(stone)
    mod = c.modifiers.new("Bevel", "BEVEL")
    mod.width = 0.08
    mod.segments = 4
    bpy.ops.object.modifier_apply(modifier="Bevel")
    light("AREA", (2.5, -3, 3.5), 90, (1, 0.95, 0.9), 3)
    cam((3.4, -3.4, 2.5), (0, 0, 0.65), ortho=True, scale=2.6)
    save("prop_block.png")


def render_wedge():
    clear()
    setup_render(360, 360, True, 64)
    clay = mat("C", (0.3, 0.26, 0.22), rough=0.45)
    bpy.ops.mesh.primitive_cone_add(vertices=3, radius1=1.0, depth=1.5, location=(0, 0, 0.55))
    w = bpy.context.object
    w.rotation_euler = (math.radians(90), 0, math.radians(180))
    bpy.ops.object.transform_apply(rotation=True)
    w.data.materials.append(clay)
    light("AREA", (2, -3, 3), 85, (1, 0.95, 0.9), 3)
    cam((3.6, -3.6, 2.2), (0, 0, 0.4), ortho=True, scale=2.8)
    save("prop_wedge.png")


def render_wing(side):
    clear()
    setup_render(420, 320, True, 64)
    silk = mat("Silk", (0.2, 0.18, 0.24), rough=0.28, sss=0.2)
    bpy.ops.mesh.primitive_uv_sphere_add(segments=24, ring_count=12, radius=0.75, location=(0, 0, 0.45))
    w = bpy.context.object
    sx = -1.45 if side == "L" else 1.45
    w.scale = (sx, 0.22, 0.95)
    bpy.ops.object.transform_apply(scale=True)
    w.data.materials.append(silk)
    # Vein
    bpy.ops.mesh.primitive_cylinder_add(radius=0.03, depth=1.2, location=(sx * 0.15, 0, 0.45))
    v = bpy.context.object
    v.rotation_euler = (0, math.radians(55 if side == "L" else -55), 0)
    v.data.materials.append(mat("Vein", (0.45, 0.35, 0.25), rough=0.4, metallic=0.3))
    light("AREA", (2, -3, 3), 70, (0.95, 0.9, 1), 3)
    cam((0, -4.2, 2.0), (0, 0, 0.4), ortho=True, scale=3.0)
    save("prop_wing_l.png" if side == "L" else "prop_wing_r.png")


def render_plaque():
    clear()
    setup_render(720, 220, True, 48)
    paper = mat("P", (0.94, 0.9, 0.84), rough=0.65)
    edge = mat("E", (0.32, 0.25, 0.18), rough=0.4, metallic=0.2)
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0, 0))
    card = bpy.context.object
    card.scale = (2.6, 0.06, 0.72)
    bpy.ops.object.transform_apply(scale=True)
    card.data.materials.append(paper)
    mod = card.modifiers.new("Bevel", "BEVEL")
    mod.width = 0.04
    mod.segments = 3
    bpy.ops.object.modifier_apply(modifier="Bevel")
    bpy.ops.mesh.primitive_cube_add(size=1, location=(0, 0.05, 0))
    fr = bpy.context.object
    fr.scale = (2.72, 0.03, 0.82)
    bpy.ops.object.transform_apply(scale=True)
    fr.data.materials.append(edge)
    light("AREA", (1, -3, 3), 70, (1, 0.95, 0.9), 3)
    cam((0, -4, 1.4), (0, 0, 0), ortho=True, scale=5.6)
    save("ui_plaque.png")


def main():
    print("=== PRO art pass ===")
    render_background()
    render_lamp()
    render_pillar()
    render_beam()
    render_block()
    render_wedge()
    render_wing("L")
    render_wing("R")
    render_plaque()
    print("DONE")


if __name__ == "__main__":
    main()
