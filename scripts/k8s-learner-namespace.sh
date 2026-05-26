aws iam get-group \
  --group-name sctp-ce-12-learner \
  --query 'Users[].UserName' \
  --output text | \
tr '\t' '\n' | \
while read user; do
  ns=$(echo "$user" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^a-z0-9]/-/g' \
    | sed 's/^-*//;s/-*$//' \
    | cut -c1-49)-eks-activity

  kubectl create namespace "$ns" --dry-run=client -o yaml | kubectl apply -f -
done
