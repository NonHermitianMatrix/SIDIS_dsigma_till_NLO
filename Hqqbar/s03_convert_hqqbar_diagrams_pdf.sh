#!/usr/bin/env bash
set -euo pipefail

# Assemble the one validated Hqqbar S02 PostScript stream into a PDF.
# This stage is visualization/provenance only and performs no physics algebra.

s03_fail() {
  printf 'S03_FATAL: %s\n' "$1" >&2
  exit 1
}

s03_invoked_source="${BASH_SOURCE[0]}"
s03_script_dir="${s03_invoked_source%/*}"
if [[ "$s03_script_dir" == "$s03_invoked_source" ]]; then
  s03_script_dir='.'
fi
cd "$s03_script_dir"
s03_script_dir="$PWD"
s03_program_path="$s03_script_dir/${s03_invoked_source##*/}"

s03_s02_source='s02_export_hqqbar_diagrams_postscript.wl'
s03_s02_result='s02_result'
s03_pages_directory='.s02_ghostscript/pages'
s03_input_postscript="$s03_pages_directory/s02_set_001.ps"
s03_output_pdf='s03_hqqbar_feynman_diagrams.pdf'
s03_temporary_pdf=".${s03_output_pdf}.partial.$$"

s03_expected_s02_source_sha256='96c0982c4dc95d4174a3866248936ba110db3ab8b29bf1203cc0e9997c6ca49c'
s03_expected_s02_result_sha256='2dc020ce5fb5eb6c591b55ddd0021ce3efc6d0ecbd5581ae1656e160187b6b38'
s03_expected_postscript_sha256='2c6c53a2f422307eab66eb5e92e916a092277ef89c2ff89097856275b3a1b48d'
s03_expected_input_stream_count=1
s03_expected_pdf_page_count=1

# The Hqq tree supplies only a generic local Ghostscript runtime. No Hqq
# physics source, result, cache, or diagram page is read by this stage.
s03_runtime='../Hqq/.s02_ghostscript/runtime'
s03_gs_binary="$s03_runtime/usr/bin/gs"
s03_expected_gs_version='10.02.1'

s03_sha256() {
  sha256sum -- "$1" | awk '{print $1}'
}

s03_require_hash() {
  local s03_label="$1"
  local s03_path="$2"
  local s03_expected="$3"
  local s03_actual

  test -s "$s03_path" || s03_fail "$s03_label is missing or empty."
  s03_actual="$(s03_sha256 "$s03_path")"
  [[ "$s03_actual" == "$s03_expected" ]] || \
    s03_fail "$s03_label SHA-256 does not match the validated handoff."
}

s03_require_hash \
  'The validated S02 source' \
  "$s03_s02_source" \
  "$s03_expected_s02_source_sha256"
s03_require_hash \
  'The validated S02 result' \
  "$s03_s02_result" \
  "$s03_expected_s02_result_sha256"
s03_require_hash \
  'The validated S02 PostScript stream' \
  "$s03_input_postscript" \
  "$s03_expected_postscript_sha256"

test -d "$s03_pages_directory" || \
  s03_fail 'The Hqqbar S02 PostScript directory is missing.'

shopt -s nullglob
s03_input_candidates=("$s03_pages_directory"/s02_*.ps)
s03_stale_temporary_pdfs=(".${s03_output_pdf}.partial."*)
shopt -u nullglob

if [[ "${#s03_input_candidates[@]}" -ne "$s03_expected_input_stream_count" ]]; then
  s03_fail 'Expected exactly one Hqqbar S02 PostScript stream.'
fi
if [[ "${s03_input_candidates[0]}" != "$s03_input_postscript" ]]; then
  s03_fail 'The sole Hqqbar S02 stream does not have the validated path.'
fi
if [[ "${#s03_stale_temporary_pdfs[@]}" -ne 0 ]]; then
  s03_fail 'A stale S03 temporary PDF exists; refusing to overwrite it.'
fi

IFS= read -r s03_postscript_header < "$s03_input_postscript"
[[ "$s03_postscript_header" == '%!PS-Adobe-'* ]] || \
  s03_fail 'The Hqqbar S02 stream lacks a PostScript header.'

s03_declared_page_count="$(
  awk '$1 == "%%Pages:" {print $2; exit}' "$s03_input_postscript"
)"
s03_marker_page_count="$(
  awk '/^%%Page:/ {count++} END {print count + 0}' "$s03_input_postscript"
)"

[[ "$s03_declared_page_count" =~ ^[0-9]+$ ]] || \
  s03_fail 'The PostScript DSC page declaration is missing or invalid.'
[[ "$s03_marker_page_count" =~ ^[0-9]+$ ]] || \
  s03_fail 'The PostScript physical-page marker count is invalid.'
