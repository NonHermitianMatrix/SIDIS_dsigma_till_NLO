#!/usr/bin/env bash
set -euo pipefail

# Convert the exact accepted Hqqprime S02 PostScript sheets into one validated
# PDF. This stage changes only the visualization container.

s03_fail() {
  printf 'S03_FATAL: %s\n' "$1" >&2
  exit 1
}

s03_sha256() {
  local s03_hash_value
  local s03_hash_path
  s03_hash_path="$1"
  read -r s03_hash_value _ < <(sha256sum -- "$s03_hash_path")
  printf '%s' "$s03_hash_value"
}

s03_script_dir="${BASH_SOURCE[0]%/*}"
cd "$s03_script_dir"

s03_source="s03_convert_hqqprime_diagrams_pdf.sh"
s03_s02_source="s02_export_hqqprime_diagrams_postscript.wl"
s03_s02_result="s02_result"
s03_s02_log="s02_export_hqqprime_diagrams_postscript.log"
s03_pages_directory=".s02_ghostscript/pages"
s03_output_pdf="s03_hqqprime_feynman_diagrams.pdf"
s03_temporary_pdf=".${s03_output_pdf}.partial.$$"

s03_expected_s02_source_sha256="1af7043dd1530bf19ea72f0261add1a3773f92a1bee9b418e87f29b2e3fd2132"
s03_expected_s02_result_sha256="2ff55677e07fbf4108e88c3e9e33606e920376e755c57e10e766df8793d3c26d"
s03_expected_s02_log_sha256="87819e34a585cb3a24ece64d84b1c39040e67f8f299d51b674e721ccf9d55d63"

s03_pages=(
  "$s03_pages_directory/s02_page_001.ps"
  "$s03_pages_directory/s02_page_002.ps"
  "$s03_pages_directory/s02_page_003.ps"
)
s03_expected_page_sha256=(
  "80dbf50748e338f4f2b681d1109d1ca201d43d8debf80ff71542530a422bd820"
  "1acf2dd5756c906e942d8f174434ca5e72930d41fb3d539cadb6e49507911b25"
  "b4c4801423adba773045f36c26bf4fa25e780b86ac114e65b64b7c525151a4da"
)
s03_expected_page_bytes=(10763 10765 10765)

test -f "$s03_source" || s03_fail "The S03 source path is unavailable."
test -f "$s03_s02_source" || s03_fail "The accepted S02 source is missing."
test -f "$s03_s02_result" || s03_fail "The accepted s02_result is missing."
test -f "$s03_s02_log" || s03_fail "The accepted S02 log is missing."
test -d "$s03_pages_directory" || \
  s03_fail "The accepted S02 page directory is missing."
test ! -e "$s03_output_pdf" || \
  s03_fail "The final S03 PDF already exists; refusing to overwrite it."
test ! -e "$s03_temporary_pdf" || \
  s03_fail "A process-specific temporary S03 PDF already exists."

[[ "$(s03_sha256 "$s03_s02_source")" == \
  "$s03_expected_s02_source_sha256" ]] || \
  s03_fail "The S02 source hash differs from the accepted ledger."
[[ "$(s03_sha256 "$s03_s02_result")" == \
  "$s03_expected_s02_result_sha256" ]] || \
  s03_fail "The s02_result hash differs from the accepted ledger."
[[ "$(s03_sha256 "$s03_s02_log")" == \
  "$s03_expected_s02_log_sha256" ]] || \
  s03_fail "The S02 production-log hash differs from the accepted ledger."

[[ "$(grep -c 'S02_SUCCESS' "$s03_s02_log")" -eq 1 ]] || \
  s03_fail "The accepted S02 log does not contain exactly one success marker."
grep -q '^S02_SHELL_EXIT=0$' "$s03_s02_log" || \
  s03_fail "The accepted S02 log lacks shell exit zero."
if grep -Eq 'S02_FATAL|Out of memory|Killed|Aborted|Terminated' "$s03_s02_log"; then
  s03_fail "The accepted S02 log contains a fatal execution marker."
fi

shopt -s nullglob
s03_discovered_pages=("$s03_pages_directory"/s02_page_*.ps)
shopt -u nullglob
[[ "${#s03_discovered_pages[@]}" -eq "${#s03_pages[@]}" ]] || \
  s03_fail "The S02 page directory has a missing or extra page."

