#! /bin/bash
resourceGroupName=rg-arc-footprint-images
vmName=arc-footprint
clusterName=aksarcfootprint
kvName=kvarcfootprint7
subscriptionId=$(az account show --query id -o tsv)
tenantId=$(az account show --query tenantId -o tsv)
appId=ea106e24-425a-4c72-88e4-8b46d2d4b127
appSecret=QOI8Q~eroJpgI.gdPne9yG30a4LEm4wtbn.l-dmy
spObjectId="7fa05364-1693-422a-ae2c-c433f1d5b85d"
location=eastus
vmIdentityName=$vmName-id

osType=$(az vm show -g $resourceGroupName -n $vmName --query storageProfile.osDisk.osType -o tsv)
principalId=$(az identity show --name $vmIdentityName -g $resourceGroupName --query principalId -o tsv)
kvId=$(az keyvault create -n $kvName -g $resourceGroupName -o tsv --no-self-perms --query id)
az keyvault set-policy -n $kvName -g $resourceGroupName --object-id $spObjectId --secret-permissions all
az keyvault set-policy -n $kvName -g $resourceGroupName --object-id $principalId --secret-permissions all

az vm extension set \
    --resource-group $resourceGroupName \
    --vm-name $vmName \
    --name CustomScriptExtension \
    --publisher Microsoft.Compute \
    --force-update \
    --settings "{\"commandToExecute\":\"powershell Get-AksEdgeKubeConfig -KubeConfigPath C:\\Scripts -Confirm:\$false; \
        kubectl get pods -A -v6 --kubeconfig C:\\scripts\\config; \
        az login --identity; \
        az extension add --name connectedk8s; \
        az extension add --name azure-iot-ops; \
        az connectedk8s connect --debug -n $clusterName -l $location -g $resourceGroupName --kube-config C:\\Scripts\\config --subscription $subscriptionId; \
        az connectedk8s enable-features -n $clusterName -g $resourceGroupName --kube-config C:\\Scripts\\config --custom-locations-oid \"\"af89a3ae-8ffe-4ce7-89fb-a615f4083dc3\"\" --features cluster-connect custom-locations; \
        \$env:KUBECONFIG='C:\\Scripts\\config'; \
        az iot ops init --cluster $clusterName -g $resourceGroupName --kv-id \"\"$kvId\"\" --sp-app-id \"\"$appId\"\" --sp-object-id \"\"$spObjectId\"\" --sp-secret \"\"$appSecret\"\"; \
    \"}"
        #\$env:KUBECONFIG='C:\\Scripts\\config'; \
        #New-Item -Path c:\\ -Name Scripts -ItemType directory -Force; \
        #Copy-Item C:\\Windows\\System32\\config\\systemprofile\\.kube\\config -Destination C:\\Scripts; \
        #az login --service-principal -u \"\"$appId\"\" -p \"\"$appSecret\"\" --tenant \"\"$tenantId\"\"; \
        #\$env:KUBECONFIG='C:\\Scripts\\config'; \


# az vm run-command invoke \
#     --command-id RunPowerShellScript \
#     --resource-group $resourceGroupName \
#     --name $vmName \
#     --scripts "Get-AksEdgeKubeConfig -Confirm:\$false" \
#         "New-Item -Path c:\\ -Name Scripts -ItemType directory -Force" \
#         "Copy-Item C:\\Windows\\System32\\config\\systemprofile\\.kube\\config -Destination C:\\Scripts" \
#         "az connectedk8s connect -n arc-aksEEAIO-mytest -l westeurope -g $resourceGroupName --kube-config C:\\Scripts\\config --subscription $subscriptionId" \
#         "az connectedk8s enable-features -n arc-aksEEAIO-mytest -g $resourceGroupName --kube-config C:\\Scripts\\config --custom-locations-oid \"af89a3ae-8ffe-4ce7-89fb-a615f4083dc3\" --features cluster-connect custom-locations"

# az vm run-command invoke \
#     --command-id RunPowerShellScript \
#     --resource-group $resourceGroupName \
#     --name $vmName \
#     --scripts "Get-AksEdgeKubeConfig -Confirm:\$false" \
#         "kubectl get pods -A -v6" \
#         "az login --service-principal -u \"ea106e24-425a-4c72-88e4-8b46d2d4b127\" -p \"QOI8Q~eroJpgI.gdPne9yG30a4LEm4wtbn.l-dmy\" --tenant \"$tenantId\"" \
#         "az extension add --name connectedk8s" \
#         "az extension add --name azure-iot-ops" \
#         "Get-AksEdgeKubeConfig -Confirm:\$false; az connectedk8s connect -n arc-aksEEAIO-mytest -l westeurope -g $resourceGroupName --kube-config C:\\Users\\azureuser\\.kube\\config --subscription $subscriptionId" \
#         "az connectedk8s enable-features -n arc-aksEEAIO-mytest -g $resourceGroupName --kube-config C:\\Users\\azureuser\\.kube\\config --custom-locations-oid \"af89a3ae-8ffe-4ce7-89fb-a615f4083dc3\" --features cluster-connect custom-locations"
    
    #     --settings '{"commandToExecute": "powershell -Command \{ \
    #     az login --service-principal -u ${{ secrets.AZURE_CLIENT_ID }} -p ${{ secrets.AZURE_CLIENT_SECRET }} --tenant $tenantId; \
    #     Get-AksEdgeKubeConfig -Confirm:\$false; \
    #     az provider register -n "Microsoft.ExtendedLocation"; \
    #     az provider register -n "Microsoft.Kubernetes"; \
    #     az provider register -n "Microsoft.KubernetesConfiguration"; \
    #     az provider register -n "Microsoft.IoTOperationsOrchestrator"; \
    #     az provider register -n "Microsoft.IoTOperationsMQ"; \
    #     az provider register -n "Microsoft.IoTOperationsDataProcessor"; \
    #     az provider register -n "Microsoft.DeviceRegistry"; \
    #     az extension add --name connectedk8s; \
    #     az extension add --name azure-iot-ops; \
    #     az connectedk8s connect -n arc-aksEEAIO-${{github.run_id}} -l ${{ inputs.location }} -g ${{ inputs.resourceGroupName }} --subscription $subscriptionId; \
    #     az connectedk8s enable-features -n arc-aksEEAIO-${{github.run_id}} -g ${{ inputs.resourceGroupName }} --custom-locations-oid ${{ secrets.CUSTOM_LOCATIONS_OBJECT_ID }} --features cluster-connect custom-locations; \
    #     az iot ops init --cluster arc-aksEEAIO-${{github.run_id}} -g ${{ inputs.resourceGroupName }} --kv-id $(az keyvault create -n kv-aksEEAIO-${{github.run_id}} -g ${{ inputs.resourceGroupName }} -o tsv --query id) --sp-app-id ${{ secrets.AZURE_SP_CLIENT_ID }} --sp-object-id ${{ secrets.AZURE_SP_OBJECT_ID }} --sp-secret ${{ secrets.AZURE_SP_CLIENT_ID }}; \
    #     \}"}'
