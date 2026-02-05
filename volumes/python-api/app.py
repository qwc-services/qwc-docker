from flask import Flask, request, jsonify
from flask_cors import CORS
import psycopg2
import time
from datetime import datetime

app = Flask(__name__)
CORS(app, origins=["http://localhost:8088"])

# Configuration de la BD

DB_CONFIG = {
    'host': 'qwc-postgis',
    'database': 'qwc_services',
    'user': 'qwc_service_write',
    'password': 'qwc_service_write',
    'options': '-c search_path=qwc_geodb,public'  # Spécification du schema
}

def get_db_connection():
    """Crée une connexion à la base de données"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        return conn
    except Exception as e:
        print(f"Database connection error: {e}")
        raise

@app.route('/api/wizard/submit', methods=['POST'])
def submit_wizard():
    """Endpoint pour recevoir les données du wizard et les sauvegarder en DB"""
    
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
    
    try:
        # Connexion à la base de données
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Insérer les données
        cursor.execute("""
            INSERT INTO wizard_submissions (name, email, preference, created_at)
            VALUES (%s, %s, %s, NOW())
            RETURNING id, created_at
        """, (data['name'], data['email'], data['preference']))
        
        # Récupérer l'ID et la date de création
        new_id, created_at = cursor.fetchone()
        
        conn.commit()
        cursor.close()
        conn.close()
        
        # Log pour debug
        print(f"[{datetime.now()}] Saved submission ID {new_id}: {data}")
        
        # Retourner la réponse
        return jsonify({
            'success': True,
            'message': 'Data saved successfully',
            'data': {
                'id': new_id,
                'name': data['name'],
                'email': data['email'],
                'preference': data['preference'],
                'created_at': created_at.isoformat()
            },
            'timestamp': datetime.now().isoformat()
        }), 200
        
    except Exception as e:
        print(f"Database error: {e}")
        return jsonify({
            'success': False,
            'error': f'Database error: {str(e)}'
        }), 500

@app.route('/api/wizard/submissions', methods=['GET'])
def get_submissions():
    """Endpoint pour récupérer toutes les soumissions"""
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Récupérer les 50 dernières soumissions
        cursor.execute("""
            SELECT id, name, email, preference, created_at
            FROM wizard_submissions
            ORDER BY created_at DESC
            LIMIT 50
        """)
        
        rows = cursor.fetchall()
        
        submissions = []
        for row in rows:
            submissions.append({
                'id': row[0],
                'name': row[1],
                'email': row[2],
                'preference': row[3],
                'created_at': row[4].isoformat()
            })
        
        cursor.close()
        conn.close()
        
        return jsonify({
            'success': True,
            'count': len(submissions),
            'submissions': submissions
        }), 200
        
    except Exception as e:
        print(f"Database error: {e}")
        return jsonify({
            'success': False,
            'error': f'Database error: {str(e)}'
        }), 500

@app.route('/api/wizard/stats', methods=['GET'])
def get_stats():
    """Endpoint pour récupérer les statistiques"""
    
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Utiliser la vue créée dans le DDL
        cursor.execute("SELECT * FROM wizard_submissions_stats")
        
        rows = cursor.fetchall()
        
        stats = []
        for row in rows:
            stats.append({
                'preference': row[0],
                'count': row[1],
                'percentage': float(row[2])
            })
        
        cursor.close()
        conn.close()
        
        return jsonify({
            'success': True,
            'stats': stats
        }), 200
        
    except Exception as e:
        print(f"Database error: {e}")
        return jsonify({
            'success': False,
            'error': f'Database error: {str(e)}'
        }), 500

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint with DB test"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM wizard_submissions")
        count = cursor.fetchone()[0]
        cursor.close()
        conn.close()
        
        return jsonify({
            'status': 'healthy',
            'service': 'QWC Wizard API',
            'database': 'connected',
            'total_submissions': count,
            'timestamp': datetime.now().isoformat()
        }), 200
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'service': 'QWC Wizard API',
            'database': 'error',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)