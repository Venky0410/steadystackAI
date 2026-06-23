import logging
import os
import httpx
import anthropic

logger = logging.getLogger(__name__)

CLAUDE_API_KEY = os.getenv('CLAUDE_API_KEY', '')

def analyze_incident(alert, metrics, logs):
    try:
        logger.info(f"Sending to Claude: {alert['name']}")

        log_summary = "\n".join(
            logs.get('sample_logs', [])[:5]
        ) or "No error logs found"

        metrics_summary = "\n".join([
            f"- {k}: {v}"
            for k, v in metrics.items()
        ]) if metrics else "No metrics available"

        prompt = f"""You are an expert SRE analyzing
a production incident for JewelHub,
a microservices e-commerce application
running on AWS EKS.

## Alert Details
- Alert Name: {alert['name']}
- Service: {alert['service']}
- Severity: {alert['severity']}
- Summary: {alert.get('summary', 'N/A')}
- Description: {alert.get('description', 'N/A')}
- Time Window: Last {alert['time_window']['duration_mins']} minutes

## Current Metrics
{metrics_summary}

## Recent Error Logs ({logs.get('total_errors', 0)} total errors)
{log_summary}

## JewelHub Services
- frontend (port 5000)
- product-service (port 5001)
- cart-service (port 5002)
- order-service (port 5003)
- user-service (port 5004)
- notification-service (port 5005)

Please provide:
1. ROOT CAUSE
2. IMPACT ASSESSMENT
3. IMMEDIATE ACTIONS (kubectl commands)
4. INVESTIGATION STEPS
5. POSTMORTEM SUMMARY

Be concise and actionable."""

        http_client = httpx.Client(
            timeout=60.0,
            follow_redirects=True
        )

        client = anthropic.Anthropic(
            api_key=CLAUDE_API_KEY,
            http_client=http_client
        )

        response = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=1000,
            messages=[
                {
                    "role": "user",
                    "content": prompt
                }
            ]
        )

        analysis = response.content[0].text
        logger.info("✅ Claude analysis complete!")
        return analysis

    except Exception as e:
        logger.error(f"Claude API error: {str(e)}")
        return f"Analysis failed: {str(e)}"