#!/bin/bash
set -e
REGION="ap-south-1"
CLUSTER="secureship-dev"
PROFILE="cloudsentry"
ACCOUNT_ID="081382613682"
ESO_ROLE="arn:aws:iam::${ACCOUNT_ID}:role/secureship-eso"

echo "==> Updating kubeconfig"
aws eks update-kubeconfig --name "$CLUSTER" --region "$REGION" --profile "$PROFILE"

echo "==> Installing ArgoCD"
helm repo add argo https://argoproj.github.io/argo-helm --force-update >/dev/null 2>&1 || true
helm upgrade --install argocd argo/argo-cd -n argocd --create-namespace -f argocd/values.yaml
kubectl wait --for=condition=available deploy/argocd-server -n argocd --timeout=300s

echo "==> Applying ArgoCD Application"
kubectl apply -f argocd/application.yaml

echo "==> Installing External Secrets Operator"
helm repo add external-secrets https://charts.external-secrets.io --force-update >/dev/null 2>&1 || true
helm upgrade --install external-secrets external-secrets/external-secrets \
  -n external-secrets --create-namespace \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="$ESO_ROLE"
kubectl wait --for=condition=available deploy/external-secrets -n external-secrets --timeout=300s 2>/dev/null || sleep 10

echo "==> Installing Kyverno"
helm repo add kyverno https://kyverno.github.io/kyverno --force-update >/dev/null 2>&1 || true
helm upgrade --install kyverno kyverno/kyverno -n kyverno --create-namespace
kubectl wait --for=condition=available deploy/kyverno-admission-controller -n kyverno --timeout=300s 2>/dev/null || true

echo "==> Applying Kyverno policies"
kubectl apply -f kyverno/policies/

echo "==> Installing Prometheus"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts --force-update >/dev/null 2>&1 || true
helm upgrade --install prometheus prometheus-community/prometheus \
  -n monitoring --create-namespace -f monitoring/prometheus-values.yaml

echo "==> Installing Grafana"
helm repo add grafana https://grafana.github.io/helm-charts --force-update >/dev/null 2>&1 || true
helm upgrade --install grafana grafana/grafana \
  -n monitoring -f monitoring/grafana-values.yaml

echo ""
echo "==> Done! Cluster bootstrapped."
echo "    ArgoCD:  kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "    Grafana: kubectl port-forward svc/grafana -n monitoring 3000:80 (admin/secureship-dev)"
echo "    ArgoCD password: kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}' | base64 -d; echo"
