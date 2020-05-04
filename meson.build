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
]

cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required : false)

vapi_dir = meson.current_source_dir() / 'vapi'
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

executable('alureplay', 'src/alureplay.vala', dependencies: alure_dependencies)
executable('alurestream', 'src/alurestream.vala', dependencies: alure_dependencies)
executable('alurephysfs', 'src/alurephysfs.vala', dependencies: [alure_dependencies, dependency('physfs')])
executable('alurephysfsstream', 'src/alurephysfsstream.vala', dependencies: [alure_dependencies, dependency('physfs')])
executable('alurestereo', 'src/alurestereo.vala', dependencies: [alure_dependencies, dependency('physfs'), m_dep])

executable('openalplay', 'src/openalplay.vala', dependencies: al_dependencies)
