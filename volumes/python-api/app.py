from flask import Flask, request, jsonify
from flask_cors import CORS
import time
from datetime import datetime

app = Flask(__name__)
# IMPORTANT: Autoriser les requêtes depuis le viewer
CORS(app, origins=["http://localhost:8088"])

@app.route('/api/wizard/submit', methods=['POST'])
def submit_wizard():
    """Endpoint pour recevoir les données du wizard"""
    
    # Simuler un traitement (optionnel)
    time.sleep(1)
    
    # Récupérer les données du POST
    data = request.get_json()
    
    # Valider les données
    if not data.get('name'):
        return jsonify({
            'success': False,
            'error': 'Name is required'
        }), 400
    
    if not data.get('email'):
        return jsonify({
            'success': False,
            'error': 'Email is required'
        }), 400
    
    # Traiter les données (ici on simule)
    result = {
        'success': True,
        'message': 'Data received successfully',
        'data': data,
        'timestamp': datetime.now().isoformat(),
        'processed_by': 'Python Flask API'
    }
    
    # Log pour debug
    print(f"[{datetime.now()}] Received data: {data}")
    
    return jsonify(result), 200

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'QWC Wizard API',
        'timestamp': datetime.now().isoformat()
    }), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)