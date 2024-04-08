import argparse

# parse arg
parser = argparse.ArgumentParser(description="remove /Zc:inline from BUILD.gn files")
parser.add_argument("path", help="BUILD.gn file path", type=str)
args = parser.parse_args()

# comment out /Zc:inline
print(f"Removing /Zc:inline from {args.path}")
with open(args.path, "r+", encoding="utf-8") as f:
    content = f.read()
    content = content.replace('"/Zc:inline"', '# "/Zc:inline"')
    f.seek(0)
    f.write(content)
    f.truncate()
