if not defined V8_BUILD_ROOT (
    set V8_BUILD_ROOT=%GITHUB_WORKSPACE%
)

echo =====[ Environment ]=====
echo ----- V8_BUILD_ROOT: %V8_BUILD_ROOT%
echo ----- V8_VERSION: %V8_VERSION%
echo ----- V8_BUILD_ARCH: %V8_BUILD_ARCH%
echo ----- V8_BUILD_TOOLCHAIN: %V8_BUILD_TOOLCHAIN%
if defined V8_ENV_HAS_DEPOT_TOOLS (
    echo ----- NOTE: using enviroment depot tools
)
if defined V8_CACHED_REPO (
    echo ----- NOTE: will use cached v8 repo
)

@REM echo =====[ Setup git info ]=====
@REM git config --global user.name "V8 Windows Builder"
@REM git config --global user.email "v8.windows.builder@localhost"
@REM git config --global core.autocrlf false
@REM git config --global core.filemode false
@REM git config --global color.ui true

echo =====[ Getting Depot Tools ]=====
if not defined V8_ENV_HAS_DEPOT_TOOLS (
    powershell -command "Invoke-WebRequest https://storage.googleapis.com/chrome-infra/depot_tools.zip -O depot_tools.zip"
    7z x depot_tools.zip -o*
    set "PATH=%CD%\depot_tools;%PATH%"
    call gclient
    set DEPOT_TOOLS_WIN_TOOLCHAIN=0
    @REM set DEPOT_TOOLS_UPDATE=0
    @REM cd depot_tools
    @REM call git reset --hard cd076ba
    @REM cd ..
)

echo =====[ Fetching V8 ]=====
if not defined V8_CACHED_REPO (
    mkdir v8
    cd v8
    call fetch v8
) else (
    echo ----- cleaning v8 repo
    cd v8/v8
    call git reset --hard
    call git clean -fdx

    echo ----- cleaing build script repo
    cd build
    call git reset --hard
    call git clean -fdx
)

echo =====[ Checking out V8 Version ]=====
cd %V8_BUILD_ROOT%/v8/v8
call git checkout %V8_VERSION%
call gclient sync -D

echo =====[ Patching v8 ]=====
set V8_PATCH_PATH=%V8_BUILD_ROOT%\patchs\%V8_VERSION%-win-%V8_BUILD_ARCH%-%V8_BUILD_TOOLCHAIN%.patch
if exist %V8_PATCH_PATH% (
    echo ----- Applying patch: %V8_PATCH_PATH%
    call git apply --cached --reject  %V8_PATCH_PATH%
) else (
    echo ----- Patch not found: %V8_PATCH_PATH%
)
call python %V8_BUILD_ROOT%\scripts\remove_zc_inline.py ./build/config/compiler/BUILD.gn

echo =====[ Building V8 ]=====
set V8_BUILD_DIR=out\%V8_BUILD_ARCH%.%V8_BUILD_TOOLCHAIN%
call gn gen %V8_BUILD_DIR%
call python %V8_BUILD_ROOT%\scripts\make_gn_args.py %V8_BUILD_DIR%\args.gn win %V8_BUILD_ARCH% %V8_BUILD_TOOLCHAIN%
call ninja -C %V8_BUILD_DIR% -t clean
call ninja -C %V8_BUILD_DIR% v8

echo =====[ Copying Product ]=====
set DLL_OUTPUT_DIR=%V8_BUILD_ROOT%\%V8_BUILD_ARCH%.%V8_BUILD_TOOLCHAIN%
set LIB_OUTPUT_DIR=%V8_BUILD_ROOT%\%V8_BUILD_ARCH%.%V8_BUILD_TOOLCHAIN%
md %DLL_OUTPUT_DIR%
md %LIB_OUTPUT_DIR%
copy /Y %V8_BUILD_DIR%\v8.dll %DLL_OUTPUT_DIR%
copy /Y %V8_BUILD_DIR%\v8_libbase.dll %DLL_OUTPUT_DIR%
copy /Y %V8_BUILD_DIR%\v8_libplatform.dll %DLL_OUTPUT_DIR%
copy /Y %V8_BUILD_DIR%\third_party_zlib.dll %DLL_OUTPUT_DIR%

copy /Y %V8_BUILD_DIR%\v8.dll.lib %LIB_OUTPUT_DIR%
copy /Y %V8_BUILD_DIR%\v8_libbase.dll.lib %LIB_OUTPUT_DIR%
copy /Y %V8_BUILD_DIR%\v8_libplatform.dll.lib %LIB_OUTPUT_DIR%
copy /Y %V8_BUILD_DIR%\third_party_zlib.dll.lib %LIB_OUTPUT_DIR%

copy /Y %V8_BUILD_DIR%\v8.dll.pdb %DLL_OUTPUT_DIR%
copy /Y %V8_BUILD_DIR%\v8_libbase.dll.pdb %DLL_OUTPUT_DIR%
copy /Y %V8_BUILD_DIR%\v8_libplatform.dll.pdb %DLL_OUTPUT_DIR%
copy /Y %V8_BUILD_DIR%\third_party_zlib.dll.pdb %DLL_OUTPUT_DIR%