[[ "$s03_declared_page_count" -eq "$s03_marker_page_count" ]] || \
  s03_fail 'The PostScript declared and physical page counts disagree.'
[[ "$s03_declared_page_count" -eq "$s03_expected_pdf_page_count" ]] || \
  s03_fail 'The Hqqbar S02 stream does not contain exactly one page.'

test -x "$s03_gs_binary" || \
  s03_fail 'The established project Ghostscript executable is unavailable.'

export LD_LIBRARY_PATH="$s03_runtime/usr/lib/x86_64-linux-gnu${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export GS_LIB="$s03_runtime/usr/share/ghostscript/10.02.1/Resource/Init:$s03_runtime/usr/share/ghostscript/10.02.1/lib:$s03_runtime/usr/share/fonts/type1/urw-base35"

s03_gs_version="$($s03_gs_binary --version)" || \
  s03_fail 'The project Ghostscript runtime could not start.'
[[ "$s03_gs_version" == "$s03_expected_gs_version" ]] || \
  s03_fail 'The Ghostscript version does not match the validated runtime.'

trap 'rm -f -- "$s03_temporary_pdf"' EXIT

printf 'S03_STAGE: validating the bound Hqqbar PostScript input\n'
"$s03_gs_binary" \
  -q -dSAFER -dBATCH -dNOPAUSE \
  -sDEVICE=nullpage \
  "$s03_input_postscript"

printf 'S03_STAGE: atomically assembling the Hqqbar diagram PDF\n'
"$s03_gs_binary" \
  -q -dSAFER -dBATCH -dNOPAUSE \
  -sDEVICE=pdfwrite \
  -dPDFSETTINGS=/prepress \
  -sOutputFile="$s03_temporary_pdf" \
  "$s03_input_postscript"

test -s "$s03_temporary_pdf" || \
  s03_fail 'Ghostscript did not create a nonempty temporary PDF.'

printf 'S03_STAGE: validating the generated Hqqbar PDF\n'
"$s03_gs_binary" \
  -q -dSAFER -dBATCH -dNOPAUSE \
  -sDEVICE=nullpage \
  "$s03_temporary_pdf"

s03_pdf_page_count="$(
  "$s03_gs_binary" \
    -q -dSAFER \
    --permit-file-read="$s03_script_dir/$s03_temporary_pdf" \
    -dNODISPLAY \
    -c "($s03_script_dir/$s03_temporary_pdf) (r) file runpdfbegin pdfpagecount = quit"
)"
[[ "$s03_pdf_page_count" =~ ^[0-9]+$ ]] || \
  s03_fail 'Ghostscript did not return a valid PDF page count.'
[[ "$s03_pdf_page_count" -eq "$s03_expected_pdf_page_count" ]] || \
  s03_fail 'The generated PDF page count does not match the S02 input.'

s03_temporary_pdf_sha256="$(s03_sha256 "$s03_temporary_pdf")"
mv -f -- "$s03_temporary_pdf" "$s03_output_pdf"
trap - EXIT

test -s "$s03_output_pdf" || \
  s03_fail 'The finalized Hqqbar PDF is missing or empty.'
s03_pdf_sha256="$(s03_sha256 "$s03_output_pdf")"
[[ "$s03_pdf_sha256" == "$s03_temporary_pdf_sha256" ]] || \
  s03_fail 'The finalized PDF hash changed during atomic rename.'

printf 'S03_SUCCESS\n'
printf 'S03_PROGRAM_SHA256=%s\n' "$(s03_sha256 "$s03_program_path")"
printf 'S03_S02_SOURCE_SHA256=%s\n' "$(s03_sha256 "$s03_s02_source")"
printf 'S03_S02_RESULT_SHA256=%s\n' "$(s03_sha256 "$s03_s02_result")"
printf 'S03_INPUT_POSTSCRIPT_SHA256=%s\n' "$(s03_sha256 "$s03_input_postscript")"
printf 'S03_INPUT_STREAM_COUNT=%s\n' "${#s03_input_candidates[@]}"
printf 'S03_INPUT_PAGE_COUNT=%s\n' "$s03_declared_page_count"
printf 'S03_PDF_PATH=%s/%s\n' "$s03_script_dir" "$s03_output_pdf"
printf 'S03_PDF_BYTES=%s\n' "$(stat -c %s "$s03_output_pdf")"
printf 'S03_PDF_SHA256=%s\n' "$s03_pdf_sha256"
printf 'S03_PDF_PAGE_COUNT=%s\n' "$s03_pdf_page_count"
printf 'S03_GHOSTSCRIPT_VERSION=%s\n' "$s03_gs_version"
