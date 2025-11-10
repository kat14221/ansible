#!/usr/bin/env python3
"""
🖥️  Network Monitor Dashboard
Monitoreo visual de dispositivos en la red IPv6 2025:db8:101::/64
Autor: Proyecto VMWARE-101001
Versión: 1.0
"""

import os
import json
import subprocess
from datetime import datetime, timedelta
from flask import Flask, render_template, jsonify, request
from flask_cors import CORS
import logging
from network_scanner import NetworkScanner

# Configuración
app = Flask(__name__)
CORS(app)
app.config['JSON_AS_ASCII'] = False
app.config['JSON_SORT_KEYS'] = False

# Setup logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/var/log/network-monitor/app.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)

# Variables globales
scanner = NetworkScanner(interface='ens192', subnet='2025:db8:101::/64')
last_scan = None
devices_cache = []

# ============================================================================
# RUTAS API
# ============================================================================

@app.route('/')
def index():
    """Página principal del dashboard"""
    return render_template('index.html')

@app.route('/api/scan', methods=['GET'])
def api_scan():
    """Realizar escaneo de dispositivos en tiempo real"""
    global last_scan, devices_cache
    
    try:
        logger.info("🔍 Iniciando escaneo de dispositivos...")
        devices = scanner.scan_devices()
        last_scan = datetime.now()
        devices_cache = devices
        
        logger.info(f"✅ Escaneo completado. Dispositivos encontrados: {len(devices)}")
        
        return jsonify({
            'status': 'success',
            'timestamp': last_scan.isoformat(),
            'device_count': len(devices),
            'devices': devices
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Error en escaneo: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/devices', methods=['GET'])
def api_devices():
    """Obtener lista de dispositivos (caché o escaneo)"""
    if not devices_cache or (last_scan and datetime.now() - last_scan > timedelta(minutes=5)):
        # Hacer nuevo escaneo si la caché está vacía o es más vieja de 5 minutos
        return api_scan()
    
    return jsonify({
        'status': 'success',
        'timestamp': last_scan.isoformat() if last_scan else None,
        'device_count': len(devices_cache),
        'devices': devices_cache,
        'from_cache': True
    }), 200

@app.route('/api/device/<ipv6>', methods=['GET'])
def api_device_detail(ipv6):
    """Obtener detalles de un dispositivo específico"""
    device = next((d for d in devices_cache if d['ipv6'] == ipv6), None)
    
    if not device:
        return jsonify({
            'status': 'error',
            'message': f'Dispositivo no encontrado: {ipv6}'
        }), 404
    
    # Obtener información adicional
    try:
        device['details'] = scanner.get_device_details(ipv6)
    except Exception as e:
        device['details'] = {'error': str(e)}
    
    return jsonify({
        'status': 'success',
        'device': device
    }), 200

@app.route('/api/ssh/<ipv6>', methods=['POST'])
def api_ssh(ipv6):
    """Generar comando SSH para conectar a un dispositivo"""
    user = request.json.get('user', 'ansible')
    
    try:
        # Validar IPv6
        if not scanner.is_valid_ipv6(ipv6):
            return jsonify({
                'status': 'error',
                'message': 'IPv6 inválido'
            }), 400
        
        # Generar comando SSH
        ssh_command = f'ssh -6 {user}@{ipv6}'
        
        # En producción, podrías usar paramiko para SSH remoto
        logger.info(f"🔐 Comando SSH generado para {ipv6}")
        
        return jsonify({
            'status': 'success',
            'ssh_command': ssh_command,
            'user': user,
            'host': ipv6,
            'help': 'Ejecuta este comando en tu terminal para conectar'
        }), 200
        
    except Exception as e:
        logger.error(f"❌ Error generando comando SSH: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/ping/<ipv6>', methods=['GET'])
def api_ping(ipv6):
    """Hacer ping a un dispositivo IPv6"""
    try:
        result = subprocess.run(
            ['ping6', '-c', '4', ipv6],
            capture_output=True,
            timeout=10,
            text=True
        )
        
        if result.returncode == 0:
            return jsonify({
                'status': 'success',
                'reachable': True,
                'output': result.stdout,
                'latency_info': scanner.parse_ping_output(result.stdout)
            }), 200
        else:
            return jsonify({
                'status': 'success',
                'reachable': False,
                'output': result.stderr
            }), 200
            
    except Exception as e:
        logger.error(f"❌ Error en ping: {str(e)}")
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/api/stats', methods=['GET'])
def api_stats():
    """Estadísticas de la red"""
    try:
        stats = {
            'timestamp': datetime.now().isoformat(),
            'total_devices': len(devices_cache),
            'last_scan': last_scan.isoformat() if last_scan else None,
            'subnet': '2025:db8:101::/64',
            'interface': 'ens192',
            'devices_by_type': _categorize_devices(),
            'gateway': {
                'ipv6': '2025:db8:101::1',
                'hostname': 'debian-router'
            }
        }
        return jsonify(stats), 200
    except Exception as e:
        logger.error(f"❌ Error obteniendo estadísticas: {str(e)}")
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/api/export', methods=['GET'])
def api_export():
    """Exportar dispositivos en formato JSON"""
    format_type = request.args.get('format', 'json').lower()
    
    try:
        if format_type == 'json':
            return jsonify({
                'timestamp': datetime.now().isoformat(),
                'devices': devices_cache
            }), 200
        elif format_type == 'csv':
            csv_data = _export_csv()
            return csv_data, 200, {'Content-Disposition': 'attachment; filename=devices.csv'}
        else:
            return jsonify({'status': 'error', 'message': 'Formato no soportado'}), 400
    except Exception as e:
        logger.error(f"❌ Error en exportación: {str(e)}")
        return jsonify({'status': 'error', 'message': str(e)}), 500

@app.route('/api/config', methods=['GET'])
def api_config():
    """Obtener configuración del monitor"""
    return jsonify({
        'status': 'success',
        'monitor_config': {
            'subnet': '2025:db8:101::/64',
            'interface': 'ens192',
            'scan_interval': 300,  # 5 minutos
            'timeout': 10,
            'retries': 3
        },
        'gateway': {
            'ipv6': '2025:db8:101::1',
            'hostname': 'debian-router',
            'ipv4_management': '172.17.25.126'
        }
    }), 200

# ============================================================================
# FUNCIONES AUXILIARES
# ============================================================================

def _categorize_devices():
    """Categorizar dispositivos por tipo"""
    categories = {
        'gateway': [],
        'linux': [],
        'windows': [],
        'unknown': []
    }
    
    for device in devices_cache:
        if '101::1' in device['ipv6']:
            categories['gateway'].append(device)
        elif 'Linux' in device.get('os', ''):
            categories['linux'].append(device)
        elif 'Windows' in device.get('os', ''):
            categories['windows'].append(device)
        else:
            categories['unknown'].append(device)
    
    return {k: len(v) for k, v in categories.items()}

def _export_csv():
    """Exportar a CSV"""
    import csv
    from io import StringIO
    
    output = StringIO()
    writer = csv.writer(output)
    writer.writerow(['IPv6', 'Hostname', 'MAC', 'Estado', 'Última Visto'])
    
    for device in devices_cache:
        writer.writerow([
            device['ipv6'],
            device.get('hostname', 'N/A'),
            device.get('mac', 'N/A'),
            device['status'],
            device.get('last_seen', 'N/A')
        ])
    
    return output.getvalue()

# ============================================================================
# ERROR HANDLERS
# ============================================================================

@app.errorhandler(404)
def not_found(error):
    return jsonify({'status': 'error', 'message': 'Recurso no encontrado'}), 404

@app.errorhandler(500)
def server_error(error):
    logger.error(f"❌ Error del servidor: {str(error)}")
    return jsonify({'status': 'error', 'message': 'Error interno del servidor'}), 500

# ============================================================================
# MAIN
# ============================================================================

if __name__ == '__main__':
    logger.info("🚀 Iniciando Network Monitor Dashboard...")
    logger.info("📊 Escucha en http://0.0.0.0:5000")
    logger.info("🔍 Red monitorizada: 2025:db8:101::/64")
    
    # Crear directorio de logs si no existe
    os.makedirs('/var/log/network-monitor', exist_ok=True)
    
    # Ejecutar en modo desarrollo (cambiar debug=False en producción)
    app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)