for s03_index in "${!s03_pages[@]}"; do
  [[ "${s03_discovered_pages[$s03_index]}" == "${s03_pages[$s03_index]}" ]] || \
    s03_fail "The ordered S02 page set differs from the accepted ledger."
  s03_page="${s03_pages[$s03_index]}"
  test -s "$s03_page" || s03_fail "An accepted S02 page is missing or empty."
  [[ "$(stat -c %s "$s03_page")" -eq \
    "${s03_expected_page_bytes[$s03_index]}" ]] || \
    s03_fail "An accepted S02 page byte size has changed."
  [[ "$(s03_sha256 "$s03_page")" == \
    "${s03_expected_page_sha256[$s03_index]}" ]] || \
    s03_fail "An accepted S02 page hash has changed."
  s03_header=$(LC_ALL=C head -c 10 "$s03_page")
  [[ "$s03_header" == '%!PS-Adobe'* ]] || \
    s03_fail "An accepted S02 page lacks its PostScript header."
done

s03_runtime="../Hqq/.s02_ghostscript/runtime"
s03_gs_binary="$s03_runtime/usr/bin/gs"
test -x "$s03_gs_binary" || \
  s03_fail "The existing project Ghostscript executable is unavailable."

export LD_LIBRARY_PATH="$s03_runtime/usr/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export GS_LIB="$s03_runtime/usr/share/ghostscript/10.02.1/Resource/Init:$s03_runtime/usr/share/ghostscript/10.02.1/lib:$s03_runtime/usr/share/fonts/type1/urw-base35"

trap 'rm -f -- "$s03_temporary_pdf"' EXIT

printf 'S03_STAGE: validating %s accepted Hqqprime PostScript pages\n' \
  "${#s03_pages[@]}"
"$s03_gs_binary" \
  -q -dSAFER -dBATCH -dNOPAUSE \
  -sDEVICE=nullpage \
  "${s03_pages[@]}"

printf 'S03_STAGE: combining the accepted pages into a temporary PDF\n'
"$s03_gs_binary" \
  -q -dSAFER -dBATCH -dNOPAUSE \
  -sDEVICE=pdfwrite \
  -dCompatibilityLevel=1.7 \
  -dPDFSETTINGS=/prepress \
  -sOutputFile="$s03_temporary_pdf" \
  "${s03_pages[@]}"

test -s "$s03_temporary_pdf" || \
  s03_fail "Ghostscript did not create a nonempty temporary PDF."
[[ "$(LC_ALL=C head -c 5 "$s03_temporary_pdf")" == '%PDF-' ]] || \
  s03_fail "The temporary output lacks a PDF header."

printf 'S03_STAGE: validating the temporary PDF\n'
"$s03_gs_binary" \
  -q -dSAFER -dBATCH -dNOPAUSE \
  -sDEVICE=nullpage \
  "$s03_temporary_pdf"

s03_temporary_pdf_absolute="$PWD/$s03_temporary_pdf"
s03_pdf_page_count=$(
  "$s03_gs_binary" \
    -q -dNODISPLAY \
    --permit-file-read="$s03_temporary_pdf_absolute" \
    -c "($s03_temporary_pdf_absolute) (r) file runpdfbegin pdfpagecount = quit"
)
[[ "$s03_pdf_page_count" =~ ^[0-9]+$ ]] || \
  s03_fail "Ghostscript did not return an integer PDF page count."
[[ "$s03_pdf_page_count" -eq "${#s03_pages[@]}" ]] || \
  s03_fail "The PDF page count differs from the accepted S02 input count."

mv -- "$s03_temporary_pdf" "$s03_output_pdf"
trap - EXIT

test -s "$s03_output_pdf" || \
  s03_fail "The atomically published S03 PDF is missing or empty."

printf 'S03_SOURCE_SHA256=%s\n' "$(s03_sha256 "$s03_source")"
printf 'S03_INPUT_S02_RESULT_SHA256=%s\n' "$s03_expected_s02_result_sha256"
printf 'S03_INPUT_PAGE_COUNT=%s\n' "${#s03_pages[@]}"
printf 'S03_PDF_PAGE_COUNT=%s\n' "$s03_pdf_page_count"
printf 'S03_PDF_SHA256=%s\n' "$(s03_sha256 "$s03_output_pdf")"
printf 'S03_PDF_BYTES=%s\n' "$(stat -c %s "$s03_output_pdf")"
printf 'S03_GHOSTSCRIPT_VERSION=%s\n' "$($s03_gs_binary --version)"
printf 'S03_SUCCESS\n'
printf 'S03_PDF_PATH=%s/%s\n' "$PWD" "$s03_output_pdf"
file "$s03_output_pdf"
