/**
 * Network Monitor Dashboard - Frontend JavaScript
 * Gestiona interacciones, escaneos y actualización de UI
 */

const API_BASE = '/api';
let devices = [];
let autoRefreshInterval = null;
let isScanning = false;

// Elementos del DOM
const btnScan = document.getElementById('btn-scan');
const btnRefresh = document.getElementById('btn-refresh');
const btnExport = document.getElementById('btn-export');
const btnClearSearch = document.getElementById('btn-clear-search');
const searchBox = document.getElementById('search-box');
const devicesTable = document.getElementById('devices-table');
const devicesTbody = document.getElementById('devices-tbody');
const statusBadge = document.getElementById('status-badge');

// Modales
const sshModal = new bootstrap.Modal(document.getElementById('sshModal'));
const detailsModal = new bootstrap.Modal(document.getElementById('detailsModal'));

// ============================================================================
// EVENTOS
// ============================================================================

document.addEventListener('DOMContentLoaded', () => {
    console.log('🚀 Network Monitor Dashboard iniciado');
    setupEventListeners();
    loadDevices();
});

function setupEventListeners() {
    btnScan.addEventListener('click', scanNetwork);
    btnRefresh.addEventListener('click', toggleAutoRefresh);
    btnExport.addEventListener('click', exportDevices);
    btnClearSearch.addEventListener('click', () => {
        searchBox.value = '';
        filterDevices('');
    });
    searchBox.addEventListener('input', (e) => filterDevices(e.target.value));
    
    // Modal SSH - actualizar comando cuando cambia usuario
    document.getElementById('ssh-user').addEventListener('change', updateSSHCommand);
    document.getElementById('btn-copy-ssh').addEventListener('click', copyToClipboard);
}

// ============================================================================
// FUNCIONES PRINCIPALES
// ============================================================================

async function scanNetwork() {
    if (isScanning) {
        showNotification('⏳ Ya hay un escaneo en progreso...', 'warning');
        return;
    }

    isScanning = true;
    btnScan.disabled = true;
    btnScan.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Escaneando...';

    try {
        const response = await fetch(`${API_BASE}/scan`);
        const data = await response.json();

        if (data.status === 'success') {
            devices = data.devices;
            renderDevices();
            updateStats();
            showNotification(`✅ Escaneo completado: ${data.device_count} dispositivos encontrados`, 'success');
        } else {
            showNotification(`❌ Error en escaneo: ${data.message}`, 'danger');
        }
    } catch (error) {
        console.error('Error:', error);
        showNotification('❌ Error al escanear la red', 'danger');
    } finally {
        isScanning = false;
        btnScan.disabled = false;
        btnScan.innerHTML = '<i class="bi bi-arrow-repeat"></i> Escanear Red';
    }
}

async function loadDevices() {
    try {
        const response = await fetch(`${API_BASE}/devices`);
        const data = await response.json();

        if (data.status === 'success') {
            devices = data.devices;
            renderDevices();
            updateStats();
        }
    } catch (error) {
        console.error('Error cargando dispositivos:', error);
    }
}

function renderDevices() {
    if (devices.length === 0) {
        devicesTbody.innerHTML = `
            <tr>
                <td colspan="8" class="text-center text-muted py-4">
                    <i class="bi bi-inbox"></i> No hay dispositivos para mostrar
                </td>
            </tr>
        `;
        return;
    }

    devicesTbody.innerHTML = devices.map((device, index) => `
        <tr class="fade-in">
            <td><strong>${index + 1}</strong></td>
            <td>
                <strong>${device.hostname}</strong>
                ${device.os ? `<br><small class="text-muted">${device.os}</small>` : ''}
            </td>
            <td>
                <code>${device.ipv6}</code>
                <br>
                <small class="text-muted">${device.mac || 'N/A'}</small>
            </td>
            <td>${device.mac || '--'}</td>
            <td>${device.os || '?'}</td>
            <td>
                ${formatLatency(device.response_time)}
            </td>
            <td>
                <span class="badge ${device.status === 'online' ? 'badge-online' : 'badge-offline'}">
                    <i class="bi ${device.status === 'online' ? 'bi-check-circle' : 'bi-x-circle'}"></i>
                    ${device.status === 'online' ? 'En Línea' : 'Fuera'}
                </span>
            </td>
            <td>
                <button class="btn btn-sm btn-outline-primary" title="SSH" 
                    onclick="showSSHModal('${device.ipv6}', '${device.hostname}')">
                    <i class="bi bi-terminal"></i>
                </button>
                <button class="btn btn-sm btn-outline-info" title="Detalles"
                    onclick="showDetails('${device.ipv6}')">
                    <i class="bi bi-info-circle"></i>
                </button>
                <button class="btn btn-sm btn-outline-success" title="Ping"
                    onclick="pingDevice('${device.ipv6}')">
                    <i class="bi bi-activity"></i>
                </button>
            </td>
        </tr>
    `).join('');
}

