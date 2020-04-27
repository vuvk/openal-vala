project('vala app', 'vala', 'c')

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('openal'),
    dependency('alure'),
]

cc = meson.get_compiler('c')
m_dep = cc.find_library('m', required : false)

vapi_dir = meson.current_source_dir() / 'vapi'
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

executable('alureplay', 'src/alureplay.vala', dependencies: dependencies)
executable('alurestream', 'src/alurestream.vala', dependencies: dependencies)
executable('alurephysfs', 'src/alurephysfs.vala', dependencies: [dependencies, dependency('physfs')])
executable('alurephysfsstream', 'src/alurephysfsstream.vala', dependencies: [dependencies, dependency('physfs')])
executable('alurestereo', 'src/alurestereo.vala', dependencies: [dependencies, dependency('physfs'), m_dep])
