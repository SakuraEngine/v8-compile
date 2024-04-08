@echo off

echo =====[ Setup build env]=====
set V8_BUILD_ROOT=%CD%
set V8_VERSION=11.2-lkgr
set V8_BUILD_ARCH=x64
set V8_BUILD_TOOLCHAIN=clang-cl

echo =====[ Setup build config ]=====
set V8_ENV_HAS_DEPOT_TOOLS=1
set V8_CACHED_REPO=1
@REM set V8_NO_COMPILE=1

call ./build_win.cmd