function updateStats() {
    const total = devices.length;
    const online = devices.filter(d => d.status === 'online').length;
    const offline = total - online;

    document.getElementById('stat-total').textContent = total;
    document.getElementById('stat-online').textContent = online;
    document.getElementById('stat-offline').textContent = offline;
    document.getElementById('stat-updated').textContent = new Date().toLocaleTimeString('es-ES');

    // Actualizar badge de estado
    const allOnline = offline === 0 && total > 0;
    statusBadge.innerHTML = `
        <span class="badge ${allOnline ? 'bg-success' : 'bg-warning'}">
            <i class="bi ${allOnline ? 'bi-check-circle' : 'bi-exclamation-triangle'}"></i>
            ${allOnline ? 'Sistema Normal' : 'Dispositivos Offline'}
        </span>
    `;
}

function filterDevices(searchTerm) {
    const filtered = devices.filter(device => 
        device.hostname.toLowerCase().includes(searchTerm.toLowerCase()) ||
        device.ipv6.toLowerCase().includes(searchTerm.toLowerCase()) ||
        (device.mac && device.mac.toLowerCase().includes(searchTerm.toLowerCase()))
    );

    if (filtered.length === 0) {
        devicesTbody.innerHTML = `
            <tr>
                <td colspan="8" class="text-center text-muted py-4">
                    <i class="bi bi-search"></i> No se encontraron resultados para "${searchTerm}"
                </td>
            </tr>
        `;
        return;
    }

    devicesTbody.innerHTML = filtered.map((device, index) => `
        <tr class="fade-in">
            <td><strong>${index + 1}</strong></td>
            <td>
                <strong>${device.hostname}</strong>
                ${device.os ? `<br><small class="text-muted">${device.os}</small>` : ''}
            </td>
            <td>
                <code>${device.ipv6}</code>
                <br>
                <small class="text-muted">${device.mac || 'N/A'}</small>
            </td>
            <td>${device.mac || '--'}</td>
            <td>${device.os || '?'}</td>
            <td>
                ${formatLatency(device.response_time)}
            </td>
            <td>
                <span class="badge ${device.status === 'online' ? 'badge-online' : 'badge-offline'}">
                    <i class="bi ${device.status === 'online' ? 'bi-check-circle' : 'bi-x-circle'}"></i>
                    ${device.status === 'online' ? 'En Línea' : 'Fuera'}
                </span>
            </td>
            <td>
                <button class="btn btn-sm btn-outline-primary" title="SSH"
                    onclick="showSSHModal('${device.ipv6}', '${device.hostname}')">
                    <i class="bi bi-terminal"></i>
                </button>
                <button class="btn btn-sm btn-outline-info" title="Detalles"
                    onclick="showDetails('${device.ipv6}')">
                    <i class="bi bi-info-circle"></i>
                </button>
                <button class="btn btn-sm btn-outline-success" title="Ping"
                    onclick="pingDevice('${device.ipv6}')">
                    <i class="bi bi-activity"></i>
                </button>
            </td>
        </tr>
    `).join('');
}

async function showSSHModal(ipv6, hostname) {
    document.getElementById('ssh-device').textContent = `${hostname} (${ipv6})`;
    updateSSHCommand();
    sshModal.show();
}

function updateSSHCommand() {
    const ipv6 = document.getElementById('ssh-device').textContent.split('(')[1].replace(')', '');
    const user = document.getElementById('ssh-user').value;
    const command = `ssh -6 ${user}@${ipv6}`;
    document.getElementById('ssh-command').value = command;
}

function copyToClipboard() {
    const command = document.getElementById('ssh-command');
    command.select();
    document.execCommand('copy');
    showNotification('✅ Comando copiado al portapapeles', 'success');
}

