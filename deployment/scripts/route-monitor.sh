#!/bin/bash

# 📊 Continuous Route Monitoring Script
# =====================================
# This script continuously monitors route health and fixes issues automatically

set -euo pipefail

# Configuration
NAMESPACE="${NAMESPACE:-cn-docs}"
APP_NAME="${APP_NAME:-cn-docs}"
CHECK_INTERVAL="${CHECK_INTERVAL:-300}"  # 5 minutes
LOG_FILE="${LOG_FILE:-/tmp/route-monitor.log}"
ALERT_EMAIL="${ALERT_EMAIL:-}"
SLACK_WEBHOOK="${SLACK_WEBHOOK:-}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_with_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

log_info() {
    log_with_timestamp "[INFO] $1"
}

log_success() {
    log_with_timestamp "[SUCCESS] $1"
}

log_warning() {
    log_with_timestamp "[WARNING] $1"
}

log_error() {
    log_with_timestamp "[ERROR] $1"
}

# Function to send alert
send_alert() {
    local message="$1"
    local severity="${2:-WARNING}"
    
    log_info "Sending alert: $message"
    
    # Email alert
    if [[ -n "$ALERT_EMAIL" ]]; then
        echo "Route Alert [$severity]: $message" | mail -s "CN-Docs Route Alert" "$ALERT_EMAIL" 2>/dev/null || true
    fi
    
    # Slack alert
    if [[ -n "$SLACK_WEBHOOK" ]]; then
        curl -X POST -H 'Content-type: application/json' \
            --data "{\"text\":\"🚨 CN-Docs Route Alert [$severity]: $message\"}" \
            "$SLACK_WEBHOOK" 2>/dev/null || true
    fi
}

# Function to run health check
run_health_check() {
    local script_dir="$(dirname "$0")"
    local health_script="$script_dir/route-health-check.sh"
    
    if [[ ! -f "$health_script" ]]; then
        log_error "Health check script not found: $health_script"
        return 1
    fi
    
    # Set environment variables
    export NAMESPACE="$NAMESPACE"
    export APP_NAME="$APP_NAME"
    export SERVICE_NAME="$APP_NAME"
    export ROUTE_HOSTNAME="cn-docs-cn-docs.apps.ocp-5.datsci.softergee.si"
    
    # Run health check and capture output
    local check_output
    if check_output=$("$health_script" check 2>&1); then
        log_success "Health check passed"
        return 0
    else
        log_error "Health check failed: $check_output"
        return 1
    fi
}

# Function to check OpenShift connectivity
check_oc_connectivity() {
    if ! oc whoami >/dev/null 2>&1; then
        log_error "Lost connection to OpenShift cluster"
        return 1
    fi
    return 0
}

# Main monitoring loop
main() {
    log_info "🔍 Starting continuous route monitoring for $APP_NAME"
    log_info "Check interval: ${CHECK_INTERVAL}s"
    log_info "Log file: $LOG_FILE"
    
    local consecutive_failures=0
    local max_consecutive_failures=3
    
    while true; do
        log_info "Running health check..."
        
        # Check OpenShift connectivity first
        if ! check_oc_connectivity; then
            log_error "OpenShift connectivity lost, waiting for reconnection..."
            consecutive_failures=$((consecutive_failures + 1))
            
            if [[ $consecutive_failures -ge $max_consecutive_failures ]]; then
                send_alert "Lost connection to OpenShift cluster for $((consecutive_failures * CHECK_INTERVAL / 60)) minutes" "CRITICAL"
            fi
            
            sleep "$CHECK_INTERVAL"
            continue
        fi
        
        # Run health check
        if run_health_check; then
            if [[ $consecutive_failures -gt 0 ]]; then
                log_success "Route recovered after $consecutive_failures failures"
                send_alert "Route health restored after $((consecutive_failures * CHECK_INTERVAL / 60)) minutes" "INFO"
            fi
            consecutive_failures=0
        else
            consecutive_failures=$((consecutive_failures + 1))
            log_warning "Health check failed (attempt $consecutive_failures/$max_consecutive_failures)"
            
            if [[ $consecutive_failures -eq 1 ]]; then
                send_alert "Route health check started failing" "WARNING"
            elif [[ $consecutive_failures -ge $max_consecutive_failures ]]; then
                send_alert "Route has been unhealthy for $((consecutive_failures * CHECK_INTERVAL / 60)) minutes" "CRITICAL"
            fi
        fi
        
        log_info "Waiting ${CHECK_INTERVAL}s until next check..."
        sleep "$CHECK_INTERVAL"
    done
}

# Handle script termination
cleanup() {
    log_info "Monitoring stopped"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Parse command line arguments
case "${1:-monitor}" in
    "monitor")
        main
        ;;
    "once")
        run_health_check
        ;;
    "test-alert")
        send_alert "Test alert from route monitor" "INFO"
        ;;
    "help")
        echo "Usage: $0 [monitor|once|test-alert|help]"
        echo "  monitor    - Start continuous monitoring (default)"
        echo "  once       - Run health check once"
        echo "  test-alert - Send test alert"
        echo "  help       - Show this help"
        echo ""
        echo "Environment variables:"
        echo "  NAMESPACE      - OpenShift namespace (default: cn-docs)"
        echo "  APP_NAME       - Application name (default: cn-docs)"
        echo "  CHECK_INTERVAL - Check interval in seconds (default: 300)"
        echo "  LOG_FILE       - Log file path (default: /tmp/route-monitor.log)"
        echo "  ALERT_EMAIL    - Email for alerts (optional)"
        echo "  SLACK_WEBHOOK  - Slack webhook URL for alerts (optional)"
        ;;
    *)
        echo "Invalid argument: $1"
        echo "Usage: $0 [monitor|once|test-alert|help]"
        exit 1
        ;;
esac
