#!/usr/bin/env bash
set -euo pipefail

script_dir="${BASH_SOURCE[0]%/*}"
cd "$script_dir"

runtime=".s02_ghostscript/runtime"
gs_binary="$runtime/usr/bin/gs"
output_pdf="s03_feynman_diagrams.pdf"
pages=(
  ".s02_ghostscript/pages/s02_page_001.ps"
  ".s02_ghostscript/pages/s02_page_002.ps"
  ".s02_ghostscript/pages/s02_page_003.ps"
  ".s02_ghostscript/pages/s02_page_004.ps"
  ".s02_ghostscript/pages/s02_page_005.ps"
  ".s02_ghostscript/pages/s02_page_006.ps"
)

test -x "$gs_binary"
for page in "${pages[@]}"; do
  test -s "$page"
done

export LD_LIBRARY_PATH="$runtime/usr/lib/x86_64-linux-gnu"
export GS_LIB="$runtime/usr/share/ghostscript/10.02.1/Resource/Init:$runtime/usr/share/ghostscript/10.02.1/lib:$runtime/usr/share/fonts/type1/urw-base35"

"$gs_binary" \
  -q -dBATCH -dNOPAUSE \
  -sDEVICE=pdfwrite \
  -dPDFSETTINGS=/prepress \
  -sOutputFile="$output_pdf" \
  "${pages[@]}"

test -s "$output_pdf"
"$gs_binary" -q -dBATCH -dNOPAUSE -sDEVICE=nullpage "$output_pdf"

echo "S03_SUCCESS"
echo "S03_PDF_PATH=$script_dir/$output_pdf"
file "$output_pdf"
