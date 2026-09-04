#!/usr/bin/env bash
set -euo pipefail

upstream_url="https://github.com/ggml-org/whisper.cpp.git"
requested_tag="${1:-}"

if [[ -z "${requested_tag}" ]]; then
	requested_tag="$(git ls-remote --tags --refs "${upstream_url}" 'v*' \
		| awk -F/ '{print $3}' \
		| grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' \
		| sort -V \
		| tail -n 1)"
fi

if [[ ! "${requested_tag}" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
	echo "Expected a stable tag such as v1.9.3; got: ${requested_tag}" >&2
	exit 1
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temp_root="$(mktemp -d)"
trap 'rm -rf "${temp_root}"' EXIT

git clone --depth 1 --branch "${requested_tag}" "${upstream_url}" "${temp_root}/whisper.cpp"

source_tree="${temp_root}/whisper.cpp"
source_commit="$(git -C "${source_tree}" rev-parse HEAD)"
destinations=(
	"android/src/whisper/whisper.cpp"
	"ios/Classes/whisper"
	"macos/Classes/whisper"
)

# Copy the maintained CPU-only manifest. Files from optional GPU/RPC backends
# are deliberately excluded because the Flutter plugin does not compile them.
for relative_destination in "${destinations[@]}"; do
	destination="${repo_root}/${relative_destination}"
	while IFS= read -r relative_file; do
		mkdir -p "${destination}/$(dirname "${relative_file}")"
		cp "${source_tree}/${relative_file}" "${destination}/${relative_file}"
	done < <(
		cd "${repo_root}"
		git ls-files "${relative_destination}/include/**" \
			"${relative_destination}/src/**" \
			"${relative_destination}/ggml/include/**" \
			"${relative_destination}/ggml/src/**" \
			| sed "s#^${relative_destination}/##"
		printf '%s\n' 'ggml/src/ggml-feats.h'
	)
done

cat > "${repo_root}/WHISPER_CPP_VERSION" <<EOF
tag=${requested_tag}
commit=${source_commit}
repository=${upstream_url}
EOF

version="${requested_tag#v}"
version_files=(
	"README.md"
	"android/src/whisper/CMakeLists.txt"
	"linux/CMakeLists.txt"
	"windows/CMakeLists.txt"
	"ios/whisper_wrapper.podspec"
	"macos/whisper_wrapper.podspec"
)

for relative_file in "${version_files[@]}"; do
	perl -0pi -e "s/v[0-9]+\\.[0-9]+\\.[0-9]+/v${version}/g; s/\\\"[0-9]+\\.[0-9]+\\.[0-9]+\\\"/\\\"${version}\\\"/g" \
		"${repo_root}/${relative_file}"
done

echo "Vendored whisper.cpp ${requested_tag} (${source_commit}) into all platform source trees."
echo "Review the diff and run the Flutter and native build tests before committing."
