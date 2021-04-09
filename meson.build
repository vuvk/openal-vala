project('vala app', 'vala', 'c')

al_dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('openal'),
    dependency('sndfile'),
]

alure_dependencies = [
    al_dependencies,
    dependency('alure'),
    dependency('physfs')
]

cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required : false)

vapi_dir = meson.current_source_dir() / 'vapi'
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

executable('alureplay',         'src/alureplay.vala',         dependencies: alure_dependencies)
executable('alurestream',       'src/alurestream.vala',       dependencies: alure_dependencies)
executable('alurephysfs',       'src/alurephysfs.vala',       dependencies: alure_dependencies)
executable('alurephysfsstream', 'src/alurephysfsstream.vala', dependencies: alure_dependencies)
executable('alurestereo',       'src/alurestereo.vala',       dependencies: [alure_dependencies, m_dep])

executable('alplay',   'src/alplay.vala',   dependencies: al_dependencies)
executable('alstream', 'src/alstream.vala', dependencies: al_dependencies)
