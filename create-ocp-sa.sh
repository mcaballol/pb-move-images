oc new-project tools
oc create serviceaccount imagereader -n tools
oc create clusterrolebinding imagereader-view --clusterrole=view --serviceaccount=tools:imagereader
oc create clusterrolebinding imagereader-edit --clusterrole=edit --serviceaccount=tools:imagereader
oc create token imagereader -n tools --duration=24h
