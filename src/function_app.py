import azure.functions as func
import logging
import json
import os
import asyncio

# Global objects
credential = None
blob_service_client = None
http_client = None
pandas_lib = None
httpx_lib = None

def get_env_var(name):
    value = os.environ.get(name)
    if not value:
        logging.error(f"Missing environment variable: {name}")
    return value

# Environment variables
STORAGE_ACCOUNT_NAME = get_env_var("STORAGE_ACCOUNT_NAME")
SERVICE_BUS_TOPIC_NAME = get_env_var("SERVICE_BUS_TOPIC_NAME")
SERVICE_BUS_SUBSCRIPTION_NAME = get_env_var("SERVICE_BUS_SUBSCRIPTION_NAME")
AZURE_MONITOR_METRICS_URL = get_env_var("AZURE_MONITOR_METRICS_URL")

def get_payload(metric_name, metric_value, pd_module):
    return {
        "time": pd_module.Timestamp.utcnow().isoformat(),
        "data": {
            "baseData": {
                "metric": metric_name,
                "namespace": "Claim Check",
                "dimNames": ["Worker Type"],
                "series": [
                    {
                        "dimValues": ["Claim Check EP1"],
                        "min": float(metric_value),
                        "max": float(metric_value),
                        "sum": float(metric_value),
                        "count": 1
                    }
                ]
            }
        }
    }

async def track_metrics_azure_monitor(file_size, row_count, pd_module, client_http):
    global credential
    token_obj = await credential.get_token("https://monitoring.azure.com/.default")
    
    headers = {
        "Authorization": f"Bearer {token_obj.token}",
        "Content-Type": "application/json"
    }
    
    tasks = [
        client_http.post(AZURE_MONITOR_METRICS_URL, headers=headers, json=get_payload("File Size", file_size, pd_module)),
        client_http.post(AZURE_MONITOR_METRICS_URL, headers=headers, json=get_payload("Rows", row_count, pd_module))
    ]
    await asyncio.gather(*tasks)

async def process_file(msg_body, pd_module, client_http):
    global credential
    import io
    import csv
    from azure.storage.blob.aio import BlobClient

    msg_data = json.loads(msg_body).get('data')
    blob_url = msg_data.get("url")

    logging.info(f"ℹ️ Working with blob {blob_url} | Size: {msg_data.get('size')}")

    async with BlobClient.from_blob_url(blob_url, credential=credential) as blob_client:
        stream = await blob_client.download_blob()
        content = await stream.readall()
        file_size = len(content)

    # Pandas
    df = pd_module.read_csv(io.BytesIO(content),         
        sep='|', 
        quotechar='`', 
        quoting=csv.QUOTE_ALL)
    row_count = len(df)

    logging.info(f"Rows: {row_count} | Size: {file_size}")

    await track_metrics_azure_monitor(file_size, row_count, pd_module, client_http)

app = func.FunctionApp()

@app.service_bus_topic_trigger(
    arg_name="message",
    topic_name=SERVICE_BUS_TOPIC_NAME,
    subscription_name=SERVICE_BUS_SUBSCRIPTION_NAME,
    connection="ServiceBusConnection",
    is_sessions_enabled=False
)
async def consumer(message: func.ServiceBusMessage):
    # --- LAZY IMPORT CON CACHE GLOBAL ---
    global credential, pandas_lib, httpx_lib, http_client
    
    # Solo importamos e instanciamos la primera vez (Cold Start)
    if pandas_lib is None:
        import pandas
        pandas_lib = pandas
    
    if httpx_lib is None:
        import httpx
        httpx_lib = httpx
        http_client = httpx.AsyncClient()

    if credential is None:
        from azure.identity.aio import DefaultAzureCredential
        credential = DefaultAzureCredential()

    body = message.get_body().decode('utf-8')
    await process_file(body, pandas_lib, http_client)
    logging.info(f"✅ Completing message {message.message_id} ...")