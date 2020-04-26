#!/bin/sh
mkdir build
cd build
valac ../src/alureplay.vala --vapidir=../vapi --pkg=openal --pkg=alure --pkg=glib-2.0 --pkg=gobject-2.0
valac ../src/alurestream.vala --vapidir=../vapi --pkg=openal --pkg=alure --pkg=glib-2.0 --pkg=gobject-2.0
valac ../src/alurephysfs.vala --vapidir=../vapi --pkg=openal --pkg=alure --pkg=glib-2.0 --pkg=gobject-2.0 --pkg=physfs
valac ../src/alurephysfsstream.vala --vapidir=../vapi --pkg=openal --pkg=alure --pkg=glib-2.0 --pkg=gobject-2.0 --pkg=physfs
