import requests
import logging
import os
from datetime import datetime

logger = logging.getLogger(__name__)

PROMETHEUS_URL = os.getenv(
    'PROMETHEUS_URL',
    'http://prometheus-kube-prometheus-prometheus.monitoring:9090'
)

def query_prometheus(query):
    """Execute PromQL query"""
    try:
        response = requests.get(
            f"{PROMETHEUS_URL}/api/v1/query",
            params={"query": query},
            timeout=10
        )
        data = response.json()
        if data['status'] == 'success':
            results = data['data']['result']
            if results:
                return float(results[0]['value'][1])
        return None
    except Exception as e:
        logger.error(f"Prometheus query error: {str(e)}")
        return None

def query_prometheus_range(query, start, end):
    """Execute PromQL range query"""
    try:
        response = requests.get(
            f"{PROMETHEUS_URL}/api/v1/query_range",
            params={
                "query": query,
                "start": start,
                "end": end,
                "step": "60s"
            },
            timeout=10
        )
        data = response.json()
        if data['status'] == 'success':
            return data['data']['result']
        return []
    except Exception as e:
        logger.error(f"Prometheus range error: {str(e)}")
        return []

def get_metrics(service, time_window):
    """
    Get relevant metrics for a service
    Returns formatted metrics string
    """
    try:
        logger.info(f"Getting metrics for: {service}")

        # Error rate
        error_rate = query_prometheus(
            f'sum(rate(flask_http_request_total'
            f'{{status=~"5.."}}[5m])) * 100'
        )

        # Request rate
        request_rate = query_prometheus(
            f'sum(rate(flask_http_request_total[5m]))'
        )

        # Availability
        availability = query_prometheus(
            'jewelhub:availability:ratio5m * 100'
        )

        # P95 latency
        p95_latency = query_prometheus(
            'jewelhub:latency:p95 * 1000'
        )

        # P99 latency
        p99_latency = query_prometheus(
            'jewelhub:latency:p99 * 1000'
        )

        # Burn rate
        burn_rate = query_prometheus(
            'jewelhub:burn_rate:1h'
        )

        # Pod restarts
        pod_restarts = query_prometheus(
            f'sum(kube_pod_container_status_restarts_total'
            f'{{namespace="jewelhub"}})'
        )

        metrics = {
            "error_rate": f"{error_rate:.2f}%" if error_rate else "N/A",
            "request_rate": f"{request_rate:.2f} req/s" if request_rate else "N/A",
            "availability": f"{availability:.3f}%" if availability else "N/A",
            "p95_latency": f"{p95_latency:.0f}ms" if p95_latency else "N/A",
            "p99_latency": f"{p99_latency:.0f}ms" if p99_latency else "N/A",
            "burn_rate": f"{burn_rate:.2f}x" if burn_rate else "N/A",
            "pod_restarts": f"{pod_restarts:.0f}" if pod_restarts else "N/A"
        }

        logger.info(f"Metrics collected: {metrics}")
        return metrics

    except Exception as e:
        logger.error(f"Error getting metrics: {str(e)}")
        return {}