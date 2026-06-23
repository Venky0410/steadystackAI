from flask import Flask, request, jsonify
from webhook import handle_alert
from prometheus_client import get_metrics
from elastic_client import get_logs
from claude_client import analyze_incident
from postmortem import format_postmortem
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "healthy"}), 200

@app.route('/webhook', methods=['POST'])
def webhook():
    try:
        # Step 1 - Receive alert
        alert_data = request.json
        logger.info(f"Alert received: {alert_data}")

        # Step 2 - Parse alert
        alerts = handle_alert(alert_data)
        if not alerts:
            return jsonify({"status": "no alerts"}), 200

        results = []
        for alert in alerts:
            logger.info(f"Processing: {alert['name']}")

            # Step 3 - Get metrics
            metrics = get_metrics(
                alert['service'],
                alert['time_window']
            )

            # Step 4 - Get logs
            logs = get_logs(
                alert['service'],
                alert['time_window']
            )

            # Step 5 - Analyze with Claude
            analysis = analyze_incident(
                alert,
                metrics,
                logs
            )

            # Step 6 - Format postmortem
            postmortem = format_postmortem(
                alert,
                analysis
            )

            results.append({
                "alert": alert['name'],
                "analysis": analysis,
                "postmortem": postmortem
            })

            logger.info(f"✅ Analysis complete: {alert['name']}")

        return jsonify({
            "status": "success",
            "results": results
        }), 200

    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route('/incidents', methods=['GET'])
def incidents():
    return jsonify({
        "message": "Incident history coming soon!"
    }), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=False)