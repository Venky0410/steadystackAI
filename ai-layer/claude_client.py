import anthropic
import logging
import os

logger = logging.getLogger(__name__)

CLAUDE_API_KEY = os.getenv('CLAUDE_API_KEY', '')

def analyze_incident(alert, metrics, logs):
    """
    Send incident data to Claude for analysis
    Returns structured incident analysis
    """
    try:
        logger.info(
            f"Sending to Claude: {alert['name']}"
        )
        
        client = anthropic.Anthropic(
            api_key=CLAUDE_API_KEY,
        )

        message = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=1000,
            messages=[
                {
                    "role": "user",
                    "content": prompt
                }
            ]
        )
        
        # Build log summary
        log_summary = ""
        if logs.get('sample_logs'):
            log_summary = "\n".join(
                logs['sample_logs'][:5]
            )
        else:
            log_summary = "No error logs found"

        # Build prompt
        prompt = f"""You are an expert SRE analyzing 
a production incident for JewelHub, 
a microservices e-commerce application 
running on AWS EKS.

## Alert Details
- Alert Name: {alert['name']}
- Service: {alert['service']}
- Severity: {alert['severity']}
- Summary: {alert['summary']}
- Description: {alert['description']}
- Time Window: Last {alert['time_window']['duration_mins']} minutes

## Current Metrics
- Error Rate: {metrics.get('error_rate', 'N/A')}
- Request Rate: {metrics.get('request_rate', 'N/A')}
- Availability: {metrics.get('availability', 'N/A')}
- P95 Latency: {metrics.get('p95_latency', 'N/A')}
- P99 Latency: {metrics.get('p99_latency', 'N/A')}
- Burn Rate: {metrics.get('burn_rate', 'N/A')}
- Pod Restarts: {metrics.get('pod_restarts', 'N/A')}

## Recent Error Logs ({logs.get('total_errors', 0)} total errors)
{log_summary}

## JewelHub Services
- frontend (port 5000)
- product-service (port 5001)
- cart-service (port 5002)
- order-service (port 5003)
- user-service (port 5004)
- notification-service (port 5005)

Please provide a structured incident analysis with:

1. ROOT CAUSE
   What most likely caused this alert?

2. IMPACT ASSESSMENT
   What is the user impact?
   How many requests affected?

3. IMMEDIATE ACTIONS
   Specific kubectl commands to run now

4. INVESTIGATION STEPS
   What to check next

5. POSTMORTEM SUMMARY
   Brief summary for the postmortem doc

Keep response concise and actionable.
Focus on specific commands and steps."""

        message = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=1000,
            messages=[
                {
                    "role": "user",
                    "content": prompt
                }
            ]
        )

        analysis = message.content[0].text
        logger.info("✅ Claude analysis complete!")
        return analysis

    except Exception as e:
        logger.error(
            f"Claude API error: {str(e)}"
        )
        return f"Analysis failed: {str(e)}"