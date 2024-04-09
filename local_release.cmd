@echo off
mkdir build_release

cd build_release
mkdir package

echo =====[ Copying build output ]=====
mkdir artifact
xcopy "../build_output" "./artifact" /s/h/e/k/f/c

@REM package tgz
echo =====[ package tgz ]=====
cd artifact
for /d %%d in (*) do (
    tar -vz -cf ../package/%%d.tgz %%d
)

@REM build manifest
echo =====[ build manifest ]=====
cd "../package"
xmake l "../../scripts/build_manifest.lua" "*.tgz" "manifest.json"
for /F %%j in ('xmake l "../../scripts/get_sha.lua" manifest.json') do ( set MANIFEST_SHA=%%j )
echo manifest.json sha is %MANIFEST_SHA%