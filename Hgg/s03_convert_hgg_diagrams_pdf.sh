#!/usr/bin/env bash
set -euo pipefail

# Convert the Hgg S02 native PostScript diagram sheet into a validated PDF.
# The Ghostscript files under Hqq are reused only as a generic local runtime;
# this stage does not read any Hqq physics result, cache, or diagram page.

s03_fail() {
  printf 'S03_FATAL: %s\n' "$1" >&2
  exit 1
}

s03_script_dir="${BASH_SOURCE[0]%/*}"
cd "$s03_script_dir"

s03_runtime="../Hqq/.s02_ghostscript/runtime"
s03_gs_binary="$s03_runtime/usr/bin/gs"
s03_pages_directory=".s02_ghostscript/pages"
s03_output_pdf="s03_hgg_feynman_diagrams.pdf"
s03_temporary_pdf=".${s03_output_pdf}.partial.$$"

test -x "$s03_gs_binary" || \
  s03_fail "The existing project Ghostscript executable is unavailable."
test -d "$s03_pages_directory" || \
  s03_fail "The Hgg S02 PostScript page directory is missing."

shopt -s nullglob
s03_pages=("$s03_pages_directory"/s02_page_*.ps)
shopt -u nullglob

if [[ "${#s03_pages[@]}" -ne 1 ]]; then
  s03_fail "Expected exactly one Hgg S02 PostScript page."
fi

for s03_page in "${s03_pages[@]}"; do
  test -s "$s03_page" || \
    s03_fail "An Hgg S02 PostScript page is missing or empty."
  IFS= read -r s03_header < "$s03_page"
  [[ "$s03_header" == '%!PS-Adobe-'* ]] || \
    s03_fail "An Hgg S02 page lacks the required PostScript header."
done

export LD_LIBRARY_PATH="$s03_runtime/usr/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export GS_LIB="$s03_runtime/usr/share/ghostscript/10.02.1/Resource/Init:$s03_runtime/usr/share/ghostscript/10.02.1/lib:$s03_runtime/usr/share/fonts/type1/urw-base35"

trap 'rm -f -- "$s03_temporary_pdf"' EXIT

printf 'S03_STAGE: validating %s Hgg PostScript input page(s)\n' "${#s03_pages[@]}"
"$s03_gs_binary" \
  -q -dSAFER -dBATCH -dNOPAUSE \
  -sDEVICE=nullpage \
  "${s03_pages[@]}"

printf 'S03_STAGE: combining Hgg diagram pages into PDF\n'
"$s03_gs_binary" \
  -q -dSAFER -dBATCH -dNOPAUSE \
  -sDEVICE=pdfwrite \
  -dPDFSETTINGS=/prepress \
  -sOutputFile="$s03_temporary_pdf" \
  "${s03_pages[@]}"

test -s "$s03_temporary_pdf" || \
  s03_fail "Ghostscript did not create a nonempty temporary PDF."

printf 'S03_STAGE: validating generated PDF\n'
"$s03_gs_binary" \
  -q -dSAFER -dBATCH -dNOPAUSE \
  -sDEVICE=nullpage \
  "$s03_temporary_pdf"

mv -f -- "$s03_temporary_pdf" "$s03_output_pdf"
trap - EXIT

test -s "$s03_output_pdf" || \
  s03_fail "The finalized Hgg PDF is missing or empty."

printf 'S03_SUCCESS\n'
printf 'S03_INPUT_PAGE_COUNT=%s\n' "${#s03_pages[@]}"
printf 'S03_PDF_PATH=%s/%s\n' "$PWD" "$s03_output_pdf"
printf 'S03_PDF_BYTES=%s\n' "$(stat -c %s "$s03_output_pdf")"
printf 'S03_GHOSTSCRIPT_RUNTIME=%s\n' "$s03_runtime"
file "$s03_output_pdf"
