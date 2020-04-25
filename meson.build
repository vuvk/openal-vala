project('vala app', 'vala', 'c')

dependencies = [
    dependency('glib-2.0'),
    dependency('gobject-2.0'),
    dependency('openal'),
    dependency('alure'),
]

vapi_dir = meson.current_source_dir() / 'vapi'
add_project_arguments(['--vapidir', vapi_dir], language: 'vala')

executable('alureplay', 'src/alureplay.vala', dependencies: dependencies)
executable('alurestream', 'src/alurestream.vala', dependencies: dependencies)
executable('alurephysfs', 'src/alurephysfs.vala', dependencies: [dependencies, dependency('physfs')])
executable('alurephysfsstream', 'src/alurephysfsstream.vala', dependencies: [dependencies, dependency('physfs')])
