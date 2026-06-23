from elasticsearch import Elasticsearch
import logging
import os
from datetime import datetime

logger = logging.getLogger(__name__)

ES_URL = os.getenv(
    'ELASTICSEARCH_URL',
    'http://elasticsearch-master.logging:9200'
)

def get_logs(service, time_window):
    """
    Get error logs from Elasticsearch
    Returns formatted log summary
    """
    try:
        logger.info(f"Getting logs for: {service}")

        es = Elasticsearch([ES_URL])

        # Search for error logs
        query = {
            "query": {
                "bool": {
                    "must": [
                        {
                            "range": {
                                "@timestamp": {
                                    "gte": time_window['start'],
                                    "lte": time_window['end']
                                }
                            }
                        }
                    ],
                    "should": [
                        {"match": {"log": "error"}},
                        {"match": {"log": "ERROR"}},
                        {"match": {"log": "exception"}},
                        {"match": {"log": "traceback"}},
                        {"match": {"log": "500"}}
                    ],
                    "minimum_should_match": 1,
                    "filter": [
                        {
                            "term": {
                                "kubernetes.namespace": "jewelhub"
                            }
                        }
                    ]
                }
            },
            "sort": [{"@timestamp": "desc"}],
            "size": 20
        }

        response = es.search(
            index="filebeat-*",
            body=query
        )

        hits = response['hits']['hits']
        total = response['hits']['total']['value']

        # Extract log messages
        log_messages = []
        for hit in hits[:10]:
            source = hit.get('_source', {})
            log_msg = source.get('log', '').strip()
            container = source.get(
                'kubernetes', {}
            ).get(
                'container', {}
            ).get('name', 'unknown')

            if log_msg:
                log_messages.append(
                    f"[{container}] {log_msg[:200]}"
                )

        logs = {
            "total_errors": total,
            "sample_logs": log_messages,
            "time_window": time_window['duration_mins']
        }

        logger.info(
            f"Found {total} error logs "
            f"for {service}"
        )
        return logs

    except Exception as e:
        logger.error(f"Error getting logs: {str(e)}")
        return {
            "total_errors": "N/A",
            "sample_logs": [],
            "error": str(e)
        }