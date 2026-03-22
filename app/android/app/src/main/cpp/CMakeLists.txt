cmake_minimum_required(VERSION 3.18)
project(tun2socks_jni)

add_library(tun2socks_jni SHARED tun2socks_jni.c)
target_link_libraries(tun2socks_jni log dl)
