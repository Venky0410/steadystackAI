import logging
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)

def handle_alert(alert_data):
    """
    Parse Prometheus Alertmanager webhook payload
    Returns list of processed alerts
    """
    try:
        alerts = []

        raw_alerts = alert_data.get('alerts', [])

        for alert in raw_alerts:
            # Only process firing alerts
            if alert.get('status') != 'firing':
                continue

            # Get labels FIRST
            labels = alert.get('labels', {})
            annotations = alert.get('annotations', {})

            # THEN check alert name
            alert_name = labels.get('alertname', '')
            skip_alerts = [
                'Watchdog',
                'InfoInhibitor',
                'KubeSchedulerDown',
                'KubeControllerManagerDown'
            ]
            if alert_name in skip_alerts:
                logger.info(
                    f"Skipping: {alert_name}"
                )
                continue

            # Extract service name
            service = (
                labels.get('service') or
                labels.get('app') or
                labels.get('job') or
                'unknown'
            )

            # Extract alert name
            name = labels.get(
                'alertname',
                'UnknownAlert'
            )

            # Extract severity
            severity = labels.get(
                'severity',
                'warning'
            )

            # Set time window (30 mins back)
            end_time = datetime.utcnow()
            start_time = end_time - timedelta(minutes=30)

            processed_alert = {
                "name": name,
                "service": service,
                "severity": severity,
                "description": annotations.get(
                    'description', ''
                ),
                "summary": annotations.get(
                    'summary', ''
                ),
                "time_window": {
                    "start": start_time.isoformat(),
                    "end": end_time.isoformat(),
                    "duration_mins": 30
                },
                "labels": labels,
                "raw": alert
            }

            alerts.append(processed_alert)
            logger.info(
                f"Parsed alert: {name} "
                f"for service: {service}"
            )

        return alerts

    except Exception as e:
        logger.error(f"Error parsing alert: {str(e)}")
        return []