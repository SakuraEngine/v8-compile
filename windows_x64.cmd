set V8_VERSION=%1

cd %HOMEPATH%

echo =====[ Getting Depot Tools ]=====
call git clone https://chromium.googlesource.com/chromium/tools/depot_tools
set PATH=%CD%\depot_tools;%PATH%
set GYP_MSVS_VERSION=2019
set DEPOT_TOOLS_WIN_TOOLCHAIN=0
call gclient

echo =====[ Fetching V8 ]=====
mkdir v8
cd v8
call fetch v8
cd v8
call git checkout %V8_VERSION%
call git pull
call git clean -fdx
cd test\test262\data
call git config --system core.longpaths true
call git restore *
cd ..\..\..\
call gclient sync -D


echo =====[ Building V8 ]=====
call gn gen out.gn\x64.release --args="target_os=""win"" target_cpu=""x64"" dcheck_always_on=false treat_warnings_as_errors=false v8_use_external_startup_data=false is_official_build=true v8_enable_test_features=false v8_monolithic=false v8_enable_i18n_support=false is_debug=false is_clang=false strip_debug_info=true v8_symbol_level=0 v8_enable_pointer_compression=false is_component_build=true v8_static_library=false"

call ninja -C out.gn\x64.release -t clean
call ninja -C out.gn\x64.release v8

echo =====[ Copying Product ]=====
set DLL_OUTPUT_DIR=output\windows-x64-release\bin
set LIB_OUTPUT_DIR=output\windows-x64-release\lib
md %DLL_OUTPUT_DIR%
md %LIB_OUTPUT_DIR%
copy /Y out.gn\x64.release\v8.dll %DLL_OUTPUT_DIR%
copy /Y out.gn\x64.release\v8_libbase.dll %DLL_OUTPUT_DIR%
copy /Y out.gn\x64.release\v8_libplatform.dll %DLL_OUTPUT_DIR%
copy /Y out.gn\x64.release\zlib.dll %DLL_OUTPUT_DIR%

copy /Y out.gn\x64.release\v8.dll.lib %LIB_OUTPUT_DIR%
copy /Y out.gn\x64.release\v8_libplatform.dll.lib %LIB_OUTPUT_DIR%

copy /Y out.gn\x64.release\v8.dll.pdb %DLL_OUTPUT_DIR%
copy /Y out.gn\x64.release\v8_libbase.dll.pdb %DLL_OUTPUT_DIR%
copy /Y out.gn\x64.release\v8_libplatform.dll.pdb %DLL_OUTPUT_DIR%
copy /Y out.gn\x64.release\zlib.dll.pdb %DLL_OUTPUT_DIR%