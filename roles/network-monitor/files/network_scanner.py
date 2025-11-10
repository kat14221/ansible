#!/usr/bin/env python3
"""
🔍 Network Scanner - Módulo de detección de dispositivos IPv6
Utiliza ping6, nmap, y ARP scanning para detectar dispositivos activos
"""

import subprocess
import socket
import ipaddress
import re
from datetime import datetime
import logging

logger = logging.getLogger(__name__)

class NetworkScanner:
    """Escaner de red para IPv6"""
    
    def __init__(self, interface='ens192', subnet='2025:db8:101::/64'):
        self.interface = interface
        self.subnet = subnet
        self.network = ipaddress.ip_network(subnet, strict=False)
        self.devices = []
        
    def scan_devices(self):
        """Escanear toda la red y retornar dispositivos activos"""
        logger.info(f"🔍 Escaneando subnet: {self.subnet}")
        
        devices = []
        
        # Método 1: Ping a direcciones conocidas
        known_hosts = [
            ('2025:db8:101::1', 'debian-router'),
            ('2025:db8:101::2', 'physical-router'),
            ('2025:db8:101::10', 'ubuntu-pc'),
            ('2025:db8:101::11', 'windows-pc'),
        ]
        
        for ipv6, hostname in known_hosts:
            if self._is_reachable(ipv6):
                device = self._get_device_info(ipv6, hostname)
                devices.append(device)
                logger.info(f"✅ Dispositivo detectado: {hostname} ({ipv6})")
        
        # Método 2: Escaneo con nmap (si está disponible)
        try:
            nmap_devices = self._nmap_scan()
            for device in nmap_devices:
                if device not in devices:
                    devices.append(device)
                    logger.info(f"✅ Dispositivo detectado (nmap): {device['hostname']} ({device['ipv6']})")
        except Exception as e:
            logger.warning(f"⚠️  nmap no disponible: {str(e)}")
        
        # Método 3: Escaneo de rango (lento pero exhaustivo)
        try:
            range_devices = self._range_scan()
            for device in range_devices:
                if device not in devices:
                    devices.append(device)
        except Exception as e:
            logger.warning(f"⚠️  Escaneo de rango incompleto: {str(e)}")
        
        self.devices = devices
        logger.info(f"📊 Total de dispositivos encontrados: {len(devices)}")
        return devices
    
    def _is_reachable(self, ipv6):
        """Verificar si un dispositivo responde a ping"""
        try:
            result = subprocess.run(
                ['ping6', '-c', '1', '-W', '2', ipv6],
                capture_output=True,
                timeout=5
            )
            return result.returncode == 0
        except:
            return False
    
    def _get_device_info(self, ipv6, hostname=None):
        """Obtener información de un dispositivo"""
        # Intentar resolver hostname si no se proporciona
        if not hostname:
            hostname = self._resolve_hostname(ipv6)
        
        # Obtener MAC
        mac = self._get_mac_address(ipv6)
        
        # Detectar OS
        os_type = self._detect_os(ipv6)
        
        device = {
            'ipv6': ipv6,
            'hostname': hostname or f"host-{ipv6[-2:]}",
            'mac': mac or 'N/A',
            'status': 'online',
            'last_seen': datetime.now().isoformat(),
            'os': os_type,
            'interface': self.interface,
            'response_time': self._measure_latency(ipv6)
        }
        
        return device
    
    def _resolve_hostname(self, ipv6):
        """Resolver hostname desde IPv6 (reverse DNS)"""
        try:
            hostname, _, _ = socket.gethostbyaddr(ipv6)
            return hostname
        except:
            return None
    
    def _get_mac_address(self, ipv6):
        """Obtener dirección MAC"""
        try:
            # Usar ip -6 neigh para obtener MAC
            result = subprocess.run(
                ['ip', '-6', 'neigh', 'show', ipv6],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            # Parsear salida: "2025:db8:101::10 dev ens192 lladdr aa:bb:cc:dd:ee:ff"
            match = re.search(r'lladdr\s+([\da-f:]+)', result.stdout)
            if match:
                return match.group(1).upper()
        except:
            pass
        
        return None
    
    def _detect_os(self, ipv6):
        """Detectar sistema operativo"""
        try:
            result = subprocess.run(
                ['ping6', '-c', '1', ipv6],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            output = result.stdout + result.stderr
            
            # Heurísticas simples basadas en TTL/Hop Limit
            if 'ttl=' in output.lower():
                ttl = re.search(r'ttl[=\s]+(\d+)', output, re.IGNORECASE)
                if ttl:
                    ttl_val = int(ttl.group(1))
                    if ttl_val == 64:
                        return 'Linux'
                    elif ttl_val == 128:
                        return 'Windows'
                    elif ttl_val == 255:
                        return 'Cisco'
            
            # Por defecto
            return 'Unknown'
        except:
            return 'Unknown'
    
    def _measure_latency(self, ipv6):
        """Medir latencia (tiempo de respuesta)"""
        try:
            result = subprocess.run(
                ['ping6', '-c', '1', '-W', '5', ipv6],
                capture_output=True,
                text=True,
                timeout=10
            )
            
            match = re.search(r'time[=\s]+([\d.]+)\s*ms', result.stdout)
            if match:
                return float(match.group(1))
        except:
            pass
        
        return None
    
    def _nmap_scan(self):
        """Escaneo con nmap (si está disponible)"""
        devices = []
        try:
            result = subprocess.run(
                ['nmap', '-6', '-sn', '-PE', '--send-ip', self.subnet],
                capture_output=True,
                text=True,
                timeout=30
            )
            
            # Parsear direcciones IPv6
            ipv6_addresses = re.findall(r'(2025:db8:101::\S+)', result.stdout)
            
            for ipv6 in ipv6_addresses:
                if self._is_reachable(ipv6):
                    device = self._get_device_info(ipv6)
                    devices.append(device)
        except Exception as e:
            logger.warning(f"nmap error: {str(e)}")
        
        return devices
    
    def _range_scan(self):
        """Escaneo de rango (primeras 256 direcciones)"""
        devices = []
        
        # Limitar a las primeras 256 IPs (no es exhaustivo pero es rápido)
        try:
            for i in range(1, 257):
                ipv6 = f"2025:db8:101::{hex(i)[2:]}"  # Convertir a hex
                
                if self._is_reachable(ipv6):
                    device = self._get_device_info(ipv6)
                    devices.append(device)
        except Exception as e:
            logger.warning(f"Range scan error: {str(e)}")
        
        return devices
    
    def get_device_details(self, ipv6):
        """Obtener detalles extendidos de un dispositivo"""
        details = {
            'ipv6': ipv6,
            'connectivity': {
                'reachable': self._is_reachable(ipv6),
                'latency_ms': self._measure_latency(ipv6)
            },
            'network': {
                'mac': self._get_mac_address(ipv6),
                'os': self._detect_os(ipv6)
            },
            'timestamps': {
                'scanned_at': datetime.now().isoformat()
            }
        }
        return details
    
    def parse_ping_output(self, output):
        """Parsear salida de ping para extraer estadísticas"""
        stats = {}
        
        try:
            # Buscar línea de estadísticas: "4 packets transmitted, 4 received"
            match = re.search(
                r'(\d+) packets? transmitted, (\d+) received, ([\d.]+)% packet loss',
                output
            )
            if match:
                stats['transmitted'] = int(match.group(1))
                stats['received'] = int(match.group(2))
                stats['loss_percent'] = float(match.group(3))
            
            # Buscar tiempos: "min/avg/max/stddev = 0.123/0.456/0.789/0.100 ms"
            match = re.search(
                r'min/avg/max(?:/stddev)?[/=\s]+([\d.]+)/([\d.]+)/([\d.]+)',
                output
            )
            if match:
                stats['min_ms'] = float(match.group(1))
                stats['avg_ms'] = float(match.group(2))
                stats['max_ms'] = float(match.group(3))
        except:
            pass
        
        return stats
    
    @staticmethod
    def is_valid_ipv6(ipv6):
        """Validar si es una dirección IPv6 válida"""
        try:
            ipaddress.ipv6_address(ipv6)
            return True
        except:
            return False
