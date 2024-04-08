import argparse

# parse arg
parser = argparse.ArgumentParser(description="remove /Zc:inline from BUILD.gn files")
parser.add_argument("path", help="args.gn file path", type=str)
parser.add_argument("plat", help="platform to build", type=str)
parser.add_argument("arch", help="architecture to build", type=str)
parser.add_argument("toolchain", help="toolchain to build", type=str)
args = parser.parse_args()

# build content
content = f'''
target_os="{args.plat}"
target_cpu="{args.arch}"
is_clang={"true" if args.toolchain == "clang-cl" else "false"}
dcheck_always_on=false
treat_warnings_as_errors=false
v8_use_external_startup_data=false
is_official_build=false
v8_enable_test_features=false
v8_monolithic=false
v8_enable_i18n_support=false
is_debug=false
strip_debug_info=true
v8_symbol_level=0
v8_enable_pointer_compression=false
is_component_build=true
v8_static_library=false
use_custom_libcxx=false
use_lld=false"
'''
with open(args.path, 'w', encoding='utf-8') as f:
    f.write(content)
