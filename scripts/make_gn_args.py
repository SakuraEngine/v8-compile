import argparse
import os

# parse arg
parser = argparse.ArgumentParser(description="remove /Zc:inline from BUILD.gn files")
parser.add_argument("path", help="args.gn file path", type=str)
parser.add_argument("plat", help="platform to build", type=str)
args = parser.parse_args()

v8_build_plat: str = args.plat
v8_version: str = os.getenv("V8_VERSION")
v8_build_arch: str = os.getenv("V8_BUILD_ARCH")
v8_build_toolchain: str = os.getenv("V8_BUILD_TOOLCHAIN")
v8_build_mode: str = os.getenv("V8_BUILD_MODE")


def _config_boolean(value: bool) -> "str":
    return "true" if value else "false"


# basic config
content = '''
treat_warnings_as_errors=false
is_official_build=false
v8_enable_test_features=false
v8_monolithic=false
v8_use_external_startup_data=false
v8_enable_i18n_support=false
v8_enable_pointer_compression=false
is_component_build=true
v8_static_library=false
use_custom_libcxx=false
use_lld=false
'''

# plat & arch & toolchain
content += f'''
target_os="{v8_build_plat}"
target_cpu="{v8_build_arch}"
is_clang={_config_boolean(v8_build_toolchain == "clang-cl")}
'''

# mode
if v8_build_mode == "debug":
    content += f'''
is_debug = true
v8_enable_backtrace = true
v8_enable_slow_dchecks = false
v8_optimized_debug = false
'''
elif v8_build_mode == "release":
    content += f'''
is_debug=false
dcheck_always_on=false
strip_debug_info=true
v8_symbol_level=0
'''
elif v8_build_mode == "releasedbg":
    content += f'''
is_debug = true
v8_enable_backtrace = true
v8_enable_slow_dchecks = false
v8_optimized_debug = true
'''
else:
    raise ValueError(f"Unknown build mode: {v8_build_mode}")

print("----- begin gn args")
print(content)
print("----- end gn args")

with open(args.path, 'w', encoding='utf-8') as f:
    f.write(content)
