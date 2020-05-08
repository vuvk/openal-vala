#!/bin/sh
mkdir build
cd build
valac ../src/alureplay.vala --vapidir=../vapi --pkg=openal --pkg=alure --pkg=glib-2.0 --pkg=gobject-2.0
valac ../src/alurestream.vala --vapidir=../vapi --pkg=openal --pkg=alure --pkg=glib-2.0 --pkg=gobject-2.0
valac ../src/alurephysfs.vala --vapidir=../vapi --pkg=openal --pkg=alure --pkg=glib-2.0 --pkg=gobject-2.0 --pkg=physfs
valac ../src/alurephysfsstream.vala --vapidir=../vapi --pkg=openal --pkg=alure --pkg=glib-2.0 --pkg=gobject-2.0 --pkg=physfs
valac ../src/alurestereo.vala --vapidir=../vapi --pkg=openal --pkg=alure --pkg=glib-2.0 --pkg=gobject-2.0 --pkg=physfs -X -lm

valac ../src/alplay.vala --vapidir=../vapi --pkg=openal --pkg=sndfile --pkg=glib-2.0 --pkg=gobject-2.0
valac ../src/alstream.vala --vapidir=../vapi --pkg=openal --pkg=sndfile --pkg=glib-2.0 --pkg=gobject-2.0