async function showDetails(ipv6) {
    try {
        const response = await fetch(`${API_BASE}/device/${ipv6}`);
        const data = await response.json();

        if (data.status === 'success') {
            const device = data.device;
            const details = device.details || {};

            const html = `
                <div class="row">
                    <div class="col-md-6">
                        <h6>Información General</h6>
                        <table class="table table-sm">
                            <tr><td><strong>IPv6:</strong></td><td><code>${device.ipv6}</code></td></tr>
                            <tr><td><strong>Hostname:</strong></td><td>${device.hostname}</td></tr>
                            <tr><td><strong>MAC:</strong></td><td><code>${device.mac || 'N/A'}</code></td></tr>
                            <tr><td><strong>S.O.:</strong></td><td>${device.os || 'Desconocido'}</td></tr>
                            <tr><td><strong>Estado:</strong></td><td>
                                <span class="badge ${device.status === 'online' ? 'badge-online' : 'badge-offline'}">
                                    ${device.status === 'online' ? 'En Línea' : 'Fuera'}
                                </span>
                            </td></tr>
                        </table>
                    </div>
                    <div class="col-md-6">
                        <h6>Conectividad</h6>
                        <table class="table table-sm">
                            <tr><td><strong>Alcanzable:</strong></td><td>
                                ${details.connectivity?.reachable ? '✅ Sí' : '❌ No'}
                            </td></tr>
                            <tr><td><strong>Latencia:</strong></td><td>
                                ${details.connectivity?.latency_ms ? details.connectivity.latency_ms.toFixed(2) + ' ms' : 'N/A'}
                            </td></tr>
                            <tr><td><strong>Interfaz:</strong></td><td>${device.interface}</td></tr>
                            <tr><td><strong>Última visto:</strong></td><td>${device.last_seen}</td></tr>
                        </table>
                    </div>
                </div>
            `;

            document.getElementById('details-body').innerHTML = html;
            detailsModal.show();
        }
    } catch (error) {
        console.error('Error obteniendo detalles:', error);
        showNotification('❌ Error al obtener detalles', 'danger');
    }
}

async function pingDevice(ipv6) {
    try {
        const response = await fetch(`${API_BASE}/ping/${ipv6}`);
        const data = await response.json();

        if (data.status === 'success') {
            if (data.reachable) {
                const stats = data.latency_info;
                let message = `✅ Dispositivo alcanzable`;
                if (stats.avg_ms) {
                    message += ` - Latencia promedio: ${stats.avg_ms.toFixed(2)} ms`;
                }
                showNotification(message, 'success');
            } else {
                showNotification('❌ Dispositivo no responde', 'danger');
            }
        }
    } catch (error) {
        console.error('Error en ping:', error);
        showNotification('❌ Error al hacer ping', 'danger');
    }
}

function toggleAutoRefresh() {
    if (autoRefreshInterval) {
        clearInterval(autoRefreshInterval);
        autoRefreshInterval = null;
        btnRefresh.textContent = '🔄 Auto Refresh (OFF)';
        btnRefresh.classList.remove('btn-danger');
        btnRefresh.classList.add('btn-success');
        showNotification('⏸️ Auto-actualización desactivada', 'info');
    } else {
        autoRefreshInterval = setInterval(loadDevices, 30000); // 30 segundos
        btnRefresh.textContent = '⏹️ Auto Refresh (ON)';
        btnRefresh.classList.add('btn-danger');
        btnRefresh.classList.remove('btn-success');
        showNotification('▶️ Auto-actualización activada (cada 30s)', 'info');
    }
}

function exportDevices() {
    try {
        const data = {
            timestamp: new Date().toISOString(),
            subnet: '2025:db8:101::/64',
            device_count: devices.length,
            devices: devices
        };

        const json = JSON.stringify(data, null, 2);
        const blob = new Blob([json], { type: 'application/json' });
        const url = URL.createObjectURL(blob);
        const a = document.createElement('a');
        a.href = url;
        a.download = `network-devices-${new Date().getTime()}.json`;
        document.body.appendChild(a);
        a.click();
        document.body.removeChild(a);
        URL.revokeObjectURL(url);

        showNotification(`✅ Exportados ${devices.length} dispositivos`, 'success');
    } catch (error) {
        console.error('Error exportando:', error);
        showNotification('❌ Error al exportar', 'danger');
    }
}

// ============================================================================
// UTILIDADES
// ============================================================================

function formatLatency(latency) {
    if (!latency) return '<span class="text-muted">--</span>';

    let cssClass = 'latency-excellent';
    if (latency > 100) cssClass = 'latency-poor';
    else if (latency > 50) cssClass = 'latency-fair';
    else if (latency > 20) cssClass = 'latency-good';

    return `<span class="${cssClass}">${latency.toFixed(2)} ms</span>`;
}

function showNotification(message, type = 'info') {
    const toast = document.getElementById('notification-toast');
    const toastTitle = document.getElementById('toast-title');
    const toastMessage = document.getElementById('toast-message');

    // Determinar título y color basado en tipo
    const titleMap = {
        'success': '✅ Éxito',
        'danger': '❌ Error',
        'warning': '⚠️ Advertencia',
        'info': 'ℹ️ Información'
    };

    toastTitle.textContent = titleMap[type] || 'Notificación';
    toastMessage.textContent = message;
    toast.classList.remove('bg-success', 'bg-danger', 'bg-warning', 'bg-info');
    toast.classList.add(`bg-${type}`);

    const bsToast = new bootstrap.Toast(toast);
    bsToast.show();
}

// Log de inicio
console.log('🖥️ Network Monitor Dashboard v1.0 - VMWARE-101001');
console.log('📊 Red monitorizada: 2025:db8:101::/64');
console.log('🔍 Interfaz: ens192');
