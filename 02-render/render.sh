#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_DIR="./templates"
OUTPUT_DIR="../03-install"
OUTPUTS_FILE="../01-infra/outputs.json"

echo "Exporting Terraform outputs from 01-infra..."
pushd ../01-infra > /dev/null
terraform output -json > outputs.json
popd > /dev/null

echo "Rendering templates to $OUTPUT_DIR..."
mkdir -p "$OUTPUT_DIR/helm-values"

for template in "$TEMPLATE_DIR"/*.gotmpl; do
  filename=$(basename "$template" .gotmpl)

  outpath="$OUTPUT_DIR/helm-values/${filename}"

  gomplate \
    --context .=${OUTPUTS_FILE} \
    --file "$template" \
    --out "$outpath"

  echo "Rendered $outpath"
done

echo "All templates rendered successfully!"